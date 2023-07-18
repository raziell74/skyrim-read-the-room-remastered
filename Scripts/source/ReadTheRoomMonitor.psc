ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

; ReadTheRoomMonitor script
; Monitors the player's location, combat state, 
; key toggles, and other events to trigger Read The Room headgear 
; management for both the player and followers.

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE
Import PO3_Events_Alias ; powerofthree's Papyrus Extender

Import ReadTheRoomUtil

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
GlobalVariable property ManageFollowers auto
FormList property ManagedActors auto
FormList property LastEquippedMonitor auto

; Location Identification Settings
FormList property SafeKeywords auto
FormList property HostileKeywords auto

; Lowerable Hood Configuration
FormList property LowerableHoods auto
FormList property LoweredHoods auto

; ReadTheRoom dedicated keywords
Keyword property RTR_Follower auto

; IED Hip/Hand Anchors
FormList property MaleHandAnchor auto
FormList property MaleHipAnchor auto
FormList property FemaleHandAnchor auto
FormList property FemaleHipAnchor auto

; Local Script Variables
String PluginName = "ReadTheRoom.esp"
String MostRecentLocationAction = "None"
String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String HipNode = "NPC Pelvis [Pelv]"
String HandNode = "NPC R Hand [RHnd]"
Bool InventoryRequired = true
Float HipScale = 0.9150
Float HandScale = 1.05
Float AnimTimeoutBuffer = 0.25

