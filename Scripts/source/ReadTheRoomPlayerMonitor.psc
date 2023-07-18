ScriptName ReadTheRoomPlayerMonitor extends ActiveMagicEffect

; ReadTheRoomPlayerMonitor
; Monitors the player's location, combat state, and keybind inputs
; Contains main logic for manaing the players head gear specifically

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE
Import PO3_Events_Alias ; powerofthree's Papyrus Extender

Import ReadTheRoomUtil ; Our helper functions

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
FormList property LastEquippedMonitor auto

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
endEvent

; @TODO - Move duplicated code for IED node placements to a helper function
;         test if it will work properly if called from ReadTheRoomUtil
function SetupRTR()
	RTR_PrintDebug(" ")
    RTR_PrintDebug("[RTR] OnPlayerLoadGame --------------------------------------------------------------------")
	RTR_PrintDebug("[RTR] Refreshing IED Attachments for PlayerRef")

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(PlayerRef)
	LastEquippedType = RTR_InferItemType(LastEquipped, LowerableHoods)
	IsFemale = PlayerRef.GetActorBase().GetSex() == 1

	; Attach helm to the hip
	Bool HipEnabled = (!PlayerRef.IsEquipped(LastEquipped) && LastEquippedType != "Hood")
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

	RTR_PrintDebug("[RTR] DEBUG: Attached Hip Item to " + (PlayerRef as Form).GetName())

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

	RTR_PrintDebug("[RTR] DEBUG: Attached Disabled Hand Item to " + (PlayerRef as Form).GetName())

	; Register for animation events
	; Events are annotations set to trigger at specific times during the hkx animations
	RegisterForAnimationEvent(PlayerRef, "RTR_SetTimeout")

	RegisterForAnimationEvent(PlayerRef, "RTR_Equip")
	RegisterForAnimationEvent(PlayerRef, "RTR_Unequip")

	; @NOTE Hand attachments were removed as invidivual events since they seem to run smoother if attached to the other events
	;       Leaving them commented out here in case they are needed in the future
	; RegisterForAnimationEvent(PlayerRef, "RTR_AttachToHand")
	; RegisterForAnimationEvent(PlayerRef, "RTR_RemoveFromHand")

	RegisterForAnimationEvent(PlayerRef, "RTR_AttachToHip")
	RegisterForAnimationEvent(PlayerRef, "RTR_RemoveFromHip")

	RegisterForAnimationEvent(PlayerRef, "RTR_AttachLoweredHood")
	RegisterForAnimationEvent(PlayerRef, "RTR_RemoveLoweredHood")

	RegisterForAnimationEvent(PlayerRef, "RTR_OffsetStop")

	RTR_PrintDebug("-------------------------------------------------------------------- [RTR] OnPlayerLoadGame Completed for PlayerRef")
	RTR_PrintDebug(" ")

	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")
endfunction

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
			RTR_PrintDebug("[RTR] Toggled Off --------------------------------------------------------------------")
			PlayerRef.removeperk(ReadTheRoomPerk)
		else
			RTR_PrintDebug("[RTR] Toggled On --------------------------------------------------------------------")
			PlayerRef.addperk(ReadTheRoomPerk)
		endif
		RTR_PrintDebug(" ")
	endif

	; Manually Toggle Head Gear
	if KeyCode == ToggleKey.GetValueInt()
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR] Toggle Head Gear --------------------------------------------------------------------")
		LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		if RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
			UnequipActorHeadgear()
		else
			LastEquipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear()
		endif
		RTR_PrintDebug(" ")
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR] Clearing ReadTheRoom attachments --------------------------------------------------------------------")
		RemoveFromHip()
		RemoveFromHand()
		GoToState("")
		RTR_PrintDebug(" ")
	endif
EndEvent

; OnLocationChange Event Handler
; Updates locational triggers/actions
;
; Records Most Recent Location Action
; Equips/Unequips based off of Config Settings
; @todo Test to see if we need "debounce" logic for when rapidly changing Locations
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnLocationChange --------------------------------------------------------------------")
	LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
	
	; Update the MostRecentLocationAction reference for other processes
	MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	
	if MostRecentLocationAction == "Equip"
		LastEquipped = RTR_GetLastEquipped(PlayerRef)
		EquipActorHeadgear()
	elseif MostRecentLocationAction == "Unequip"
		UnequipActorHeadgear()		
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnCombatStateChanged Event Handler
; Toggles Headgear based off Players Combat State
; @todo Test to see if this triggers on any actor, don't think it does but worth checking
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnCombatStateChanged: --------------------------------------------------------------------")
	RTR_PrintDebug("[RTR] Target: " + akTarget.GetActorBase().GetName())
	RTR_PrintDebug("[RTR] Combat State: " + aeCombatState)

	if aeCombatState == 1
		; Player entered combat
		LastEquipped = RTR_GetLastEquipped(PlayerRef)
		EquipActorHeadgear()
	elseif aeCombatState == 0
		; Player left combat
		; Make sure to check the location to see if it's safe to unequip
		if MostRecentLocationAction == "Unequip"
			LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
			UnequipActorHeadgear()
		endif
	endIf

	if aeCombatState == 2
		; Someone is looking for the player
		; @todo Implement
	endif
	RTR_PrintDebug(" ")
