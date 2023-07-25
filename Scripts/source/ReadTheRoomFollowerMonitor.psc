ScriptName ReadTheRoomFollowerMonitor extends ActiveMagicEffect

; ReadTheRoomFollowerMonitor
; Registers followers to listen for ReadTheRoom Mod Events
; To trigger head wear management for followers

Import IED ; Immersive Equipment Display
Import ReadTheRoomUtil ; Our helper functions

; Uninitialized Script Version
Float RTR_Version = 0.0

; Read The Room Follower Perk
Perk property ReadTheRoomFollowerPerk auto

; Current Follower Faction
Faction property CurrentFollowerFaction auto

; Management Settings
GlobalVariable property ManageFollowers auto
GlobalVariable property ManageCirclets auto
GlobalVariable property RemoveHelmetWithoutArmor auto

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
Actor FollowerRef = None
Bool IsFemale = false
Form LastEquipped = None
Form LastLoweredHood = None
String LastEquippedType = "None"
Float AnimTimeoutBuffer = 0.05
String MostRecentEvent = "None"
Bool IsFollowerSetup = false

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
	SetupRTR()
	RTR_Version = RTR_GetVersion()
EndEvent

Event OnLoad()
	SetupRTR()
	CheckForUpdates()
EndEvent

Function SetupRTR()
	FollowerRef = GetTargetActor()
    
	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

	; Delete any existing IED Placements, to ensure a full refresh
	DeleteItemActor(FollowerRef, PluginName, HelmetOnHip)
	DeleteItemActor(FollowerRef, PluginName, HelmetOnHand)

	; Attach helm to the hip
	Bool HipEnabled = ManageFollowers.GetValueInt() == 1 && IsCurrentFollower() && !FollowerRef.IsEquipped(LastEquipped) && LastEquippedType != "Hood"
	Float[] hip_position = RTR_GetPosition(LastEquippedType, HipAnchor())
	Float[] hip_rotation = RTR_GetRotation(LastEquippedType, HipAnchor())

	; Create the Hip Placement
	CreateItemActor(FollowerRef, PluginName, HelmetOnHip, InventoryRequired, LastEquipped, IsFemale, HipNode)
	SetItemPositionActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, hip_position)
	SetItemRotationActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, hip_rotation)
	SetItemFormActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
	SetItemNodeActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, HipNode)
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, HipEnabled)
	SetItemScaleActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, HipScale)

	; Attach Helm to hand - setup as disabled since the enabled flag is switched during animation
	Float[] hand_position = RTR_GetPosition(LastEquippedType, HandAnchor())
	Float[] hand_rotation = RTR_GetRotation(LastEquippedType, HandAnchor())
	
	; Create the Hand Placement
	CreateItemActor(FollowerRef, PluginName, HelmetOnHand, InventoryRequired, LastEquipped, IsFemale, HandNode)
	SetItemPositionActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, hand_position)
	SetItemRotationActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, hand_rotation)
	SetItemFormActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)
	SetItemNodeActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, HandNode)
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, false)
	if LastEquippedType == "Helmet"
		SetItemScaleActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, HandScale)
	endif

	; Register for animation events
	; Events are annotations set to trigger at specific times during the hkx animations
	RegisterForAnimationEvent(FollowerRef, "RTR_SetTimeout")
	RegisterForAnimationEvent(FollowerRef, "RTR_Equip")
	RegisterForAnimationEvent(FollowerRef, "RTR_Unequip")
	RegisterForAnimationEvent(FollowerRef, "RTR_AttachToHip")
	RegisterForAnimationEvent(FollowerRef, "RTR_RemoveFromHip")
	RegisterForAnimationEvent(FollowerRef, "RTR_AttachLoweredHood")
	RegisterForAnimationEvent(FollowerRef, "RTR_RemoveLoweredHood")
	RegisterForAnimationEvent(FollowerRef, "RTR_OffsetStop")

    ; Register for Mod Events
    ; Mod events are triggered from the Player Monitor script
    RegisterForModEvent("ReadTheRoomEquip", "OnReadTheRoomEquip")
    RegisterForModEvent("ReadTheRoomEquipNoAnimation", "OnReadTheRoomEquipNoAnimation")
    RegisterForModEvent("ReadTheRoomUnequip", "OnReadTheRoomUnequip")
    RegisterForModEvent("ReadTheRoomUnequipNoAnimation", "OnReadTheRoomUnequipNoAnimation")
	RegisterForModEvent("ReadTheRoomLocationChange", "OnReadTheRoomLocationChange")

	if !FollowerRef.IsEquipped(LastEquipped)
		MostRecentEvent = "ReadTheRoomUnequip"
	endif

	FollowerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")
