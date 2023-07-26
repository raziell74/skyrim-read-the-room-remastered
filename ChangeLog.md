# Change Log

## Version 1.2

### Changes and Updates 

- Complete Rewrite of all scripts
- New *unique* animation events and variables added using [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
- Existing animations updated with new annotations to trigger RTR *unique* animation events
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089) annotations were also added to the existing animations that update actor animation variables that the scripts interpret to understand what the actor is currently doing or if it had gotten interrupted
- Various checks were added / updated using the new Behavior data that overhaul detection of interrupted animations, or if the actor can execute an animation.
- Added new `ReadTheRoom_Exclusions_KID.ini` file to Misc Downloads which comes pre-written with exclusions to popular mods that dad wigs
- Overhauled/Optimized follower support so that it uses SKSE Mod Events to trigger follower actions directly from the player
- Added new `ReadTheRoom_Hoods_FLM.ini` file to Misc Downloads makes it easy to add patches for lowerable hoods
  - Comes preset with an example using `H2135's Fantasy Series 6` Sylvannas hoods, because it already has lowered versions
- Optimized IED placement functionality so that instead of creating/delete actor items every time something is attached, it will now already have an actor item and simply update the form to display and toggle the enabled flag during specific animation events
- Better Last Equipped tracking
- Keybind Toggle will override Auto Equip/Unequip while at a location
  - If entering a safety and RTR auto unequips your head gear. If you use the keybind to put it back on and RTR will not attempt to remove it again until either you leave safety or enter danger and then return to safety
- Added new `ReadTheRoom_CustomFollowers_DIST.ini` SPID file to Misc Downloads. This file adds the "RTR_FollowerKW" keyword to popular custom followers that might not get it through the Current/Potential Follower faction. It also distributes the new "RTR_CustomFollowerKW" keyword which forces followers that never enter the CurrentFollowerFaction to be managed by RTR
- Better state management when RTR is active
  - RTR will now enter a "Busy" state which blocks all RTR actions while it works preventing things like Key spamming or rapidly changing locations
- Follower queued actions
  - If the player continuously equips and unequips their head gear back to back, followers will queue their actions so their animations won't overlap and "break" their brains
- Complete overhaul of the CombatEquip system. Head wear will now only be equipped if the player is in combat and will return to what ever previous head wear state they were in when they started combat. So if you start combat with no helmet, you will remove your helmet once you've left combat. Also fixed an issue with the original where certain actors like animals or dragons wouldn't report leaving combat on death. I also added a future plan to extend the system to include options for when an NPC is searching for the player. Default behavior of the original was to treat searching the same as "in combat" but I personally would prefer to only equip when actually fighting. 
- Added notifications for automated RTR actions: Entering Safety, Leaving Safety, Nearing Danger, Leaving Danger, Combat Equip
  - Notifications can be toggled on/off for location and combat equips in the MCM
