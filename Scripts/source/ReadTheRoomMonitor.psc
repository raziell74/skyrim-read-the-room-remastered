ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE
Import PO3_Events_Alias ; powerofthree's Papyrus Extender

Import ReadTheRoomUtil

; @todo Use the RTR_GlobalEnable
GlobalVariable property RTR_GlobalEnable auto

GlobalVariable property ToggleKey auto
GlobalVariable property DeleteKey auto
GlobalVariable property EnableKey auto

GlobalVariable[] property MaleHandAnchor auto
GlobalVariable[] property MaleHipAnchor auto
GlobalVariable[] property FemaleHandAnchor auto
GlobalVariable[] property FemaleHipAnchor auto

GlobalVariable property CombatEquip auto
GlobalVariable property CombatEquipAnimation auto
GlobalVariable property EquipWhenSafe auto
GlobalVariable property UnequipWhenUnsafe auto

GlobalVariable property ManageCirclets auto
GlobalVariable property ManageFollowers auto

GlobalVariable property RemoveHelmetWithoutArmor auto

FormList property SafeKeywords auto
FormList property HostileKeywords auto

FormList property LowerableHoods auto
FormList property LoweredHoods auto

Perk property ReadTheRoomPerk auto

; @todo Add more keywords that are used in string form
Keyword property RTR_Follower auto

Actor property PlayerRef auto

String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String HipNode = "NPC Pelvis [Pelv]"
String HandNode = "NPC R Hand [RHnd]"
Float HipScale = 0.9150
Float HandScale = 1.05

String MostRecentLocationAction = "None"

Event OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

Event OnKeyDown(Int KeyCode)
	; Prevent keypresses from being registered if in menu mode or text input mode (console)
	if Utility.IsInMenuMode() || ui.IsTextInputEnabled()
		return
	endif

	; Toggle Read the Room
	if KeyCode == EnableKey.GetValueInt()
		if PlayerRef.hasperk(ReadTheRoomPerk)
			PlayerRef.removeperk(ReadTheRoomPerk)
		else
			PlayerRef.addperk(ReadTheRoomPerk)
		endif
	endif

	; Manually Toggle Head Gear
	if KeyCode == ToggleKey.GetValueInt()
		Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
		Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
		
		if is_valid
			UnequipActorHeadgear(PlayerRef, equipped)
		else
			Form last_equipped = RTR_GetLastEquipped(PlayerRef)
			EquipActorHeadgear(PlayerRef, last_equipped)
		endif

		; Make Absolutely sure we've cleared our hand node
		RTR_Detatch(PlayerRef, HelmetOnHand)

		; @todo Implement Follower Headwear Management [Experimental]
		; if ManageFollowers.GetValueInt() == 1
		; 	Actor[] followers = ScanCellNPCs(PlayerRef, 150.0, RTR_Follower)
			
		; 	; @DEBUG List the followers
		; 	int followerIndex = 0
		; 	while (followerIndex < followers.Length)
		; 		Actor followerActor = followers[followerIndex]
		; 		string followerActorName = followerActor.GetBaseObject().GetName()
		; 		Debug.Notification("RTR Detected Follower: " + followerActorName)

		; 		; increment through
		; 		followerIndex += 1
		; 	endwhile
		; endif
	endif

	; Force clear attachment nodes
	if KeyCode == DeleteKey.GetValueInt()
		RTR_DetatchAll()
		; TargetActor.UnequipItem(LoweredLastEquippedHood)
	endif
EndEvent

; @todo Test to see if this will need "debounce" logic for when rapidly changing Locations
Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	Form equipped = RTR_GetEquipped(PlayerRef, ManageCirclets.getValueInt() == 1)
	Bool is_valid = RTR_IsValidHeadWear(PlayerRef, equipped, LoweredHoods)
	Bool equip_when_safe = EquipWhenSafe.getValueInt() == 1
	Bool unequip_when_unsafe = UnequipWhenUnsafe.getValueInt() == 1
	
	; Update the MostRecentLocationAction
	MostRecentLocationAction = RTR_GetLocationAction(akNewLoc, is_valid, equip_when_safe, unequip_when_unsafe, SafeKeywords, HostileKeywords)

	if MostRecentLocationAction == "Equip"
		Form last_equipped = RTR_GetLastEquipped(PlayerRef)
		EquipActorHeadgear(PlayerRef, last_equipped)
	elseif MostRecentLocationAction == "Unequip"
		UnequipActorHeadgear(PlayerRef, equipped)
	endif
EndEvent

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

