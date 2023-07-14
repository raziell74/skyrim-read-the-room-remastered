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
String MostRecentLocationAction = "None"
String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String HipNode = "NPC Pelvis [Pelv]"
String HandNode = "NPC R Hand [RHnd]"
Float HipScale = 0.9150
Float HandScale = 1.05
Float AnimTimeoutBuffer = 0.5

Event OnInit()
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

;;;; Event Handlers ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
		MiscUtil.PrintConsole("[RTR] DEBUG --------------------------------------------------------------------")
		Form male_hand_anchor_posX = MaleHandAnchor.GetAt(0)
		GlobalVariable male_hand_anchor_posXGV = male_hand_anchor_posX as GlobalVariable
		Float male_hand_anchor_posX_Value = male_hand_anchor_posXGV.GetValue()
		MiscUtil.PrintConsole("[RTR] DEBUG: MaleHandAnchor.GetAt(0) returned Form As String " + (male_hand_anchor_posX as String))
		MiscUtil.PrintConsole("[RTR] DEBUG: GV MaleHandAnchorPosX value" + male_hand_anchor_posX_Value)
		MiscUtil.PrintConsole("[RTR] DEBUG: GV MaleHandAnchorPosX value as string" + male_hand_anchor_posX_Value)

		MiscUtil.PrintConsole(" ")
		MiscUtil.PrintConsole(" ")
		MiscUtil.PrintConsole("[RTR] Toggle --------------------------------------------------------------------")
		Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)

		UpdateManagedFollowersList()
		
		if is_valid
			UnequipActorHeadgear(PlayerRef, equipped)
		else
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		endif

		; Make Absolutely sure we've cleared our hand node
		RTR_Detatch(PlayerRef, HelmetOnHand)
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RTR_DetatchAll()
	endif
EndEvent

; OnLocationChange Event Handler
; Updates locational triggers/actions
;
; Records Most Recent Location Action
; Equips/Unequips based off of Config Settings
; @todo Test to see if we need "debounce" logic for when rapidly changing Locations
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
	
	; Update the MostRecentLocationAction
	MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)
	UpdateManagedFollowersList()

	if MostRecentLocationAction == "Equip"
		Form last_equipped = RTR_GetLastEquipped(PlayerRef)
		EquipActorHeadgear(PlayerRef, last_equipped)
	elseif MostRecentLocationAction == "Unequip"
		UnequipActorHeadgear(PlayerRef, equipped)
	endif
EndEvent

; OnCombatStateChanged Event Handler
; Toggles Headgear based off Players Combat State
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if akTarget == PlayerRef && CombatEquip.GetValueInt() == 1
		if aeCombatState == 1
			; Player entered combat
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		elseif aeCombatState == 0
			; Player left combat
			if MostRecentLocationAction == "Unequip"
				Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
				UnequipActorHeadgear(PlayerRef, equipped)
			endif
		endIf
	endIf

	if CombatEquip.GetValueInt() == 1 && aeCombatState == 2
		; Someone is looking for the player
		; @todo Implement
	endif
endEvent

