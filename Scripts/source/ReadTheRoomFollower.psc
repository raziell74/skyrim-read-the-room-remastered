ScriptName ReadTheRoomFollower extends ActiveMagicEffect

; ReadTheRoomPlayerMonitor
; Monitors the player's location, combat state, and keybind inputs
; Contains main logic for manaing the players head gear specifically

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE
Import PO3_Events_Alias ; powerofthree's Papyrus Extender

Import ReadTheRoomUtil ; Our helper functions

; Player reference and script application perk
Perk property ReadTheRoomFollowerPerk Auto

; Management Settings
GlobalVariable property ManageFollowers auto
GlobalVariable property ManageCirclets auto

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

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnInit()
	SetupRTR()
EndEvent

Event OnPlayerLoadGame()
	SetupRTR()
endEvent

function SetupRTR()
	RTR_PrintDebug(" ")
    RTR_PrintDebug("[RTR] Refreshing Follower --------------------------------------------------------------------")

    ; Set the FollowerRef to the targeted actor of the magic effect, just incase it didn't take during the variables instantiation
    FollowerRef = GetTargetActor()
    RTR_PrintDebug("-- Attaching to Follower: " + FollowerRef.GetActorBase().GetName())

	; Update the last equipped item
	LastEquipped = RTR_GetLastEquipped(FollowerRef)
	LastEquippedType = RTR_InferItemType(LastEquipped, LowerableHoods)
	IsFemale = FollowerRef.GetActorBase().GetSex() == 1

	; Attach helm to the hip
	Bool HipEnabled = (!FollowerRef.IsEquipped(LastEquipped) && LastEquippedType != "Hood")
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

	RTR_PrintDebug("-- Attached Hip Item to " + (FollowerRef as Form).GetName())

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

	RTR_PrintDebug("-- Attached Disabled Hand Item to " + (FollowerRef as Form).GetName())

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

	RTR_PrintDebug("-------------------------------------------------------------------- [RTR] OnPlayerLoadGame Completed for FollowerRef")
	RTR_PrintDebug(" ")

	FollowerRef.SetAnimationVariableInt("RTR_Action", 0)
	GoToState("")
endfunction

;;;; Mod Even Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnReadTheRoomEquip(String eventName, String strArg, Float numArg, Form sender)
    ; Do Follower Equip
EndEvent

Event OnReadTheRoomEquipNoAnimation(String eventName, String strArg, Float numArg, Form sender)
    ; Do Follower Equip without animation
EndEvent

Event OnReadTheRoomUnequip(String eventName, String strArg, Float numArg, Form sender)
    ; Do Follower Unequip
EndEvent

Event OnReadTheRoomUnequipNoAnimation(String eventName, String strArg, Float numArg, Form sender)
    ; Do Follower Unequip without animation
EndEvent

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Local Script Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