endEvent

; OnAnimationEvent Event Handler
; Where the MAGIC happens, processes animation events triggered from 
; ReadTheRoom Annotations in the hkx animation files
Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] Animation Event: " + asEventName + " --------------------------------------------------------------------")

	; @TODO - replace all of these to be for player only
	String anim_action = GetRTRAction(PlayerRef.GetAnimationVariableInt("RTR_Action"))

	; RTR Event Handlers
	if asEventName == "RTR_Equip"
		; Equip Headgear
		RemoveFromHand()
		PlayerRef.EquipItem(LastEquipped, false, true)
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Equipped")
		return
	endif

	if asEventName == "RTR_Unequip"
		; Unequip Headgear
		if (anim_action != "EquipHood" && anim_action != "UnequipHood")  
			AttachToHand()
		endif
		PlayerRef.UnequipItem(LastEquipped, false, true)
		RTR_PrintDebug("- " + (LastEquipped as Armor).GetName() + " Unequipped")
		return
	endif

	if asEventName == "RTR_AttachToHip"
		; Attach to Hip
		RemoveFromHand()
		AttachToHip()
		return
	endif

	if asEventName == "RTR_RemoveFromHip"
		; Remove from Hip
		RemoveFromHip()
		AttachToHand()
		return
	endif

	if asEventName == "RTR_AttachLoweredHood"
		; Attach Lowered Hood
			PlayerRef.EquipItem(LastLoweredHood, false, true)
		return
	endif

	if asEventName == "RTR_RemoveLoweredHood"
		; Remove Lowered Hood
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		RTR_PrintDebug("- " + (LastLoweredHood as Armor).GetName() + " (Lowered Hood) Unequipped")
		return
	endif

	if asEventName == "RTR_OffsetStop"
		; Stop Offset
		Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		RTR_PrintDebug("- Animation Finished. OffsetStop Animation Event Sent")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Float timeout = PlayerRef.GetAnimationVariableFloat("RTR_Timeout")
		RTR_PrintDebug("- Animation Ends in " + (timeout + AnimTimeoutBuffer) + " seconds")

		; Disable certain controls for the player
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)

		Utility.wait(timeout + AnimTimeoutBuffer)
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR] OnAnimationEvent: Timeout Finished --------------------------------------------------------------------")

		; Check if the animation completed successfully or if it was interuppted
		if anim_action == "None"
			RTR_PrintDebug("- RTR Action completed successfully")
		elseif anim_action == "Equip"
			RTR_PrintDebug("- Timed Out on Equip")
			; Finalize Equip
			PlayerRef.EquipItem(LastEquipped, false, true)
			RemoveFromHand()
			RemoveFromHip()
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		elseif anim_action == "Unequip"
			RTR_PrintDebug("- Timed Out on Unequip")
			; Finalize Unequip
			PlayerRef.UnequipItem(LastEquipped, false, true)
			RemoveFromHand()
			AttachToHip()
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		elseif anim_action == "EquipHood"
			RTR_PrintDebug("- Timed Out on EquipHood")
			; Finalize EquipHood
			PlayerRef.UnequipItem(LastLoweredHood, false, true)
			PlayerRef.RemoveItem(LastLoweredHood, 1, true)
			PlayerRef.EquipItem(LastEquipped, false, true)
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		elseif anim_action == "UnequipHood"
			RTR_PrintDebug("- Timed Out on UnequipHood")
			; Finalize UnequipHood
			PlayerRef.UnequipItem(LastEquipped, false, true)
			PlayerRef.EquipItem(LastLoweredHood, false, true)
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		endif

		; Post Animation Actions
		Bool draw_weapon = PlayerRef.GetAnimationVariableBool("RTR_RedrawWeapons")
		Bool return_to_first_person = PlayerRef.GetAnimationVariableBool("RTR_ReturnToFirstPerson")
		
		RTR_PrintDebug("- CLEANUP - Enabling Player Controls")
		Game.EnablePlayerControls()

		if draw_weapon
			RTR_PrintDebug("- CLEANUP - Drawing Weapon")
			PlayerRef.DrawWeapon()
			PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", false)
		endif

		if return_to_first_person
			RTR_PrintDebug("- CLEANUP - Returning to First Person")
			Game.ForceFirstPerson()
			PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", false)
		endif

		Bool finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
		while !finishedEquipUnequip
			RTR_PrintDebug("- Waiting for Equip / Unequip to finish")
			Utility.wait(0.1)
			finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
		endwhile
		; Clear RTR_Action
		RTR_PrintDebug("- CLEANUP - Clearing RTR_Action")
		PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
		GoToState("")
	endif