; @todo refactor duplicated logic from EquipActorHeadgear and UnequipActorHeadgear
Function EquipActorHeadgear(Actor target_actor, Form last_equipped)
	; Exit early if the actor is already wearing the item
	if target_actor.IsEquipped(last_equipped)
		RTR_DetatchAllActor(target_actor)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		if CombatEquip.GetValueInt() == 0
			return
		endif

		; Equip with no animation
		if CombatEquipAnimation.getValueInt() == 0
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
		
		; Force equip with no animation
		EquipWithNoAnimation(target_actor, last_equipped)
		return
	endif

	; Animated Equip
	bool was_drawn = false
	bool was_first_person = false

	; If weapon is drawn, sheath it
	if target_actor.IsWeaponDrawn()
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		was_drawn = true
		while target_actor.GetAnimationVariableInt("IsUnequipping") == 1
			utility.wait(0.01)
		endwhile
	endif

	; If actor is in first person, force third person
	if target_actor.GetAnimationVariableInt("i1stPerson") == 1 
		Game.ForceThirdPerson()
		was_first_person = true
	endif

	String animation = "RTREquip"
	Float animation_time = 3.3
	Bool is_hood = LowerableHoods.hasForm(last_equipped)

	; Register for animation events
	; These are needed for the animation annotations used in the animation to queue needed functions
	if is_hood
		animation = "RTREquipHood"
		animation_time = 1.0
		RegisterForAnimationEvent(target_actor, "RTR.Hood.Equip.Start")
		RegisterForAnimationEvent(target_actor, "RTR.Hood.Equip.End")
	else
		RegisterForAnimationEvent(target_actor, "RTR.Equip.Start")
		RegisterForAnimationEvent(target_actor, "RTR.Equip.Attach")
		RegisterForAnimationEvent(target_actor, "RTR.Equip.End")
	endif

	; Play the equip animation
	Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
	Debug.sendAnimationEvent(target_actor, animation)
	Utility.wait(animation_time)

	; End equip animation
	Debug.sendAnimationEvent(target_actor, "OffsetStop")
	Game.EnablePlayerControls()

	; If actor was drawn, redraw weapon
	if was_drawn
		target_actor.DrawWeapon()
		while target_actor.GetAnimationVariableInt("IsEquipping") == 1
			utility.wait(0.01)
		endwhile
	endif

	; If actor was in first person, return to first person
	if was_first_person
		Game.ForceFirstPerson()
	endif

	; Check attachment node accuracy. Just in case the animation was interrupted
	RTR_Detatch(target_actor, HelmetOnHand)
	if RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
		EquipWithNoAnimation(target_actor, last_equipped)
	endif
EndFunction

