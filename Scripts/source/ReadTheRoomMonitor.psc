ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

; ReadTheRoomMonitor
; Monitors the player's location, combat state, and keybind inputs
; Contains main logic for manaing the players head gear specifically

Import IED ; Immersive Equipment Display
Import StringUtil ; SKSE String Utility
Import ReadTheRoomUtil ; Our helper Functions

; Uninitialized Script Version
Float Script_Version = 0.0

; Player reference and script application perk
GlobalVariable property RTR_Version auto
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
GlobalVariable property SheathWeaponsForAnimation auto

; Notification Settings
GlobalVariable property NotifyOnLocation auto
GlobalVariable property NotifyOnCombat auto

; Management Settings
GlobalVariable property RTR_EquipState auto
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
Bool IsPlayerSetup = false
Bool WasInCombat = false

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
	SetupRTR()
	Script_Version = RTR_GetVersion()
	RTR_Version.SetValue(Script_Version) ; Updates the MCM with the current version
	Debug.Notification("Read The Room - Version " + Substring(RTR_Version as String, 0, Find(RTR_Version as String, ".", 0)+3) + " Installed Successfully!")
EndEvent

Event OnPlayerLoadGame()
	SetupRTR()
	CheckForUpdates()
EndEvent

Function SetupRTR()
	RegisterForMenu("InventoryMenu")
	RegisterForMenu("Journal Menu")
	RegisterForMenu("ContainerMenu")
	RegisterForMenu("GiftMenu")

	RegisterForKey(ToggleKey.GetValue() as Int)
	RegisterForKey(DeleteKey.GetValue() as Int)
	RegisterForKey(EnableKey.GetValue() as Int)

	Game.EnablePlayerControls()
	
	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = PlayerRef.GetActorBase().GetSex() == 1

	; Attach helm to the hip
	Bool HipEnabled = LastEquippedType != "Hood" && !PlayerRef.IsEquipped(LastEquipped)
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

	; Initialize variables for the current location
	; Update the MostRecentLocationAction reference for other processes
	Location akLoc = PlayerRef.GetCurrentLocation()
	Bool equip_when_safe = EquipWhenSafe.GetValue() as Bool
	Bool unequip_when_unsafe = UnequipWhenUnsafe.GetValue() as Bool
	
	String locationAction = RTR_GetLocationAction(akLoc, true, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	if locationAction == "Entering Safety" || locationAction == "Leaving Danger" 	
		MostRecentLocationAction = "Unequip"
	elseif locationAction == "Entering Danger" || locationAction == "Leaving Safety"
		MostRecentLocationAction = "Equip"
	else
		MostRecentLocationAction = "None"
	endif
	PreviousLocationAction = MostRecentLocationAction

	; Setup animations to be processed
	PlayerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")

	; Attempt to correct RTR state on game load
	Utility.wait(0.1)
	if (RTR_EquipState.GetValue() as Int) == 1
		EquipActorHeadgear()
	elseif (RTR_EquipState.GetValue() as Int) == 0
		UnequipActorHeadgear()
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
	if KeyCode == (EnableKey.GetValue() as Int)
		if PlayerRef.hasperk(ReadTheRoomPerk)
			PlayerRef.removeperk(ReadTheRoomPerk)
			RemoveFromHip()
			RemoveFromHand()
			LastEquipped = None
			LastLoweredHood = None
			LastEquippedType = "None"
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
			GoToState("busy")
		else
			PlayerRef.addperk(ReadTheRoomPerk)
			SetupRTR()
			Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
			GoToState("")
		endif
	endif

	; Manually Toggle Head Gear
	if KeyCode == (ToggleKey.GetValue() as Int)
		LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValue() as Bool)
		if RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
			UnequipActorHeadgear()
		else
			LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
			EquipActorHeadgear()
		endif
	endif

	; Force clear attachment nodes
	if KeyCode == (DeleteKey.GetValue() as Int)
		SendModEvent("ReadTheRoomClearPlacements")
		RemoveFromHip()
		RemoveFromHand()
		LastEquipped = None
		LastLoweredHood = None
		LastEquippedType = "None"
		Game.EnablePlayerControls()
		GoToState("")
	endif
EndEvent

