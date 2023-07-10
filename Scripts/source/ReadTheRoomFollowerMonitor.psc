ScriptName ReadTheRoomFollowerMonitor extends ActiveMagicEffect

Import IED 
GlobalVariable property ToggleKey auto
GlobalVariable property DeleteKey auto
GlobalVariable property EnableKey auto
GlobalVariable property HipPositionX auto
GlobalVariable property HipPositionY auto
GlobalVariable property HipPositionZ auto
GlobalVariable property HipRotationPitch auto
GlobalVariable property HipRotationRoll auto
GlobalVariable property HipRotationYaw auto
GlobalVariable property HipPositionXCirclet auto
GlobalVariable property HipPositionYCirclet auto
GlobalVariable property HipPositionZCirclet auto
GlobalVariable property HipRotationPitchCirclet auto
GlobalVariable property HipRotationRollCirclet auto
GlobalVariable property HipRotationYawCirclet auto
GlobalVariable property HandPositionX auto
GlobalVariable property HandPositionY auto
GlobalVariable property HandPositionZ auto
GlobalVariable property HandRotationPitch auto
GlobalVariable property HandRotationRoll auto
GlobalVariable property HandRotationYaw auto
GlobalVariable property HandPositionXCirclet auto
GlobalVariable property HandPositionYCirclet auto
GlobalVariable property HandPositionZCirclet auto
GlobalVariable property HandRotationPitchCirclet auto
GlobalVariable property HandRotationRollCirclet auto
GlobalVariable property HandRotationYawCirclet auto
GlobalVariable property HipPositionXFemale auto
GlobalVariable property HipPositionYFemale auto
GlobalVariable property HipPositionZFemale auto
GlobalVariable property HipRotationPitchFemale auto
GlobalVariable property HipRotationRollFemale auto
GlobalVariable property HipRotationYawFemale auto
GlobalVariable property HipPositionXCircletFemale auto
GlobalVariable property HipPositionYCircletFemale auto
GlobalVariable property HipPositionZCircletFemale auto
GlobalVariable property HipRotationPitchCircletFemale auto
GlobalVariable property HipRotationRollCircletFemale auto
GlobalVariable property HipRotationYawCircletFemale auto
GlobalVariable property HandPositionXFemale auto
GlobalVariable property HandPositionYFemale auto
GlobalVariable property HandPositionZFemale auto
GlobalVariable property HandRotationPitchFemale auto
GlobalVariable property HandRotationRollFemale auto
GlobalVariable property HandRotationYawFemale auto
GlobalVariable property HandPositionXCircletFemale auto
GlobalVariable property HandPositionYCircletFemale auto
GlobalVariable property HandPositionZCircletFemale auto
GlobalVariable property HandRotationPitchCircletFemale auto
GlobalVariable property HandRotationRollCircletFemale auto
GlobalVariable property HandRotationYawCircletFemale auto
GlobalVariable property EquipWhenSafe auto
GlobalVariable property UnequipWhenUnsafe auto
GlobalVariable property CombatEquip auto
GlobalVariable property CombatEquipAnimation auto
GlobalVariable property ManageCirclets auto
GlobalVariable property RemoveHelmetWithoutArmor auto
FormList property HostileKeywords auto
FormList property SafeKeywords auto
FormList property LoweredHoods auto
FormList property LowerableHoods auto
MagicEffect property RTR_CombatEffect auto
Spell property RTR_EquipSpell auto
Spell property RTR_UnequipSpell auto
Perk property ReadTheRoomPerk auto
Actor property PlayerRef auto
Actor TargetActor
Bool HelmetEquipped = false
Bool HelmetWasEquipped = false
Bool Status
Bool InventoryRequired = false
Bool IsFemale = false
Bool DismountIsEquip = false
Bool EquipAnimation = false
Bool UnequipAnimation = false
Bool WasDrawn = false
Bool WasToggle = false
Bool Active = false
Bool WasFirstPerson = false
Bool LowerHood = false
Bool WasCombat = false
String plugin = "ReadTheRoom.esp"
String hip_name = "HelmetOnHipFollower"
String hand_name = "HelmetOnHandFollower"
String hip_node = "NPC Pelvis [Pelv]"
String hand_node = "NPC R Hand [RHnd]"
String LastEquippedType
Float hip_scale = 0.9150
Float hand_scale = 1.0
Form LastEquippedHelmet
Form LastEquippedHood
Form LoweredLastEquippedHood
Form LoweredLastEquippedHoodPlayer
Bool RegisteredTrue
Int Attempt = 0

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if UnequipAnimation
		if LastEquippedType == "Helmet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
			if LastEquippedHelmet as String == "None"
				LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
			endif
		elseif LastEquippedType == "Circlet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
		endif
		if (LastEquippedHelmet as Armor).IsHelmet() || LastEquippedHelmet.HasKeywordString("ClothingCirclet") || LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
			if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleA"
				Float[] hand_position = new Float[3]
				Float[] hand_rotation = new Float[3]
				if LastEquippedType == "Helmet"
					if IsFemale
						hand_position[0] = HandPositionXFemale.GetValue()
						hand_position[1] = HandPositionYFemale.GetValue()
						hand_position[2] = HandPositionZFemale.GetValue()
						hand_rotation[0] = HandRotationPitchFemale.GetValue()
						hand_rotation[1] = HandRotationRollFemale.GetValue()
						hand_rotation[2] = HandRotationYawFemale.GetValue()
					else
						hand_position[0] = HandPositionX.GetValue()
						hand_position[1] = HandPositionY.GetValue()
						hand_position[2] = HandPositionZ.GetValue()
						hand_rotation[0] = HandRotationPitch.GetValue()
						hand_rotation[1] = HandRotationRoll.GetValue()
						hand_rotation[2] = HandRotationYaw.GetValue()
					endif
				elseif LastEquippedType == "Circlet"
					if IsFemale
						hand_position[0] = HandPositionXCircletFemale.GetValue()
						hand_position[1] = HandPositionYCircletFemale.GetValue()
						hand_position[2] = HandPositionZCircletFemale.GetValue()
						hand_rotation[0] = HandRotationPitchCircletFemale.GetValue()
						hand_rotation[1] = HandRotationRollCircletFemale.GetValue()
						hand_rotation[2] = HandRotationYawCircletFemale.GetValue()
					else
						hand_position[0] = HandPositionXCirclet.GetValue()
						hand_position[1] = HandPositionYCirclet.GetValue()
						hand_position[2] = HandPositionZCirclet.GetValue()
						hand_rotation[0] = HandRotationPitchCirclet.GetValue()
						hand_rotation[1] = HandRotationRollCirclet.GetValue()
						hand_rotation[2] = HandRotationYawCirclet.GetValue()
					endif
				endif
				Status = CreateItemActor(TargetActor, plugin, hand_name, IsFemale, LastEquippedHelmet, InventoryRequired, hand_node)
				Status = SetItemFormActor(TargetActor, plugin, hand_name, IsFemale, LastEquippedHelmet)
				Status = SetItemNodeActor(TargetActor, plugin, hand_name, IsFemale, hand_node)
				Status = SetItemPositionActor(TargetActor, plugin, hand_name, IsFemale, hand_position)
				Status = SetItemRotationActor(TargetActor, plugin, hand_name, IsFemale, hand_rotation)
				if LastEquippedType == "Helmet"
					Status = SetItemScaleActor(TargetActor, plugin, hand_name, IsFemale, hand_scale)
				endif
				Status = SetItemEnabledActor(TargetActor, plugin, hand_name, IsFemale, true)
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
			endif
			if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleB"
				;enable helmet on hip, disable helmet on hand
				if LastEquippedType == "Helmet" || LastEquippedType == "Circlet"
					Float[] hip_position = new Float[3]
					Float[] hip_rotation = new Float[3]
					if LastEquippedType == "Helmet"
						if IsFemale
							hip_position[0] = HipPositionXFemale.GetValue()
							hip_position[1] = HipPositionYFemale.GetValue()
							hip_position[2] = HipPositionZFemale.GetValue()
							hip_rotation[0] = HipRotationPitchFemale.GetValue()
							hip_rotation[1] = HipRotationRollFemale.GetValue()
							hip_rotation[2] = HipRotationYawFemale.GetValue()
						else
							hip_position[0] = HipPositionX.GetValue()
							hip_position[1] = HipPositionY.GetValue()
							hip_position[2] = HipPositionZ.GetValue()
							hip_rotation[0] = HipRotationPitch.GetValue()
							hip_rotation[1] = HipRotationRoll.GetValue()
							hip_rotation[2] = HipRotationYaw.GetValue()
						endif
					elseif LastEquippedType == "Circlet"
						if IsFemale
							hip_position[0] = HipPositionXCircletFemale.GetValue()
							hip_position[1] = HipPositionYCircletFemale.GetValue()
							hip_position[2] = HipPositionZCircletFemale.GetValue()
							hip_rotation[0] = HipRotationPitchCircletFemale.GetValue()
							hip_rotation[1] = HipRotationRollCircletFemale.GetValue()
							hip_rotation[2] = HipRotationYawCircletFemale.GetValue()
						else
							hip_position[0] = HipPositionXCirclet.GetValue()
							hip_position[1] = HipPositionYCirclet.GetValue()
							hip_position[2] = HipPositionZCirclet.GetValue()
							hip_rotation[0] = HipRotationPitchCirclet.GetValue()
							hip_rotation[1] = HipRotationRollCirclet.GetValue()
							hip_rotation[2] = HipRotationYawCirclet.GetValue()
						endif
					endif
					Status = CreateItemActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet, InventoryRequired, hip_node)
					Status = SetItemFormActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet)
					Status = SetItemNodeActor(TargetActor, plugin, hip_name, IsFemale, hip_node)
					Status = SetItemRotationActor(TargetActor, plugin, hip_name, IsFemale, hip_rotation)
					Status = SetItemPositionActor(TargetActor, plugin, hip_name, IsFemale, hip_position)
					Status = SetItemScaleActor(TargetActor, plugin, hip_name, IsFemale, hip_scale)
					Status = SetItemEnabledActor(TargetActor, plugin, hip_name, IsFemale, true)
					DeleteItemActor(TargetActor, plugin, hand_name)
				elseif LastEquippedType == "Hood"
					TargetActor.UnequipItem(LastEquippedHood, false, true)
					TargetActor.EquipItem(LoweredLastEquippedHood, false, true)
				endif
			endif
			if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleC"
				debug.sendAnimationEvent(TargetActor, "OffsetStop")
			endif
		endif
	elseif EquipAnimation
		if LastEquippedType == "Helmet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
			if LastEquippedHelmet as String == "None"
				LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
			endif
		elseif LastEquippedType == "Circlet"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
		endif
		if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleA"
			Float[] hand_position = new Float[3]
			Float[] hand_rotation = new Float[3]
			if LastEquippedType == "Helmet"
				if IsFemale
					hand_position[0] = HandPositionXFemale.GetValue()
					hand_position[1] = HandPositionYFemale.GetValue()
					hand_position[2] = HandPositionZFemale.GetValue()
					hand_rotation[0] = HandRotationPitchFemale.GetValue()
					hand_rotation[1] = HandRotationRollFemale.GetValue()
					hand_rotation[2] = HandRotationYawFemale.GetValue()
				else
					hand_position[0] = HandPositionX.GetValue()
					hand_position[1] = HandPositionY.GetValue()
					hand_position[2] = HandPositionZ.GetValue()
					hand_rotation[0] = HandRotationPitch.GetValue()
					hand_rotation[1] = HandRotationRoll.GetValue()
					hand_rotation[2] = HandRotationYaw.GetValue()
				endif
			elseif LastEquippedType == "Circlet"
				if IsFemale
					hand_position[0] = HandPositionXCircletFemale.GetValue()
					hand_position[1] = HandPositionYCircletFemale.GetValue()
					hand_position[2] = HandPositionZCircletFemale.GetValue()
					hand_rotation[0] = HandRotationPitchCircletFemale.GetValue()
					hand_rotation[1] = HandRotationRollCircletFemale.GetValue()
					hand_rotation[2] = HandRotationYawCircletFemale.GetValue()
				else
					hand_position[0] = HandPositionXCirclet.GetValue()
					hand_position[1] = HandPositionYCirclet.GetValue()
					hand_position[2] = HandPositionZCirclet.GetValue()
					hand_rotation[0] = HandRotationPitchCirclet.GetValue()
					hand_rotation[1] = HandRotationRollCirclet.GetValue()
					hand_rotation[2] = HandRotationYawCirclet.GetValue()
				endif
			endif
			DeleteItemActor(TargetActor, plugin, hip_name)
			Status = CreateItemActor(TargetActor, plugin, hand_name, IsFemale, LastEquippedHelmet, InventoryRequired, hand_node)
			Status = SetItemFormActor(TargetActor, plugin, hand_name, IsFemale, LastEquippedHelmet)
			Status = SetItemNodeActor(TargetActor, plugin, hand_name, IsFemale, hand_node)
			Status = SetItemPositionActor(TargetActor, plugin, hand_name, IsFemale, hand_position)
			Status = SetItemRotationActor(TargetActor, plugin, hand_name, IsFemale, hand_rotation)
			if LastEquippedType == "Helmet"
				Status = SetItemScaleActor(TargetActor, plugin, hand_name, IsFemale, hand_scale)
			endif
			Status = SetItemEnabledActor(TargetActor, plugin, hand_name, IsFemale, true)
		endif
		if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleB"
			;equip helmet, disable helmet on hand
			if LastEquippedType == "Helmet" || LastEquippedType == "Circlet"
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
				DeleteItemActor(TargetActor, plugin, hand_name)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LoweredLastEquippedHood, false, true)
				TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
				TargetActor.EquipItem(LastEquippedHood, false, true)
			endif
		endif
		if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleC"
			debug.sendAnimationEvent(TargetActor, "OffsetStop")
		endif
		;endif
	endif
