ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

Import IED 
Import ReadTheRoomUtil
; Import PO3_Events_Alias
; Import MiscUtil

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

MagicEffect property RTR_CombatEffect auto
Perk property ReadTheRoomPerk auto

Keyword property RTR_Follower auto

Actor property PlayerRef auto
Actor TargetActor

Bool HelmetEquipped = false
Bool HelmetWasEquipped = false
Bool Status
Bool InventoryRequired = true
Bool IsFemale = false
Bool DismountIsEquip = false
Bool EquipAnimation = false
Bool UnequipAnimation = false
Bool WasDrawn = false
Bool WasToggle = false
Bool Active = false
Bool WasFirstPerson = false
Bool LowerHood = false
String plugin = "ReadTheRoom.esp"
String hip_name = "HelmetOnHip"
String hand_name = "HelmetOnHand"
String HelmetOnHip = "HelmetOnHip"
String HelmetOnHand = "HelmetOnHand"
String hip_node = "NPC Pelvis [Pelv]"
String hand_node = "NPC R Hand [RHnd]"
String LastEquippedType = "None"
Float hip_scale = 0.9150
Float hand_scale = 1.05

Form LastEquippedHelmet
Form LastEquippedHood
Form LoweredLastEquippedHood

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	; RTR Active Gate Check
	if !Active
		return
	endif

	; Type cast our reference source
	Actor target_actor = akSource as Actor
	bool is_female = target_actor.GetActorBase().GetSex() == 1

	; RTR Actor Gate Check
	; @TODO Check target_actor against followers as well as player
	if target_actor != PlayerRef || target_actor.GetActorBase().HasKeyword(RTR_Follower)
		return
	endif

	; Get Last Equipped Head Wear
	if LastEquippedType == "Helmet"
		LastEquippedHelmet = GetLastEquippedForm(target_actor, 1, true, false)
		if LastEquippedHelmet as String == "None"
			LastEquippedHelmet = GetLastEquippedForm(target_actor, 0, true, false)
		endif
	elseif LastEquippedType == "Circlet"
		LastEquippedHelmet = GetLastEquippedForm(target_actor, 12, true, false)
	endif

	; Exit early if LastEquippedHelmet isn't valid hear wear
	if !RTR_IsValidHeadWear(LastEquippedHelmet)
		return
	endif

	; Double check LastEquippedType accuracy for hoods
	if LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
		LastEquippedType = "Hood"
	endif

	; Determine hip/hand Anchors by gender 
	GlobalVariable[] hip_anchor = new GlobalVariable[12]
	GlobalVariable[] hand_anchor = new GlobalVariable[12]

	if is_female 
		hip_anchor = FemaleHipAnchor
		hand_anchor = FemaleHandAnchor 
	else
		hip_anchor = MaleHipAnchor
		hand_anchor = MaleHandAnchor
	endif

	; Prevent game from re-equipping the helmet if actor is an NPC
	bool prevent_equip = target_actor != PlayerRef
	
	if UnequipAnimation
		; Enable helmet on hand during unequip animation
		if asEventName == "SoundPlay.NPCHumanCombatIdleA" ; Anim Start Annotation
			RTR_Attach(target_actor, HelmetOnHand, LastEquippedHelmet, LastEquippedType, hand_scale, hand_node, is_female, hand_anchor)
			target_actor.UnequipItem(LastEquippedHelmet, prevent_equip, true)
		endif

		; Enable Helmet on hip, disable helmet on hand
		if asEventName == "SoundPlay.NPCHumanCombatIdleB" ; Anim Attach Annotation
			if LastEquippedType != "Hood"
				; Place helmet/circlet on hip
				RTR_Attach(target_actor, HelmetOnHip, LastEquippedHelmet, LastEquippedType, hip_scale, hip_node, is_female, hip_anchor)
				RTR_Detatch(target_actor, HelmetOnHand)
			else
				; Skip hip placement for hoods and equip lowered version of hood instead
				; @TODO Should be using IED attachment instead of physically equipping the item so it is consistent with other helmets
				target_actor.UnequipItem(LastEquippedHood, false, true)
				target_actor.EquipItem(LoweredLastEquippedHood, prevent_equip, true)
			endif
		endif

		if asEventName == "SoundPlay.NPCHumanCombatIdleC" ; Anim End Annotation
			debug.sendAnimationEvent(target_actor, "OffsetStop")
		endif
	elseif EquipAnimation
		if asEventName == "SoundPlay.NPCHumanCombatIdleA" ; Anim Start Annotation
			RTR_Detatch(target_actor, HelmetOnHip)
			RTR_Attach(target_actor, HelmetOnHand, LastEquippedHelmet, LastEquippedType, hand_scale, hand_node, is_female, hand_anchor)
		endif

		if asEventName == "SoundPlay.NPCHumanCombatIdleB" ; Anim Attach Annotation
			if LastEquippedType != "Hood"
				; Equip Helmet
				target_actor.EquipItem(LastEquippedHelmet, false, true)
				RTR_Detatch(target_actor, HelmetOnHand)
			else
				; Equip Hood
				; @TODO Should be switched to IED detatch of lowered hood instead physically eqiupping the item
				target_actor.UnequipItem(LoweredLastEquippedHood, false, true)
				target_actor.RemoveItem(LoweredLastEquippedHood, 1, true)
				target_actor.EquipItem(LastEquippedHood, false, true)
			endif
		endif

		if asEventName == "SoundPlay.NPCHumanCombatIdleC" ; Anim End Annotation
			debug.sendAnimationEvent(target_actor, "OffsetStop")
		endif
	else
		; Ensure that if we're not currently animating we don't have any hand items attached
		RTR_Detatch(target_actor, HelmetOnHand)
	endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	TargetActor.UnequipItem(LoweredLastEquippedHood, true, true)
	TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
	DeleteAll(plugin)