; OnLocationChange Event Handler
; Updates locational triggers/actions
;
; Records Most Recent Location Action
; Equips/Unequips based off of Config Settings
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Location akLoc = PlayerRef.GetCurrentLocation() ; After testing... I do not trust the akNewLoc parameter to be accurate after loading from save -.-'
	LastEquipped = RTR_GetEquipped(PlayerRef, ManageCirclets.GetValue() as Bool)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.GetValue() as Bool
	Bool unequip_when_unsafe = UnequipWhenUnsafe.GetValue() as Bool

	; Update the MostRecentLocationAction reference for other processes
	String locationAction = RTR_GetLocationAction(akLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)

	if locationAction == "Entering Safety" || locationAction == "Leaving Danger" 	
		MostRecentLocationAction = "Unequip"
	elseif locationAction == "Entering Danger" || locationAction == "Leaving Safety"
		MostRecentLocationAction = "Equip"
	else
		MostRecentLocationAction = "None"
	endif
	
	; Only apply the action if we didn't already do it, prevents ToggleKey from being overwritten unless changing location action
	if MostRecentLocationAction != "None" && MostRecentLocationAction != PreviousLocationAction
		if NotifyOnLocation.GetValue() as Bool
			Debug.Notification(locationAction)
		endif

		Utility.wait(0.5) ; Short Delay before equipping or unequipping, because it looks better than finishing the equipping animation as the screen finally fades in.

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
EndEvent

; OnReadTheRoomCombatStateChanged Event Handler
; Toggles Headgear based off Players Combat State
; @todo Test to see if this triggers on any actor, don't think it does but worth checking
Event OnReadTheRoomCombatStateChanged(String eventName, String strArg, Float numArg, Form sender)
	; Ignore the event if if CombatEquip is disabled
	if (CombatEquip.GetValue() as Int) == 0
		return
	endif

	Int aeCombatState = numArg as Int
	if aeCombatState == 1 && PlayerRef.IsInCombat() && !PlayerRef.IsEquipped(LastEquipped)
		; An NPC has reported they are in combat with the player and the player is not wearing the item
		if (NotifyOnCombat.GetValue() as Bool)
			Debug.Notification("Entering Combat!")
		endIf
		WasInCombat = true
		EquipActorHeadgear(true)
	endif
	
	if aeCombatState == 0 && !PlayerRef.IsInCombat() && WasInCombat
		; Player left combat
		; Return to the most recent action
		if RecentAction == "Unequip"
			Utility.wait(1.0) ; short delay of time before unequipping post combat so it doesn't feel abrupt
			if (NotifyOnCombat.GetValue() as Bool)
				Debug.Notification("Leaving Combat")
			endIf
			UnequipActorHeadgear()
		endif
		WasInCombat = false
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
	String anim_action = RTR_GetActionString(PlayerRef.GetAnimationVariableInt("RTR_Action"))

	; Equip Headgear
	if asEventName == "RTR_Equip"
		RemoveFromHand()
		PlayerRef.EquipItem(LastEquipped, false, true)
		SendModEvent("ReadTheRoomEquip")
		return
	endif

	; Unequip Headgear
	if asEventName == "RTR_Unequip"
		if (anim_action != "EquipHood" && anim_action != "UnequipHood")  
			AttachToHand()
		endif
		PlayerRef.UnequipItem(LastEquipped, false, true)
		SendModEvent("ReadTheRoomUnequip")
		return
	endif

	; Attach to Hip
	if asEventName == "RTR_AttachToHip"
		RemoveFromHand()
		AttachToHip()
		return
	endif

	; Remove from Hip
	if asEventName == "RTR_RemoveFromHip"
		RemoveFromHip()
		AttachToHand()
		return
	endif

	; Attach Lowered Hood
	if asEventName == "RTR_AttachLoweredHood" && LastLoweredHood
		PlayerRef.EquipItem(LastLoweredHood, false, true)
		return
	endif

	; Remove Lowered Hood
	if asEventName == "RTR_RemoveLoweredHood" && LastLoweredHood
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		return
	endif

	; Stop Offset
	if asEventName == "RTR_OffsetStop"
		RemoveFromHand()
		Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Float timeout = PlayerRef.GetAnimationVariableFloat("RTR_Timeout")

		; Disable certain controls for the player during the animation
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)

		Utility.wait(timeout + AnimTimeoutBuffer)

		; Wait for player inventory to complete the equipping / unequipping actions
		Bool finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
		Int waitCount = 0
		while !finishedEquipUnequip && waitCount < 60
			Utility.wait(0.1)
			finishedEquipUnequip = PlayerRef.GetAnimationVariableInt("IsEquipping") == 0 && PlayerRef.GetAnimationVariableInt("IsUnequipping") == 0
			waitCount += 1
		endwhile

		; Post Animation Clean Up
		Game.EnablePlayerControls()
		PostAnimCleanUp()
	endif
EndEvent