Function UnequipWithNoAnimation(Actor target_actor, Form equipped)
	; Prevent game from re-equipping the helmet if actor is an NPC
	Bool prevent_equip = target_actor != PlayerRef
	String equipped_type = RTR_InferItemType(equipped, LowerableHoods)

	if equipped_type == "Hood"
		Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(equipped))
		target_actor.UnequipItem(equipped, false, true)
		target_actor.EquipItem(lowered_hood, prevent_equip, true)
	else
		String last_equipped_type = RTR_InferItemType(equipped, LowerableHoods)
		Bool is_female = target_actor.GetActorBase().getSex() == 1
		GlobalVariable[] hip_anchor = new GlobalVariable[12]
		if is_female 
			hip_anchor = FemaleHipAnchor
		else
			hip_anchor = MaleHipAnchor
		endif
		
		target_actor.UnequipItem(equipped, prevent_equip, true)
		RTR_Detatch(target_actor, HelmetOnHand)
		RTR_Attach(target_actor, HelmetOnHip, equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
	endif
endFunction

Function UnequipActorHeadgear(Actor target_actor, Form equipped)
	; Exit early if the actor is not wearing the item
	if !target_actor.IsEquipped(equipped)
		RTR_Detatch(target_actor, HelmetOnHand)
		return
	endif

	; Combat State Unequip
	if target_actor.GetCombatState() == 1
		if CombatEquip.GetValueInt() == 0
			return
		endif

		; Unequip with no animation
		if CombatEquipAnimation.getValueInt() == 0
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
		
		; Force unequip with no animation
		UnequipWithNoAnimation(target_actor, equipped)
		return
	endif

	; Animated Unequip
	bool was_drawn = false
	bool was_first_person = false

	; If weapon is drawn, sheath it
	if target_actor.IsWeaponDrawn()
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		was_drawn = true
		while target_actor.GetAnimationVariableInt("IsUnequipping") == 1
			utility.wait(0.01)
		endwhile
	endif

	; If actor is in first person, force third person
	if target_actor.GetAnimationVariableInt("i1stPerson") == 1 
		Game.ForceThirdPerson()
		was_first_person = true
	endif

	String animation = "RTRUnequip"
	Float animation_time = 3.25
	Bool is_hood = LowerableHoods.hasForm(equipped)

	; Register for animation events
	; These are needed for the animation annotations used in the animation to queue needed functions
	if is_hood
		animation = "RTRHoodUnequip"
		animation_time = 1.0
		RegisterForAnimationEvent(target_actor, "RTR.Hood.Unequip.Start")
		RegisterForAnimationEvent(target_actor, "RTR.Hood.Unequip.End")
	else
		RegisterForAnimationEvent(target_actor, "RTR.Unequip.Start")
		RegisterForAnimationEvent(target_actor, "RTR.Unequip.Attach")
		RegisterForAnimationEvent(target_actor, "RTR.Unequip.End")
	endif

	; Play the unequip animation
	Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
	Debug.sendAnimationEvent(target_actor, animation)
	Utility.wait(animation_time)

	; End unequip animation
	Debug.sendAnimationEvent(target_actor, "OffsetStop")
	Game.EnablePlayerControls()

	; If actor was drawn, redraw weapon
	if was_drawn
		target_actor.DrawWeapon()
		while target_actor.GetAnimationVariableInt("IsEquipping") == 1
			utility.wait(0.01)
		endwhile
	endif

	; If actor was in first person, return to first person
	if was_first_person
		Game.ForceFirstPerson()
	endif

	; Check attachment node accuracy. Just in case the animation was interrupted
	RTR_Detatch(target_actor, HelmetOnHand)
	if !RTR_IsAttached(target_actor, HelmetOnHip, target_actor.GetActorBase().getSex())
		UnequipWithNoAnimation(target_actor, equipped)
	endif
EndFunction

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	Actor target_actor = akSource as Actor
	Form last_equipped = RTR_GetLastEquipped(target_actor)

	; Exit early if last_equipped isn't a valid Helmet, Hood, or Circlet
	if !RTR_IsValidHeadWear(target_actor, last_equipped, LoweredHoods)
		return
	endif

	; Determine hip/hand Anchors by gender 
	GlobalVariable[] hip_anchor = new GlobalVariable[12]
	GlobalVariable[] hand_anchor = new GlobalVariable[12]

	Bool is_female = target_actor.GetActorBase().GetSex() == 1
	if is_female 
		hip_anchor = FemaleHipAnchor
		hand_anchor = FemaleHandAnchor 
	else
		hip_anchor = MaleHipAnchor
		hand_anchor = MaleHandAnchor
	endif

	String last_equipped_type = RTR_InferItemType(last_equipped, LowerableHoods)

	if last_equipped_type == "None"
		return
	endif

	; Prevent game from re-equipping the helmet if actor is an NPC
	Bool prevent_equip = target_actor != PlayerRef

	; Helmet/Circlet Equip
	if asEventName == "RTR.Equip.Start"
		RTR_Detatch(target_actor, HelmetOnHip)
		RTR_Attach(target_actor, HelmetOnHand, last_equipped, last_equipped_type, HandScale, HandNode, is_female, hand_anchor)
	elseif asEventName == "RTR.Equip.Attach"
		target_actor.EquipItem(last_equipped, false, true)
		RTR_Detatch(target_actor, HelmetOnHand)
	elseif asEventName == "RTR.Equip.End"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	; Helmet/Circlet Unequip
	if asEventName == "RTR.Unequip.Start"
		RTR_Attach(target_actor, HelmetOnHand, last_equipped, last_equipped_type, HandScale, HandNode, is_female, hand_anchor)
		target_actor.UnequipItem(last_equipped, prevent_equip, true)
	elseif asEventName == "RTR.Unequip.Attach"
		RTR_Attach(target_actor, HelmetOnHip, last_equipped, last_equipped_type, HipScale, HipNode, is_female, hip_anchor)
		RTR_Detatch(target_actor, HelmetOnHand)
	elseif asEventName == "RTR.Unequip.End"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	; Hood Equip
	; @TODO Should be switched to IED attach/detatch lowered hood Form instead physically eqiupping the item
	if asEventName == "RTR.Hood.Equip.Start"
		if LowerableHoods.HasForm(last_equipped)
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(lowered_hood, false, true)
			target_actor.RemoveItem(lowered_hood, 1, true)
		endif

		target_actor.EquipItem(last_equipped, false, true)
	elseif asEventName == "RTR.Hood.Equip.End"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif

	; Hood Unequip
	; @TODO Should be switched to IED attach/detatch lowered hood Form instead physically eqiupping the item
	if asEventName == "RTR.Hood.Unequip.Start"
		if LowerableHoods.HasForm(last_equipped)
			Form lowered_hood = LoweredHoods.GetAt(LowerableHoods.Find(last_equipped))
			target_actor.UnequipItem(last_equipped, false, true)
			target_actor.EquipItem(lowered_hood, prevent_equip, true)
		Else
			target_actor.UnequipItem(last_equipped, prevent_equip, true)
		endif
	elseif asEventName == "RTR.Hood.Unequip.End"
		Debug.sendAnimationEvent(target_actor, "OffsetStop")
	endif
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if RTR_IsValidHeadWear(target_actor, akBaseObject, LoweredHoods)
		RTR_Detatch(target_actor, HelmetOnHip)
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	Actor target_actor = akReference as Actor
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !RTR_IsTorsoEquipped(target_actor))
		RTR_DetatchAllActor(target_actor)
	endif
	RTR_Detatch(target_actor, HelmetOnHand)
EndEvent 

Event OnRaceSwitchComplete()
	RTR_DetatchAllActor(PlayerRef)
EndEvent