Event OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Event OnPlayerLoadGame()
	RTR_PrintDebug(" ")
    RTR_PrintDebug("[RTR] OnPlayerLoadGame --------------------------------------------------------------------")
    
	; Check/Update IED Attachments for each managed actor
	int actorIndex = 0
	int managedActorCount = ManagedActors.GetSize()
	while actorIndex < managedActorCount
		Actor target_actor = ManagedActors.GetAt(actorIndex) as Actor
		if target_actor != None
			RTR_PrintDebug("[RTR] DEBUG: Updating Initial IED Attachments for " + target_actor.GetActorBase().GetName())
			Form LastEquipped = RTR_GetLastEquipped(target_actor)
			String type = RTR_InferItemType(LastEquipped, LowerableHoods)
			Bool IsFemale = target_actor.GetActorBase().GetSex() == 1

			; Attach helm to the hip
			Bool HipEnabled = (!target_actor.IsEquipped(LastEquipped) && type != "Hood")
			Float[] hip_position = RTR_GetPosition(type, HipAnchor(IsFemale))
			Float[] hip_rotation = RTR_GetRotation(type, HipAnchor(IsFemale))
			RTR_PrintDebug("[RTR] DEBUG: Hip Position from FemaleHipAnchor FormList. posX = " + (hip_position[0] as String) + " posY = " + (hip_position[1] as String) + " posZ = " + (hip_position[2] as String))
			RTR_PrintDebug("[RTR] DEBUG: Hip Rotation from FemaleHipAnchor FormList. Pitch = " + (hip_position[0] as String) + " Roll = " + (hip_position[1] as String) + " Yaw = " + (hip_position[2] as String))

			; Create the item, should show the item on the hip
			RTR_PrintDebug("[RTR] DEBUG: Creating Hip item with the following parameters:")
			RTR_PrintDebug("[RTR] DEBUG: " + (target_actor as Form).GetName())
			RTR_PrintDebug("[RTR] DEBUG: Plugin " + PluginName)
			RTR_PrintDebug("[RTR] DEBUG: Name " + HelmetOnHip)
			RTR_PrintDebug("[RTR] DEBUG: InventoryRequired " + (InventoryRequired as String))
			RTR_PrintDebug("[RTR] DEBUG: IsFemale " + (IsFemale as String))
			RTR_PrintDebug("[RTR] DEBUG: Node " + HipNode)
			RTR_PrintDebug("[RTR] DEBUG: Enabled " + (HipEnabled as String))
			
			; Create the Hip Placement
			CreateItemActor(target_actor, PluginName, HelmetOnHip, InventoryRequired, LastEquipped, IsFemale, HipNode)
			SetItemPositionActor(target_actor, PluginName, HelmetOnHip, IsFemale, hip_position)
			SetItemRotationActor(target_actor, PluginName, HelmetOnHip, IsFemale, hip_rotation)
			SetItemFormActor(target_actor, PluginName, HelmetOnHip, IsFemale, LastEquipped)
			SetItemNodeActor(target_actor, PluginName, HelmetOnHip, IsFemale, HipNode)
			SetItemEnabledActor(target_actor, PluginName, HelmetOnHip, IsFemale, HipEnabled)
			SetItemScaleActor(target_actor, PluginName, HelmetOnHip, IsFemale, HipScale)

			RTR_PrintDebug("[RTR] DEBUG: Attached Hip Item to " + (target_actor as Form).GetName())

			;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

			; Attach Helm to hand - setup as disabled since the enabled flag is switched during animation
			Float[] hand_position = RTR_GetPosition(type, HandAnchor(IsFemale))
			Float[] hand_rotation = RTR_GetRotation(type, HandAnchor(IsFemale))
			RTR_PrintDebug("[RTR] DEBUG: Hip Position from FemaleHipAnchor FormList. posX = " + (hand_position[0] as String) + " posY = " + (hand_position[1] as String) + " posZ = " + (hand_position[2] as String))
			RTR_PrintDebug("[RTR] DEBUG: Hip Rotation from FemaleHipAnchor FormList. Pitch = " + (hand_rotation[0] as String) + " Roll = " + (hand_rotation[1] as String) + " Yaw = " + (hand_rotation[2] as String))

			; Create the item, should show the item on the Hand
			RTR_PrintDebug("[RTR] DEBUG: Creating Hand item with the following parameters:")
			RTR_PrintDebug("[RTR] DEBUG: " + (target_actor as Form).GetName())
			RTR_PrintDebug("[RTR] DEBUG: Plugin " + PluginName)
			RTR_PrintDebug("[RTR] DEBUG: Name " + HelmetOnHand)
			RTR_PrintDebug("[RTR] DEBUG: InventoryRequired " + (InventoryRequired as String))
			RTR_PrintDebug("[RTR] DEBUG: IsFemale " + (IsFemale as String))
			RTR_PrintDebug("[RTR] DEBUG: Node " + HandNode)
			RTR_PrintDebug("[RTR] DEBUG: Enabled FALSE")

			; Create the Hand Placement
			CreateItemActor(target_actor, PluginName, HelmetOnHand, InventoryRequired, LastEquipped, IsFemale, HandNode)
			SetItemPositionActor(target_actor, PluginName, HelmetOnHand, IsFemale, hand_position)
			SetItemRotationActor(target_actor, PluginName, HelmetOnHand, IsFemale, hand_rotation)
			SetItemFormActor(target_actor, PluginName, HelmetOnHand, IsFemale, LastEquipped)
			SetItemNodeActor(target_actor, PluginName, HelmetOnHand, IsFemale, HandNode)
			SetItemEnabledActor(target_actor, PluginName, HelmetOnHand, IsFemale, false)
			if type == "Helmet"
				SetItemScaleActor(target_actor, PluginName, HelmetOnHand, IsFemale, HandScale)
			endif

			RTR_PrintDebug("[RTR] DEBUG: Attached Hand Item to " + (target_actor as Form).GetName())

			RegisterForAnnotationEvents(target_actor)
		endIf
		actorIndex += 1
	endWhile

	RTR_PrintDebug("-------------------------------------------------------------------- [RTR] OnPlayerLoadGame COMPLETE")
	RTR_PrintDebug(" ")
 endEvent

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
		if PlayerRef.hasperk(ReadTheRoomPerk)
			PlayerRef.removeperk(ReadTheRoomPerk)
		else
			PlayerRef.addperk(ReadTheRoomPerk)
		endif
	endif

	; Manually Toggle Head Gear
	if KeyCode == ToggleKey.GetValueInt()
		RTR_PrintDebug(" ")
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR] Toggle --------------------------------------------------------------------")
		if PlayerRef.GetAnimationVariableInt("RTR_Action") != 0
			return
		endif
		Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
		
		if is_valid
			if ManageFollowers.GetValueInt() == 0
				UnequipActorHeadgear(PlayerRef, equipped)
			else
				UnequipFollowerHeadgear()
			endif
		else
			if ManageFollowers.GetValueInt() == 0
				Form last_equipped = RTR_GetLastEquipped(PlayerRef)
				EquipActorHeadgear(PlayerRef, last_equipped)
			else
				EquipFollowerHeadgear()
			endif
		endif
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RemoveFromHip(PlayerRef)
		RemoveFromHand(PlayerRef)
		UpdateManagedFollowersList()
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
	if PlayerRef.GetAnimationVariableInt("RTR_Action") != 0
		return
	endif
	Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
	
	; Update the MostRecentLocationAction
	MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	UpdateManagedFollowersList()

	if MostRecentLocationAction == "Equip"
		if ManageFollowers.GetValueInt() == 0
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		else
			EquipFollowerHeadgear()
		endif
	elseif MostRecentLocationAction == "Unequip"
		if ManageFollowers.GetValueInt() == 0
			UnequipActorHeadgear(PlayerRef, equipped)
		else
			UnequipFollowerHeadgear()
		endif
		
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnCombatStateChanged Event Handler
; Toggles Headgear based off Players Combat State
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnCombatStateChanged: " + aeCombatState + " --------------------------------------------------------------------")
	if PlayerRef.GetAnimationVariableInt("RTR_Action") != 0
		return
	endif
	if akTarget == PlayerRef && CombatEquip.GetValueInt() == 1
		if aeCombatState == 1
			; Player entered combat
			if ManageFollowers.GetValueInt() == 0
				Form last_equipped = RTR_GetLastEquipped(PlayerRef)
				EquipActorHeadgear(PlayerRef, last_equipped)
			else
				EquipFollowerHeadgear()
			endif
		elseif aeCombatState == 0
			; Player left combat
			if MostRecentLocationAction == "Unequip"
				if ManageFollowers.GetValueInt() == 0
					Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
					UnequipActorHeadgear(PlayerRef, equipped)
				else
					UnequipFollowerHeadgear()
				endif
			endif
		endIf
	endIf

	if CombatEquip.GetValueInt() == 1 && aeCombatState == 2
		; Someone is looking for the player
		; @todo Implement
	endif
	RTR_PrintDebug(" ")