EndEvent

Event OnEffectStart(Actor Target, Actor Caster)
	TargetActor = Target
	RegisterForMenu("InventoryMenu")
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

Event OnInit()
	RegisterForMenu("InventoryMenu")
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	RegisterForKey(EnableKey.GetValueInt())
EndEvent

Event OnKeyDown(Int KeyCode)
	if KeyCode == ToggleKey.GetValueInt()
		if (!Utility.IsInMenuMode() && ui.IsTextInputEnabled() == False && !LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0 && !LastEquippedHelmet.HasKeywordString("RTR_ExcludeKW")) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0 && !LastEquippedHood.HasKeywordString("RTR_ExcludeKW"))
			if Active == false
				Active = true
				WasToggle = true
				HelmetEquipped = IsHelmetEquipped()
				if HelmetEquipped
					Bool Check = UnequipActorHeadgear()
					if !Check || ItemEnabledActor(TargetActor, plugin, hand_name, IsFemale)
						FixInterruptedUnequip()
					endif
				else
					Bool Check = EquipActorHeadgear()
					if !Check || (TargetActor.IsEquipped(LastEquippedHelmet) == false && TargetActor.IsEquipped(LastEquippedHood) == false)
						FixInterruptedEquip()
					endif
				endif

				; Trigger Follower Headwear Management
				; if ManageFollowers.GetValueInt() == 1
				Actor[] followers = MiscUtil.ScanCellNPCs(PlayerRef, 150.0, RTR_Follower)
				; List the followers
				int followerIndex = 0
				while (followerIndex < followers.Length)
					Actor followerActor = followers[followerIndex]
					string followerActorName = followerActor.GetBaseObject().GetName()
					Debug.Notification("RTR Detected Follower: " + followerActorName)

					; increment through
					followerIndex += 1
				endwhile
				; endif

				Active = false
			endif
		endif
	endif
	if KeyCode == DeleteKey.GetValueInt()
		DeleteAll(plugin)
		TargetActor.UnequipItem(LoweredLastEquippedHood)
	endif
	if KeyCode == EnableKey.GetValueInt()
		if TargetActor.hasperk(ReadTheRoomPerk)
			TargetActor.removeperk(ReadTheRoomPerk)
		else
			TargetActor = Game.GetPlayer()
			TargetActor.addperk(ReadTheRoomPerk)
		endif
	endif
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0 && !LastEquippedHelmet.HasKeywordString("RTR_ExcludeKW")) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0 && !LastEquippedHood.HasKeywordString("RTR_ExcludeKW"))
		Location current_loc = akNewLoc
		Bool Check
		Bool IsSafe = CheckLocationForKeyword(current_loc, SafeKeywords)
		Bool IsHostile = CheckLocationForKeyword(current_loc, HostileKeywords)
		Float UnequipWhenUnsafeVal = UnequipWhenUnsafe.GetValue()
		Float EquipWhenSafeVal = EquipWhenSafe.GetValue()
		HelmetEquipped = IsHelmetEquipped()
		if (IsSafe && UnequipWhenUnsafeVal == 0) || (HelmetEquipped && !IsHostile && UnequipWhenUnsafeVal == 1)
			if HelmetEquipped && Active == false
				Active = true
				Check = UnequipActorHeadgear()
				if ItemEnabledActor(TargetActor, plugin, hand_name, IsFemale)
					FixInterruptedUnequip()
				endif
				Active = false
			endif
		endif
		if (IsHostile && EquipWhenSafeVal == 0) || (!HelmetEquipped && !IsSafe && EquipWhenSafeVal == 1)
			if HelmetEquipped == false && Active == false
				Active = true
				Check = EquipActorHeadgear()
				if Check && TargetActor.IsEquipped(LastEquippedHelmet) == false && TargetActor.IsEquipped(LastEquippedHood) == false
					FixInterruptedEquip()
				endif
				Active = false
			endif
		endif
	endif