EndEvent

; OnObjectEquipped Event Handler
; Cheks if the actor equipped head gear outside of RTR and removes any placements / lowered hoods
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnObjectEquipped --------------------------------------------------------------------")

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
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnObjectUnequipped Event Handler
; Checks if the actor removed their torso armor and removes any placements / lowered hoods if RemoveHelmetWithoutArmor is enabled
; Also checkes if the actor removed their head gear outside of RTR and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnObjectUnequipped --------------------------------------------------------------------")
	
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
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnMenuClose Event Handler
; Checks if the actor closed their inventory and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnMenuClose(String MenuName)
	if MenuName == "InventoryMenu"
		LastEquipped = RTR_GetLastEquipped(PlayerRef)
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
; @TODO - Update placement positioning with gender swaps
Event OnRaceSwitchComplete()
	IsFemale = PlayerRef.GetActorBase().GetSex() == 1
	RemoveFromHip()
	RemoveFromHand()
EndEvent

;;;; Action functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
; 
; @TODO - Add SendModEvent so NPCs registered to the event can trigger their own Equip
Function EquipActorHeadgear()
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] EquipActorHeadgear --------------------------------------------------------------------")

	; Update the IED Node with the last_equipped item
	UseHelmet()

	; Exit early if the actor is already wearing the item
	if PlayerRef.IsEquipped(LastEquipped)
		RTR_PrintDebug("- Exiting because item " + (LastEquipped as Armor).GetName() + " is already equipped")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Combat State Unequip
	if PlayerRef.GetCombatState() == 1
		RTR_PrintDebug("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			RTR_PrintDebug("- CombatEquip is disabled")
			return
		endif

		RTR_PrintDebug("- CombatEquip is enabled")

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			RTR_PrintDebug("- CombatEquipAnimation is disabled. Equipping with no animation")
			EquipWithNoAnimation()
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
	Game.EnablePlayerControls()
	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	GoToState("")
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
Function EquipWithNoAnimation()
	; Update the IED Node with the last_equipped item
	UseHelmet()

	if LastEquippedType == "Hood"
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.EquipItem(LastEquipped, false, true)
	else
		PlayerRef.EquipItem(LastEquipped, false, true)
		RemoveFromHip()
		RemoveFromHand()
	endif
endFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
;
; @TODO - Add SendModEvent so NPCs registered to the event can trigger their own Unequip
Function UnequipActorHeadgear()
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] UnequipActorHeadgear --------------------------------------------------------------------")

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
		RTR_PrintDebug("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			RTR_PrintDebug("- CombatEquip is disabled")
			return
		endif

		RTR_PrintDebug("- CombatEquip is enabled")

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			RTR_PrintDebug("- CombatEquipAnimation is disabled. Unequipping with no animation")
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
	Game.EnablePlayerControls()
	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	GoToState("")
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
Function UnequipWithNoAnimation()
	; Update the IED Node with the equipped item
	UseHelmet()

	if LastEquippedType == "Hood"
		PlayerRef.UnequipItem(LastEquipped, false, true)
		PlayerRef.EquipItem(LastLoweredHood, false, true)
	else
		LastEquippedType = RTR_InferItemType(LastEquipped, LowerableHoods)
		PlayerRef.UnequipItem(LastEquipped, false, true)
		RemoveFromHand()
		AttachToHip()
	endif
endFunction

;;;; Busy State - Blocked Actions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
State busy
	Event OnKeyDown(Int KeyCode)
		RTR_PrintDebug("xXx [RTR-Busy] OnKeyDown - Disabled In Busy State")

		; Continue to allow full mod enable/disable, also resets the state
		if KeyCode == EnableKey.GetValueInt()
			RTR_PrintDebug(" ")
			if PlayerRef.hasperk(ReadTheRoomPerk)
				RTR_PrintDebug("[RTR] Toggled Off --------------------------------------------------------------------")
				PlayerRef.removeperk(ReadTheRoomPerk)
			else
				RTR_PrintDebug("[RTR] Toggled On --------------------------------------------------------------------")
				PlayerRef.addperk(ReadTheRoomPerk)
			endif
			GoToState("")
			RTR_PrintDebug(" ")
		endif

		; Continue to allow forced placement clearing, also resets the state
		if KeyCode == DeleteKey.GetValueInt()
			RTR_PrintDebug(" ")
			RTR_PrintDebug("[RTR] Clearing ReadTheRoom attachments --------------------------------------------------------------------")
			RemoveFromHip()
			RemoveFromHand()
			GoToState("")
			RTR_PrintDebug(" ")
		endif
	EndEvent

	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		RTR_PrintDebug("xXx [RTR-Busy] OnLocationChange - Disabled In Busy State")
		
		; Update the MostRecentLocationAction reference even in Busy State
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
		Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
		Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
		MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	EndEvent

	Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
		RTR_PrintDebug("xXx [RTR-Busy] OnCombatStateChanged - Disabled In Busy State")
	endEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		RTR_PrintDebug("xXx [RTR-Busy] OnObjectEquipped - Disabled In Busy State")
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
		RTR_PrintDebug("xXx [RTR-Busy] OnObjectUnequipped - Disabled In Busy State")
	EndEvent

	Event OnMenuClose(String MenuName)
		RTR_PrintDebug("xXx [RTR-Busy] OnMenuClose - Disabled In Busy State")
	EndEvent

	Function EquipActorHeadgear()
		RTR_PrintDebug("xXx [RTR-Busy] EquipActorHeadgear - Disabled In Busy State")
	EndFunction

	Function EquipWithNoAnimation()
		RTR_PrintDebug("xXx [RTR-Busy] EquipWithNoAnimation - Disabled In Busy State")
	EndFunction

	Function UnequipActorHeadgear()
		RTR_PrintDebug("xXx [RTR-Busy] UnequipActorHeadgear - Disabled In Busy State")
	EndFunction

	Function UnequipWithNoAnimation()
		RTR_PrintDebug("xXx [RTR-Busy] UnequipWithNoAnimation - Disabled In Busy State")
	EndFunction
EndState

;;;; Local Script Helper Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RegisterManagedFollowers
; Registers followers for management that are close to the player
; In the current cell
; @TODO - Follower Management will be under going an overhaul, this will either be replaced or removed at that point
function UpdateManagedFollowersList()
	; if ManageFollowers.GetValueInt() == 0
	; 	return
	; endif

	; RTR_PrintDebug(" ")
	; RTR_PrintDebug("[RTR] UpdateManagedFollowersList --------------------------------------------------------------------")
	
	; ; ManagedFollowers
	; Actor[] found_followers = ScanCellNPCs(PlayerRef, 500.0, RTR_Follower)
	
	; int i = 0
	; int foundCount = found_followers.Length
	; while (i < foundCount)
	;  	Actor followerActor = found_followers[i]
	;  	if !ManagedActors.HasForm(followerActor)
	; 		ManagedActors.AddForm(followerActor)
	; 		RegisterForAnnotationEvents(followerActor)
	; 		string followerActorName = followerActor.GetActorBase().GetName()
	; 		RTR_PrintDebug("- Detected Follower: " + followerActorName)
	; 	endIf
	;  	i += 1
	; endwhile
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Local Script Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; @TODO Refactor all of these to be player specific

function AttachToHip()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, true)
endFunction