; OnObjectEquipped Event Handler
; Cheks if the actor equipped head gear outside of RTR and removes any placements / lowered hoods
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	; Check if a head wear item was equipped
	String type = RTR_InferItemType(akBaseObject)
	if type != "None"
		RemoveFromHip()
		RemoveFromHand()
		
		if LastLoweredHood
			; Remove lowered hood
			PlayerRef.UnequipItem(LastLoweredHood, false, true)
			PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		endif
		SendModEvent("ReadTheRoomEquipNoAnimation")
	endif
EndEvent

; OnObjectUnequipped Event Handler
; Checks if the actor removed their torso armor and removes any placements / lowered hoods if RemoveHelmetWithoutArmor is enabled
; Also checkes if the actor removed their head gear outside of RTR and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	; Check if it was armor that was removed
	if (RemoveHelmetWithoutArmor.GetValue() as Bool) && !RTR_IsTorsoEquipped(PlayerRef)
		RemoveFromHip()
		RemoveFromHand()

		if LastLoweredHood
			; Remove lowered hood from player
			PlayerRef.UnequipItem(LastLoweredHood, false, true)
			PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		endif
	endif

	; Check if it was a helmet, circlet, or hood that was removed
	String type = RTR_InferItemType(akBaseObject)
	if type != "None"
		RemoveFromHip()
		RemoveFromHand()
		
		if LastLoweredHood
			; remove any lowered hoods from actor
			PlayerRef.UnequipItem(LastLoweredHood, false, true)
			PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		endIf
		SendModEvent("ReadTheRoomUnequipNoAnimation")
	endif
EndEvent

; OnMenuOpen Event Handler
; Pauses RTR Follower Events while a container is open to prevent OnObjectEquip/Unequip Lag while trading with a follower
Event OnMenuOpen(String MenuName)
	if MenuName == "ContainerMenu" || MenuName == "GiftMenu"
		SendModEvent("ReadTheRoomPauseFollowerActions")
	endif
EndEvent

; OnMenuClose Event Handler
; Checks if the actor closed their inventory and removes any placements / lowered hoods
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

		RemoveFromHand() ; I don't think this is needed anymore but leaving it here just in case
	endif

	; Resume Follower Processing
	if MenuName == "ContainerMenu" || MenuName == "GiftMenu"
		SendModEvent("ReadTheRoomResumeFollowerActions")
	endif

	if MenuName == "Journal Menu"
		; @Todo check if an update to registrations and positioning needs to be done
	endif
EndEvent

; OnRaceSwitchComplete Event Handler
; Resets RTR
Event OnRaceSwitchComplete()
	IsFemale = PlayerRef.GetActorBase().GetSex() == 1
	
	; Removing and Readding the perk should refersh all properties and baked gender variables
	if PlayerRef.HasPerk(ReadTheRoomPerk)
		PlayerRef.RemovePerk(ReadTheRoomPerk)
		Utility.wait(1.0)
		PlayerRef.AddPerk(ReadTheRoomPerk)
	endif
EndEvent

;;;; Action Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
Function EquipActorHeadgear(Bool IsCombatEquip = false)
	; Check Controls and Exit Early if any of them are disabled
	; Solves any issue with RTR trigging when something else has purposefully disabled controls
	if !RTR_CanRun() || PlayerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Update the IED Node with the last_equipped item
	UseHelmet()

	; Exit early if the actor is already wearing the item
	if PlayerRef.IsEquipped(LastEquipped)
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Combat State Unequip
	if PlayerRef.IsInCombat()
		if (CombatEquip.GetValue() as Int) == 0
			return
		endif

		; Equip with no animation
		if !(CombatEquipAnimation.GetValue() as Bool)
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
		; Force equip with no animation
		EquipWithNoAnimation()
		return
	endif

	; Skip animation if weapons are drawn but the setting is disabled
	if !(SheathWeaponsForAnimation.GetValue() as Bool) && PlayerRef.IsWeaponDrawn()
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
	endif

	Bool was_drawn = RTR_SheathWeapon(PlayerRef)
	Bool was_first_person = RTR_ForceThirdPerson(PlayerRef)
	PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
	PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)

	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	Debug.sendAnimationEvent(PlayerRef, animation)
	
	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	Game.EnablePlayerControls()
	PostAnimCleanUp()
	if !IsCombatEquip
		RecentAction = "Equip"
		RTR_EquipState.SetValue(1.0)
	endif
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
Function EquipWithNoAnimation(Bool sendFollowerEvent = true, Bool IsCombatEquip = false)
	; Check Controls and Exit Early if any of them are disabled
	; Solves any issue with RTR trigging when something else has purposefully disabled controls
	if !RTR_CanRun() || PlayerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Make sure our last equipped item is up to date
	LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)

	; Update the IED Node with the last_equipped item
	UseHelmet()
	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	
	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	if LastEquippedType == "Hood"
		if LastLoweredHood
			PlayerRef.UnequipItem(LastLoweredHood, false, true)
			PlayerRef.RemoveItem(LastLoweredHood, 1, true)
		endif
		PlayerRef.EquipItem(LastEquipped, false, true)
	else
		PlayerRef.EquipItem(LastEquipped, false, true)
		RemoveFromHip()
		RemoveFromHand()
	endif

	if sendFollowerEvent
		SendModEvent("ReadTheRoomEquipNoAnimation")
	endif

	if !IsCombatEquip
		RecentAction = "Equip"
		RTR_EquipState.SetValue(1.0)
	endif

	Utility.wait(0.1)
	GoToState("")
EndFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
Function UnequipActorHeadgear()
	; Check Controls and Exit Early if any of them are disabled
	; Solves any issue with RTR trigging when something else has purposefully disabled controls
	if !RTR_CanRun() || PlayerRef.HasKeywordString("ActorTypeCreature")
		return
	endif
	
	; Update the IED Node with the equipped item
	UseHelmet()

	; Exit early if the actor is not wearing the item
	if !PlayerRef.IsEquipped(LastEquipped)
		RemoveFromHand()
		return
	endif

	; Combat State Unequip
	if PlayerRef.GetCombatState()
		if (CombatEquip.GetValue() as Int) == 0
			return
		endif

		; Unequip with no animation
		if !(CombatEquipAnimation.GetValue() as Bool)
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
		; Force unequip with no animation
		UnequipWithNoAnimation()
		return
	endif

	; Skip animation if weapons are drawn but the setting is disabled
	if !(SheathWeaponsForAnimation.GetValue() as Bool) && PlayerRef.IsWeaponDrawn()
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
	endif

	Bool was_drawn = RTR_SheathWeapon(PlayerRef)
	Bool was_first_person = RTR_ForceThirdPerson(PlayerRef)
	PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
	PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)

	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
	Debug.sendAnimationEvent(PlayerRef, animation)

	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	Game.EnablePlayerControls()
	PostAnimCleanUp()
	RecentAction = "Unequip"
	RTR_EquipState.SetValue(0.0)
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
Function UnequipWithNoAnimation(Bool sendFollowerEvent = true)
	; Check Controls and Exit Early if any of them are disabled
	; Solves any issue with RTR trigging when something else has purposefully disabled controls
	if !RTR_CanRun() || PlayerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Make sure our last equipped item is up to date
	LastEquipped = RTR_GetLastEquipped(PlayerRef, LastEquippedType)
	
	; Update the IED Node with the equipped item
	UseHelmet()
	GoToState("busy")
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")

	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	if LastEquippedType == "Hood"
		PlayerRef.UnequipItem(LastEquipped, false, true)
		if LastLoweredHood
			PlayerRef.EquipItem(LastLoweredHood, false, true)
		endif
	else
		RemoveFromHand()
		AttachToHip()
		PlayerRef.UnequipItem(LastEquipped, false, true)
	endif

	if sendFollowerEvent
		SendModEvent("ReadTheRoomUnequipNoAnimation")
	endif
	RecentAction = "Unequip"
	RTR_EquipState.SetValue(0.0)

	Utility.wait(0.1)
	GoToState("")
EndFunction