EndEvent

Event OnMagicEffectApplyEx(ObjectReference akCaster, MagicEffect akEffect)
	if akEffect == RTR_CombatEffect
		if !IsHelmetEquipped()
			if CombatEquipAnimation.GetValue() == 1
				if Active == false
					Active = true
					Bool Check = EquipActorHeadgear()
					if Check && TargetActor.IsEquipped(LastEquippedHelmet) == false && TargetActor.IsEquipped(LastEquippedHood) == false
						FixInterruptedEquip()
					endif
					Active = false
				endif
			else
				if LastEquippedType == "Helmet"
					if TargetActor.GetItemCount(LastEquippedHelmet) > 0 && !LastEquippedHelmet.HasKeywordString("RTR_ExcludeKW")
						TargetActor.EquipItem(LastEquippedHelmet, false, true)
						DeleteItemActor(TargetActor, plugin, hip_name)
					endif
				elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
					if TargetActor.GetItemCount(LastEquippedHelmet) > 0 && !LastEquippedHelmet.HasKeywordString("RTR_ExcludeKW")
						TargetActor.EquipItem(LastEquippedHelmet, false, true)
						DeleteItemActor(TargetActor, plugin, hip_name)
					endif
				elseif LastEquippedType == "Hood"
					if TargetActor.GetItemCount(LastEquippedHood) > 0 && !LastEquippedHood.HasKeywordString("RTR_ExcludeKW")
						TargetActor.EquipItem(LastEquippedHood, false, true)
					endif
				endif
			endif
		endif
	endif
EndEvent

Event OnMenuOpen(String MenuName)
	Active = false
EndEvent

