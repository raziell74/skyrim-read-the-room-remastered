# Known Bugs - Currently Looking Into

These are bugs that either I've encountered or were reported in "Bugs" tab of the original mod.
Check the Change Log for a list of bugs that have been squashed so far!

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

# Remastered Version

- [ ] There's a compatibility bug with Nether's Follower Framework where after loading a save and then changing cells followers will equip their helmets / hoods without clearing the RTR placements. It's especially noticeable with lowered hoods. The next equip/unequip from RTR will correct them for the rest of the session but that first cell change breaks. I have not found a fix yet.
  - An additional compatibility issue with NFF is that when changing cells the Helmet on Hip seems to disappear.
- [ ] Lowerable hoods have a brief fully unequiped state when unequipping after a Combat Equip. The hood is removed without a lowered hood added and then the animation plays a tiny bit of time after that. It's not ... game breaking, but it does break the immersion.
