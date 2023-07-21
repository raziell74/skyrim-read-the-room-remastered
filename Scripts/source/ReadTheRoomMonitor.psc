ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

; ReadTheRoomMonitor
; Monitors the player's location, combat state, and keybind inputs
; Contains main logic for manaing the players head gear specifically

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE

Import ReadTheRoomUtil ; Our helper Functions

; Player reference and script application perk
Actor property PlayerRef auto
Perk property ReadTheRoomPerk auto

; KeyBindings
GlobalVariable property ToggleKey auto
GlobalVariable property DeleteKey auto
GlobalVariable property EnableKey auto

; Equip Scenario Settings
GlobalVariable property CombatEquip auto
GlobalVariable property CombatEquipAnimation auto
GlobalVariable property EquipWhenSafe auto
GlobalVariable property UnequipWhenUnsafe auto
GlobalVariable property RemoveHelmetWithoutArmor auto

; Management Settings
GlobalVariable property ManageCirclets auto

; Location Identification Settings
FormList property SafeKeywords auto
FormList property HostileKeywords auto

; Lowerable Hood Configuration
FormList property LowerableHoods auto
FormList property LoweredHoods auto

; IED Hip/Hand Anchors
FormList property MaleHandAnchor auto
FormList property MaleHipAnchor auto
FormList property FemaleHandAnchor auto
FormList property FemaleHipAnchor auto

; IED Constants
String PluginName = "ReadTheRoom.esp"
String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String HipNode = "NPC Pelvis [Pelv]"
String HandNode = "NPC R Hand [RHnd]"
Bool InventoryRequired = true
Float HipScale = 0.9150
Float HandScale = 1.05

; Local Script Variables
Bool IsFemale = false
Form LastEquipped = None
Form LastLoweredHood = None
String LastEquippedType = "None"
Float AnimTimeoutBuffer = 0.05
String MostRecentLocationAction = "None"
String PreviousLocationAction = "None"
String RecentAction = "None"

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())

	SetupRTR()
EndEvent

Event OnPlayerLoadGame()
	SetupRTR()
EndEvent

Function SetupRTR()
	RTR_PrintDebug(" ")
    RTR_PrintDebug("[RTR-Player] Refreshing RTR --------------------------------------------------------------------")

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped, LowerableHoods)
	IsFemale = PlayerRef.GetActorBase().GetSex() == 1

	; Attach helm to the hip
	Bool HipEnabled = (!PlayerRef.IsEquipped(LastEquipped) && LastEquippedType != "Hood") || RecentAction == "Unequip"
	Float[] hip_position = RTR_GetPosition(LastEquippedType, HipAnchor())
	Float[] hip_rotation = RTR_GetRotation(LastEquippedType, HipAnchor())

	; Create the Hip Placement
	CreateItemActor(PlayerRef, PluginName, HelmetOnHip, InventoryRequired, LastEquipped, IsFemale, HipNode)
	SetItemPositionActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, hip_position)
	SetItemRotationActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, hip_rotation)
	SetItemFormActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
	SetItemNodeActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, HipNode)
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, HipEnabled)
	SetItemScaleActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, HipScale)

	RTR_PrintDebug("-- Attached Hip Item to " + PlayerRef.GetActorBase().GetName())

	; Attach Helm to hand - setup as disabled since the enabled flag is switched during animation
	Float[] hand_position = RTR_GetPosition(LastEquippedType, HandAnchor())
	Float[] hand_rotation = RTR_GetRotation(LastEquippedType, HandAnchor())
	
	; Create the Hand Placement
	CreateItemActor(PlayerRef, PluginName, HelmetOnHand, InventoryRequired, LastEquipped, IsFemale, HandNode)
	SetItemPositionActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, hand_position)
	SetItemRotationActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, hand_rotation)
	SetItemFormActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)
	SetItemNodeActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, HandNode)
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, false)
	if LastEquippedType == "Helmet"
		SetItemScaleActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, HandScale)
	endif

	RTR_PrintDebug("-- Attached Disabled Hand Item to " + PlayerRef.GetActorBase().GetName())

	; Register for animation events
	; Events are annotations set to trigger at specific times during the hkx animations
	RegisterForAnimationEvent(PlayerRef, "RTR_SetTimeout")
	RegisterForAnimationEvent(PlayerRef, "RTR_Equip")
	RegisterForAnimationEvent(PlayerRef, "RTR_Unequip")
	RegisterForAnimationEvent(PlayerRef, "RTR_AttachToHip")
	RegisterForAnimationEvent(PlayerRef, "RTR_RemoveFromHip")
	RegisterForAnimationEvent(PlayerRef, "RTR_AttachLoweredHood")
	RegisterForAnimationEvent(PlayerRef, "RTR_RemoveLoweredHood")
	RegisterForAnimationEvent(PlayerRef, "RTR_OffsetStop")

	; Listen for Actor Combat State Changes
	RegisterForModEvent("ReadTheRoomCombatStateChanged", "OnReadTheRoomCombatStateChanged")

	RTR_PrintDebug("-------------------------------------------------------------------- [RTR-Player] OnPlayerLoadGame Completed for PlayerRef")
	RTR_PrintDebug(" ")

	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")

	; Send Mod Event to correctly adjust followers when game is loaded
	Utility.wait(0.1)
	if RecentAction == "Equip"
		SendModEvent("ReadTheRoomEquipNoAnimation")
	elseif RecentAction == "Unequip"
		SendModEvent("ReadTheRoomUnequipNoAnimation")
	endif