EndEvent

Event OnCellDetach()
	if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
		Attempt = 0
		while TargetActor.Is3DLoaded() == false
			Utility.Wait(0.1)
		endwhile
		if TargetActor.GetActorBase().GetSex() == 1
			IsFemale = true
		else
			IsFemale = False
		endif
		Bool ShouldBeEquipped
		Bool PlayerEquipped = IsPlayerHelmetEquipped()
		if !PlayerEquipped && (ItemExistsActor(PlayerRef, plugin, hip_name) || PlayerRef.IsEquipped(LoweredLastEquippedHoodPlayer))
			ShouldbeEquipped = false
		elseif !PlayerEquipped && (!ItemExistsActor(PlayerRef, plugin, hip_name) &&  !PlayerRef.IsEquipped(LoweredLastEquippedHoodPlayer))
			ShouldBeEquipped = HelmetEquipped
		else
			ShouldBeEquipped = true
		endif
		if ShouldBeEquipped
			if LastEquippedType == "Helmet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
			elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LastEquippedHood, false, true)
				TargetActor.EquipItem(LastEquippedHood, false, true)
			endif
			if ItemExistsActor(TargetActor, plugin, hip_name)
				DeleteItemActor(TargetActor, plugin, hip_name)
			endif
			TargetActor.UnequipItem(LoweredLastEquippedHood)
		else
			if LastEquippedType == "Helmet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
			elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LastEquippedHood, false, true)
			endif
			if !(ManageCirclets.GetValueInt() == 0 && LastEquippedType == "Circlet")
				Float[] hip_position = new Float[3]
				Float[] hip_rotation = new Float[3]
				if LastEquippedType == "Helmet"
					if IsFemale
						hip_position[0] = HipPositionXFemale.GetValue()
						hip_position[1] = HipPositionYFemale.GetValue()
						hip_position[2] = HipPositionZFemale.GetValue()
						hip_rotation[0] = HipRotationPitchFemale.GetValue()
						hip_rotation[1] = HipRotationRollFemale.GetValue()
						hip_rotation[2] = HipRotationYawFemale.GetValue()
					else
						hip_position[0] = HipPositionX.GetValue()
						hip_position[1] = HipPositionY.GetValue()
						hip_position[2] = HipPositionZ.GetValue()
						hip_rotation[0] = HipRotationPitch.GetValue()
						hip_rotation[1] = HipRotationRoll.GetValue()
						hip_rotation[2] = HipRotationYaw.GetValue()
					endif
				elseif LastEquippedType == "Circlet"
					if IsFemale
						hip_position[0] = HipPositionXCircletFemale.GetValue()
						hip_position[1] = HipPositionYCircletFemale.GetValue()
						hip_position[2] = HipPositionZCircletFemale.GetValue()
						hip_rotation[0] = HipRotationPitchCircletFemale.GetValue()
						hip_rotation[1] = HipRotationRollCircletFemale.GetValue()
						hip_rotation[2] = HipRotationYawCircletFemale.GetValue()
					else
						hip_position[0] = HipPositionXCirclet.GetValue()
						hip_position[1] = HipPositionYCirclet.GetValue()
						hip_position[2] = HipPositionZCirclet.GetValue()
						hip_rotation[0] = HipRotationPitchCirclet.GetValue()
						hip_rotation[1] = HipRotationRollCirclet.GetValue()
						hip_rotation[2] = HipRotationYawCirclet.GetValue()
					endif
				endif
				Status = CreateItemActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet, InventoryRequired, hip_node)
				Status = SetItemFormActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet)
				Status = SetItemNodeActor(TargetActor, plugin, hip_name, IsFemale, hip_node)
				Status = SetItemRotationActor(TargetActor, plugin, hip_name, IsFemale, hip_rotation)
				Status = SetItemPositionActor(TargetActor, plugin, hip_name, IsFemale, hip_position)
				Status = SetItemScaleActor(TargetActor, plugin, hip_name, IsFemale, hip_scale)
				Status = SetItemEnabledActor(TargetActor, plugin, hip_name, IsFemale, true)
			endif
		endif
	endif
