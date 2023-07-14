# ReadTheRoom Refactor Planning

Possibly to use IED.SetItemAnimationEventEnabledActor to simplify IED placement triggers in the onAnimationEvent?
This would mean we could create the hip, hood, and hand attachments onInit  
and then just update the Form on the asName (attachment_name) in Actor.OnObjectEquipped and Actor.OnObjectUnequipped 
Animation Events set in the annotations can then control the enable/disable state of IED attachments on the actor

If the IED attachment is always there can we get the form that it is set to using `IED.GetSlottedForm(Actor akActor, int aiSlot)`?
To test this I should add debug print outs for iterations through IED aiBiped slots to figure out which one holds our specified equipment attachment

ReadTheRoom Animation Variables
    Name: RTR_Action
    Anno: PIE.@SGVI|RTR_Active|(int) RTR action identifier
    Desc: Tracks if RTR is active in an actors animation graph and identifies what action RTR is doing.
    - 0: Inactive
    - 1: Equipping Helmet/Circlet
    - 2: Unequipping Helmet/Circlet
    - 3: Equipping Lowerable Hood
    - 4: Unequipping Lowerable Hood 

    Name: RTR_Timeout
    Anno: PIE.@SGVF|RTR_Timeout|(float) animation_length
    Desc: If RTR_Active is still set after the animation length it is likely it was interrupted so we use this to do the final phase the helmet management since it won't be triggered by the animation event

    Name: RTR_RedrawWeapons
    Anno: None
    Desc: Set by the script for the player if they had their weapons drawn before the animation started. RTR_SetTimeout and RTR_OffsetStop events will check this if they need to redraw the players weapons.

    Name: RTR_ReturnToFirstPerson
    Anno: None
    Desc: Set by the script for the player if they were in first person before the animation started. RTR_SetTimeout and RTR_OffsetStop events will check this and return the player to first person.

ReadTheRoom Animation Events
    RTR_SetTimeout
    RTR_Equip
    RTR_Unequip
    RTR_AttachToHand
    RTR_RemoveFromHand
    RTR_AttachToHip
    RTR_RemoveFromHip
    RTR_AttachLoweredHood
    RTR_RemoveLoweredHood
    RTR_OffsetStop

# New Dependencies

- [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048)
    - Used for the `ScanCellNPCs` function to detect NPCs in a 500 radius around the Player that have the `RTR_Follower` keyword. This should solve the issue with mod added followers not being tracked.
- [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
    - Will Inject new unique RTR animation events and animation variables into the behavior graphs
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089)
    - Uses updated animation annotations to trigger updates on the new animation variables