; OnAnimationEvent Event Handler
; Applys IED node attachments and head gear equipping for RTR annotated animations
Event OnAnimationEvent(ObjectReference akSource, String asEventName)
	MiscUtil.PrintConsole(" ")
	MiscUtil.PrintConsole("[RTR] Animation Event: " + asEventName + " --------------------------------------------------------------------")

	Actor target_actor = akSource as Actor
	bool is_player = target_actor == PlayerRef
	Bool prevent_equip = !is_player
	Bool is_female = target_actor.GetActorBase().GetSex() == 1

	; FormList should be in esp so that it can be stored in save
	Form last_equipped = RTR_GetLastEquipped(target_actor)
	if !RTR_IsValidHeadWear(target_actor, last_equipped, LoweredHoods)
		return ; Exit early if last_equipped isn't a valid Helmet, Hood, or Circlet
	endif

	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)
	if last_equipped_type == "None"
		return ; Exit early if we can't infer the item type
	endif

	FormList hip_anchor = HipAnchor(is_female)
	FormList hand_anchor = HandAnchor(is_female)

	; RTR Event Handlers
	; @todo Pass to an RTR Action Delegate?

	if asEventName == "RTR_Equip"
		; Equip Headgear
		target_actor.EquipItem(last_equipped, false, true)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Equipped")
		return
	endif

	if asEventName == "RTR_Unequip"
		; Unequip Headgear
		target_actor.UnequipItem(last_equipped, prevent_equip, true)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Unequipped")
		return
	endif

	; @todo move IED attachments to IED.SetItemAnimationEventEnabledActor
	if asEventName == "RTR_AttachToHand"
		; Attach to Hand
		RTR_Attach(target_actor, HelmetOnHand, last_equipped, last_equipped_type, HandScale, HandNode, is_female, hand_anchor)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Attached to hand ")
		return
	endif

	if asEventName == "RTR_RemoveFromHand"
		; Remove from Hand
		RTR_Detatch(target_actor, HelmetOnHand)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Removed from hand")
		return
	endif

	if asEventName == "RTR_AttachToHip"
		; Attach to Hip
		RTR_Attach(target_actor, HelmetOnHip, last_equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Attached to Hip")
		return
	endif

	if asEventName == "RTR_RemoveFromHip"
		; Remove from Hip
		RTR_Detatch(target_actor, HelmetOnHip)
		MiscUtil.PrintConsole("- " + (last_equipped as Armor).GetName() + " Removed from Hip")
		return
	endif

	if asEventName == "RTR_AttachLoweredHood"
		; Attach Lowered Hood
		if LowerableHoods.HasForm(last_equipped)
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.EquipItem(lowered_hood, prevent_equip, true)
			MiscUtil.PrintConsole("- " + (lowered_hood as Armor).GetName() + " (Lowered Hood) Equipped")
		endif
		return
	endif

	if asEventName == "RTR_RemoveLoweredHood"
		; Remove Lowered Hood
		if LowerableHoods.HasForm(last_equipped) 
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(lowered_hood, false, true)
			target_actor.RemoveItem(lowered_hood, 1, true)
			MiscUtil.PrintConsole("- " + (lowered_hood as Armor).GetName() + " (Lowered Hood) Unequipped")
		endif
		return
	endif

	if asEventName == "RTR_OffsetStop"
		; Stop Offset
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
		MiscUtil.PrintConsole("- Animation Finished. OffsetStop Animation Event Sent")
		return
	endif

	; RTR_SetTimeout waits for animation to completely finish and then does post animation actions
	if asEventName == "RTR_SetTimeout"
		Float timeout = target_actor.GetAnimationVariableFloat("RTR_Timeout")
		MiscUtil.PrintConsole("- Animation Ends in " + timeout + " seconds")

		; Disable certain controls for the player
		if is_player
			Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		endif

		Utility.wait(timeout + AnimTimeoutBuffer)
		MiscUtil.PrintConsole(" ")
		MiscUtil.PrintConsole("[RTR] OnAnimationEvent: Timeout Finished --------------------------------------------------------------------")
		String anim_action = getAction(target_actor.GetAnimationVariableInt("RTR_Action"))

		; Check if the animation completed successfully or if it was interuppted
		if anim_action == "None"
			MiscUtil.PrintConsole("- RTR Action completed successfully")
		elseif anim_action == "Equip"
			MiscUtil.PrintConsole("- Timed Out on Equip")
			; Finalize Equip
			target_actor.EquipItem(last_equipped, false, true)
			RTR_Detatch(target_actor, HelmetOnHand)
			RTR_Detatch(target_actor, HelmetOnHip)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "Unequip"
			MiscUtil.PrintConsole("- Timed Out on Unequip")
			; Finalize Unequip
			target_actor.UnequipItem(last_equipped, prevent_equip, true)
			RTR_Detatch(target_actor, HelmetOnHand)
			RTR_Attach(target_actor, HelmetOnHip, last_equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "EquipHood"
			MiscUtil.PrintConsole("- Timed Out on EquipHood")
			; Finalize EquipHood
			if LowerableHoods.HasForm(last_equipped) 
				Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
				target_actor.UnequipItem(lowered_hood, false, true)
				target_actor.RemoveItem(lowered_hood, 1, true)
			endif
			target_actor.EquipItem(last_equipped, false, true)
			Debug.sendAnimationEvent(target_actor, "OffsetStop")
		elseif anim_action == "UnequipHood"
			MiscUtil.PrintConsole("- Timed Out on UnequipHood")
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
			
			MiscUtil.PrintConsole("- CLEANUP - Enabling Player Controls")
			Game.EnablePlayerControls()

			if draw_weapon
				MiscUtil.PrintConsole("- CLEANUP - Drawing Weapon")
				target_actor.DrawWeapon()
				target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", false)
			endif

			if return_to_first_person
				MiscUtil.PrintConsole("- CLEANUP - Returning to First Person")
				Game.ForceFirstPerson()
				target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", false)
			endif
		endif

		; Clear RTR_Action
		MiscUtil.PrintConsole("- CLEANUP - Clearing RTR_Action")
		target_actor.SetAnimationVariableInt("RTR_Action", 0)
	endif
EndEvent

; OnObjectEquipped Event Handler
; Detatching last equipped head gear from hip and hand
Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if RTR_IsValidHeadWear(target_actor, akBaseObject, LoweredHoods)
		RTR_Detatch(target_actor, HelmetOnHip)
		
		; remove any lowered hoods from actor
		int i = 0
		int loweredHoodsCount = LoweredHoods.GetSize()
		while (i < loweredHoodsCount)
			Form lowered_hood = LoweredHoods.GetAt(i)
			if target_actor.IsEquipped(lowered_hood)
				target_actor.UnequipItem(lowered_hood, false, true)
				target_actor.RemoveItem(lowered_hood, 1, true)
			endif
			i += 1
		endwhile
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent

; OnObjectUnequipped Event Handler
Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(target_actor))
		RTR_DetatchAllActor(target_actor)

		; remove any lowered hoods from actor
		int i = 0
		int LoweredHoodsCount = LoweredHoods.GetSize()
		while i < LoweredHoodsCount
			Form lowered_hood = LoweredHoods.GetAt(i)
			if target_actor.IsEquipped(lowered_hood)
				target_actor.UnequipItem(lowered_hood, false, true)
				target_actor.RemoveItem(lowered_hood, 1, true)
			endif
			i += 1
		endwhile
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent 

; OnRaceSwitchComplete Event Handler
Event OnRaceSwitchComplete()
	RTR_DetatchAllActor(PlayerRef)
EndEvent

;;;; Action functions ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; EquipActorHeadgear
; Triggers equipping head gear to an actor
; 
; @param Actor target_actor
; @param Form last_equipped
Function EquipActorHeadgear(Actor target_actor, Form last_equipped)
	MiscUtil.PrintConsole(" ")
	MiscUtil.PrintConsole("[RTR] EquipActorHeadgear --------------------------------------------------------------------")
	Int RTR_InAction = target_actor.GetAnimationVariableInt("RTR_Active")
	if RTR_InAction > 0
		MiscUtil.PrintConsole("- RTR_Active " + getAction(RTR_InAction))
		return
	endif

	; Exit early if the actor is already wearing the item
	if target_actor.IsEquipped(last_equipped)
		MiscUtil.PrintConsole("- Exiting because item " + (last_equipped as Armor).GetName() + " is already equipped")
		RTR_DetatchAllActor(target_actor)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		MiscUtil.PrintConsole("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquip is disabled")
			return
		endif

		MiscUtil.PrintConsole("- CombatEquip is enabled")

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquipAnimation is disabled. Equipping with no animation")
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
		
		MiscUtil.PrintConsole("- Actor can't be animated. Unequipping with no animation")
		; Force equip with no animation
		EquipWithNoAnimation(target_actor, last_equipped)
		return
	endif

	; Animated Equip
	RegisterForAnnotationEvents(target_actor)
	String animation = "RTREquip"

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(last_equipped)
		animation = "RTREquipHood"
		MiscUtil.PrintConsole("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	if target_actor == PlayerRef
		MiscUtil.PrintConsole("- Setting player RTR_RedrawWeapons to " + was_drawn)
		target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
		MiscUtil.PrintConsole("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
		target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)
	endif

	MiscUtil.PrintConsole("- Triggering " + animation + " animation")
	Debug.sendAnimationEvent(target_actor, animation)

	; Check attachment node accuracy...
	; Just in case the animation was interrupted
	; RTR_Detatch(target_actor, HelmetOnHand)
	; if RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
	; 	EquipWithNoAnimation(target_actor, last_equipped)
	; endif
	; Commetting out for now. Should work with out it

	; [Experimental] Will not do anything unless follower support is enabled
	EquipFollowerHeadgear()
EndFunction

; EquipWithNoAnimation
; Equips an item to an actor without playing an animation
;
; @param Actor target_actor
; @param Form last_equipped
Function EquipWithNoAnimation(Actor target_actor, Form last_equipped)
	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)

	if last_equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
		target_actor.UnequipItem(lowered_hood, false, true)
		target_actor.EquipItem(last_equipped, false, true)
	else
		target_actor.EquipItem(last_equipped, false, true)
		RTR_DetatchAllActor(target_actor)
	endif
endFunction

; UnequipActorHeadgear
; Triggers unequipping head gear from an actor
;
; @param Actor target_actor
; @param Form equipped
Function UnequipActorHeadgear(Actor target_actor, Form equipped)
	MiscUtil.PrintConsole(" ")
	MiscUtil.PrintConsole("[RTR] UnequipActorHeadgear --------------------------------------------------------------------")
	Int RTR_InAction = target_actor.GetAnimationVariableInt("RTR_Active")
	if RTR_InAction > 0
		MiscUtil.PrintConsole("- RTR_Active " + getAction(RTR_InAction))
		return
	endif

	; Exit early if the actor is not wearing the item
	if !target_actor.IsEquipped(equipped)
		MiscUtil.PrintConsole("- Exiting because item " + (equipped as Armor).GetName() + " is not equipped")
		RTR_Detatch(target_actor, HelmetOnHand)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		MiscUtil.PrintConsole("- Actor is in combat")
		if CombatEquip.GetValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquip is disabled")
			return
		endif

		MiscUtil.PrintConsole("- CombatEquip is enabled")

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
			MiscUtil.PrintConsole("- CombatEquipAnimation is disabled. Unequipping with no animation")
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
		
		MiscUtil.PrintConsole("- Actor can't be animated. Unequipping with no animation")
		; Force unequip with no animation
		UnequipWithNoAnimation(target_actor, equipped)
		return
	endif

	; Animated Unequip
	RegisterForAnnotationEvents(target_actor)
	String animation = "RTRUnequip"

	; Switch animation if equipping a lowerable hood
	if LowerableHoods.hasForm(equipped)
		animation = "RTRUnequipHood"
		MiscUtil.PrintConsole("- Lowerable Hood Detected. Switching animation to " + animation)
	endif

	Bool was_drawn = RTR_SheathWeapon(target_actor)
	Bool was_first_person = RTR_ForceThirdPerson(target_actor)

	if target_actor == PlayerRef
		MiscUtil.PrintConsole("- Setting player RTR_RedrawWeapons to " + was_drawn)
		target_actor.SetAnimationVariableBool("RTR_RedrawWeapons", was_drawn)
		MiscUtil.PrintConsole("- Setting player RTR_ReturnToFirstPerson to " + was_first_person)
		target_actor.SetAnimationVariableBool("RTR_ReturnToFirstPerson", was_first_person)
	endif

	MiscUtil.PrintConsole("- Triggering " + animation + " animation")
	Debug.sendAnimationEvent(target_actor, animation)

	; Check attachment node accuracy...
	; Just in case the animation was interrupted
	; RTR_Detatch(target_actor, HelmetOnHand)
	; if !RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
	; 	UnequipWithNoAnimation(target_actor, equipped)
	; endif
	; Commetting out for now. Should work with out it

	; [Experimental] Will not do anything unless follower support is enabled
	UnequipFollowerHeadgear()
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

	if equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(equipped))
		target_actor.UnequipItem(equipped, false, true)
		target_actor.EquipItem(lowered_hood, prevent_equip, true)
	else
		String last_equipped_type = RTR_InferItemType(equipped, LowerableHoods)
		Bool is_female = target_actor.GetActorBase().getSex() == 1
		FormList hip_anchor = HipAnchor(is_female)
		
		target_actor.UnequipItem(equipped, prevent_equip, true)
		RTR_Detatch(target_actor, HelmetOnHand)
		RTR_Attach(target_actor, HelmetOnHip, equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
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

	RegisterForAnimationEvent(target_actor, "RTR_AttachToHand")
	RegisterForAnimationEvent(target_actor, "RTR_RemoveFromHand")

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

	; ManagedFollowers
	; Actor[] found_followers = ScanCellNPCs(PlayerRef, 500.0, RTR_Follower)
	
	; int i = 0
	; int managedFollowerCount = ManagedFollowers.GetSize()
	; while (i < managedFollowerCount)
	; 	Actor followerActor = ManagedFollowers.GetAt(i) as Actor
	; 	ManagedFollowers.AddForm(followerActor)
	; 	; @DEBUG Output Current Managed Followers
	; 	string followerActorName = followerActor.GetActorBase().GetName()
	; 	Debug.Notification("RTR Detected Follower: " + followerActorName)
	; 	i += 1
	; endwhile
endFunction

function UnequipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif

	; int i = 0
	; int managedFollowerCount = ManagedFollowers.GetSize()
	; while (i < managedFollowerCount)
	; 	Actor follower = ManagedFollowers.GetAt(i) as Actor
	; 	Form equipped = RTR_GetEquipped(follower, ManageCirclets.getValueInt() == 1)
	; 	Bool is_valid = RTR_IsValidHeadWear(follower, equipped, LoweredHoods)
		
	; 	if is_valid
	; 		UnequipActorHeadgear(follower, equipped)
	; 	endif

	; 	; Make Absolutely sure their hand nodes are clear
	; 	RTR_Detatch(follower, HelmetOnHand)
	; 	i += 1 ; NEXT
	; endwhile
endFunction

function EquipFollowerHeadgear()
	if ManageFollowers.GetValueInt() == 0
		return
	endif
	
	; int i = 0
	; int managedFollowerCount = ManagedFollowers.GetSize()
	; while (i < managedFollowerCount)
	; 	Actor follower = ManagedFollowers.GetAt(i) as Actor
	; 	Form last_equipped = RTR_GetLastEquipped(follower)
	; 	Bool is_valid = RTR_IsValidHeadWear(follower, last_equipped, LoweredHoods)
		
	; 	if is_valid
	; 		EquipActorHeadgear(follower, last_equipped)
	; 	endif

	; 	; Make Absolutely sure their hand nodes are clear
	; 	RTR_Detatch(follower, HelmetOnHand)
	; 	i += 1 ; NEXT
	; endwhile
endFunction

; HipAnchor
; Returns the correct hip anchor for the actor's gender
;
; @param Bool is_female
; @return FormList
FormList function HipAnchor(Bool is_female)
	if is_female 
		return FemaleHipAnchor
	endif
	return MaleHipAnchor
endFunction

; HandAnchor
; Returns the correct hand anchor for the actor's gender
;
; @param Bool is_female
; @return FormList
FormList function HandAnchor(Bool is_female)
	if is_female 
		return FemaleHandAnchor
	endif
	return MaleHandAnchor
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