EndEvent

Event OnEffectFinish(Actor akTarget, Actor akCaster)
	TargetActor.UnequipItem(LoweredLastEquippedHood, true, true)
	TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
	DeleteAll(plugin)
EndEvent

Event OnEffectStart(Actor Target, Actor Caster)
	TargetActor = Target
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
	if TargetActor.GetActorBase().GetSex() == 1
		IsFemale = true
	else
		IsFemale = False
	endif
EndEvent

Event OnInit()
	RegisterForKey(ToggleKey.GetValueInt())
	RegisterForKey(DeleteKey.GetValueInt())
EndEvent

Event OnPlayerLoadGame()
	if TargetActor.GetActorBase().GetSex() == 1
		IsFemale = true
	else
		IsFemale = False
	endif
	if ItemExistsActor(TargetActor, plugin, hip_name)
		LastEquippedHelmet = GetLastEquippedForm(TargetActor, 1, true, false)
		if LastEquippedHelmet as String == "None"
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 0, true, false)
		endif
		if LastEquippedHelmet as String == "None" || TargetActor.GetItemCount(LastEquippedHelmet) < 1
			LastEquippedHelmet = GetLastEquippedForm(TargetActor, 12, true, false)
			LastEquippedType = "Circlet"
		else
			if LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
				LastEquippedType = "Hood"
			else
				LastEquippedType = "Helmet"
			endif
		endif
	endif
	if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
		Attempt = 0
		while TargetActor.Is3DLoaded() == false
			Utility.Wait(0.1)
		endwhile
		if TargetActor.GetActorBase().GetSex() == 1
			IsFemale = true
		else
			IsFemale = False
		endif
		Bool ShouldBeEquipped
		Bool PlayerEquipped = IsPlayerHelmetEquipped()
		if !PlayerEquipped && (ItemExistsActor(PlayerRef, plugin, hip_name) || PlayerRef.IsEquipped(LoweredLastEquippedHoodPlayer))
			ShouldbeEquipped = false
		elseif !PlayerEquipped && (!ItemExistsActor(PlayerRef, plugin, hip_name) &&  !PlayerRef.IsEquipped(LoweredLastEquippedHoodPlayer))
			ShouldBeEquipped = HelmetEquipped
		else
			ShouldBeEquipped = true
		endif
		if ShouldBeEquipped
			if LastEquippedType == "Helmet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
			elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LastEquippedHood, false, true)
				TargetActor.EquipItem(LastEquippedHood, false, true)
			endif
			if ItemExistsActor(TargetActor, plugin, hip_name)
				DeleteItemActor(TargetActor, plugin, hip_name)
			endif
			TargetActor.UnequipItem(LoweredLastEquippedHood)
		else
			if LastEquippedType == "Helmet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
			elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
				TargetActor.UnequipItem(LastEquippedHelmet, false, true)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LastEquippedHood, false, true)
			endif
			if !(ManageCirclets.GetValueInt() == 0 && LastEquippedType == "Circlet")
				Float[] hip_position = new Float[3]
				Float[] hip_rotation = new Float[3]
				if LastEquippedType == "Helmet"
					if IsFemale
						hip_position[0] = HipPositionXFemale.GetValue()
						hip_position[1] = HipPositionYFemale.GetValue()
						hip_position[2] = HipPositionZFemale.GetValue()
						hip_rotation[0] = HipRotationPitchFemale.GetValue()
						hip_rotation[1] = HipRotationRollFemale.GetValue()
						hip_rotation[2] = HipRotationYawFemale.GetValue()
					else
						hip_position[0] = HipPositionX.GetValue()
						hip_position[1] = HipPositionY.GetValue()
						hip_position[2] = HipPositionZ.GetValue()
						hip_rotation[0] = HipRotationPitch.GetValue()
						hip_rotation[1] = HipRotationRoll.GetValue()
						hip_rotation[2] = HipRotationYaw.GetValue()
					endif
				elseif LastEquippedType == "Circlet"
					if IsFemale
						hip_position[0] = HipPositionXCircletFemale.GetValue()
						hip_position[1] = HipPositionYCircletFemale.GetValue()
						hip_position[2] = HipPositionZCircletFemale.GetValue()
						hip_rotation[0] = HipRotationPitchCircletFemale.GetValue()
						hip_rotation[1] = HipRotationRollCircletFemale.GetValue()
						hip_rotation[2] = HipRotationYawCircletFemale.GetValue()
					else
						hip_position[0] = HipPositionXCirclet.GetValue()
						hip_position[1] = HipPositionYCirclet.GetValue()
						hip_position[2] = HipPositionZCirclet.GetValue()
						hip_rotation[0] = HipRotationPitchCirclet.GetValue()
						hip_rotation[1] = HipRotationRollCirclet.GetValue()
						hip_rotation[2] = HipRotationYawCirclet.GetValue()
					endif
				endif
				Status = CreateItemActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet, InventoryRequired, hip_node)
				Status = SetItemFormActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet)
				Status = SetItemNodeActor(TargetActor, plugin, hip_name, IsFemale, hip_node)
				Status = SetItemRotationActor(TargetActor, plugin, hip_name, IsFemale, hip_rotation)
				Status = SetItemPositionActor(TargetActor, plugin, hip_name, IsFemale, hip_position)
				Status = SetItemScaleActor(TargetActor, plugin, hip_name, IsFemale, hip_scale)
				Status = SetItemEnabledActor(TargetActor, plugin, hip_name, IsFemale, true)
			endif
		endif
	endif