- All items flagged with the "RTR_HoodKW" keyword will now use the hood equip/unequip animations. This change applies to all dragon priest masks as well. There will be no lowered variant mesh for these though since I am not experienced in 3D modeling at all. But at least they won't look SUPER weird when RTR unequips them.
- Refactored lowered hoods to be assignable via keyword. The `ReadTheRoom_KID.ini` file has been updated to support all vanilla hoods as well as those added by the [Weapons Armor Clothing and Clutter Fixes](https://www.nexusmods.com/skyrimspecialedition/mods/18994) (WACCF for short) mod. It is HIGHLY recommended to use WACCF, because it separates the hoods from the robes for many items. Without it things like monk robe hoods, arch-mage hood, and Dunmer Hoods cannot be managed through RTR.
- Added a fall back system for adding direct Hood to Lowered Hood form assignment via the [FormList Manipulator FLM](https://www.nexusmods.com/skyrimspecialedition/mods/74037). A sample file with instructions for how to use it is included (`ReadTheRoom_Hoods_FLM.ini`). 
- Added a "Sheath On Animation" setting which will force the player to sheath their weapons to play the RTR animations. If this is disabled RTR will equip/unequip with no animation when weapons are drawn
- MCM has been updated to include the new Remaster feature settings.
- Added a patch for the [Read The Room - Settings Loader](https://www.nexusmods.com/skyrimspecialedition/mods/78689) mod
  - Honestly might just switch to using MCM helper by default. MCM is an annoying tedious process without it.
- Implemented a safe update versioning system so that scripts can safely be updated mid-save without breaking anything

### Bugs Squashed

- [x] Helmet/hood sometimes remains in the hand even after equipping
- [x] Helmet/hood showing in the hand during other animations
- [x] Hoods would periodically use the helmet animations, better hood detection implemented
- [x] OnMagicEffectApply issue as reported by GOOGLEPOX, Remastered removed the need for the OnMagicEffectApply event
- [x] RTR_MonitorEffect xEdit error
- [x] Dirt and Blood animations break helmet management
- [x] First helmet from new save works great, the rest don't
- [x] Hotkey Triggers in menu's and console
- [x] Exclusions for Wigs from popular hair mods
- [x] Helmets/Hoods sometimes get stuck in hand
- [x] Mod added Followers is hit or miss on if they receive the RTR follower scripts 
- [x] Followers support is slow and buggy and sometimes wouldn't even trigger
- [x] Follower helmet state should match the players
- [x] Combat settings to skip animations are sometimes ignored
- [x] Unquipped items that were cleared using the Hotkey will re-appear on the player after exiting the inventory
- [x] Followers re-equip head gear when moving to new cells
- [x] RTR does not work with custom followers that have their own unique follower framework. I.E. are never placed in the `CurrentFollowerFaction`
- [x] Followers should only trigger RTR when the player does. Instead of having their own location change, combat, keybind, and on magic effect event handlers
- [x] Toggling RTR during sneak alerts NPCs to your presence
- [x] Taking off helmet during Rogvir's Execution makes guards hostile
- [x] Helmets equipped in a safe zone using the Keybind are unequipped when changing cells (going in and out of houses). The Hotkey should override the safe zone auto equipping while you're in the safe zone
- [x] Lowered hoods sometimes get stuck on when switching to a helmet
- [x] RTR occasionally just stops working
  - Remastered adds a maintenance script that ensures everything is reset for head wear management when ever a save is load. If you run into an issue where it has stopped working, try reloading the save. If the issue persists please open a new bug report.
- [x] Drawn weapon while equipping bug
- [x] Camera is forced from third person into first person when approaching enemy
  - I have not managed to reproduce this yet with the remastered version
  - I'll add some additional clean up to the "Clear placed headgear" keybinding so any "pre animation" camera state is cleared and set to the correct value so you can use that button to fix that issue anytime it happens
- [x] Inigo and Lucifer Not applied
  - There is a `ReadTheRoom_CustomFollowers_DIST` download available in Misc that contains a SPID file which distributes a the keyword "RTR_FollowerKW" that is used to decide who to apply the RTR Follower Perk to. 
  - The file is preset to distribute to several popular follower mods: Inigo, Lucifer, Lucien, Kaidan, Auri, and Daegon
- [x] Elden Rim Conflict?
  - RTR Remastered fixes this by using [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146) to add new *unique* animation events that are only used by RTR
- [x] mod locking the game
- [x] RemoveHelmetWithoutArmor does not work with Schlongs of Skyrim
  - SOS moves torso armor from slot 32 to slot 52 so RTR will check both slots now
- [x] Circlets are not always correctly identified as "Circlets"
- [x] Fixed an issue with external outfit managers that would "refresh" follower outfits on cell change which would re-equip helmets that were removed using RTR
  - Discovered as an incompatibility with Nether's Follower Framework, NFFs outfit system re-equips followers entire outfits regardless of if it's enabled or not
  - Head wear equipped within the first 5 seconds after a cell change will be immediately unequipped if it was previous unequipped through RTR
- [x] Added a check to see if the Player has the "ActorTypeCreature" keyword which is added when the player is transformed into a werewolf or vampire lord.
  - RTR will no longer execute helmet management automated or otherwise if the player is a "creature" 
- [x] Some hoods would identify as circlets and wouldn't be correctly managed by RTR if the player had the "Manage Circlets like Helmets" option disabled
- [x] Equip with no animation does not keep helmet on hip or lowered hood applied
- [x] Followers that can turn into Werewolves or other creatures break if RTR triggers while they are in their transition
- [x] Follower RTR placements were not being cleared when the player pressed the Delete key to clear RTR placeholders
- [x] Circlets are still treated as Helmets even if "Manage Circlets like Helmets" is disabled in the MCM
- [x] Function 'Require Armor for Hip Placement' is bugged
- [x] Some Vanilla/DLC Hoods aren't lowered and instead are treated like helmets
- [x] Some Vanilla/DLC Masks and Hoods break RTR
- [x] Compatibility issue with Nether's Follower Framework.
- [x] Pauses Follower Support while in container menus to avoid lag caused by follower synchronization Event scripts

### Added Dependencies

- [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089)
- [FormList Manipulator - FLM](https://www.nexusmods.com/skyrimspecialedition/mods/74037)
  - *Optional* if you want to use the `ReadTheRoom_Hoods_FLM.ini` file to add direct lowered hood assignment for your favorite hood mods
- [MCM Helper](https://www.nexusmods.com/skyrimspecialedition/mods/53000) 
  - *Optional* For the Settings Loader patch