EndFunction

; OnKeyDown Event Handler
; Processes Key Events for configured keybindings
;
; EnableKey: Read the Room enable/disable
; ToggleKey: Toggle Headgear
; DeleteKey: Force Clear Attachment Nodes
Event OnKeyDown(Int KeyCode)
	; Prevent keypresses from being registered if in menu or text-input mode
	if Utility.IsInMenuMode() || ui.IsTextInputEnabled()
		return
	endif

	; Toggle Read the Room on/off
	if KeyCode == EnableKey.GetValueInt()
		RTR_PrintDebug(" ")
		if PlayerRef.hasperk(ReadTheRoomPerk)
			RTR_PrintDebug("[RTR-Player] Toggled Off --------------------------------------------------------------------")
			PlayerRef.removeperk(ReadTheRoomPerk)
			RemoveFromHip()
			RemoveFromHand()
			LastEquipped = None
			LastLoweredHood = None
			LastEquippedType = "None"
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
			GoToState("busy")
		else
			RTR_PrintDebug("[RTR-Player] Toggled On --------------------------------------------------------------------")
			PlayerRef.addperk(ReadTheRoomPerk)
			SetupRTR()
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
			GoToState("")
		endif
		RTR_PrintDebug(" ")
	endif

	; Manually Toggle Head Gear
	if KeyCode == ToggleKey.GetValueInt()
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR-Player] Toggle Head Gear --------------------------------------------------------------------")
		LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		if RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
			UnequipActorHeadgear()
		else
			LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
			EquipActorHeadgear()
		endif
		RTR_PrintDebug(" ")
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR-Player] Clearing ReadTheRoom placements --------------------------------------------------------------------")
		RemoveFromHip()
		RemoveFromHand()
		LastEquipped = None
		LastLoweredHood = None
		LastEquippedType = "None"
		GoToState("")
		RTR_PrintDebug(" ")
	endif
EndEvent

; OnLocationChange Event Handler
; Updates locational triggers/actions
;
; Records Most Recent Location Action
; Equips/Unequips based off of Config Settings
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR-Player] OnLocationChange --------------------------------------------------------------------")

	LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1

	RTR_PrintDebug("-- RTR EquipWhenSafe global var value: " + EquipWhenSafe.getValueInt())
	RTR_PrintDebug("-- RTR UnequipWhenUnsafe global var value: " + EquipWhenSafe.getValueInt())

	; Update the MostRecentLocationAction reference for other processes
	String locationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)

	if locationAction == "Entering Safety" || locationAction == "Leaving Danger" 	
		MostRecentLocationAction = "Unequip"
	elseif locationAction == "Entering Danger" || locationAction == "Leaving Safety"
		MostRecentLocationAction = "Equip"
	else
		MostRecentLocationAction = "None"
	endif

	RTR_PrintDebug("-- RTR MostRecentLocationAction set to: " + MostRecentLocationAction)
	
	; Only apply the action if we didn't already do it, prevents ToggleKey from being overwritten unless changing location action
	if MostRecentLocationAction != PreviousLocationAction 
		Debug.Notification("ReadTheRoom: " + locationAction)

		if MostRecentLocationAction == "Equip"
			LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
			EquipActorHeadgear()
		elseif MostRecentLocationAction == "Unequip"
			UnequipActorHeadgear()		
		endif
	endif

	; Record the previous location action so we don't fire the same action over and over again
	PreviousLocationAction = MostRecentLocationAction
	SendModEvent("ReadTheRoomLocationChange")
	RTR_PrintDebug(" ")