EndEvent

Event OnKeyDown(Int KeyCode)
	if KeyCode == ToggleKey.GetValueInt()
		if (!Utility.IsInMenuMode() && ui.IsTextInputEnabled() == false && !LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
			WasToggle = true
			Bool PlayerEquipped = IsPlayerHelmetEquipped()
			if HelmetEquipped && PlayerEquipped
				UnequipActorHeadgear()
				if ItemEnabledActor(TargetActor, plugin, hand_name, IsFemale)
					FixInterruptedUnequip()
				endif
			elseif HelmetEquipped && PlayerEquipped == false
				Bool Check = EquipActorHeadgear()
				if Check && TargetActor.IsEquipped(LastEquippedHelmet) == false && TargetActor.IsEquipped(LastEquippedHood) == false
					FixInterruptedEquip()
				endif
			endif
		endif
	endif
	if KeyCode == DeleteKey.GetValueInt()
		TargetActor.UnequipItem(LoweredLastEquippedHood)
	endif
EndEvent

Event OnLocationChange(Location akOldLoc, Location akNewLoc)
	EvaluateLocation(akNewLoc)
EndEvent

Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
	if aeCombatState == 1
		if !HelmetEquipped
			DeleteItemActor(TargetActor, plugin, hip_name)
			if LastEquippedType == "Helmet"
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
				DeleteItemActor(TargetActor, plugin, hip_name)
			elseif ManageCirclets.GetValueInt() == 1 && LastEquippedType == "Circlet"
				TargetActor.EquipItem(LastEquippedHelmet, false, true)
				DeleteItemActor(TargetActor, plugin, hip_name)
			elseif LastEquippedType == "Hood"
				TargetActor.UnequipItem(LoweredLastEquippedHood, false, true)
				TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
				TargetActor.EquipItem(LastEquippedHood, false, true)
			endif
		endif
	endif
EndEvent

Event OnObjectEquipped(Form akBaseObject, ObjectReference akReference)
	Utility.Wait(0.1)
	if TargetActor.IsEquipped(LoweredLastEquippedHood)
		if TargetActor.GetItemCount(LastEquippedHood) < 1
			TargetActor.UnequipItem(LoweredLastEquippedHood)
			LowerHood = true
		endif
	endif
	if LoweredHoods.Find(akBaseObject) == -1
		Armor EquippedItem = akBaseObject as Armor
		if EquippedItem.IsHelmet()
			LastEquippedHelmet = akBaseObject
			HelmetEquipped = true
			if EquippedItem.HasKeywordString("RTR_HoodKW")
				LastEquippedType = "Hood"
				LastEquippedHood = akBaseObject
				if LowerableHoods.HasForm(LastEquippedHood)
					LowerHood = true
					LoweredLastEquippedHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHood))
				endif
			else
				LowerHood = false
				LastEquippedType = "Helmet"
			endif
		else
			LowerHood = false
		endif
		if EquippedItem.HasKeywordString("ClothingCirclet")
			LastEquippedType = "Circlet"
			LastEquippedHelmet = akBaseObject
			HelmetEquipped = true
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
	if LoweredHoods.Find(akBaseObject) == -1
		Armor EquippedItem = akBaseObject as Armor
		if EquippedItem.IsHelmet()
			LastEquippedHelmet = akBaseObject
			HelmetEquipped = false
			if EquippedItem.HasKeywordString("RTR_HoodKW")
				LastEquippedType = "Hood"
				LastEquippedHood = akBaseObject
				if LowerableHoods.HasForm(LastEquippedHood)
					LowerHood = true
					LoweredLastEquippedHood = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHood))
				endif
			else
				LowerHood = false
				LastEquippedType = "Helmet"
			endif
		else
			LowerHood = false
		endif
		if EquippedItem.HasKeywordString("ClothingCirclet")
			LastEquippedHelmet = akBaseObject
			LastEquippedType = "Circlet"
			HelmetEquipped = false
		endif
	endif