EndFunction

Bool Function CanProcessFollower()
	; Do nothing if this isn't a current follower
    if ManageFollowers.GetValueInt() != 1 || !IsCurrentFollower()
        return false
    endif

	if !IsFollowerSetup || !LastEquipped
		SetupRTR()
		IsFollowerSetup = true
	endif

    ; If event received while currently in an animation wait for the current one to finish before starting the next
    Int rtrAction = FollowerRef.GetAnimationVariableInt("RTR_Action")
    while rtrAction != 0
        rtrAction = FollowerRef.GetAnimationVariableInt("RTR_Action")
        Utility.wait(0.1)
    endwhile

	return true
EndFunction

;;;; Mod Even Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnReadTheRoomClearPlacements(String eventName, String strArg, Float numArg, Form sender)
    MostRecentEvent = "ReadTheRoomEquip"
	if !CanProcessFollower()
		return
	endif

	RemoveFromHip()
	RemoveFromHand()
	LastEquipped = None
	LastLoweredHood = None
	LastEquippedType = "None"
	GoToState("")
EndEvent

Event OnReadTheRoomEquip(String eventName, String strArg, Float numArg, Form sender)
    MostRecentEvent = "ReadTheRoomEquip"
	if !CanProcessFollower()
		return
	endif

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

    EquipActorHeadgear()
EndEvent

Event OnReadTheRoomEquipNoAnimation(String eventName, String strArg, Float numArg, Form sender)
    MostRecentEvent = "ReadTheRoomEquipNoAnimation"
	if !CanProcessFollower()
		return
	endif

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

    EquipWithNoAnimation()
EndEvent

Event OnReadTheRoomUnequip(String eventName, String strArg, Float numArg, Form sender)
    MostRecentEvent = "ReadTheRoomUnequip"
	if !CanProcessFollower()
		return
	endif

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

    UnequipActorHeadgear()
EndEvent

Event OnReadTheRoomUnequipNoAnimation(String eventName, String strArg, Float numArg, Form sender)
    MostRecentEvent = "ReadTheRoomUnequipNoAnimation"
	if !CanProcessFollower()
		return
	endif
	
	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	LastEquippedType = RTR_InferItemType(LastEquipped)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

    UnequipWithNoAnimation()
EndEvent

; Work around for some follower frameworks and outfit managers (looking at you NFF) that forcefully re-equip followers gear when ever you change cells
Event OnReadTheRoomLocationChange(String eventName, String strArg, Float numArg, Form sender)
	if ManageFollowers.GetValueInt() != 1 || !IsCurrentFollower()
        return
    endif

	GoToState("CellChange")

	; If the follower somehow managed to get their gear on before we even got here, remove it
	Form Equipped = RTR_GetEquipped(FollowerRef, ManageCirclets.getValueInt() == 1)
	if Equipped && (MostRecentEvent == "ReadTheRoomUnequip" || MostRecentEvent == "ReadTheRoomUnequipNoAnimation")
		UnequipWithNoAnimation()
	endIf

	; Wait 5 seconds after changing cells to allow head wear to be refreshed
	Utility.wait(5.0)

	; Allow object equipping again, only if an the player hasn't initiated an RTR Action
	Int rtrAction = FollowerRef.GetAnimationVariableInt("RTR_Action")
	if rtrAction == 0
		GoToState("")
	endif
EndEvent

