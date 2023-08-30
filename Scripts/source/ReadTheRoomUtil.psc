ScriptName ReadTheRoomUtil Hidden

Import IED ; Immersive Equipment Display

String property PluginName = "ReadTheRoom.esp" auto

; RTR_GetVersion
; Returns the hard set version of ReadTheRoom
; Used for detecting if a scripts properties need to be updated or not
;
; @return Float
Float Function RTR_GetVersion() global
    return 1.24
EndFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;; ReadTheRoom Helpers ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RTR_CanRun
; Checks if the script should be running
;
; @return Bool
Bool Function RTR_CanRun() global
    ; Check Controls and Exit Early if any of them are disabled
	; Solves any issue with RTR trigging when something else has purposefully disabled controls
	if !Game.IsActivateControlsEnabled() || \
		!Game.IsCamSwitchControlsEnabled() || \
		!Game.IsFightingControlsEnabled() || \
		!Game.IsJournalControlsEnabled() || \
		!Game.IsMenuControlsEnabled() || \
		!Game.IsMovementControlsEnabled() || \
		!Game.IsSneakingControlsEnabled()
		return false
	endif
    return true
EndFunction

; RTR_IsValidHeadWear
; Checks if an item is a valid headwear item
;
; @param Form item
; @return Bool
Bool Function RTR_IsValidHeadWear(Actor target_actor, Form item, FormList LoweredHoods) global
    ; Make sure there really is an item to check against
    if !item
        return false
    endif

    Armor thisArmor = item as Armor

    ; Has this item been assigned to the exclusion list?
    Bool isExcluded = thisArmor.HasKeywordString("RTR_ExcludeKW")
    if isExcluded
        return false
    endif

    ; Is the item a helmet, circlet, or hood?
    Bool isHelmet = thisArmor.IsHelmet()
    Bool isCirclet = thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet")
    Bool isHood = thisArmor.HasKeywordString("RTR_HoodKW")
    if isHelmet || isCirclet || isHood
        ; Since Lowered Hoods are equipped and not placed through IED they can show up here, we need to 
        ; invalidate them so they character doesn't try to equip/unequip them
        if LoweredHoods.HasForm(item)
            return false
        endif

        return true
    endif

    ; Item is not head gear
    return false
EndFunction

; RTR_InferItemType
; Infers the type of headwear an item Form is
;
; @param Form item
; @return String
String Function RTR_InferItemType(Form item) global
    Armor thisArmor = item as Armor

    ; Check if a hood has been set up to be lowered
    if thisArmor.HasKeywordString("RTR_HoodKW")
        return "Hood"
    elseif thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet")
        return "Circlet"
    elseif thisArmor.IsHelmet()
        return "Helmet"
    endif

    return "None"
EndFunction

; RTR_GetEquipped
; Gets the Form for the item equipped in the HEAD biped slot
;
; @param Actor target_actor
; @param Bool manage_circlets
; @return Armor
Form Function RTR_GetEquipped(Actor target_actor, Bool manage_circlets) global
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
    while (thisSlot < maxSlot) 
        if (Math.LogicalAnd(slotsChecked, thisSlot) != thisSlot) ; only check slots we haven't found anything equipped on already
            Armor thisArmor = target_actor.GetWornForm(thisSlot) as Armor
            if (thisArmor)
                if (thisArmor.HasKeywordString("RTR_HoodKW")) ; Equipped item is a hood
                    return thisArmor
                elseif (thisArmor.isHelmet()) ; Equipped item is a helmet
                    return thisArmor
                elseif (manage_circlets && (thisArmor.IsClothingHead() || thisArmor.HasKeywordString("ClothingCirclet"))) ; if this is a circlet or hat
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