EndEvent 

Event OnRaceSwitchComplete()
	DeleteAllActor(TargetActor, plugin)
	TargetActor.UnequipItem(LoweredLastEquippedHood)
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
					&& TargetActor.GetAnimationVariableInt("bInJumpState") == 0 && TargetActor.GetAnimationVariableInt("IsUnequipping") == 0 \
					&& !TargetActor.IsWeaponDrawn()
					WasDrawn = false
					EquipAnimation = true
					UnequipAnimation = false
					if TargetActor.GetActorBase().GetSex() == 1
						IsFemale = true
					else
						IsFemale = False
					endif
					BreakSynchronization()
					;Start animation
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleA") ;These are needed for animation annotations used in the animation to queue needed functions
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleB")
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleC")
					if !LowerHood
						debug.sendAnimationEvent(TargetActor, "RTREquip")
						Utility.wait(3.3);Waits for animation
					else
						debug.sendAnimationEvent(TargetActor, "RTREquipHood")
						Utility.wait(1.0);Waits for animation
					endif
					debug.sendAnimationEvent(TargetActor, "OffsetStop")
					WasToggle = false
					if WasDrawn
						TargetActor.DrawWeapon()
					endif
				endif
			endif
		endif
	endif
	return Equip
EndFunction

Function EvaluateLocation(Location current_loc)
	if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
		Bool Check
		Bool IsSafe = CheckLocationForKeyword(current_loc, SafeKeywords)
		Bool IsHostile = CheckLocationForKeyword(current_loc, HostileKeywords)
		Float UnequipWhenUnsafeVal = UnequipWhenUnsafe.GetValue()
		Float EquipWhenSafeVal = EquipWhenSafe.GetValue()
		if (IsSafe && UnequipWhenUnsafeVal == 0) || (HelmetEquipped && !IsHostile && UnequipWhenUnsafeVal == 1)
			if HelmetEquipped && Active == false
				Check = UnequipActorHeadgear()
				if ItemEnabledActor(TargetActor, plugin, hand_name, IsFemale)
					FixInterruptedUnequip()
				endif
			endif
		endif
		if (IsHostile && EquipWhenSafeVal == 0) || (!HelmetEquipped && !IsSafe && EquipWhenSafeVal == 1)
			if !HelmetEquipped
				Check = EquipActorHeadgear()
				if Check && TargetActor.IsEquipped(LastEquippedHelmet) == false && TargetActor.IsEquipped(LastEquippedHood) == false
					FixInterruptedEquip()
				endif
			endif
		endif
	endif