;;;; Busy State - Blocked Actions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
State busy
	Event OnKeyDown(Int KeyCode)
		; Continue to allow full mod enable/disable, also resets the state
		if KeyCode == EnableKey.GetValue() as Int
			if PlayerRef.hasperk(ReadTheRoomPerk)
				PlayerRef.removeperk(ReadTheRoomPerk)
				RemoveFromHip()
				RemoveFromHand()
				LastEquipped = None
				LastLoweredHood = None
				LastEquippedType = "None"
				Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
				GoToState("busy")
			else
				PlayerRef.addperk(ReadTheRoomPerk)
				SetupRTR()
				Debug.sendAnimationEvent(PlayerRef, "OffsetStop")
				GoToState("")
			endif
		endif

		; Continue to allow forced placement clearing, also resets the state
		if KeyCode == DeleteKey.GetValue() as Int
			SendModEvent("ReadTheRoomClearPlacements")
			RemoveFromHip()
			RemoveFromHand()
			LastEquipped = None
			LastLoweredHood = None
			LastEquippedType = "None"
			GoToState("")
		endif
	EndEvent

	Event OnLocationChange(Location akOldLoc, Location akNewLoc)
		; Update the MostRecentLocationAction reference even in Busy State
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, LastEquipped, LoweredHoods)
		Bool equip_when_safe = EquipWhenSafe.GetValue() as Bool
		Bool unequip_when_unsafe = UnequipWhenUnsafe.GetValue() as Bool
		String locationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
		if locationAction == "Entering Safety" || locationAction == "Leaving Danger" 	
			MostRecentLocationAction = "Unequip"
		elseif locationAction == "Entering Danger" || locationAction == "Leaving Safety"
			MostRecentLocationAction = "Equip"
		else
			MostRecentLocationAction = "None"
		endif
	EndEvent

	Event OnReadTheRoomCombatStateChanged(String eventName, String strArg, Float numArg, Form sender)
	EndEvent

	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent

	Event OnMenuOpen(String MenuName)
	EndEvent

	Event OnMenuClose(String MenuName)
	EndEvent

	Function EquipActorHeadgear(Bool IsCombatEquip = false)
	EndFunction

	Function EquipWithNoAnimation(Bool sendFollowerEvent = true, Bool IsCombatEquip = false)
	EndFunction

	Function UnequipActorHeadgear()
	EndFunction

	Function UnequipWithNoAnimation(Bool sendFollowerEvent = true)
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
	Game.EnablePlayerControls()

	; Check if the animation completed successfully or if it was interuppted
	if animAction == "Equip" || animAction == "EquipHood"
		; Finalize Equip
		EquipWithNoAnimation(false)
	elseif animAction == "Unequip" || animAction == "UnequipHood"
		; Finalize Unequip
		UnequipWithNoAnimation(false)
	endif
	
	; Ensure the hand node is disabled before continuing
	RemoveFromHand()
	Debug.sendAnimationEvent(PlayerRef, "OffsetStop")

	; Return to previous weapon and first person states, if animation wasn't interuppted
	Bool draw_weapon = PlayerRef.GetAnimationVariableBool("RTR_RedrawWeapons")
	Bool return_to_first_person = PlayerRef.GetAnimationVariableBool("RTR_ReturnToFirstPerson")

	if draw_weapon && animAction == "None"
		PlayerRef.DrawWeapon()
		PlayerRef.SetAnimationVariableBool("RTR_RedrawWeapons", false)
	endif

	if return_to_first_person && animAction == "None"
		Game.ForceFirstPerson()
		PlayerRef.SetAnimationVariableBool("RTR_ReturnToFirstPerson", false)
	endif

	Utility.wait(0.5) ; Short delay befoer allowing another RTR Action, prevents weird OnEquip / OnUnequip Loops

	; Clear RTR_Action and return from busy state
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
	if LastLoweredHood
		PlayerRef.UnequipItem(LastLoweredHood, false, true)
		PlayerRef.RemoveItem(LastLoweredHood, 1, true)
	endif
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
	if !IsPlayerSetup || !LastEquipped || LastEquippedType == "None"
		SetupRTR()
		IsPlayerSetup = true
	endif

	; Conditional Placement Scaling / Lowered Hood Update
	LastEquippedType = RTR_InferItemType(LastEquipped)
	if LastEquippedType == "Hood"
		LastLoweredHood = RTR_GetLoweredHood(LastEquipped, LowerableHoods, LoweredHoods)
	elseif LastEquippedType == "Helmet"
		; Update IED Placements to use LastEquipped Helmet Form
		SetItemFormActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
		SetItemFormActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)
		SetItemScaleActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, HandScale)
	else 
		; Update IED Placements to use LastEquipped Helmet Form
		SetItemFormActor(PlayerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
		SetItemFormActor(PlayerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)
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

; CheckForUpdates
; Checks if the script version has changed 
; If it has then refreshes the RTR Monitor Perk with the updated version
Function CheckForUpdates()
	if Script_Version != RTR_GetVersion()
		Debug.Notification("Read The Room - Detected outdated scripts, updating...")

		; Use Game.GetFormFromFile to get a garenteed fresh version of the perk
		ReadTheRoomPerk = Game.GetFormFromFile(0x800, "ReadTheRoom.esp") As Perk

		; Removing and Readding the perk should refersh all properties and baked variables
		if PlayerRef.HasPerk(ReadTheRoomPerk)
			PlayerRef.RemovePerk(ReadTheRoomPerk)
			Utility.wait(5.0)
			PlayerRef.AddPerk(ReadTheRoomPerk)
		endif

		Script_Version = RTR_GetVersion()
	endif
EndFunction