; RTR_GetLoweredHood
; Match a forms keywords to a lowered hood keyword and then get the cooresponding lowered hood form
;
; @param Form Hood
; @param FormList LowerableHoodKeywords
; @param FormList LoweredHoods
; @return Form
Form Function RTR_GetLoweredHood(Form Hood, FormList LowerableHoodKeywords, FormList LoweredHoods) global
    int i = 0
    int keywordCount = LowerableHoodKeywords.GetSize()
    while i < keywordCount
        Form kw = LowerableHoodKeywords.GetAt(i)
        if kw.GetType() == 4 ; Keyword Type - Generalized Assignment
            if Hood.HasKeyword(kw as Keyword)
                return LoweredHoods.GetAt(i)
            endif
        elseif kw.GetType() == 26 ; Armor - Direct Assignment
            if Hood == kw
                return LoweredHoods.GetAt(i)
            endif
        endif
        i += 1
    endwhile
    return None
EndFunction

; RTR_IsTorsoEquipped
; Checks if the player has any torso armor equipped
;
; @return Bool
Bool Function RTR_IsTorsoEquipped(Actor target_actor) global
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
; @param Int equip_when 0 = Nearing Danger, 1 = Leaving Safety, 3 = Only On toggle
; @param Int unequip_when 0 = Entering Safety, 1 = Leaving Danger, 3 = Only On toggle
; @param FormList safe_keywords
; @param FormList hostile_keywords
; @return String "Entering Safety", "Leaving Safety", "Nearing Danger", "Leaving Danger", or "None"
String Function RTR_GetLocationAction(Location loc, Bool is_wearing_headwear, Int equip_when, Int unequip_when, FormList safe_keywords, FormList hostile_keywords) global
    Bool isSafe = RTR_LocationHasKeyword(loc, safe_keywords)
	Bool isHostile = RTR_LocationHasKeyword(loc, hostile_keywords)

    if is_wearing_headwear
        ; Unequip by Location 
        if isSafe && unequip_when == 0
            return "Entering Safety"
        endif

        if !isHostile && unequip_when == 1
            return "Leaving Danger"
        endif
    else
        ; Equip by Location 
        if isHostile && equip_when == 0
            return "Nearing Danger"
        endif

        if !isSafe && !isHostile && equip_when == 1
            return "Leaving Safety"
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
		Bool finishedEquipUnequip = target_actor.GetAnimationVariableInt("IsEquipping") == 0 && target_actor.GetAnimationVariableInt("IsUnequipping") == 0
		Int waitCount = 0
		while !finishedEquipUnequip && waitCount < 60
			Utility.wait(0.1)
			finishedEquipUnequip = target_actor.GetAnimationVariableInt("IsEquipping") == 0 && target_actor.GetAnimationVariableInt("IsUnequipping") == 0
			waitCount += 1
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
    Int PosXIndex = 0
    Int PosYIndex = 1
    Int PosZIndex = 2
    Int CircletIndexOffset = 6
    Float[] position = new Float[3]
    
    if helm_type == "Circlet"
        position[0] = (anchor[PosXIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        position[1] = (anchor[PosYIndex + CircletIndexOffset] as GlobalVariable).GetValue()
        position[2] = (anchor[PosZIndex + CircletIndexOffset] as GlobalVariable).GetValue()
    else
        position[0] = (anchor[PosXIndex] as GlobalVariable).GetValue()
        position[1] = (anchor[PosYIndex] as GlobalVariable).GetValue()
        position[2] = (anchor[PosZIndex] as GlobalVariable).GetValue()
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
    else
        rotation[0] = (anchor[RotPitchIndex] as GlobalVariable).GetValue()
        rotation[1] = (anchor[RotRollIndex] as GlobalVariable).GetValue()
        rotation[2] = (anchor[RotYawIndex] as GlobalVariable).GetValue()
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
    Form last_equipped = None
    Int helmet_aiBipedSlot = 1
    Int circlet_aiBipedSlot = 12

    ; If we happen to have a last equipped type, use it
    if LastEquippedType == "Circlet"
        last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)
        if last_equipped
            return last_equipped
        endif
    endif
    
    ; Attempt to Get From helmet_aiBipedSlot
    last_equipped = GetLastEquippedForm(target_actor, helmet_aiBipedSlot, true, false)
    if last_equipped
        return last_equipped
    endif

    ; Attempt to Get From circlet_aiBipedSlot
    last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)
    
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