EndFunction

Function FixInterruptedEquip()
	DeleteItemActor(TargetActor, plugin, hip_name)
	if !LowerHood
		TargetActor.EquipItem(LastEquippedHelmet, false, true)
	else
		TargetActor.UnequipItem(LoweredLastEquippedHood, false, true)
		TargetActor.RemoveItem(LoweredLastEquippedHood, 1, true)
		TargetActor.EquipItem(LastEquippedHood, false, true)
	endif
	DeleteItemActor(TargetActor, plugin, hand_name)
EndFunction

Function FixInterruptedUnequip()
	Float[] hip_position = new Float[3]
	Float[] hip_rotation = new Float[3]
	if LastEquippedType == "Helmet"
		if IsFemale
			hip_position[0] = HipPositionXFemale.GetValue()
			hip_position[1] = HipPositionYFemale.GetValue()
			hip_position[2] = HipPositionZFemale.GetValue()
			hip_rotation[0] = HipRotationPitchFemale.GetValue()
			hip_rotation[1] = HipRotationRollFemale.GetValue()
			hip_rotation[2] = HipRotationYawFemale.GetValue()
		else
			hip_position[0] = HipPositionX.GetValue()
			hip_position[1] = HipPositionY.GetValue()
			hip_position[2] = HipPositionZ.GetValue()
			hip_rotation[0] = HipRotationPitch.GetValue()
			hip_rotation[1] = HipRotationRoll.GetValue()
			hip_rotation[2] = HipRotationYaw.GetValue()
		endif
	elseif LastEquippedType == "Circlet"
		if IsFemale
			hip_position[0] = HipPositionXCircletFemale.GetValue()
			hip_position[1] = HipPositionYCircletFemale.GetValue()
			hip_position[2] = HipPositionZCircletFemale.GetValue()
			hip_rotation[0] = HipRotationPitchCircletFemale.GetValue()
			hip_rotation[1] = HipRotationRollCircletFemale.GetValue()
			hip_rotation[2] = HipRotationYawCircletFemale.GetValue()
		else
			hip_position[0] = HipPositionXCirclet.GetValue()
			hip_position[1] = HipPositionYCirclet.GetValue()
			hip_position[2] = HipPositionZCirclet.GetValue()
			hip_rotation[0] = HipRotationPitchCirclet.GetValue()
			hip_rotation[1] = HipRotationRollCirclet.GetValue()
			hip_rotation[2] = HipRotationYawCirclet.GetValue()
		endif
	endif
	DeleteItemActor(TargetActor, plugin, hip_name)
	DeleteItemActor(TargetActor, plugin, hand_name)
	TargetActor.UnequipItem(LastEquippedHelmet, false, true)
	Status = CreateItemActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet, InventoryRequired, hip_node)
	Status = SetItemFormActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet)
	Status = SetItemNodeActor(TargetActor, plugin, hip_name, IsFemale, hip_node)
	Status = SetItemRotationActor(TargetActor, plugin, hip_name, IsFemale, hip_rotation)
	Status = SetItemPositionActor(TargetActor, plugin, hip_name, IsFemale, hip_position)
	Status = SetItemScaleActor(TargetActor, plugin, hip_name, IsFemale, hip_scale)
	Status = SetItemEnabledActor(TargetActor, plugin, hip_name, IsFemale, true)