EndEvent

; OnReadTheRoomCombatStateChanged Event Handler
; Toggles Headgear based off Players Combat State
; @todo Test to see if this triggers on any actor, don't think it does but worth checking
Event OnReadTheRoomCombatStateChanged(String eventName, String strArg, Float numArg, Form sender)
	; Ignore the event if if CombatEquip is disabled
	if CombatEquip.GetValueInt() == 0
		return
	endif

	Int aeCombatState = numArg as Int
	MiscUtil.PrintConsole("[RTR-Player] " + strArg + " Combat State Changed to " + aeCombatState + " -- PlayerRef.IsInCombat " + PlayerRef.IsInCombat() + " -- PlayerRef.IsEquipped(LastEquipped) " + PlayerRef.IsEquipped(LastEquipped) + " RecentAction " + RecentAction)
	if aeCombatState == 1 && PlayerRef.IsInCombat() && !PlayerRef.IsEquipped(LastEquipped)
		; An NPC has reported they are in combat with the player and the player is not wearing the item
		Debug.Notification("ReadTheRoom: Combat Equip!")
		EquipActorHeadgear(true)
	elseif aeCombatState == 0 && !PlayerRef.IsInCombat() && PlayerRef.IsEquipped(LastEquipped)
		; Player left combat
		; Return to the most recent action
		if RecentAction == "Unequip"
			UnequipActorHeadgear()
		endif
	endIf

	if aeCombatState == 2
		; Someone is looking for the player
		; @todo Implement this as a new feature with its own MCM option that will mark "searching" to be the same as entering combat 
	endif
EndEvent

; OnAnimationEvent Event Handler
; Where the MAGIC happens, processes animation events triggered from 
; ReadTheRoom Annotations in the hkx animation files
Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR-Player] Animation Event: " + asEventName + " --------------------------------------------------------------------")

	String anim_action = RTR_GetActionString(PlayerRef.GetAnimationVariableInt("RTR_Action"))

	; Equip Headgear
	if asEventName == "RTR_Equip"
		RemoveFromHand()
		PlayerRef.EquipItem(LastEquipped, false, true)
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Equipped")
		SendModEvent("ReadTheRoomEquip")
		return
	endif

	; Unequip Headgear
	if asEventName == "RTR_Unequip"
		if (anim_action != "EquipHood" && anim_action != "UnequipHood")  
			AttachToHand()
		endif
		PlayerRef.UnequipItem(LastEquipped, false, true)
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Unequipped")
		SendModEvent("ReadTheRoomUnequip")
		return
	endif

	; Attach to Hip
	if asEventName == "RTR_AttachToHip"
		RemoveFromHand()
		AttachToHip()
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Attached to Hip node")
		return
	endif

	; Remove from Hip
	if asEventName == "RTR_RemoveFromHip"
		RemoveFromHip()
		AttachToHand()
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Removed from Hip node")
		return
	endif

	; Attach Lowered Hood
	if asEventName == "RTR_AttachLoweredHood"
		PlayerRef.EquipItem(LastLoweredHood, false, true)
		RTR_PrintDebug("- Equipped Lowered Hood: " + (LastLoweredHood as Armor).GetName())
		return
	endif

	; Remove Lowered Hood
	if asEventName == "RTR_RemoveLoweredHood"
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		RTR_PrintDebug("- Removed Lowered Hood: " + (LastLoweredHood as Armor).GetName())
		return
	endif

	; Stop Offset
	if asEventName == "RTR_OffsetStop"
		RemoveFromHand()
		Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		RTR_PrintDebug("- Animation Finished. OffsetStop Animation Event Sent")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Float timeout = PlayerRef.GetAnimationVariableFloat("RTR_Timeout")
		RTR_PrintDebug("- Animation Ends in " + (timeout + AnimTimeoutBuffer) + " seconds")

		; Disable certain controls for the player during the animation
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)

		Utility.wait(timeout + AnimTimeoutBuffer)
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR-Player] OnAnimationEvent: Timeout Finished --------------------------------------------------------------------")

		; Wait for player inventory to complete the equipping / unequipping actions
		Bool finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
		while !finishedEquipUnequip
			RTR_PrintDebug("- Waiting for Equip / Unequip to finish")
			Utility.wait(0.1)
			finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
		endwhile

		; Post Animation Clean Up
		PostAnimCleanUp()
	endif
