# Known Bugs - Currently Looking Into

These are bugs that either I've encountered or were reported in "Bugs" tab of the original mod.
Check the Change Log for a list of bugs that have been squashed so far!

_Legend: [ ] = Not Started, [-] = In Progress, [x] = Complete_

- [-] If there is no last_equipped item form
  - Player has just started the game, RTR will still run logic and animations even with no helmet
- [x] RTR does not properly detect if the last equipped head gear item is in the players inventory
  - Results in combat equip adding the item to the player and equipping it
  - Another example is removing a head gear item from a follower and then triggering RTR equip will force the item back into the followers inventory and equip it
- [ ] Wooden Mask (Labyrithian) Auto equips when leaving the mask realm
- [ ] Cannot remove ReadTheRoom
  - This issue is being addressed in the "Uninstall Button" feature outlined in the "future plans" section.
  - As a work around disable the mod in the MCM and save your game, uninstall the mod, reload your save and save again, then clean the latest save with ReSaver. Remove any unattached scripts that start with `ReadTheRoom` and you should be good to go.
- [ ] RTR Breaks if triggered while drawing a bow.
  - If RTR triggers while player is drawing a bow and the "sheath for animation" setting is enabled it will break the bow animation and freeze the characters animation until the bow is unequipped. This can also sometimes cause the player controls to be locked. 
  - Most common occurrences happen after combat with combat equip setting enabled and the player is drawing a bow when combat ends.

## Content Patches

Occasionally mod added head gear can be incompatible with RTR. There are several things that can cause issues and they are almost always related to the items world mesh. _world/inventory mesh does not match equipped mesh_ Items in the hand/hip nodes do not match the item that was equipped, wigs items tend to be the biggest offenders. _world/inventory mesh collisions were not set properly_ Items float around the character when in the hand or hip nodes. _item does not have a world/inventory mesh_ Item is invisible in players hand/hip.

Here are the currently planned patches:

- [ ] Some CC Content helmets and hats have incorrect world/inventory meshes
  - A patch to each broken items world/inventory meshes will need to be made
- [ ] Some Helmets from Immersive Armors have missing or incorrect world/inventory meshes
  - A patch to each broken items world/inventory meshes will need to be made

_If you have any items that are broken and you would like patched please comment the name of the mod and the items you'd like to see supported on the "patches" thread in the "posts" tab of the mod page._

_Please note that if you want a hood patched to be a "lowered hood" and that hood does not match any of the existing lowered hood meshes then this will take much longer since a lowered version mesh will need to be created from scratch and I have zero experience in creating meshes so expect a very long wait for hood requests_