EndFunction
	
Bool Function IsHelmetEquipped()
	if LastEquippedType == "Helmet" || LastEquippedType == "Circlet"
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
EndFunction

Bool Function IsPlayerHelmetEquipped()
	Form LastEquippedHelmetPlayer = GetLastEquippedForm(PlayerRef, 1, true, false)
	if LastEquippedHelmetPlayer as String == "None"
		LastEquippedHelmetPlayer = GetLastEquippedForm(PlayerRef, 0, true, false)
	endif
	if LastEquippedHelmetPlayer.HasKeywordString("RTR_HoodKW")
		Form LastEquippedHoodPlayer = LastEquippedHelmetPlayer
		if LowerableHoods.HasForm(LastEquippedHoodPlayer)
			LoweredLastEquippedHoodPlayer = LoweredHoods.GetAt(LowerableHoods.Find(LastEquippedHoodPlayer))
		endif
	endif
	if PlayerRef.IsEquipped(LastEquippedHelmetPlayer)
		return true
	else
		LastEquippedHelmetPlayer = GetLastEquippedForm(PlayerRef, 12, true, false)
		if PlayerRef.IsEquipped(LastEquippedHelmetPlayer)
			return true
		else
			if PlayerRef.GetItemCount(LastEquippedHelmetPlayer) > 0
				Bool IsFemalePlayer = PlayerRef.GetActorBase().GetSex()
				Float[] hip_position = new Float[3]
				Float[] hip_rotation = new Float[3]
				if LastEquippedType == "Helmet"
					if IsFemalePlayer
						hip_position[0] = HipPositionXFemale.GetValue()
						hip_position[1] = HipPositionYFemale.GetValue()
						hip_position[2] = HipPositionZFemale.GetValue()
						hip_rotation[0] = HipRotationPitchFemale.GetValue()
						hip_rotation[1] = HipRotationRollFemale.GetValue()
						hip_rotation[2] = HipRotationYawFemale.GetValue()
					else
						hip_position[0] = HipPositionX.GetValue()
						hip_position[1] = HipPositionY.GetValue()
						hip_position[2] = HipPositionZ.GetValue()
						hip_rotation[0] = HipRotationPitch.GetValue()
						hip_rotation[1] = HipRotationRoll.GetValue()
						hip_rotation[2] = HipRotationYaw.GetValue()
					endif
				elseif LastEquippedType == "Circlet"
					if IsFemalePlayer
						hip_position[0] = HipPositionXCircletFemale.GetValue()
						hip_position[1] = HipPositionYCircletFemale.GetValue()
						hip_position[2] = HipPositionZCircletFemale.GetValue()
						hip_rotation[0] = HipRotationPitchCircletFemale.GetValue()
						hip_rotation[1] = HipRotationRollCircletFemale.GetValue()
						hip_rotation[2] = HipRotationYawCircletFemale.GetValue()
					else
						hip_position[0] = HipPositionXCirclet.GetValue()
						hip_position[1] = HipPositionYCirclet.GetValue()
						hip_position[2] = HipPositionZCirclet.GetValue()
						hip_rotation[0] = HipRotationPitchCirclet.GetValue()
						hip_rotation[1] = HipRotationRollCirclet.GetValue()
						hip_rotation[2] = HipRotationYawCirclet.GetValue()
					endif
				endif
				String hip_name_player = "HelmetOnHip"
				Status = CreateItemActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, LastEquippedHelmetPlayer, InventoryRequired, hip_node)
				Status = SetItemFormActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, LastEquippedHelmetPlayer)
				Status = SetItemNodeActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, hip_node)
				Status = SetItemRotationActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, hip_rotation)
				Status = SetItemPositionActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, hip_position)
				Status = SetItemScaleActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, hip_scale)
				Status = SetItemEnabledActor(PlayerRef, plugin, hip_name_player, IsFemalePlayer, true)
			endif
			return false
		endif
	endif