EndEvent

; OnObjectEquipped Event Handler
; Cheks if the actor equipped head gear outside of RTR and removes any placements / lowered hoods
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR-Player] OnObjectEquipped --------------------------------------------------------------------")

	; Check if a head wear item was equipped
	String type = RTR_InferItemType(akBaseObject, LowerableHoods)
	RTR_PrintDebug("- ItemType = " + type)
	if type != "None"
		RTR_PrintDebug("- Actor equipped head gear outside of RTR, Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip()
		RemoveFromHand()
		
		; Remove lowered hood
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		SendModEvent("ReadTheRoomEquipNoAnimation")
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnObjectUnequipped Event Handler
; Checks if the actor removed their torso armor and removes any placements / lowered hoods if RemoveHelmetWithoutArmor is enabled
; Also checkes if the actor removed their head gear outside of RTR and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR-Player] OnObjectUnequipped --------------------------------------------------------------------")
	
	; Check if it was armor that was removed
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(PlayerRef))
		RTR_PrintDebug("- Actor is not wearing anything on their torso and RemoveHelmetWithoutArmor is enabled. Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip()
		RemoveFromHand()

		; Remove lowered hood from player
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
	endif

	; Check if it was a helmet, circlet, or hood that was removed
	String type = RTR_InferItemType(akBaseObject, LowerableHoods)
	if type != "None"
		RTR_PrintDebug("- Actor intentionally unequipped a helmet or hood outside of RTR, Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip()
		RemoveFromHand()
		
		; remove any lowered hoods from actor
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		SendModEvent("ReadTheRoomUnequipNoAnimation")
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnMenuClose Event Handler
; Checks if the actor closed their inventory and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnMenuClose(String MenuName)
	if MenuName == "InventoryMenu"
		LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
		if PlayerRef.IsEquipped(LastEquipped)
			RemoveFromHip()
		else
			; purposefully unequipped a helmet
			; @todo implement an MCM setting to change what happens when items are unequipped from the inventory
			; 		- default: 0
			;       - 0: Do Nothing
			;	    - 1: Attach to Belt / Lower Hood
			; UnequipWithNoAnimation()
		endif
	endif

	; Regardless, the item should be removed from the hand
	RemoveFromHand()
EndEvent

; OnRaceSwitchComplete Event Handler
; Resets RTR
Event OnRaceSwitchComplete()
	SetupRTR()
EndEvent

;;;; Action Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
Function EquipActorHeadgear(Bool IsCombatEquip = false)
	RTR_PrintDebug(" ")
	MiscUtil.PrintConsole("[RTR-Player] EquipActorHeadgear --------------------------------------------------------------------")

	if PlayerRef.HasKeywordString("ActorTypeCreature")
		MiscUtil.PrintConsole("- Exiting because actor is a creature")
		return
	endif

	; Update the IED Node with the last_equipped item
	UseHelmet()

	; Exit early if the actor is already wearing the item
	if PlayerRef.IsEquipped(LastEquipped)
		MiscUtil.PrintConsole("- Exiting because item " + (LastEquipped as Armor).GetName() + " is already equipped")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Combat State Unequip
	if PlayerRef.IsInCombat()
		MiscUtil.PrintConsole("- Player is in combat")
		if CombatEquip.GetValueInt() == 0
			MiscUtil.PrintConsole("- Existing because CombatEquip is disabled")
			return
		endif

		MiscUtil.PrintConsole("- CombatEquip is enabled")

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquipAnimation is disabled. Equipping with no animation")
			EquipWithNoAnimation(true, IsCombatEquip)
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if PlayerRef.GetSitState() || \
		PlayerRef.IsSwimming() || \
		PlayerRef.GetAnimationVariableInt("bInJumpState") == 1 || \
		PlayerRef.GetAnimationVariableInt("IsEquipping") == 1 || \
		PlayerRef.GetAnimationVariableInt("IsUnequipping") == 1
		
		RTR_PrintDebug("- Actor can't be animated. Unequipping with no animation")
		; Force equip with no animation
		EquipWithNoAnimation()
		return
	endif

	; Animated Equip
	String animation = "RTREquip"
	Float animation_time = 3.33

	; Switch animation if equipping a lowerable hood
	if LastEquippedType == "Hood"
		animation = "RTREquipHood"
		animation_time = 1.2
		RTR_PrintDebug("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(PlayerRef)
	Bool was_first_person = RTR_ForceThirdPerson(PlayerRef)

	RTR_PrintDebug("- Setting player RTR_RedrawWeapons to " + was_drawn)
	PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
	RTR_PrintDebug("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
	PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)
	
	RTR_PrintDebug("- Triggering " + animation + " animation")
	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, animation)
	
	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	PostAnimCleanUp()
	if !IsCombatEquip
		RecentAction = "Equip"
	endif
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
Function EquipWithNoAnimation(Bool sendFollowerEvent = true, Bool IsCombatEquip = false)
	if PlayerRef.HasKeywordString("ActorTypeCreature")
		MiscUtil.PrintConsole("- Exiting EquipWithNoAnimation because actor is a creature")
		return
	endif

	; Make sure our last equipped item is up to date
	LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)

	; Update the IED Node with the last_equipped item
	UseHelmet()

	if LastEquippedType == "Hood"
		MiscUtil.PrintConsole("- Equipping Lowered Hood: " + (LastLoweredHood as Armor).GetName())
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.EquipItem(LastEquipped, false, true)
	else
		MiscUtil.PrintConsole("- Equipping: " + (LastEquipped as Armor).GetName())
		PlayerRef.EquipItem(LastEquipped, false, true)
		RemoveFromHip()
		RemoveFromHand()
	endif

	if sendFollowerEvent
		SendModEvent("ReadTheRoomEquipNoAnimation")
	endif

	if !IsCombatEquip
		RecentAction = "Equip"
	endif
EndFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
Function UnequipActorHeadgear()
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR-Player] UnequipActorHeadgear --------------------------------------------------------------------")

	if PlayerRef.HasKeywordString("ActorTypeCreature")
		RTR_PrintDebug("- Exiting because actor is a creature")
		return
	endif
	
	; Update the IED Node with the equipped item
	UseHelmet()

	; Exit early if the actor is not wearing the item
	if !PlayerRef.IsEquipped(LastEquipped)
		RTR_PrintDebug("- Exiting because item " + (LastEquipped as Armor).GetName() + " is not equipped")
		RemoveFromHand()
		return
	endif

	; Combat State Unequip
	if PlayerRef.GetCombatState() == 1
		MiscUtil.PrintConsole("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			RTR_PrintDebug("- CombatEquip is disabled")
			return
		endif

		MiscUtil.PrintConsole("- CombatEquip is enabled")

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquipAnimation is disabled. Unequipping with no animation")
			UnequipWithNoAnimation()
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if PlayerRef.GetSitState() || \
		PlayerRef.IsSwimming() || \
		PlayerRef.GetAnimationVariableInt("bInJumpState") == 1 || \
		PlayerRef.GetAnimationVariableInt("IsEquipping") == 1 || \
		PlayerRef.GetAnimationVariableInt("IsUnequipping") == 1
		
		RTR_PrintDebug("- Actor can't be animated. Unequipping with no animation")
		; Force unequip with no animation
		UnequipWithNoAnimation()
		return
	endif

	; Animated Unequip
	String animation = "RTRUnequip"
	Float animation_time = 3.33

	; Switch animation if equipping a lowerable hood
	if LastEquippedType == "Hood"
		animation = "RTRUnequipHood"
		animation_time = 1.2
		RTR_PrintDebug("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(PlayerRef)
	Bool was_first_person = RTR_ForceThirdPerson(PlayerRef)

	RTR_PrintDebug("- Setting player RTR_RedrawWeapons to " + was_drawn)
	PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
	RTR_PrintDebug("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
	PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)

	RTR_PrintDebug("- Triggering " + animation + " animation")
	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, animation)

	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	PostAnimCleanUp()
	RecentAction = "Unequip"
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
Function UnequipWithNoAnimation(Bool sendFollowerEvent = true)
	if PlayerRef.HasKeywordString("ActorTypeCreature")
		RTR_PrintDebug("- Exiting because actor is a creature")
		return
	endif
	
	; Update the IED Node with the equipped item
	UseHelmet()

	if LastEquippedType == "Hood"
		PlayerRef.UnequipItem(LastEquipped, false, true)
		PlayerRef.EquipItem(LastLoweredHood, false, true)
	else
		RemoveFromHand()
		AttachToHip()
		PlayerRef.UnequipItem(LastEquipped, false, true)
	endif

	if sendFollowerEvent
		SendModEvent("ReadTheRoomUnequipNoAnimation")
	endif
	RecentAction = "Unequip"
EndFunction

;;;; Busy State - Blocked Actions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
State busy
	Event OnKeyDown(Int KeyCode)
		RTR_PrintDebug("xXx [RTR-Busy] OnKeyDown xXx")

		; Continue to allow full mod enable/disable, also resets the state
		if KeyCode == EnableKey.GetValueInt()
			RTR_PrintDebug(" ")
			if PlayerRef.hasperk(ReadTheRoomPerk)
				RTR_PrintDebug("[RTR-Player] Toggled Off --------------------------------------------------------------------")
				PlayerRef.removeperk(ReadTheRoomPerk)
				RemoveFromHip()
				RemoveFromHand()
				LastEquipped = None
				LastLoweredHood = None
				LastEquippedType = "None"
				Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
				GoToState("busy")
			else
				RTR_PrintDebug("[RTR-Player] Toggled On --------------------------------------------------------------------")
				PlayerRef.addperk(ReadTheRoomPerk)
				SetupRTR()
				Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
				GoToState("")
			endif
			RTR_PrintDebug(" ")
		endif

		; Continue to allow forced placement clearing, also resets the state
		if KeyCode == DeleteKey.GetValueInt()
			RTR_PrintDebug(" ")
			RTR_PrintDebug("[RTR-Player] Clearing ReadTheRoom placements --------------------------------------------------------------------")
			RemoveFromHip()
			RemoveFromHand()
			LastEquipped = None
			LastLoweredHood = None
			LastEquippedType = "None"
			GoToState("")
			RTR_PrintDebug(" ")
		endif
	EndEvent

	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		RTR_PrintDebug("xXx [RTR-Busy] OnLocationChange xXx")
		
		; Update the MostRecentLocationAction reference even in Busy State
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
		Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
		Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
		String locationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
		if locationAction == "Entering Safety" || locationAction == "Leaving Danger" 	
			MostRecentLocationAction = "Unequip"
		elseif locationAction == "Entering Danger" || locationAction == "Leaving Safety"
			MostRecentLocationAction = "Equip"
		else
			MostRecentLocationAction = "None"
		endif
	EndEvent

	Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
		RTR_PrintDebug("xXx [RTR-Busy] OnCombatStateChanged xXx")
	EndEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		RTR_PrintDebug("xXx [RTR-Busy] OnObjectEquipped xXx")
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		RTR_PrintDebug("xXx [RTR-Busy] OnObjectUnequipped xXx")
	EndEvent

	Event OnMenuClose(String MenuName)
		RTR_PrintDebug("xXx [RTR-Busy] OnMenuClose xXx")
	EndEvent

	Function EquipActorHeadgear(Bool IsCombatEquip = false)
		RTR_PrintDebug("xXx [RTR-Busy] EquipActorHeadgear xXx")
	EndFunction

	Function EquipWithNoAnimation(Bool sendFollowerEvent = true, Bool IsCombatEquip = false)
		RTR_PrintDebug("xXx [RTR-Busy] EquipWithNoAnimation xXx")
	EndFunction

	Function UnequipActorHeadgear()
		RTR_PrintDebug("xXx [RTR-Busy] UnequipActorHeadgear xXx")
	EndFunction

	Function UnequipWithNoAnimation(Bool sendFollowerEvent = true)
		RTR_PrintDebug("xXx [RTR-Busy] UnequipWithNoAnimation xXx")
	EndFunction
EndState

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Local Script Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PostAnimCleanUp
; Performs the post-animation cleanup actions
Function PostAnimCleanUp()
	; Post Animation Actions
	String animAction = RTR_GetActionString(PlayerRef.GetAnimationVariableInt("RTR_Action"))

	RTR_PrintDebug("- CLEANUP - Enabling Player Controls")
	Game.EnablePlayerControls()

	; Check if the animation completed successfully or if it was interuppted
	if animAction == "None"
		RTR_PrintDebug("- RTR Action completed successfully")
	elseif animAction == "Equip" || animAction == "EquipHood"
		RTR_PrintDebug("- Timed Out on Equip")
		; Finalize Equip
		EquipWithNoAnimation(false)
		Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	elseif animAction == "Unequip" || animAction == "UnequipHood"
		RTR_PrintDebug("- Timed Out on Unequip")
		; Finalize Unequip
		UnequipWithNoAnimation(false)
		Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	endif
	
	; Ensure the hand node is disabled before continuing
	RemoveFromHand()

	; Return to previous weapon and first person states, if animation wasn't interuppted
	Bool draw_weapon = PlayerRef.GetAnimationVariableBool("RTR_RedrawWeapons")
	Bool return_to_first_person = PlayerRef.GetAnimationVariableBool("RTR_ReturnToFirstPerson")

	if draw_weapon && animAction == "None"
		RTR_PrintDebug("- CLEANUP - Drawing Weapon")
		PlayerRef.DrawWeapon()
		PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", false)
	endif

	if return_to_first_person && animAction == "None"
		RTR_PrintDebug("- CLEANUP - Returning to First Person")
		Game.ForceFirstPerson()
		PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", false)
	endif

	; Clear RTR_Action and return from busy state
	RTR_PrintDebug("- CLEANUP - Clearing RTR_Action and Returning from busy state")
	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")
EndFunction

; Enables IED Hip Placement
Function AttachToHip()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, true)
EndFunction