Event OnMenuClose(String MenuName)
	Active = false
	if MenuName == "InventoryMenu"
		HelmetEquipped = IsHelmetEquipped()
		if HelmetEquipped || (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !IsTorsoEquipped())
			DeleteItemActor(TargetActor, plugin, hip_name)
			TargetActor.UnequipItem(LoweredLastEquippedHood, false, true)
			TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
		else
			if LastEquippedType == "Helmet" || LastEquippedType == "Circlet" && TargetActor.GetItemCount(LastEquippedHelmet) > 0 && !LastEquippedHelmet.HasKeywordString("RTR_ExcludeKW")
				Bool Place
				if LastEquippedHelmet == "Helmet"
					LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
					if LastEquippedHelmet as String == "None"
						LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
					endif
				endif
				if LastEquippedHelmet == "Circlet"
					LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
				endif
				if (LastEquippedHelmet as Armor).IsHelmet() || LastEquippedHelmet.HasKeywordString("ClothingCirclet")
					Place = true
				else
					Place = false
				endif
				if Place
					; @BOOKMARK
					GlobalVariable[] anchor = new GlobalVariable[12]
					if TargetActor.GetActorBase().GetSex() == 1
						IsFemale = true
						anchor = FemaleHipAnchor
					else
						IsFemale = False
						anchor = MaleHandAnchor
					endif

					RTR_Attach(TargetActor, HelmetOnHip, LastEquippedHelmet, LastEquippedType, hip_scale, hip_node, IsFemale, anchor)
				endif
			else
				DeleteItemActor(TargetActor, plugin, hip_name)
				if TargetActor == PlayerRef && TargetActor.GetItemCount(LastEquippedHood) > 0 && !LastEquippedHood.HasKeywordString("RTR_ExcludeKW")
					TargetActor.EquipItem(LoweredLastEquippedHood, false, true)
				endif
			endif
		endif
		
	endif
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	if TargetActor.IsEquipped(LoweredLastEquippedHood)
		if TargetActor.GetItemCount(LastEquippedHood) < 1
			TargetActor.UnequipItem(LoweredLastEquippedHood)
			LowerHood = true
			DeleteItemActor(TargetActor, plugin, hand_name)
		endif
	endif
	if LoweredHoods.Find(akBaseObject) == -1
		Armor EquippedItem = akBaseObject as Armor
		if EquippedItem.IsHelmet()
			LastEquippedHelmet = EquippedItem
			if EquippedItem.HasKeywordString("RTR_HoodKW")
				LastEquippedType = "Hood"
				LastEquippedHood = EquippedItem
				if LowerableHoods.HasForm(LastEquippedHood)
					LowerHood = true
					LoweredLastEquippedHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHood))
				endif
			else
				LowerHood = false
				LastEquippedType = "Helmet"
			endif
			DeleteItemActor(TargetActor, plugin, hand_name)
		else
			LowerHood = false
		endif
		if EquippedItem.HasKeywordString("ClothingCirclet")
			LastEquippedType = "Circlet"
			LastEquippedHelmet = akBaseObject
		endif
	endif
EndEvent

Event OnObjectUnequipped(Form akBaseObject, ObjectReference akReference)
	if (RemoveHelmetWithoutArmor.GetValueInt() == 1 && !IsTorsoEquipped())
		DeleteAllActor(TargetActor, plugin)
	endif
	if TargetActor.IsEquipped(LoweredLastEquippedHood)
		if TargetActor.GetItemCount(LastEquippedHood) < 1
			TargetActor.UnequipItem(LoweredLastEquippedHood)
			LowerHood = true
		endif
	endif
EndEvent 

Event OnRaceSwitchComplete()
	DeleteAllActor(TargetActor, plugin)
EndEvent

Bool Function CheckLocationForKeyword(Location current_loc, FormList keywords_to_check)
	int i = 0
	while i < keywords_to_check.GetSize()
		if current_loc.HasKeyword(keywords_to_check.GetAt(i) as Keyword)
			return true
		endif
		i += 1
	endwhile
	return false
EndFunction

