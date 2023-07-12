ScriptName ReadTheRoomUtil 

Import IED

String Property PluginName = "ReadTheRoom.esp" Auto

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; ReadTheRoom Functions ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; RTR_IsValidHeadWear
; Checks if an item is a valid headwear item
;
; @param Form item
; @return Bool
Bool function RTR_IsValidHeadWear(Actor target_actor, Form item, FormList LoweredHoods) global
    ; Make sure there really is an item to check against
    if !item
        return false
    endif

    ; Has this item been assigned to the exclusion list?
    Bool isExcluded = item.HasKeywordString("RTR_ExcludeKW")
    if isExcluded
        return false
    endif

    ; Is the item a helmet, circlet, or hood?
    Bool isHelmet = (item as Armor).IsHelmet()
    Bool isCirclet = item.HasKeywordString("ClothingCirclet")
    Bool isHood = item.HasKeywordString("RTR_HoodKW")
    if isHelmet || isCirclet || isHood
        ; Since Lowered Hoods are equipped (dumb) make sure the item isn't one of those
        if isHood && LoweredHoods.HasForm(item)
            return false
        endif

        ; Does the actor have the item in their inventory?
        if target_actor.GetItemCount(item) <= 0
            return false
        endif

        return true
    endif

    ; Item is not head gear
    return false
endFunction

; RTR_InferItemType
; Infers the type of headwear an item Form is
;
; @param Form item
; @return String
Bool function RTR_InferItemType(Form item, FormList LowerableHoods) global
    ; Check if a hood has been set up to be lowered
    if item.HasKeywordString("RTR_HoodKW") && LowerableHoods.HasForm(item)
        return "Hood"
    elseif item.HasKeywordString("ClothingCirclet")
        return "Circlet"
    elseif (item as Armor).IsHelmet()
        return "Helmet"
    endif

    return "None"
endFunction

Form function RTR_GetEquipped(Actor target_actor, Bool manage_circlets) global
    ; Get any item equipped in the HEAD biped slot
    Form equipped = PlayerRef.GetWornForm(kSlotMask30)
    
    ; Check for a circlet
    if ManageCirclets.getValueInt() == 1 && !equipped
        equipped = PlayerRef.GetWornForm(kSlotMask42)
    endif

    return equipped
endFunction

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;; Positioning Helpers ;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Anchor Array Index Mapping from Script Property
; The ReadTheRoom.esp plugin provies Anchors as arrays of GlobalVariables
; Example: [PosX, PosY, PosZ, RotRoll, RotPitch, RotYaw, CircletPosX, CircletPosY, CircletPosZ, CircletRotRoll, CircletRotPitch, CircletRotYaw]
Int Property PosXIndex = 0 Auto
Int Property PosYIndex = 1 Auto
Int Property PosZIndex = 2 Auto
Int Property RotRollIndex = 3 Auto
Int Property RotPitchIndex = 4 Auto
Int Property RotYawIndex = 5 Auto
Int Property CircletIndexOffset = 6 Auto

; RTR_GetPosition
; Takes an Anchor Positioning Array and translates it to an IED positoin variable
;
; @param String HelmType
; @param GlobalVariable[] Anchor
; Returns Float[3] = {x, y, z}
Float[] function RTR_GetPosition(String helm_type, GlobalVariable[] anchor)
    Float[] position = new Float[3]
    
    if helm_type == "Circlet"
        position[0] = anchor[PosXIndex + CircletIndexOffset].getValue()
        position[1] = anchor[PosYIndex + CircletIndexOffset].getValue()
        position[2] = anchor[PosZIndex + CircletIndexOffset].getValue()
    else
        position[0] = anchor[PosXIndex].getValue()
        position[1] = anchor[PosYIndex].getValue()
        position[2] = anchor[PosZIndex].getValue()
    endif

    return position
endFunction

