ScriptName ReadTheRoomUtil 

Import IED

String Property PluginName = "ReadTheRoom.esp" Auto

; Anchor Array Index Mapping from Script Property
Int Property PosXIndex = 0 Auto
Int Property PosYIndex = 1 Auto
Int Property PosZIndex = 2 Auto
Int Property RotRollIndex = 3 Auto
Int Property RotPitchIndex = 4 Auto
Int Property RotYawIndex = 5 Auto
Int Property CircletIndexOffset = 6 Auto

; Takes an Anchor Positioning Array and translates it to an IED positoin variable
; Returns Float[3] = {x, y, z}
Float[] function RTR_GetPosition(String HelmType, GlobalVariable[] Anchor)
    Float[] position = new Float[3]
    
    if HelmType == "Circlet"
        position[0] = Anchor[PosXIndex + CircletIndexOffset].getValue()
        position[1] = Anchor[PosYIndex + CircletIndexOffset].getValue()
        position[2] = Anchor[PosZIndex + CircletIndexOffset].getValue()
    else
        position[0] = Anchor[PosXIndex].getValue()
        position[1] = Anchor[PosYIndex].getValue()
        position[2] = Anchor[PosZIndex].getValue()
    endif

    return position
endFunction

; Takes an Anchor Positioning Array and translates it to an IED rotation variable
; Returns Float[3] = {pitch, roll, yaw}
Float[] function RTR_GetRotation(String HelmType, GlobalVariable[] Anchor)
    Float[] rotation = new Float[3]
    
    if HelmType == "Circlet"
        rotation[0] = Anchor[RotPitchIndex + CircletIndexOffset].getValue()
        rotation[1] = Anchor[RotRollIndex + CircletIndexOffset].getValue()
        rotation[2] = Anchor[RotYawIndex + CircletIndexOffset].getValue()
    else
        rotation[0] = Anchor[RotPitchIndex].getValue()
        rotation[1] = Anchor[RotRollIndex].getValue()
        rotation[2] = Anchor[RotYawIndex].getValue()
    endif

    return rotation
endFunction

; IED Attach Item to Actor
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

; IED Detach Item from Actor
function RTR_Detatch(Actor target_actor, String attachment_name) global
    ReadTheRoomUtil s
    DeleteItemActor(target_actor, s.PluginName, attachment_name)
endFunction

; IED Detach All Items from Actor
function RTR_DetatchAll() global
    ReadTheRoomUtil s
    DeleteAll(s.PluginName)
endFunction

Bool function RTR_IsValidHeadWear(Form Item) global
    bool isHelmet = (Item as Armor).IsHelmet()
    bool isCirclet = Item.HasKeywordString("ClothingCirclet")
    bool isHood = Item.HasKeywordString("RTR_HoodKW")
    
    if isHelmet || isCirclet || isHood
        return true
    endif

    return false
endFunction