Bool Function EquipActorHeadgear()
	Bool Equip
	if !LowerHood
		if LastEquippedType == "Helmet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
			if LastEquippedHelmet as String == "None"
				LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
			endif
		elseif LastEquippedType == "Circlet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
		endif

		; Check if last equipped is a hood
		if LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
			LastEquippedType = "Hood"
			LastEquippedHood = LastEquippedHelmet
			LowerHood = true
			LoweredLastEquippedHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHood))
		endif

		if (LastEquippedHelmet as Armor).IsHelmet() || (ManageCirclets.GetValueInt() == 1 && LastEquippedHelmet.HasKeywordString("ClothingCirclet")) || (WasToggle && LastEquippedHelmet.HasKeywordString("ClothingCirclet"))
			Equip = true
		else
			Equip = false
		endif
	else 
		Equip = true
	endif
	
	if Equip
		if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
			if CombatEquip.GetValueInt() == 1 || TargetActor.GetCombatState() == 0 || WasToggle 
				if TargetActor.GetSitState() == 0 && !TargetActor.IsSwimming() \ 
					&& TargetActor.GetAnimationVariableInt("IsEquipping") == 0 \ 
					&& TargetActor.GetAnimationVariableInt("bInJumpState") == 0 && TargetActor.GetAnimationVariableInt("IsUnequipping") == 0
					WasDrawn = false
					EquipAnimation = true
					UnequipAnimation = false
					if TargetActor.IsWeaponDrawn()
						Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
						WasDrawn = true
						while TargetActor.GetAnimationVariableInt("IsUnequipping") == 1
							utility.wait(0.01)
						endwhile
					endif
					if TargetActor.GetActorBase().GetSex() == 1
						IsFemale = true
					else
						IsFemale = False
					endif
					;Start animation
					if TargetActor == PlayerRef
						if TargetActor.GetAnimationVariableInt("i1stPerson") == 1 
							WasFirstPerson = true
							Game.ForceThirdPerson()
						else
							WasFirstPerson = false
						endif
					endif
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleA") ;These are needed for animation annotations used in the animation to queue needed functions
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleB")
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleC")
					Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
					if !LowerHood
						debug.sendAnimationEvent(TargetActor, "RTREquip")
						Utility.wait(3.3);Waits for animation
					else
						debug.sendAnimationEvent(TargetActor, "RTREquipHood")
						Utility.wait(1.0);Waits for animation
					endif
					debug.sendAnimationEvent(TargetActor, "OffsetStop")
					Game.EnablePlayerControls()
					WasToggle = false
					if WasDrawn
						TargetActor.DrawWeapon()
					endif
					if WasFirstPerson
						Game.ForceFirstPerson()
					endif
				endif
			endif
		endif
	endif
	return Equip
EndFunction

Function FixInterruptedEquip()
	DeleteItemActor(TargetActor, plugin, hip_name)
	if !LowerHood
		if TargetActor.GetItemCount(LastEquippedHelmet) > 0
			TargetActor.EquipItem(LastEquippedHelmet, false, true)
		endif
	else
		if TargetActor == PlayerRef
			TargetActor.UnequipItem(LoweredLastEquippedHood, false, true)
			TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
			TargetActor.EquipItem(LastEquippedHood, false, true)
		else
			TargetActor.UnequipItem(LoweredLastEquippedHood, true, true)
			TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
			TargetActor.EquipItem(LastEquippedHood, true, true)
		endif
	endif
	if WasFirstPerson
		Game.ForceFirstPerson()
	endif
	DeleteItemActor(TargetActor, plugin, hand_name)
EndFunction

Function FixInterruptedUnequip()
	; @BOOKMARK
	GlobalVariable[] anchor = new GlobalVariable[12]
	if IsFemale
		anchor = FemaleHipAnchor
	else
		anchor = MaleHandAnchor
	endif

	RTR_Detatch(TargetActor, HelmetOnHip)
	RTR_Detatch(TargetActor, HelmetOnHand)
	TargetActor.UnequipItem(LastEquippedHelmet, false, true)

	RTR_Attach(TargetActor, HelmetOnHip, LastEquippedHelmet, LastEquippedType, hip_scale, hip_node, IsFemale, anchor)

	if WasFirstPerson
		Game.ForceFirstPerson()
	endif