endEvent

; OnAnimationEvent Event Handler
; Applys IED node attachments and head gear equipping for RTR annotated animations
Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] Animation Event: " + asEventName + " --------------------------------------------------------------------")

	Actor target_actor = akSource as Actor
	bool is_player = target_actor == PlayerRef
	Bool prevent_equip = !is_player
	String anim_action = getAction(target_actor.GetAnimationVariableInt("RTR_Action"))

	; RTR Event Handlers
	; @todo Pass to an RTR Action Delegate?

	if asEventName == "RTR_Equip"
		Form last_equipped = RTR_GetLastEquipped(target_actor)
		; Equip Headgear
		RemoveFromHand(target_actor)
		target_actor.EquipItem(last_equipped, false, true)
		RTR_PrintDebug("- " + (last_equipped as Armor).GetName() + " Equipped")
		return
	endif

	if asEventName == "RTR_Unequip"
		Form last_equipped = RTR_GetLastEquipped(target_actor)
		; Unequip Headgear
		if (anim_action != "EquipHood" && anim_action != "UnequipHood")  
			AttachToHand(target_actor)
		endif
		target_actor.UnequipItem(last_equipped, prevent_equip, true)
		RTR_PrintDebug("- " + (last_equipped as Armor).GetName() + " Unequipped")
		return
	endif

	if asEventName == "RTR_AttachToHip"
		; Attach to Hip
		RemoveFromHand(target_actor)
		AttachToHip(target_actor)
		return
	endif

	if asEventName == "RTR_RemoveFromHip"
		; Remove from Hip
		RemoveFromHip(target_actor)
		AttachToHand(target_actor)
		return
	endif

	if asEventName == "RTR_AttachLoweredHood"
		Form last_equipped = RTR_GetLastEquipped(target_actor)
		; Attach Lowered Hood
		if LowerableHoods.HasForm(last_equipped)
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.EquipItem(lowered_hood, false, true)
		endif
		return
	endif

	if asEventName == "RTR_RemoveLoweredHood"
		Form last_equipped = RTR_GetLastEquipped(target_actor)
		; Remove Lowered Hood
		if LowerableHoods.HasForm(last_equipped) 
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(lowered_hood, false, true)
			target_actor.RemoveItem(lowered_hood, 1, true)
			RTR_PrintDebug("- " + (lowered_hood as Armor).GetName() + " (Lowered Hood) Unequipped")
		endif
		return
	endif

	if asEventName == "RTR_OffsetStop"
		; Stop Offset
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
		RTR_PrintDebug("- Animation Finished. OffsetStop Animation Event Sent")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Form last_equipped = RTR_GetLastEquipped(target_actor)
		Float timeout = target_actor.GetAnimationVariableFloat("RTR_Timeout")
		RTR_PrintDebug("- Animation Ends in " + (timeout + AnimTimeoutBuffer) + " seconds")

		; Disable certain controls for the player
		if is_player
			Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		endif

		Utility.wait(timeout + AnimTimeoutBuffer)
		RTR_PrintDebug(" ")
		RTR_PrintDebug("[RTR] OnAnimationEvent: Timeout Finished --------------------------------------------------------------------")

		; Check if the animation completed successfully or if it was interuppted
		if anim_action == "None"
			RTR_PrintDebug("- RTR Action completed successfully")
		elseif anim_action == "Equip"
			RTR_PrintDebug("- Timed Out on Equip")
			; Finalize Equip
			target_actor.EquipItem(last_equipped, false, true)
			RemoveFromHand(target_actor)
			RemoveFromHip(target_actor)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "Unequip"
			RTR_PrintDebug("- Timed Out on Unequip")
			; Finalize Unequip
			target_actor.UnequipItem(last_equipped, prevent_equip, true)
			RemoveFromHand(target_actor)
			AttachToHip(target_actor)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "EquipHood"
			RTR_PrintDebug("- Timed Out on EquipHood")
			; Finalize EquipHood
			if LowerableHoods.HasForm(last_equipped) 
				Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
				target_actor.UnequipItem(lowered_hood, false, true)
				target_actor.RemoveItem(lowered_hood, 1, true)
			endif
			target_actor.EquipItem(last_equipped, false, true)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "UnequipHood"
			RTR_PrintDebug("- Timed Out on UnequipHood")
			; Finalize UnequipHood
			if LowerableHoods.HasForm(last_equipped)
				Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
				target_actor.UnequipItem(last_equipped, false, true)
				target_actor.EquipItem(lowered_hood, prevent_equip, true)
			Else
				target_actor.UnequipItem(last_equipped, prevent_equip, true)
			endif
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		endif

		; Post Animation Actios
		if is_player
			Bool draw_weapon = target_actor.GetAnimationVariableBool("RTR_RedrawWeapons")
			Bool return_to_first_person = target_actor.GetAnimationVariableBool("RTR_ReturnToFirstPerson")
			
			RTR_PrintDebug("- CLEANUP - Enabling Player Controls")
			Game.EnablePlayerControls()

			if draw_weapon
				RTR_PrintDebug("- CLEANUP - Drawing Weapon")
				target_actor.DrawWeapon()
				target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", false)
			endif

			if return_to_first_person
				RTR_PrintDebug("- CLEANUP - Returning to First Person")
				Game.ForceFirstPerson()
				target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", false)
			endif
		endif

		Bool finishedEquipUnequip = target_actor.GetAnimationVariableInt("IsEquipping") == 0 && target_actor.GetAnimationVariableInt("IsUnequipping") == 0
		while !finishedEquipUnequip
			RTR_PrintDebug("- Waiting for Equip or Unequip to finish")
			Utility.wait(0.1)
			finishedEquipUnequip = target_actor.GetAnimationVariableInt("IsEquipping") == 0 && target_actor.GetAnimationVariableInt("IsUnequipping") == 0
		endwhile
		; Clear RTR_Action
		RTR_PrintDebug("- CLEANUP - Clearing RTR_Action")
		target_actor.SetAnimationVariableInt("RTR_Action", 0)
	endif