;;;; Animation Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OnAnimationEvent Event Handler
; Where the MAGIC happens, processes animation events triggered from 
; ReadTheRoom Annotations in the hkx animation files
Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	String animAction = RTR_GetActionString(FollowerRef.GetAnimationVariableInt("RTR_Action"))

	; Equip Headgear
	if asEventName == "RTR_Equip"
		RemoveFromHand()
		FollowerRef.EquipItem(LastEquipped, false, true)
		return
	endif

	; Unequip Headgear
	if asEventName == "RTR_Unequip"
		if (animAction != "EquipHood" && animAction != "UnequipHood")  
			AttachToHand()
		endif
		FollowerRef.UnequipItem(LastEquipped, true, true)
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
		FollowerRef.EquipItem(LastLoweredHood, true, true)
		return
	endif

	; Remove Lowered Hood
	if asEventName == "RTR_RemoveLoweredHood" && LastLoweredHood
		FollowerRef.UnequipItem(LastLoweredHood, false, true)
		FollowerRef.RemoveItem(LastLoweredHood, 1, true)
		return
	endif

	; Stop Offset
	if asEventName == "RTR_OffsetStop"
		RemoveFromHand()
		Debug.sendAnimationEvent(FollowerRef, "OffsetStop")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Float timeout = FollowerRef.GetAnimationVariableFloat("RTR_Timeout")

		Utility.wait(timeout + AnimTimeoutBuffer)

		; Wait for player inventory to complete the equipping / unequipping actions
		Bool finishedEquipUnequip = FollowerRef.GetAnimationVariableInt("IsEquipping") == 0 && FollowerRef.GetAnimationVariableInt("IsUnequipping") == 0
		while !finishedEquipUnequip
			Utility.wait(0.1)
			finishedEquipUnequip = FollowerRef.GetAnimationVariableInt("IsEquipping") == 0 && FollowerRef.GetAnimationVariableInt("IsUnequipping") == 0
		endwhile

		; Post Animation Clean Up
		PostAnimCleanUp()
	endif
EndEvent

;;;; Misc Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; OnObjectEquipped Event Handler
; Cheks if the actor equipped head gear outside of RTR and removes any placements / lowered hoods
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if ManageFollowers.GetValueInt() != 1 || !IsCurrentFollower()
        return
    endif

	; Check if a head wear item was equipped
	String type = RTR_InferItemType(akBaseObject)
	if type != "None"
		; Update the last equipped
		LastEquipped = akBaseObject
		LastEquippedType = type

		; Check RTR headwear state based on attached RTR items
		Bool isAttachedToHip = ItemEnabledActor(FollowerRef, PluginName, HelmetOnHip, IsFemale)
		Bool isLoweredHoodEquipped = FollowerRef.IsEquipped(LastLoweredHood)
		
		if isAttachedToHip || isLoweredHoodEquipped || MostRecentEvent == "ReadTheRoomUnequip" || MostRecentEvent == "ReadTheRoomUnequipNoAnimation"
			UnequipWithNoAnimation()
		else
			RemoveFromHip()
			RemoveFromHand()
			
			if LastLoweredHood
				; Remove lowered hood
				FollowerRef.UnequipItem(LastLoweredHood, false, true)
				FollowerRef.RemoveItem(LastLoweredHood, 1, true)
			endif
		endIf
	endif
EndEvent

; OnObjectUnequipped Event Handler
; Checks if the actor removed their torso armor and removes any placements / lowered hoods if RemoveHelmetWithoutArmor is enabled
; Also checkes if the actor removed their head gear outside of RTR and removes any placements / lowered hoods
; @TODO - Add MCM option to add RTR placements if manually unequipping head gear
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if ManageFollowers.GetValueInt() != 1 || !IsCurrentFollower()
        return
    endif
	
	; Check if it was armor that was removed
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(FollowerRef))
		RemoveFromHip()
		RemoveFromHand()
	endif

	; Check if it was a helmet, circlet, or hood that was removed
	String type = RTR_InferItemType(akBaseObject)
	if type != "None"
		RemoveFromHip()
		RemoveFromHand()
	endif
EndEvent