EndFunction
	
Bool Function IsHelmetEquipped()
	if LastEquippedType == "Helmet" || LastEquippedType == "Circlet"
		if LastEquippedType == "Helmet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
			if LastEquippedHelmet as String == "None"
				LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
			endif
		elseif LastEquippedType == "Circlet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
		endif
		if TargetActor.IsEquipped(LastEquippedHelmet)
			return true
		else
			return false
		endif
	endif
	if LastEquippedType == "Hood"
		if TargetActor.IsEquipped(LastEquippedHood)
			return true
		else
			return false
		endif
	endif
EndFunction	

Int Function IsInFormList(Form FormToCheck, FormList FormListToCheck)
	int i = 0
	while i < FormListToCheck.GetSize()
		if FormListToCheck.GetAt(i) == FormToCheck
			return i
		endif
		i += 1
	endwhile
	return -1
endfunction

Bool Function IsTorsoEquipped()
	Form LastEquippedArmor = GetLastEquippedForm(TargetActor, 2, true, false)
	if TargetActor.IsEquipped(LastEquippedArmor)
		return true
	else
		return false
	endif
EndFunction	

Bool Function UnequipPrecheck()
	if !LowerHood
		if LastEquippedType == "Helmet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
			if LastEquippedHelmet as String == "None"
				LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
			endif
		elseif LastEquippedType == "Circlet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
		endif
		
		; Check if last equipped is a hood
		if LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
			LastEquippedType = "Hood"
			LastEquippedHood = LastEquippedHelmet
			LowerHood = true
			LoweredLastEquippedHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHood))
		endif

		if (LastEquippedHelmet as Armor).IsHelmet() || (ManageCirclets.GetValueInt() == 1 && LastEquippedHelmet.HasKeywordString("ClothingCirclet")) || (WasToggle && LastEquippedHelmet.HasKeywordString("ClothingCirclet"))
			return true
		else
			return false
		endif
	else
		return true
	endif
EndFunction

Bool Function UnequipActorHeadgear()
	Bool Unequip = UnequipPrecheck()
	if Unequip
		if TargetActor.GetCombatState() == 0 || WasToggle
			if TargetActor.GetSitState() == 0 && !TargetActor.IsSwimming() \ 
				&& TargetActor.GetAnimationVariableInt("bInJumpState") == 0 && TargetActor.GetAnimationVariableInt("IsEquipping") == 0 \ 
				&& TargetActor.GetAnimationVariableInt("IsUnequipping") == 0
				WasDrawn = false
				EquipAnimation = false
				UnequipAnimation = true
				if TargetActor.IsWeaponDrawn()
					Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
					WasDrawn = true
					while TargetActor.GetAnimationVariableInt("IsUnequipping") == 1
						utility.wait(0.01)
					endwhile
				endif
				if TargetActor.GetActorBase().GetSex() == 1
					IsFemale = true
				else
					IsFemale = False
				endif
				if TargetActor.GetAnimationVariableInt("i1stPerson") == 1 
					Game.ForceThirdPerson()
					WasFirstPerson = true
				endif
				RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleA") ;These are needed for animation annotations used in the animation to queue needed functions
				RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleB")
				RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleC")
				Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
				if !LowerHood
					debug.sendAnimationEvent(TargetActor, "RTRUnequip")
					Utility.wait(3.25)
				else
					debug.sendAnimationEvent(TargetActor, "RTRUnequipHood")
					Utility.wait(1.0)
				endif
				debug.sendAnimationEvent(TargetActor, "OffsetStop")
				Game.EnablePlayerControls()
				DeleteItemActor(TargetActor, plugin, hand_name)
				WasToggle = false
				if WasDrawn
					TargetActor.DrawWeapon()
				endif
				if WasFirstPerson
					Game.ForceFirstPerson()
				endif
				return true
			endif
		endif
	endif
EndFunction