function RemoveFromHip()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, false)
	PlayerRef.UnequipItem(LastLoweredHood, false, true)
	PlayerRef.RemoveItem(LastLoweredHood, 1, true)
endFunction

function AttachToHand()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, true)
endFunction

function RemoveFromHand()
	SetItemEnabledActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, false)
endFunction

; UseHelmet
; Sets an Armor Form as the IED placement display forms
function UseHelmet()
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
endFunction

; HipAnchor
; Returns the correct Hip Anchor position for the actor's gender
;
; @return FormList
Form[] function HipAnchor()
	if IsFemale 
		return FemaleHipAnchor.ToArray()
	endif
	return MaleHipAnchor.ToArray()
endFunction

; HandAnchor
; Returns the correct Hand Anchor position for the actor's gender
;
; @return FormList
Form[] function HandAnchor()
	if IsFemale 
		return FemaleHandAnchor.ToArray()
	endif
	return MaleHandAnchor.ToArray()
endFunction

; GetRTRAction
; Returns the correct action string for the animation event based on the RTR_Action
;
; @TODO - Move to ReadTheRoomUtil
; @param int RTRAction
; @return String
String function GetRTRAction(int RTR_Action)
	String[] AnimationActionMap = new String[4]
	AnimationActionMap[0] = "None" ; None
	AnimationActionMap[1] = "Equip" ; Equip
	AnimationActionMap[2] = "Unequip" ; Unequip
	AnimationActionMap[3] = "EquipHood" ; Equip Lowerable Hood
	AnimationActionMap[4] = "UnequipHood" ; Unequip Lowerable Hood
	return AnimationActionMap[RTR_Action]
endFunction