;;;; Action Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
Function EquipActorHeadgear()
	if FollowerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Update the IED Node with the last_equipped item
	UseHelmet()

	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Exit early if the actor is already wearing the item
	if FollowerRef.IsEquipped(LastEquipped)
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Check Actor status for any conditions that would prevent animation
	if FollowerRef.GetSitState() || \
		FollowerRef.IsSwimming() || \
		FollowerRef.GetAnimationVariableInt("bInJumpState") == 1 || \
		FollowerRef.GetAnimationVariableInt("IsEquipping") == 1 || \
		FollowerRef.GetAnimationVariableInt("IsUnequipping") == 1
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
	endif

	Bool was_drawn = RTR_SheathWeapon(FollowerRef)
	FollowerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)

    GoToState("busy")
	Debug.sendAnimationEvent(FollowerRef, animation)
	
	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	PostAnimCleanUp()
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
Function EquipWithNoAnimation(Bool sendFollowerEvent = true)
	if FollowerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Make sure our last equipped item is up to date
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)
	
	; Update the IED Node with the last_equipped item
	UseHelmet()
	GoToState("busy")

	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	if LastEquippedType == "Hood"
		if LastLoweredHood
			FollowerRef.UnequipItem(LastLoweredHood, false, true)
			FollowerRef.RemoveItem(LastLoweredHood, 1, true)
		endif
		FollowerRef.EquipItem(LastEquipped, false, true)
	else
		FollowerRef.EquipItem(LastEquipped, false, true)
		RemoveFromHip()
		RemoveFromHand()
	endif

	Utility.wait(0.1)
	GoToState("")
EndFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
Function UnequipActorHeadgear()
	if FollowerRef.HasKeywordString("ActorTypeCreature")
		return
	endif
	
	; Update the IED Node with the equipped item
	UseHelmet()

	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	; Exit early if the actor is not wearing the item
	if !FollowerRef.IsEquipped(LastEquipped)
		RemoveFromHand()
		return
	endif

	; Check Actor status for any conditions that would prevent animation
	if FollowerRef.GetSitState() || \
		FollowerRef.IsSwimming() || \
		FollowerRef.GetAnimationVariableInt("bInJumpState") == 1 || \
		FollowerRef.GetAnimationVariableInt("IsEquipping") == 1 || \
		FollowerRef.GetAnimationVariableInt("IsUnequipping") == 1
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
	endif

	Bool was_drawn = RTR_SheathWeapon(FollowerRef)
	FollowerRef.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)

    GoToState("busy")
	Debug.sendAnimationEvent(FollowerRef, animation)

	; Add a typical timeout to ensure the post-animation is called
	Utility.wait(animation_time)
	PostAnimCleanUp()
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
Function UnequipWithNoAnimation()
	if FollowerRef.HasKeywordString("ActorTypeCreature")
		return
	endif

	; Make sure our last equipped item is up to date
	LastEquipped = RTR_GetLastEquipped(FollowerRef, LastEquippedType)

	; Update the IED Node with the equipped item
	UseHelmet()
	GoToState("busy")

	if LastEquipped.HasKeywordString("RTR_ExcludeKW")
		RemoveFromHip()
		RemoveFromHand()
		return
	endif

	if LastEquippedType == "Hood"
		FollowerRef.UnequipItem(LastEquipped, true, true)
		if LastLoweredHood
			FollowerRef.EquipItem(LastLoweredHood, true, true)
		endif
	else
		FollowerRef.UnequipItem(LastEquipped, true, true)
		AttachToHip()
		RemoveFromHand()
	endif

	Utility.wait(0.1)
	GoToState("")
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Local Script Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; PostAnimCleanUp
; Performs the post-animation cleanup actions
Function PostAnimCleanUp()
	; Post Animation Actions
	String animAction = RTR_GetActionString(FollowerRef.GetAnimationVariableInt("RTR_Action"))

	; Check if the animation completed successfully or if it was interuppted
	if animAction == "Equip" || animAction == "EquipHood"
		; Finalize Equip
		EquipWithNoAnimation()
		Debug.sendAnimationEvent(FollowerRef, "OffsetStop")
	elseif animAction == "Unequip" || animAction == "UnequipHood"
		; Finalize Unequip
		UnequipWithNoAnimation()
		Debug.sendAnimationEvent(FollowerRef, "OffsetStop")
	endif
	
	; Ensure the hand node is disabled before continuing
	RemoveFromHand()

	; Return to previous weapon state, if animation wasn't interuppted
	Bool draw_weapon = FollowerRef.GetAnimationVariableBool("RTR_RedrawWeapons")

	if draw_weapon && animAction == "None"
		FollowerRef.DrawWeapon()
		FollowerRef.SetAnimationVariableBool("RTR_RedrawWeapons", false)
	endif

	; Clear RTR_Action and return from busy state
	FollowerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")