; Disables IED Hip Placement
Function RemoveFromHip()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, false)
	PlayerRef.UnequipItem(LastLoweredHood, false, true)
	PlayerRef.RemoveItem(LastLoweredHood, 1, true)
EndFunction

; Enables IED Hand Placement
Function AttachToHand()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, true)
EndFunction

; Disables IED Hand Placement
Function RemoveFromHand()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, false)
EndFunction

; UseHelmet
; Sets an Armor Form as the IED placement display forms
Function UseHelmet()
	; Update IED Placements to use LastEquipped Helmet Form
	SetItemFormActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
	SetItemFormActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)

	; Conditional Placement Scaling / Lowered Hood Update
	LastEquippedType = RTR_InferItemType(LastEquipped, LowerableHoods)
	if LastEquippedType == "Hood"
		LastLoweredHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquipped))
	elseif LastEquippedType == "Helmet"
		SetItemScaleActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, HandScale)
	else 
		SetItemScaleActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, 1)
	endif
EndFunction

; HipAnchor
; Returns the correct Hip Anchor position for the actor's gender
;
; @return FormList
Form[] Function HipAnchor()
	if IsFemale 
		return FemaleHipAnchor.ToArray()
	endif
	return MaleHipAnchor.ToArray()
EndFunction

; HandAnchor
; Returns the correct Hand Anchor position for the actor's gender
;
; @return FormList
Form[] Function HandAnchor()
	if IsFemale 
		return FemaleHandAnchor.ToArray()
	endif
	return MaleHandAnchor.ToArray()
EndFunction
