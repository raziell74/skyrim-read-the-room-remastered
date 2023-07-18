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
Bool function RTR_IsValidHeadWear(Actor target_actor, Form item, FormList LoweredHoods) global
    MiscUtil.PrintConsole(">>>>>>>> [RTRUtil] RTR_IsValidHeadWear")
    ; Make sure there really is an item to check against
    if !item
        MiscUtil.PrintConsole(">> Provided form is null")
        return false
    endif

    ; Has this item been assigned to the exclusion list?
    Bool isExcluded = item.HasKeywordString("RTR_ExcludeKW")
    if isExcluded
        MiscUtil.PrintConsole(">> " + (item as Armor).GetName() + " has exclusion keyword (RTR_ExcludeKW). Invalid")
        return false
    endif

    ; Is the item a helmet, circlet, or hood?
    Bool isHelmet = (item as Armor).IsHelmet()
    Bool isCirclet = item.HasKeywordString("ClothingCirclet")
    Bool isHood = item.HasKeywordString("RTR_HoodKW")
    if isHelmet || isCirclet || isHood
        ; Since Lowered Hoods are equipped (dumb) make sure the item isn't one of those
        if isHood && LoweredHoods.HasForm(item)
            MiscUtil.PrintConsole(">> Detected Lowered Hood. Invalid")
            return false
        endif

        ; Does the actor have the item in their inventory?
        if target_actor.GetItemCount(item as Armor) == 0
            MiscUtil.PrintConsole(">> Missing from inventory. Invalid")
            return false
        endif

        MiscUtil.PrintConsole(">> Valid")
        return true
    endif

    ; Item is not head gear
    MiscUtil.PrintConsole(">> " + (item as Armor).GetName() + " is not head wear")
    return false
endFunction

; RTR_InferItemType
; Infers the type of headwear an item Form is
;
; @param Form item
; @return String
String function RTR_InferItemType(Form item, FormList LowerableHoods) global
    MiscUtil.PrintConsole(">>>>>>>> [RTRUtil] RTR_InferItemType")

    Armor thisArmor = item as Armor

    ; Check if a hood has been set up to be lowered
    if thisArmor.HasKeywordString("RTR_HoodKW") && LowerableHoods.HasForm(thisArmor)
        MiscUtil.PrintConsole(">> item " + thisArmor.GetName() + " type: Hood")
        return "Hood"
    elseif thisArmor.IsClothingHead()
        MiscUtil.PrintConsole(">> item " + thisArmor.GetName() + " type: Circlet")
        return "Circlet"
    elseif thisArmor.IsHelmet()
        MiscUtil.PrintConsole(">> item " + thisArmor.GetName() + " type: Helmet")
        return "Helmet"
    endif

    MiscUtil.PrintConsole(">> Type could not be inferred for item " + thisArmor.GetName())
    return "None"
endFunction

; RTR_GetEquipped
; Gets the Form for the item equipped in the HEAD biped slot
;
; @param Actor target_actor
; @param Bool manage_circlets
; @return Armor
Form function RTR_GetEquipped(Actor target_actor, Bool manage_circlets) global
    MiscUtil.PrintConsole(">>>>>>>> [RTRUtil] RTR_GetEquipped")

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
                        MiscUtil.PrintConsole(">> Found a Worn Hood " + thisArmor.GetName())
                        equipped_head_wear = thisArmor
                    else
                        MiscUtil.PrintConsole(">> Found a Worn Helmet " + thisArmor.GetName())
                        equipped_head_wear = thisArmor
                    endif
                elseif (manage_circlets && thisArmor.IsClothingHead()) ; if this is a circlet or hat
                    MiscUtil.PrintConsole(">> Found a Worn Circlet/Hat " + thisArmor.GetName())
                    MiscUtil.PrintConsole(">> Circlet/Hat SlotMask " + thisArmor.GetSlotMask())
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
endFunction

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
Bool function RTR_LocationHasKeyword(Location current_loc, FormList keywords_to_check) global
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
String function RTR_GetLocationAction(Location loc, Bool has_valid_helmet, Bool equip_when_safe, Bool unequip_when_unsafe, FormList safe_keywords, FormList hostile_keywords) global
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
        Bool CanEquipInHostileLoc = !has_valid_helmet && IsHostile && !equip_when_safe
        Bool CanEquipInNonHostileLoc = !has_valid_helmet && !IsHostile && equip_when_safe

        if CanEquipInHostileLoc || CanEquipInNonHostileLoc
            return "Equip"
        endif
    endif

    return "None"
endFunction