EndEvent

; OnObjectEquipped Event Handler
; Detatching last equipped head gear from hip and hand
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnObjectEquipped --------------------------------------------------------------------")

	Actor target_actor = PlayerRef
	
	; Check if a head wear item was equipped
	String type = RTR_InferItemType(akBaseObject, LowerableHoods)
	RTR_PrintDebug("- ItemType = " + type)
	Int active = PlayerRef.GetAnimationVariableInt("RTR_Action")
	if type != "None" && active == 0
		RTR_PrintDebug("- Actor equipped head gear outside of RTR, Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip(PlayerRef)
		RemoveFromHand(PlayerRef)
		
		; remove any lowered hoods from actor
		int i = 0
		int loweredHoodsCount = LoweredHoods.GetSize()
		while (i < loweredHoodsCount)
			Form lowered_hood = LoweredHoods.GetAt(i)
			if PlayerRef.IsEquipped(lowered_hood)
				PlayerRef.UnequipItem(lowered_hood, false, true)
				PlayerRef.RemoveItem(lowered_hood, 1, true)
			endif
			i += 1
		endwhile
	endif
	RTR_PrintDebug(" ")
EndEvent

; OnObjectUnequipped Event Handler
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] OnObjectUnequipped --------------------------------------------------------------------")
	
	; Check if it was armor that was removed
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(PlayerRef))
		RTR_PrintDebug("- Actor is not wearing anything on their torso and RemoveHelmetWithoutArmor is enabled. Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip(PlayerRef)
		RemoveFromHand(PlayerRef)
		
		; remove any lowered hoods from actor
		int i = 0
		int LoweredHoodsCount = LoweredHoods.GetSize()
		while i < LoweredHoodsCount
			Form lowered_hood = LoweredHoods.GetAt(i)
			if PlayerRef.IsEquipped(lowered_hood)
				PlayerRef.UnequipItem(lowered_hood, false, true)
				PlayerRef.RemoveItem(lowered_hood, 1, true)
			endif
			i += 1
		endwhile
	endif

	; Check if it was a helmet, circlet, or hood that was removed
	String type = RTR_InferItemType(akBaseObject, LowerableHoods)
	Int active = PlayerRef.GetAnimationVariableInt("RTR_Action")
	if type != "None" && active == 0
		RTR_PrintDebug("- Actor intentionally unequipped a helmet or hood outside of RTR, Clearing IED Nodes and removing any lowered hood")
		RemoveFromHip(PlayerRef)
		RemoveFromHand(PlayerRef)
		
		; remove any lowered hoods from actor
		int i = 0
		int LoweredHoodsCount = LoweredHoods.GetSize()
		while i < LoweredHoodsCount
			Form lowered_hood = LoweredHoods.GetAt(i)
			if PlayerRef.IsEquipped(lowered_hood)
				PlayerRef.UnequipItem(lowered_hood, false, true)
				PlayerRef.RemoveItem(lowered_hood, 1, true)
			endif
			i += 1
		endwhile
	endif
	RTR_PrintDebug(" ")
EndEvent


Event OnMenuClose(String MenuName)
	if MenuName == "InventoryMenu"
		Form last_equipped = RTR_GetLastEquipped(PlayerRef)
		if PlayerRef.IsEquipped(last_equipped)
			RemoveFromHip(PlayerRef)
		else
			; purposefully unequipped a helmet
			; @todo implement an MCM setting to change what happens when items are unequipped from the inventory
			; 		- default: 0
			;       - 0: Do Nothing
			;	    - 1: Attach to Belt / Lower Hood
			; UnequipWithNoAnimation(PlayerRef, last_equipped)
		endif
	endif

	; Regardless, the item should be removed from the hand
	RemoveFromHand(PlayerRef)
EndEvent

; OnRaceSwitchComplete Event Handler
Event OnRaceSwitchComplete()
	RemoveFromHip(PlayerRef)
	RemoveFromHand(PlayerRef)
EndEvent

;;;; Action functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
; 
; @param Actor target_actor
; @param Form last_equipped
Function EquipActorHeadgear(Actor target_actor, Form last_equipped)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] EquipActorHeadgear --------------------------------------------------------------------")
	Int RTR_InAction = target_actor.GetAnimationVariableInt("RTR_Active")
	if RTR_InAction > 0
		RTR_PrintDebug("- RTR_Active " + getAction(RTR_InAction))
		return
	endif

	; Update the IED Node with the last_equipped item
	UseHelmet(target_actor, last_equipped)

	; Exit early if the actor is already wearing the item
	if target_actor.IsEquipped(last_equipped)
		RTR_PrintDebug("- Exiting because item " + (last_equipped as Armor).GetName() + " is already equipped")
		RemoveFromHip(target_actor)
		RemoveFromHand(target_actor)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		RTR_PrintDebug("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			RTR_PrintDebug("- CombatEquip is disabled")
			return
		endif

		RTR_PrintDebug("- CombatEquip is enabled")

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			RTR_PrintDebug("- CombatEquipAnimation is disabled. Equipping with no animation")
			EquipWithNoAnimation(target_actor, last_equipped)
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if target_actor.GetSitState() || \
		target_actor.IsSwimming() || \
		target_actor.GetAnimationVariableInt("bInJumpState") == 1 || \
		target_actor.GetAnimationVariableInt("IsEquipping") == 1 || \
		target_actor.GetAnimationVariableInt("IsUnequipping") == 1
		
		RTR_PrintDebug("- Actor can't be animated. Unequipping with no animation")
		; Force equip with no animation
		EquipWithNoAnimation(target_actor, last_equipped)
		return
	endif

	; Animated Equip
	String animation = "RTREquip"

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(last_equipped)
		animation = "RTREquipHood"
		RTR_PrintDebug("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	if target_actor == PlayerRef
		RTR_PrintDebug("- Setting player RTR_RedrawWeapons to " + was_drawn)
		target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
		RTR_PrintDebug("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
		target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)
	endif

	RTR_PrintDebug("- Triggering " + animation + " animation")
	Debug.sendAnimationEvent(target_actor, animation)
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
;
; @param Actor target_actor
; @param Form last_equipped
Function EquipWithNoAnimation(Actor target_actor, Form last_equipped)
	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)

	; Update the IED Node with the last_equipped item
	UseHelmet(target_actor, last_equipped)

	if last_equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
		target_actor.UnequipItem(lowered_hood, false, true)
		target_actor.EquipItem(last_equipped, false, true)
	else
		target_actor.EquipItem(last_equipped, false, true)
		RemoveFromHip(target_actor)
		RemoveFromHand(target_actor)
	endif
endFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
;
; @param Actor target_actor
; @param Form equipped
Function UnequipActorHeadgear(Actor target_actor, Form equipped)
	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] UnequipActorHeadgear --------------------------------------------------------------------")
	
	Int RTR_InAction = target_actor.GetAnimationVariableInt("RTR_Active")
	if RTR_InAction > 0
		RTR_PrintDebug("- RTR_Active " + getAction(RTR_InAction))
		return
	endif

	; Update the IED Node with the equipped item
	UseHelmet(target_actor, equipped)

	; Exit early if the actor is not wearing the item
	if !target_actor.IsEquipped(equipped)
		RTR_PrintDebug("- Exiting because item " + (equipped as Armor).GetName() + " is not equipped")
		RemoveFromHand(target_actor)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		RTR_PrintDebug("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			RTR_PrintDebug("- CombatEquip is disabled")
			return
		endif

		RTR_PrintDebug("- CombatEquip is enabled")

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			RTR_PrintDebug("- CombatEquipAnimation is disabled. Unequipping with no animation")
			UnequipWithNoAnimation(target_actor, equipped)
			return
		endif
	endif

	; Check Actor status for any conditions that would prevent animation
	if target_actor.GetSitState() || \
		target_actor.IsSwimming() || \
		target_actor.GetAnimationVariableInt("bInJumpState") == 1 || \
		target_actor.GetAnimationVariableInt("IsEquipping") == 1 || \
		target_actor.GetAnimationVariableInt("IsUnequipping") == 1
		
		RTR_PrintDebug("- Actor can't be animated. Unequipping with no animation")
		; Force unequip with no animation
		UnequipWithNoAnimation(target_actor, equipped)
		return
	endif

	; Animated Unequip
	String animation = "RTRUnequip"

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(equipped)
		animation = "RTRUnequipHood"
		RTR_PrintDebug("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	if target_actor == PlayerRef
		RTR_PrintDebug("- Setting player RTR_RedrawWeapons to " + was_drawn)
		target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
		RTR_PrintDebug("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
		target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)
	endif

	RTR_PrintDebug("- Triggering " + animation + " animation")
	Debug.sendAnimationEvent(target_actor, animation)
EndFunction

; UnequipWithNoAnimation
; Unequips an item from an actor without playing an animation
;
; @param Actor target_actor
; @param Form equipped
Function UnequipWithNoAnimation(Actor target_actor, Form equipped)
	; Prevent follower re-equip
	Bool prevent_equip = target_actor != PlayerRef
	String equipped_type = RTR_InferItemType(equipped, LowerableHoods)

	; Update the IED Node with the equipped item
	UseHelmet(target_actor, equipped)

	if equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(equipped))
		target_actor.UnequipItem(equipped, false, true)
		target_actor.EquipItem(lowered_hood, prevent_equip, true)
	else
		String last_equipped_type = RTR_InferItemType(equipped, LowerableHoods)
		
		target_actor.UnequipItem(equipped, prevent_equip, true)
		RemoveFromHand(target_actor)
		AttachToHip(target_actor)
	endif
endFunction

;;;; Local Script Helper Functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RegisterForAnnotationEvents
; Register To Animation Events for RTR annotations
; Annotations trigger IED node attachment and Gear Equipping/Unequipping at specific points during the animation
;
; @param Actor target_actor
function RegisterForAnnotationEvents(Actor target_actor)
	RegisterForAnimationEvent(target_actor, "RTR_SetTimeout")

	RegisterForAnimationEvent(target_actor, "RTR_Equip")
	RegisterForAnimationEvent(target_actor, "RTR_Unequip")

	; RegisterForAnimationEvent(target_actor, "RTR_AttachToHand")
	; RegisterForAnimationEvent(target_actor, "RTR_RemoveFromHand")

	RegisterForAnimationEvent(target_actor, "RTR_AttachToHip")
	RegisterForAnimationEvent(target_actor, "RTR_RemoveFromHip")

	RegisterForAnimationEvent(target_actor, "RTR_AttachLoweredHood")
	RegisterForAnimationEvent(target_actor, "RTR_RemoveLoweredHood")

	RegisterForAnimationEvent(target_actor, "RTR_OffsetStop")
endFunction

; RegisterManagedFollowers
; Registers followers for management that are close to the player
; In the current cell
function UpdateManagedFollowersList()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] UpdateManagedFollowersList --------------------------------------------------------------------")
	
	; ManagedFollowers
	Actor[] found_followers = ScanCellNPCs(PlayerRef, 500.0, RTR_Follower)
	
	int i = 0
	int foundCount = found_followers.Length
	while (i < foundCount)
	 	Actor followerActor = found_followers[i]
	 	if !ManagedActors.HasForm(followerActor)
			ManagedActors.AddForm(followerActor)
			RegisterForAnnotationEvents(followerActor)
			string followerActorName = followerActor.GetActorBase().GetName()
			RTR_PrintDebug("- Detected Follower: " + followerActorName)
		endIf
	 	i += 1
	endwhile
