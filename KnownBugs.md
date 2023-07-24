# Known Bugs - Currently Looking Into

These are bugs that either I've encountered or were reported in "Bugs" tab of the original mod.
Check the Change Log for a list of bugs that have been squashed so far!

- [ ] Equip/Unequip helmet while in beast form breaks the character
- [ ] Some Vanilla/DLC Masks and Hoods break RTR
- [ ] Wooden Mask (Labyrithian) Auto equips when leaving the mask realm
  - Pretty sure the Remaster fixes this but I haven't tested it yet
- [ ] Cannot remove ReadTheRoom
  - This issue is being addressed in the "Uninstall Button" feature outlined in the "future plans" section.
- [ ] CC Content helmets and hats don't work
- [ ] Some Vanilla/DLC Hoods aren't lowered and instead are treated like helmets
- [ ] Function 'Require Armor for Hip Placement' is bugged
- [ ] Immersive Armors Helmets don't work
- [ ] Circlets are still treated as Helmets even if "Manage Circlets like Helmets" is disabled in the MCM
  - I think the Remaster fixes this but I need to test

# Remastered Version

- [ ] Compatibility issue with Nether's Follower Framework. 
  - After loading a save, followers will equip their head wear after the first cell. If the player toggles headwear between the first and the second cell change the issue is corrected for the rest of the play session. I am working on a fix for this but it is a complex issue around NFF's outfit management. ***Note*** the issue happens even if NFFs outfit management is disabled.
- [ ] Lowerable hoods have a brief fully unequiped state when unequipping after a Combat Equip. The hood is removed without a lowered hood added and then the animation plays a tiny bit of time after that. It's not ... game breaking, but it does break the immersion.