; RTR_SheathWeapon
; If actors weapons are drawn, sheath them
;
; @param Actor target_actor
; @return Bool true if weapons were sheathed
Bool function RTR_SheathWeapon(Actor target_actor) global
    if target_actor.IsWeaponDrawn()
		Game.DisablePlayerControls(0, 1, 0, 0, 0, 1, 1)
		while target_actor.GetAnimationVariableInt("IsUnequipping") == 1
			utility.wait(0.01)
		endwhile
        return true
	endif
    return false
endFunction

; RTR_ForceThirdPerson
; If the player is in first person, force them into third person
; NPCs don't have a i1stPerson animation var so this will ignore followers
;
; @param Actor target_actor
; @return Bool true if player was forced into third person
Bool function RTR_ForceThirdPerson(Actor target_actor) global
    if target_actor.GetAnimationVariableInt("i1stPerson") == 1 
		Game.ForceThirdPerson()
		return true
	endif
    return false
endFunction

; RTR_Log
; Prints a message to the console if logging is enabled
;
; @param String msg
function RTR_PrintDebug(String msg) global
    ; if !logging_enabled
    ;     return
    ; endif

    MiscUtil.PrintConsole(msg)
endFunction

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
Float[] function RTR_GetPosition(String helm_type, Form[] anchor) global
    MiscUtil.PrintConsole(">>>>>>>> [RTRUtil] RTR_GetPosition")
    Int PosXIndex = 0
    Int PosYIndex = 1
    Int PosZIndex = 2
    Int CircletIndexOffset = 6
    Float[] position = new Float[3]
    
    if helm_type == "Circlet"
        MiscUtil.PrintConsole(">> Applying CircletIndexOffset: " + CircletIndexOffset)
        MiscUtil.PrintConsole(">>  PosX Index" + (PosXIndex + CircletIndexOffset))
        position[0] = (anchor[PosXIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        MiscUtil.PrintConsole(">>  PosY Index" + (PosYIndex + CircletIndexOffset))
        position[1] = (anchor[PosYIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        MiscUtil.PrintConsole(">>  PosZ Index" + (PosZIndex + CircletIndexOffset))
        position[2] = (anchor[PosZIndex + CircletIndexOffset] as GlobalVariable).GetValue()
    else
        MiscUtil.PrintConsole(">>  PosX Index" + PosXIndex)
        position[0] = (anchor[PosXIndex] as GlobalVariable).GetValue()
        MiscUtil.PrintConsole(">>  PosY Index" + PosYIndex)
        position[1] = (anchor[PosYIndex] as GlobalVariable).GetValue()
        MiscUtil.PrintConsole(">>  PosZ Index" + PosZIndex)
        position[2] = (anchor[PosZIndex] as GlobalVariable).GetValue()
    endif

    return position
endFunction

; RTR_GetRotation
; Takes an Anchor Positioning Array and translates it to an IED rotation variable
;
; @param String helm_type
; @param GlobalVariable[] anchor
; @return Float[3] = {pitch, roll, yaw}
Float[] function RTR_GetRotation(String helm_type, Form[] anchor) global
    Int RotPitchIndex = 3 
    Int RotRollIndex = 4 
    Int RotYawIndex = 5
    Int CircletIndexOffset = 6
    Float[] rotation = new Float[3]
    
    if helm_type == "Circlet"
        rotation[0] = (anchor[RotPitchIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        rotation[1] = (anchor[RotRollIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        rotation[2] = (anchor[RotYawIndex + CircletIndexOffset] as GlobalVariable).GetValue()
    else
        rotation[0] = (anchor[RotPitchIndex] as GlobalVariable).GetValue()
        rotation[1] = (anchor[RotRollIndex] as GlobalVariable).GetValue()
        rotation[2] = (anchor[RotYawIndex] as GlobalVariable).GetValue()
    endif

    return rotation
endFunction

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
Form function RTR_GetLastEquipped(Actor target_actor) global
    MiscUtil.PrintConsole(">>>>>>>> [RTRUtil] RTR_GetLastEquipped")

    Form last_equipped
    Int helmet_aiBipedSlot = 1
    Int circlet_aiBipedSlot = 12
    
    ; Attempt to Get From helmet_aiBipedSlot
    last_equipped = GetLastEquippedForm(target_actor, helmet_aiBipedSlot, true, false)
    MiscUtil.PrintConsole(">> found helmet " + (last_equipped as Armor).GetName() + " in IED.aiBipedSlot 1")

    ; Attempt to Get From circlet_aiBipedSlot
    if last_equipped as String == "None"
        last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)
        MiscUtil.PrintConsole(">> found Circlet/Hat  " + (last_equipped as Armor).GetName() + "  in IED.aiBipedSlot 12")
    endif

    return last_equipped
endFunction
