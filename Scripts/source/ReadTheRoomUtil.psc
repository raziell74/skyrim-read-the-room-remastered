ScriptName ReadTheRoomUtil 

Import IED ; Immersive Equipment Display
Import MiscUtil ; PapyrusUtil SE

String Property PluginName = "ReadTheRoom.esp" Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; ReadTheRoom Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RTR_IsValidHeadWear
; Checks if an item is a valid headwear item
;
; @param Form item
; @return Bool
Bool Function RTR_IsValidHeadWear(Actor target_actor, Form item, FormList LoweredHoods) global
    ;MiscUtil.PrintConsole(">>> [RTRUtil] RTR_IsValidHeadWear")
    ; Make sure there really is an item to check against
    if !item
        ;MiscUtil.PrintConsole(">>>>>> Provided form is null")
        return false
    endif

    Armor thisArmor = item as Armor

    ; Has this item been assigned to the exclusion list?
    Bool isExcluded = thisArmor.HasKeywordString("RTR_ExcludeKW")
    if isExcluded
        ;MiscUtil.PrintConsole(">>>>>> " + thisArmor.GetName() + " has exclusion keyword (RTR_ExcludeKW). Invalid")
        return false
    endif

    ; Is the item a helmet, circlet, or hood?
    Bool isHelmet = thisArmor.IsHelmet()
    Bool isCirclet = thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet")
    Bool isHood = thisArmor.HasKeywordString("RTR_HoodKW")
    if isHelmet || isCirclet || isHood
        ; Since Lowered Hoods are equipped (dumb) make sure the item isn't one of those
        if isHood && LoweredHoods.HasForm(item)
            ;MiscUtil.PrintConsole(">>>>>> Detected Lowered Hood. Invalid")
            return false
        endif

        ; Does the actor have the item in their inventory?
        if target_actor.GetItemCount(item as Armor) == 0
            ;MiscUtil.PrintConsole(">>>>>> Missing from inventory. Invalid")
            return false
        endif

        ;MiscUtil.PrintConsole(">>>>>> Valid")
        return true
    endif

    ; Item is not head gear
    ;MiscUtil.PrintConsole(">>>>>> " + thisArmor.GetName() + " is not head wear")
    return false
EndFunction

; RTR_InferItemType
; Infers the type of headwear an item Form is
;
; @param Form item
; @return String
String Function RTR_InferItemType(Form item, FormList LowerableHoods) global
    ;MiscUtil.PrintConsole(">>> [RTRUtil] RTR_InferItemType")

    Armor thisArmor = item as Armor

    ; Check if a hood has been set up to be lowered
    if thisArmor.HasKeywordString("RTR_HoodKW") && LowerableHoods.HasForm(thisArmor)
        ;MiscUtil.PrintConsole(">>>>>> item " + thisArmor.GetName() + " type: Hood")
        return "Hood"
    elseif thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet")
        ;MiscUtil.PrintConsole(">>>>>> item " + thisArmor.GetName() + " type: Circlet")
        return "Circlet"
    elseif thisArmor.IsHelmet()
        ;MiscUtil.PrintConsole(">>>>>> item " + thisArmor.GetName() + " type: Helmet")
        return "Helmet"
    endif

    ;MiscUtil.PrintConsole(">>>>>> Type could not be inferred for item " + thisArmor.GetName())
    return "None"
EndFunction