endFunction

function UnequipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] UnequipFollowerHeadgear --------------------------------------------------------------------")

	int i = 0 ; Includes PlayerRef at index 0
	int managedFollowerCount = ManagedActors.GetSize()
	while (i < managedFollowerCount)
		Actor followerActor = ManagedActors.GetAt(i) as Actor
		
		Form equipped = RTR_GetEquipped(followerActor, ManageCirclets.getValueInt() == 1)
		string followerActorName = followerActor.GetActorBase().GetName()
		if equipped
			RTR_PrintDebug("- Unequipping Follower Head Gear for: " + followerActorName)
			UnequipActorHeadgear(followerActor, equipped)
		else
			RTR_PrintDebug("- No Head Gear to Unequip for: " + followerActorName)
		endif
		
		i += 1 ; NEXT
	endwhile
	RTR_PrintDebug(" ")
endFunction

function EquipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	RTR_PrintDebug(" ")
	RTR_PrintDebug("[RTR] EquipFollowerHeadgear --------------------------------------------------------------------")

	int i = 0 ; Includes PlayerRef at index 0
	int managedFollowerCount = ManagedActors.GetSize()
	while (i < managedFollowerCount)
		Actor followerActor = ManagedActors.GetAt(i) as Actor
		
		Form last_equipped = RTR_GetLastEquipped(followerActor)
		string followerActorName = followerActor.GetActorBase().GetName()
		if last_equipped
			RTR_PrintDebug("- Unequipping Follower Head Gear for: " + followerActorName)
			EquipActorHeadgear(followerActor, last_equipped)
		else 
			RTR_PrintDebug("- No Head Gear to Equip for: " + followerActorName)
		endif
		
		i += 1 ; NEXT
	endwhile
	RTR_PrintDebug(" ")