EndFunction

; Enables IED Hip Placement
Function AttachToHip()
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, true)
EndFunction

; Disables IED Hip Placement
Function RemoveFromHip()
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, false)
	if LastLoweredHood
		FollowerRef.UnequipItem(LastLoweredHood, false, true)
		FollowerRef.RemoveItem(LastLoweredHood, 1, true)
	endif
EndFunction

; Enables IED Hand Placement
Function AttachToHand()
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, true)
EndFunction

; Disables IED Hand Placement
Function RemoveFromHand()
	SetItemEnabledActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, false)
EndFunction

; UseHelmet
; Sets an Armor Form as the IED placement display forms
Function UseHelmet()
	; Update IED Placements to use LastEquipped Helmet Form
	SetItemFormActor(FollowerRef, PluginName, HelmetOnHip, IsFemale, LastEquipped)
	SetItemFormActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, LastEquipped)

	; Conditional Placement Scaling / Lowered Hood Update
	LastEquippedType = RTR_InferItemType(LastEquipped)
	if LastEquippedType == "Hood"
		LastLoweredHood = RTR_GetLoweredHood(LastEquipped, LowerableHoods, LoweredHoods)
	elseif LastEquippedType == "Helmet"
		SetItemScaleActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, HandScale)
	else 
		SetItemScaleActor(FollowerRef, PluginName, HelmetOnHand, IsFemale, 1)
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

; IsCurrentFollower
; Returns true if the actor is the current follower
Bool Function IsCurrentFollower()
	return FollowerRef.IsPlayerTeammate() || FollowerRef.HasKeywordString("RTR_CustomFollowerKW")
EndFunction

;;;; Busy State - Blocked Actions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
State busy
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
	
	Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	EndEvent
EndState

;;;; CellChange State ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
State CellChange
	; OnObjectEquipped CellChange State Override
	; Reverse cell triggered head wear equips from third party mods like NFF
	Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
		if ManageFollowers.GetValueInt() != 1 || !IsCurrentFollower()
			return
		endif

		; Check if a head wear item was equipped
		String type = RTR_InferItemType(akBaseObject)
		if type != "None"
			; Update the last equipped
			LastEquipped = akBaseObject
			LastEquippedType = type

			; Check RTR headwear state based on attached RTR items
			Bool isAttachedToHip = ItemEnabledActor(FollowerRef, PluginName, HelmetOnHip, IsFemale)
			Bool isLoweredHoodEquipped = FollowerRef.IsEquipped(LastLoweredHood)
			
			if isAttachedToHip || isLoweredHoodEquipped || MostRecentEvent == "ReadTheRoomUnequip" || MostRecentEvent == "ReadTheRoomUnequipNoAnimation xXx"
				UnequipWithNoAnimation()
			endif
		endif
	EndEvent
EndState

; CheckForUpdates
; Checks if the script version has changed 
; If it has then refreshes the RTR Monitor Perk with the updated version
Function CheckForUpdates()
	if RTR_Version != RTR_GetVersion()
		; Use Game.GetFormFromFile to get a garenteed fresh version of the perk
		ReadTheRoomFollowerPerk = Game.GetFormFromFile(0xE5A, "ReadTheRoom.esp") As Perk

		; Removing and Readding the perk should refersh all properties and baked variables
		if FollowerRef.HasPerk(ReadTheRoomFollowerPerk)
			FollowerRef.RemovePerk(ReadTheRoomFollowerPerk)
			Utility.wait(5.0)
			FollowerRef.AddPerk(ReadTheRoomFollowerPerk)
		endif

		RTR_Version = RTR_GetVersion()
	endif
EndFunction