; RTR_GetRotation
; Takes an Anchor Positioning Array and translates it to an IED rotation variable
;
; @param String helm_type
; @param GlobalVariable[] anchor
; @return Float[3] = {pitch, roll, yaw}
Float[] function RTR_GetRotation(String helm_type, GlobalVariable[] anchor)
    Float[] rotation = new Float[3]
    
    if helm_type == "Circlet"
        rotation[0] = anchor[RotPitchIndex + CircletIndexOffset].getValue()
        rotation[1] = anchor[RotRollIndex + CircletIndexOffset].getValue()
        rotation[2] = anchor[RotYawIndex + CircletIndexOffset].getValue()
    else
        rotation[0] = anchor[RotPitchIndex].getValue()
        rotation[1] = anchor[RotRollIndex].getValue()
        rotation[2] = anchor[RotYawIndex].getValue()
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
    Form last_equipped
    Int circlet_aiBipedSlot = 12
    Int helmet_aiBipedSlot = 1
    Int hair_aiBipedSlot = 0

    ; Attempt to Get From Circlet BipedSlot
    last_equipped = GetLastEquippedForm(target_actor, circlet_aiBipedSlot, true, false)

    ; Attempt to Get From Helmet BipedSlot
    if last_equipped as String == "None"
        last_equipped = GetLastEquippedForm(target_actor, helmet_aiBipedSlot, true, false)
    endif

    ; Attempt to Get From Hair BipedSlot
    if last_equipped as String == "None"
        last_equipped = GetLastEquippedForm(target_actor, hair_aiBipedSlot, true, false)
    endif

    return last_equipped
endFunction

; RTR_Attach
; Attaches an IED Object to an Actor
;
; @todo Refactor to reduce the number of parameters
; @param Actor target_actor
; @param String attachment_name
; @param Form item
; @param String item_type
; @param Float item_scale
; @param String node_name
; @param bool is_female
; @param GlobalVariable[] anchor
; @return void
function RTR_Attach(Actor target_actor, String attachment_name, Form item, String item_type, Float item_scale, String node_name, bool is_female, GlobalVariable[] anchor) global
    ReadTheRoomUtil s
    Bool inventory_required = true

    Float[] pos = s.RTR_GetPosition(item_type, anchor)
    Float[] rot = s.RTR_GetRotation(item_type, anchor)

    CreateItemActor(target_actor, s.PluginName, attachment_name, is_female, item, inventory_required, node_name)
    SetItemFormActor(target_actor, s.PluginName, attachment_name, is_female, item)
    SetItemNodeActor(target_actor, s.PluginName, attachment_name, is_female, node_name)
    SetItemPositionActor(target_actor, s.PluginName, attachment_name, is_female, pos)
    SetItemRotationActor(target_actor, s.PluginName, attachment_name, is_female, rot)
    if item_type == "Helmet"
        SetItemScaleActor(target_actor, s.PluginName, attachment_name, is_female, item_scale)
    endif
    SetItemEnabledActor(target_actor, s.PluginName, attachment_name, is_female, true)
endFunction

; RTR_IsAttached
; Checks if an IED Object is attached to an Actor
;
; @param Actor target_actor
; @param String attachment_name
; @param Bool is_female
; @return Bool
Bool function RTR_IsAttached(Actor target_actor, String attachment_name, Bool is_female = false) global
    ReadTheRoomUtil s
    return ItemEnabledActor(target_actor, s.PluginName, attachment_name, is_female)
endFunction

; RTR_Detatch
; Detach an IED Object from Actor
;
; @param Actor target_actor
; @param String attachment_name
; @return void
function RTR_Detatch(Actor target_actor, String attachment_name) global
    ReadTheRoomUtil s
    DeleteItemActor(target_actor, s.PluginName, attachment_name)
endFunction

; RTR_DetatchAllActor
; Detach All IED Objects from an Actor
;
; @param Actor target_actor
; @return void
function RTR_DetatchAllActor(Actor target_actor) global
    ReadTheRoomUtil s
    DeleteAllActor(target_actor, s.PluginName)
endFunction

; RTR_DetatchAll
; Detach All IED Objects from all Actors
;
; @return void
function RTR_DetatchAll() global
    ReadTheRoomUtil s
    DeleteAll(s.PluginName)
endFunction