endFunction

function setIEDNodeEnabled(Actor target_actor, String attachName, Bool enabled)
	Bool is_female = target_actor.GetActorBase().GetSex() == 1
	SetItemEnabledActor(target_actor, PluginName, attachName, is_female, enabled)
endFunction

function AttachToHip(Actor target_actor)
	setIEDNodeEnabled(target_actor, HelmetOnHip, true)
endFunction

function RemoveFromHip(Actor target_actor)
	setIEDNodeEnabled(target_actor, HelmetOnHip, false)
	Int i = 0
	Int loweredHoodsCount = LoweredHoods.GetSize()
	while (i < loweredHoodsCount)
		Form loweredHood = LoweredHoods.GetAt(i)
		if target_actor.IsEquipped(loweredHood) 
			target_actor.UnequipItem(loweredHood, false, true)
		endif
		i += 1
	endwhile
endFunction

function AttachToHand(Actor target_actor)
	setIEDNodeEnabled(target_actor, HelmetOnHand, true)
endFunction

function RemoveFromHand(Actor target_actor)
	setIEDNodeEnabled(target_actor, HelmetOnHand, false)
endFunction

function UseHelmet(Actor target_actor, Form helmet)
	String type = RTR_InferItemType(helmet, LowerableHoods)
	Bool is_female = target_actor.GetActorBase().GetSex() == 1
	SetItemFormActor(target_actor, PluginName, HelmetOnHip, is_female, helmet)
	SetItemFormActor(target_actor, PluginName, HelmetOnHand, is_female, helmet)
	if type == "Helmet"
		SetItemScaleActor(target_actor, PluginName, HelmetOnHand, is_female, HandScale)
	else
		SetItemScaleActor(target_actor, PluginName, HelmetOnHand, is_female, 1)
	endif
endFunction

; HipAnchor
; Returns the correct hip anchor for the actor's gender
;
; @param Bool is_female
; @return FormList
Form[] function HipAnchor(Bool is_female)
	if is_female 
		return FemaleHipAnchor.ToArray()
	endif
	return MaleHipAnchor.ToArray()
endFunction

; HandAnchor
; Returns the correct hand anchor for the actor's gender
;
; @param Bool is_female
; @return FormList;;
Form[] function HandAnchor(Bool is_female)
	if is_female 
		return FemaleHandAnchor.ToArray()
	endif
	return MaleHandAnchor.ToArray()
endFunction

; getAction
; Returns the correct action string for the animation event based on the RTR_Action
;
; @param int RTRAction
; @return String
String function getAction(int RTR_Active)
	String[] AnimationActionMap = new String[4]
	AnimationActionMap[0] = "None" ; None
	AnimationActionMap[1] = "Equip" ; Equip
	AnimationActionMap[2] = "Unequip" ; Unequip
	AnimationActionMap[3] = "EquipHood" ; Equip Lowerable Hood
	AnimationActionMap[4] = "UnequipHood" ; Unequip Lowerable Hood
	return AnimationActionMap[RTR_Active]
endFunction
