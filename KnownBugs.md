# Known Bugs

Bugs that either I've encountered or were reported in "Bugs" tab of the original mod.

## Looking Into

- [ ] Equip/Unequip helmet while in beast form breaks the character
- [ ] Some Vanilla/DLC Masks and Hoods break RTR
- [ ] Wooden Mask (Labyrithian) Auto equips when leaving the mask realm
  - Pretty sure the Remaster fixes this but I haven't tested it yet
- [ ] Undeletable
  - This issue is being addressed in a future plans feature
- [ ] CC Content helmets and hats don't work
- [ ] Some Vanilla/DLC Hoods aren't lowered and instead are treated like helmets
- [ ] Function 'Require Armor for Hip Placement' is bugged
- [ ] Immersive Armors Helmets don't work
- [ ] Circlets are still treated as Helmets even if "Manage Circlets like Helmets" is disabled in the MCM
  - I think the Remaster fixes this but I need to test

## Tweaks and Enhancements

  - Tools used
    - [HKanno64](https://www.nexusmods.com/skyrimspecialedition/mods/54244)
    - [SkyrimGulid Annotation Tool](https://www.skyrim-guild.com/guides/skyrimannotationtool)

- [ ] Add new "RTRNoAnimation" keyword to the `ReadTheRoom_Exclusions_KID.ini` so people can set modded head gear with bad gnd meshes to still equip/unequip but skip the animations/hand and hip attachment.
- [ ] Better "Last Equipped" tracking. 
  - Currently it is only tracked through IED and requires the mod to make a call to get the item from IED and then run logic to "categorize" it. This is an issue when exiting your inventory because there is an event trigger for when you close the inventory to refresh the helmet placements based on this last equipped item regardless if you intentionally removed it or switched to another item that's on the exclusion list. 
  - This changes the logic so if you intentionally "unequip" an object it will track that and not show the item on your belt or as a lowerable hood. 
  - New MCM option to control if unequipping an item in the inventory attaches the item to your belt just like if you changed locations or hit the keybinding
  - Defaults to "Clear on unequip" so items removed in the inventory don't attach through RTR