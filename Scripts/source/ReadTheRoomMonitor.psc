ScriptName ReadTheRoomMonitor extends ActiveMagicEffect

Import IED 
import PO3_Events_Alias

GlobalVariable property RTR_GlobalEnable auto
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
Perk property ReadTheRoomPerk auto
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
String hip_node = "NPC Pelvis [Pelv]"
String hand_node = "NPC R Hand [RHnd]"
String LastEquippedType = "None"
Float hip_scale = 0.9150
Float hand_scale = 1.05
Form LastEquippedHelmet
Form LastEquippedHood
Form LoweredLastEquippedHood

Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	if Active
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
					;enable helmet on hand, unequip helmet
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
					if TargetActor == PlayerRef
						TargetActor.UnequipItem(LastEquippedHelmet, false, true)
					else
						TargetActor.UnequipItem(LastEquippedHelmet, true, true)
					endif
				endif
				if akSource == TargetActor && asEventName == "SoundPlay.NPCHumanCombatIdleB"
					if LastEquippedType == "Helmet" || LastEquippedType == "Circlet"
						;enable helmet on hip, disable helmet on hand
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
			if (LastEquippedHelmet as Armor).IsHelmet() || LastEquippedHelmet.HasKeywordString("ClothingCirclet") || LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
				; Check if we need to fix the LastEquippedType for hoods
				if LastEquippedHelmet.HasKeywordString("RTR_HoodKW")
					LastEquippedType = "Hood"
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
					;disable helmet on hip
					DeleteItemActor(TargetActor, plugin, hip_name)
					;enable helmet on hand
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
						if TargetActor.GetItemCount(LastEquippedHelmet) > 0
							if TargetActor == PlayerRef
								TargetActor.EquipItem(LastEquippedHelmet, false, true)
							else
								TargetActor.EquipItem(LastEquippedHelmet, true, true)
							endif
						endif
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
			endif
		else 
			DeleteItemActor(TargetActor, plugin, hand_name)
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
					if TargetActor.GetActorBase().GetSex() == 1
						IsFemale = true
					else
						IsFemale = False
					endif
					DeleteItemActor(TargetActor, plugin, hip_name)
					Status = CreateItemActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet, InventoryRequired, hip_node)
					Status = SetItemFormActor(TargetActor, plugin, hip_name, IsFemale, LastEquippedHelmet)
					Status = SetItemNodeActor(TargetActor, plugin, hip_name, IsFemale, hip_node)
					Status = SetItemRotationActor(TargetActor, plugin, hip_name, IsFemale, hip_rotation)
					Status = SetItemPositionActor(TargetActor, plugin, hip_name, IsFemale, hip_position)
					Status = SetItemScaleActor(TargetActor, plugin, hip_name, IsFemale, hip_scale)
					Status = SetItemEnabledActor(TargetActor, plugin, hip_name, IsFemale, true)
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