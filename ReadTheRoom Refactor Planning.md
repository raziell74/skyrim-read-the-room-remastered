# ReadTheRoom Refactor Planning

This document outlines my plans and strategy for refactoring ReadTheRoom

## Behavior based event handling

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

## Lowerable Hoods - IED Attachment 

Lowerable hoods is a half baked feature with very limited functionality. The current implementation doesn't even follow the same processes as the rest of the helmet management. Lowered Hood models were custom made for the vanilla hoods and they are equipped instead of attached via IED. This is because no valid ground meshes were ever made for these items. 

In addition to being physically equipped on Actors there is also no real way to manage the hoods or add new compatibility for mod added hoods. Hoods that can be "lowered" are identified through a FormList called `LowerableHoods`. These share a 1 to 1 relation to another FormList that holds a list of `LoweredHoods`. So if a hood is in the Lowerable list it will look at the same array index to get the armor item to swap to that represents the Lowered version of the hood.

Lowerable Hoods Update Tasks

- Generate a GND mesh for all current lowered hoods
  - IED uses the GND mesh (AKA ground mesh, AKA world model, AKA inventory model) as the model it uses to display items on the character
  - [Video Tutorial using BodySlide->Outfit Studio](https://www.youtube.com/watch?v=K2gI-_nFchA&ab_channel=SunJeongCh.)
  - *xEdit nifscope script??? 
    - Perhaps I can figure out how to write an xEdit script to auto generate ground meshes similar to how AllGud has scripts to generate meshes for weapons
    - It could make fixing broken modded items that don't have valid ground meshes or ground meshes that positioned in the correct location
- Add Lowered Hood IED node positioning variables to esp
  - Once ground meshes are generated and identically positioned
  - Go into IED in-game and position the lowered hood model to get Attachment Node, PosX, PosY, PosZ, RotPitch, RotRoll, and RotYaw
  - Use the IED in-game preset to check each ground mesh for accuracy
- Update scripts to attach lowered hoods via IED like any other helmet or circlet

### Lowerable Hoods Assignment Refactor

Using FormLists set up in an ESP is not very extendable. Making it very difficult add new lowerable hood compatibility for other mods or even CC content.

Options:

- Use FLM to update the formlists
  - This will somewhat works but has a downfall that exists because FLM doesn't add duplicates. So you cannot use a single lowered hood armor for more than one Lowerable Hood
  - Even with that draw back this is the easiest to implement solution for the time being
- Overhaul system to load through a JSON file. 
  - This comes with a ton of added work for me, but could help people make their own compatibility patches

# New Dependencies

- [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048)
    - Used for the `ScanCellNPCs` function to detect NPCs in a 500 radius around the Player that have the `RTR_Follower` keyword. This should solve the issue with mod added followers not being tracked.
- [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
    - Will Inject new unique RTR animation events and animation variables into the behavior graphs
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089)
    - Uses updated animation annotations to trigger updates on the new animation variables