; RTR_GetEquipped
; Gets the Form for the item equipped in the HEAD biped slot
;
; @param Actor target_actor
; @param Bool manage_circlets
; @return Armor
Form Function RTR_GetEquipped(Actor target_actor, Bool manage_circlets) global
    ;MiscUtil.PrintConsole(">>> [RTRUtil] RTR_GetEquipped")

    ReadTheRoomUtil s
    Form equipped_head_wear

    ; Ignore slots that are not possible head wear
    int slotsChecked
    slotsChecked += 0x00000004 ; Body
    slotsChecked += 0x00000008 ; Hands
    slotsChecked += 0x00000010 ; Forearms
    slotsChecked += 0x00000020 ; Amulet
    slotsChecked += 0x00000040 ; Ring
    slotsChecked += 0x00000080 ; Feet
    slotsChecked += 0x00000100 ; Calves
    slotsChecked += 0x00000200 ; Shield
    slotsChecked += 0x00000400 ; Tail

    int maxSlot = 0x00040000 ; Only check up unreserved named slots (up to 43)
 
    int thisSlot = 0x01 
    while (thisSlot < 0x00040000) 
        if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot) ; only check slots we haven't found anything equipped on already
            Armor thisArmor = target_actor.GetWornForm(thisSlot) as Armor
            if (thisArmor)
                if (thisArmor.isHelmet()) ; Equipped item is a helmet/hood
                    if (thisArmor.HasKeywordString("RTR_HoodKW"))
                        ;MiscUtil.PrintConsole(">>>>>> Found a Worn Hood " + thisArmor.GetName())
                        return thisArmor
                    else
                        ;MiscUtil.PrintConsole(">>>>>> Found a Worn Helmet " + thisArmor.GetName())
                        return thisArmor
                    endif
                elseif (manage_circlets && (thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet"))) ; if this is a circlet or hat
                    ;MiscUtil.PrintConsole(">>>>>> Found a Worn Circlet/Hat " + thisArmor.GetName())
                    ;MiscUtil.PrintConsole(">>>>>> Circlet/Hat SlotMask " + thisArmor.GetSlotMask())
                    return thisArmor
                endif
                slotsChecked += thisArmor.GetSlotMask() ; add all slots this item covers to our slotsChecked variable
            else ; no armor was found on this slot
                slotsChecked += thisSlot
            endif
        endif
        thisSlot *= 2 ; double the number to move on to the next slot
    endWhile
    
    return equipped_head_wear
EndFunction

; RTR_IsTorsoEquipped
; Checks if the player has any torso armor equipped
;
; @return Bool
Bool Function RTR_IsTorsoEquipped(Actor target_actor) global
    ReadTheRoomUtil s
	Armor TorsoArmor = target_actor.GetEquippedArmorInSlot(32) as Armor
    if TorsoArmor == None
        ; SOS moves armor to slot 52 so check there too
        TorsoArmor = target_actor.GetEquippedArmorInSlot(52) as Armor
    endif
	return TorsoArmor != None
EndFunction

; RTR_LocationHasKeyword
; Checks if a location has any of the keywords in a FormList
;
; @param Location current_loc
; @param FormList keywords_to_check
; @return Bool
Bool Function RTR_LocationHasKeyword(Location current_loc, FormList keywords_to_check) global
	int i = 0
	while i < keywords_to_check.GetSize()
		if current_loc.HasKeyword(keywords_to_check.GetAt(i) as Keyword)
			return true
		endif
		i += 1
	endwhile
	return false
EndFunction

; RTR_GetLocationAction
; Determines if the player should equip or unequip their headwear based on the location
;
; @param Location loc
; @param Bool has_valid_helmet
; @param Bool equip_when_safe
; @param Bool unequip_when_unsafe
; @param FormList safe_keywords
; @param FormList hostile_keywords
; @return String "Equip", "Unequip", or "None"
String Function RTR_GetLocationAction(Location loc, Bool has_valid_helmet, Bool equip_when_safe, Bool unequip_when_unsafe, FormList safe_keywords, FormList hostile_keywords) global
    Bool IsSafe = RTR_LocationHasKeyword(loc, safe_keywords)
	Bool IsHostile = RTR_LocationHasKeyword(loc, hostile_keywords)

    if has_valid_helmet
        ; Unequip in safe/non-hostile locations
        Bool CanUnequipInSafeLoc = IsSafe && !unequip_when_unsafe
        Bool CanUnequipInNonHostileLoc = !IsHostile && unequip_when_unsafe

        if CanUnequipInSafeLoc || CanUnequipInNonHostileLoc
            return "Unequip"
        endif
    else
        ; Equip in hostile/non-safe locations
        Bool CanEquipInHostileLoc = IsHostile && !equip_when_safe
        Bool CanEquipInNonHostileLoc = !IsHostile && equip_when_safe

        if CanEquipInHostileLoc || CanEquipInNonHostileLoc
            return "Equip"
        endif
    endif

    return "None"
EndFunction

; RTR_SheathWeapon
; If actors weapons are drawn, sheath them
;
; @param Actor target_actor
; @return Bool true if weapons were sheathed
Bool Function RTR_SheathWeapon(Actor target_actor) global
    if target_actor.IsWeaponDrawn()
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		while target_actor.GetAnimationVariableInt("IsUnequipping") == 1
			utility.wait(0.01)
		endwhile
        return true
	endif
    return false
EndFunction

; RTR_ForceThirdPerson
; If the player is in first person, force them into third person
; NPCs don't have a i1stPerson animation var so this will ignore followers
;
; @param Actor target_actor
; @return Bool true if player was forced into third person
Bool Function RTR_ForceThirdPerson(Actor target_actor) global
    if target_actor.GetAnimationVariableInt("i1stPerson") == 1 
		Game.ForceThirdPerson()
		return true
	endif
    return false
EndFunction

; RTR_Log
; Prints a message to the console if logging is enabled
;
; @param String msg
Function RTR_PrintDebug(String msg) global
    ; if !logging_enabled
    ;     return
    ; endif

    MiscUtil.PrintConsole(msg)
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Positioning Helpers ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Anchor Array Index Mapping from Script Property
; The ReadTheRoom.esp plugin provies Anchors as arrays of GlobalVariable Objects
; Example: [PosX, PosY, PosZ, RotRoll, RotPitch, RotYaw, CircletPosX, CircletPosY, CircletPosZ, CircletRotRoll, CircletRotPitch, CircletRotYaw]

; RTR_GetPosition
; Takes an Anchor Positioning Array and translates it to an IED positoin variable
;
; @param String HelmType
; @param FormList Anchor
; Returns Float[3] = {x, y, z}
Float[] Function RTR_GetPosition(String helm_type, Form[] anchor) global
    ;MiscUtil.PrintConsole(">>> [RTRUtil] RTR_GetPosition")
    Int PosXIndex = 0
    Int PosYIndex = 1
    Int PosZIndex = 2
    Int CircletIndexOffset = 6
    Float[] position = new Float[3]
    
    if helm_type == "Circlet"
        position[0] = (anchor[PosXIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        position[1] = (anchor[PosYIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        position[2] = (anchor[PosZIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        
        ;MiscUtil.PrintConsole(">>>>>> Applying CircletIndexOffset: " + CircletIndexOffset)
        ;MiscUtil.PrintConsole(">>>>>>  Circlet PosX Index " + (PosXIndex + CircletIndexOffset) + " Value: " + position[0])
        ;MiscUtil.PrintConsole(">>>>>>  Circlet PosY Index " + (PosYIndex + CircletIndexOffset) + " Value: " + position[1])
        ;MiscUtil.PrintConsole(">>>>>>  Circlet PosZ Index " + (PosZIndex + CircletIndexOffset) + " Value: " + position[2])
    else
        position[0] = (anchor[PosXIndex] as GlobalVariable).GetValue()
        position[1] = (anchor[PosYIndex] as GlobalVariable).GetValue()
        position[2] = (anchor[PosZIndex] as GlobalVariable).GetValue()

        ;MiscUtil.PrintConsole(">>>>>>  PosX Index " + PosXIndex + " Value: " + position[0])
        ;MiscUtil.PrintConsole(">>>>>>  PosY Index " + PosYIndex + " Value: " + position[1])
        ;MiscUtil.PrintConsole(">>>>>>  PosZ Index " + PosZIndex + " Value: " + position[2])
    endif

    return position
EndFunction

; RTR_GetRotation
; Takes an Anchor Positioning Array and translates it to an IED rotation variable
;
; @param String helm_type
; @param GlobalVariable[] anchor
; @return Float[3] = {pitch, roll, yaw}
Float[] Function RTR_GetRotation(String helm_type, Form[] anchor) global
    Int RotPitchIndex = 3 
    Int RotRollIndex = 4 
    Int RotYawIndex = 5
    Int CircletIndexOffset = 6
    Float[] rotation = new Float[3]
    
    if helm_type == "Circlet"
        rotation[0] = (anchor[RotPitchIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        rotation[1] = (anchor[RotRollIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        rotation[2] = (anchor[RotYawIndex + CircletIndexOffset] as GlobalVariable).GetValue()

        ;MiscUtil.PrintConsole(">>>>>> Applying CircletIndexOffset: " + CircletIndexOffset)
        ;MiscUtil.PrintConsole(">>>>>>  Circlet Pitch Index " + (RotPitchIndex + CircletIndexOffset) + " Value: " + rotation[0])
        ;MiscUtil.PrintConsole(">>>>>>  Circlet Roll Index " + (RotRollIndex + CircletIndexOffset) + " Value: " + rotation[1])
        ;MiscUtil.PrintConsole(">>>>>>  Circlet Yaw Index " + (RotYawIndex + CircletIndexOffset) + " Value: " + rotation[2])
    else
        rotation[0] = (anchor[RotPitchIndex] as GlobalVariable).GetValue()
        rotation[1] = (anchor[RotRollIndex] as GlobalVariable).GetValue()
        rotation[2] = (anchor[RotYawIndex] as GlobalVariable).GetValue()

        ;MiscUtil.PrintConsole(">>>>>>  Pitch Index " + RotPitchIndex + " Value: " + rotation[0])
        ;MiscUtil.PrintConsole(">>>>>>  Roll Index " + RotRollIndex + " Value: " + rotation[1])
        ;MiscUtil.PrintConsole(">>>>>>  Yaw Index " + RotYawIndex + " Value: " + rotation[2])
    endif

    return rotation
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;; Immersive Equipment Display - Utilities ;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RTR_GetLastEquipped
; Gets the Form for the last equipped item in a slot
;
; @todo Get details of aiBipedSlots from in game IED config menu
; @param Actor target_actor
; @param String prev_equip_type
; @return Form
Form Function RTR_GetLastEquipped(Actor target_actor, String LastEquippedType) global
    ;MiscUtil.PrintConsole(">>> [RTRUtil] RTR_GetLastEquipped")

    Form last_equipped
    Int helmet_aiBipedSlot = 1
    Int circlet_aiBipedSlot = 12

    ; If we happen to have a last equipped type, use it
    if LastEquippedType == "Circlet"
        last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)
        if last_equipped
            ;MiscUtil.PrintConsole(">>>>>> found Circlet/Hat  " + (last_equipped as Armor).GetName() + "  in IED.aiBipedSlot 12")
            return last_equipped
        endif
    endif
    
    ; Attempt to Get From helmet_aiBipedSlot
    last_equipped = GetLastEquippedForm(target_actor, helmet_aiBipedSlot, true, false)
    if last_equipped
        ;MiscUtil.PrintConsole(">>>>>> found helmet " + (last_equipped as Armor).GetName() + " in IED.aiBipedSlot 1")
        return last_equipped
    endif

    ; Attempt to Get From circlet_aiBipedSlot
    last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)
    if last_equipped
        ;MiscUtil.PrintConsole(">>>>>> found Circlet/Hat  " + (last_equipped as Armor).GetName() + "  in IED.aiBipedSlot 12")
    endif

    return last_equipped
EndFunction

; RTR_GetActionString
; Returns the correct action string for the animation event based on the RTR_Action
;
; @TODO - Move to ReadTheRoomUtil
; @param int RTRAction
; @return String
String Function RTR_GetActionString(int RTR_Action) global
	String[] AnimationActionMap = new String[4]
	AnimationActionMap[0] = "None" ; None
	AnimationActionMap[1] = "Equip" ; Equip
	AnimationActionMap[2] = "Unequip" ; Unequip
	AnimationActionMap[3] = "EquipHood" ; Equip Lowerable Hood
	AnimationActionMap[4] = "UnequipHood" ; Unequip Lowerable Hood
	return AnimationActionMap[RTR_Action]
EndFunction