EndFunction

Bool Function IsTorsoEquipped()
	Form LastEquippedArmor = GetLastEquippedForm(TargetActor, 2, true, false)
	if TargetActor.IsEquipped(LastEquippedArmor)
		return true
	else
		return false
	endif
EndFunction

Function BreakSynchronization()
	Float WaitTime = Utility.RandomFloat(0.1, 1.0)
	Utility.Wait(WaitTime)
EndFunction	

Bool Function UnequipActorHeadgear()
	Bool Unequip
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
			Unequip = true
		else
			Unequip = false
		endif
	else
		Unequip =  true
	endif

	if Unequip
		if (!LowerHood && TargetActor.GetItemCount(LastEquippedHelmet) > 0) || (LowerHood && TargetActor.GetItemCount(LastEquippedHood) > 0)
			if TargetActor.GetCombatState() == 0 || WasToggle
				if TargetActor.GetSitState() == 0 && !TargetActor.IsSwimming() \ 
					&& TargetActor.GetAnimationVariableInt("bInJumpState") == 0 && TargetActor.GetAnimationVariableInt("IsEquipping") == 0 \ 
					&& TargetActor.GetAnimationVariableInt("IsUnequipping") == 0 \
					&& !TargetActor.IsWeaponDrawn()
					WasDrawn = false
					EquipAnimation = false
					UnequipAnimation = true
					if TargetActor.GetActorBase().GetSex() == 1
						IsFemale = true
					else
						IsFemale = False
					endif
					BreakSynchronization()
					;Start animation
					Bool Registered = false
					int i = 0
					Registered = RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleA") ;These are needed for animation annotations used in the animation to queue needed functions
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleB")
					RegisterForAnimationEvent(TargetActor, "SoundPlay.NPCHumanCombatIdleC")
					if !Registered
						return false
					endif
					if !LowerHood
						debug.sendAnimationEvent(TargetActor, "RTRUnequip")
						Utility.wait(3.25);Waits for animation
					else
						debug.sendAnimationEvent(TargetActor, "RTRUnequipHood")
						Utility.wait(1.0);Waits for animation
					endif
					debug.sendAnimationEvent(TargetActor, "OffsetStop")
					WasToggle = false
					if WasDrawn
						TargetActor.DrawWeapon()
					endif
					return true
				endif
			endif
		endif
	endif
EndFunction