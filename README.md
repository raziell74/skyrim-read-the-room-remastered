# Read The Room - Tweaks and Fixes

It seems the original author of [Read the Room - Immersive and Animated Helmet Management](https://www.nexusmods.com/skyrimspecialedition/mods/77605) has stopped development on the project.
I absolutely love the idea but it has a lot of buggy behavior, half finished features, and things I just feel should work differently. It's a staple in my load order but I got tired of waiting for an update. So with my minimal modding/papyrus scripting experience I decided to make the updates myself.

## bugs... Bugs.... BUGS!!!!!!

### Squashed

- [x] Helmet/hood sometimes remains in the hand even after equipping
- [x] Helmet/hood showing in the hand during other animations
- [x] Hoods would periodically use the helmet animations, better hood detection implemented
- [x] OnMagicEffectApply issue 
  - OnMagicEffectApply is notorious for causing save bloat and script lag, replacing with OnMagicEffectApplyEx from [po3's Papyrus Extender](https://www.nexusmods.com/skyrimspecialedition/mods/22854)
  - Update: The OnMagicEffectApply was used as a cloaking spell on NPCs for detecting the 'searching for player' combat state to trigger the helmet to equip. I've removed this for now and might add it back in later  
- [x] RTR_MonitorEffect xEdit error
- [x] Dirt and Blood animations break helmet management
- [x] First helmet from new save works great, rest doesn't
- [x] Hotkey Triggers in menu's and console
- [x] Exclusions for Wigs from popular hair mods
- [x] Helmets/Hoods sometimes get stuck in hand
- [x] Mod added Followers is hit or miss on if they receive the RTR follower scripts 

### Known Bugs

- [ ] Follower support only affects a single follower, and it's buggy as hell. Refactor entire "follower monitor" script to instead work as functional hooks that iterate through each npc that has the "RTRFollower" keyword and "CurrentFollowerFaction" faction and equip/unequip when ever the player does. The original script uses single variables to control things like "lastEquipped". This needs to be changed to track an array of followers equipment states.
- [ ] Follower helmet state should match the players. Using the Hotkey to put on a helmet while your follower already has a helmet would trigger the follower to remove theirs.
- [ ] Equip/Unequip helmet while in beast form breaks the character
- [ ] CC Alternate Armor + Vanilla Masks + some hoods of vanilla light armor break
- [ ] Combat settings to skip animations are sometimes ignored
- [ ] Prevent the game from re-equipping removed helmet/hood
    - Any suggestions on a fix for this would be appreciated. 
    - Currently I'm thinking of equipping a hidden helmet so the follower won't try to switch it with one from inventory.
- [ ] There is no check for if a follower is a current follower so if they have the RTR perk applied through SPID they will trigger the helmet equip/unequip
- [ ] Followers should only trigger RTR when the player does. They should not have their own location/key-hit checks for optimization reasons
  - Fixing the followers required some extra functionality. Had to add [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048) as a dependency. I've heard that PapyrusUtil is incompatible with 1.6.640 *sad_face* so if I can find another solution I'll remove it as a dependency but for now it was the quickiest and easiest solution. I'll keep work shopping different solutions to find the best one! Apologies for those on the latest version, for now just disable follower support and the mod should still work for the player.
  - I did some digging and some users managed to get PapyrusUtil working again by installing the [All in one (Anniversary Edition)](https://www.nexusmods.com/skyrimspecialedition/mods/32444?tab=files) version of Address Library for SKSE Plugins. 
  - I'll keep looking for a different work around though because I don't like having to include SKSE dependencies if I can help it because of this exact reason.
- [ ] Lowered Hoods should be attached through IED
  - Currently they are physically equipped and unequipped
  - Causes compatibility issues when it comes to mods like Trade and Barter that give benefits to not having head gear equipped
  - It also does not match how RTR handles EVERY other piece of head equipment...

## Tweaks and Enhancements

- Adding various modded hood support using [FLM - Form List Manipulator](https://www.nexusmods.com/skyrimspecialedition/mods/74037)
  - [x] [H2135's Fantasy Series6](https://www.patreon.com/posts/sse-h2135s-cbbe-39697683)
  - *Will add more mod support as they are suggested*
- [x] Animation Annotation Update - Changes to the animation annotations to be more descriptive and unique. Instead of generic events that are used by lots of other animations.
  - By using unique annotations for each phase of each animation the scripts Animation Event registration can be stream lined, reducing tons of extra script checks and headache.
  - With these unique annotations any actor can be sent RTR Animations and they will be handled by a single event handler instead of attempting to split the event handlers in two for the player and other NPCs
  - FYI for those using older versions of [Eating Animations and Sounds SE](https://www.nexusmods.com/skyrimspecialedition/mods/42602) the reason the helmet would attach is due to the `SoundPlay.NPCHumanCombatIdleA` annotations in eating animation files. 
  - Unique annotations just for RTR animations ensures compatibility
  - Old Non-Uniqueified Annotations
    - `SoundPlay.NPCHumanCombatIdleA` = hand node placement during animation
    - `SoundPlay.NPCHumanCombatIdleB` = hip node placement during animation
    - `SoundPlay.NPCHumanCombatIdleC` = OffsetStop Trigger at end of animation 
  - New Hottness!
    - `RTR.Equip.Start`
    - `RTR.Equip.Attach`
    - `RTR.Equip.End`
    - `RTR.Unequip.Start`
    - `RTR.Unequip.Attach`
    - `RTR.Unequip.End`
    - `RTR.Hood.Equip.Start`
    - `RTR.Hood.Equip.End`
    - `RTR.Hood.Unequip.Start`
    - `RTR.Hood.Unequip.End`
  - Tools used
    - [HKanno64](https://www.nexusmods.com/skyrimspecialedition/mods/54244)
    - [SkyrimGulid Annotation Tool](https://www.skyrim-guild.com/guides/skyrimannotationtool)
- [ ] Major Script Refactor. Duplicated code, Unoptimized logic patterns, Unused properties/variables, Redundant behavior, OH MY!
- [ ] Additional Wig support. Treat wigs as "unequipped" state so putting on the last equipped helmet will still trigger. Also re-equip the wig when the helmet is removed.
- [ ] Add new "RTRNoAnimation" keyword to the `ReadTheRoom_Exclusions_KID.ini` so people can set modded head gear with bad gnd meshes to still equip/unequip but skip the animations/hand and hip attachment.
- [ ] Plugin clean up. Unused forms are abound in the plugin. Clean these out to make the plugin smaller so formIds can be opened up to be used by some new features.
- [ ] Updated hood animations to using the great animations from chikuwan's [Serana's Hood Fix with Animation](https://www.nexusmods.com/skyrimspecialedition/mods/80336) mod.

## Possible New Features

These are just a few features I would love to implement. Fair warning though, my brain is a fickle electric meat lump riddled with ADHD and fueled only by coffee and handfuls of vodka infused gummy bears... So I make no promises!

<details>
  <summary>Locational "Head Gear" Management</summary>

  I use wigs all the time for both my character and followers. I like to have followers in particular have different wigged outfits (manged by NFF) for towns and homes and then wear their helmets while out in the wilderness. I feel like Read the Room is the most logical place for head gear specific locational management. Why should it only be equipping and unequipping? We should be able to assign specific head gear for location types just like we set if we should have a helmet or not per location type.

  This feature would allow users to set "unequipped" items per location type in the MCM. Followers would of course be included in this MCM allowing you to set "no helmet" head gear for you and your followers based off of location type.
  
  Example use cases:
  
    - Setting a hat or circlet with a speech enchantment while in town
    - Have a wig that represents your hair being "up" while in town for you or your followers
    - Having a hat or wig for more comfortable locations like home or inns

  **Note** I realize this feature is kind of a dumbed down version of the popular [Let Your Hair Down](https://www.nexusmods.com/skyrimspecialedition/mods/81444) mod but it would work better for follower management. 
  
  **Additional Note** I also realize this feature may come with TONS of conflict possibilities with other mods especially those that specialize in outfit management, so this is more for people like me who don't really change outfits that often and just want to "read the room" when it comes to what's on my characters head.  

  A shout out to Dint999 for having a KICK ASS selection of hairs that all have corresponding equitable wigs. Be sure to check out his [Patreon](https://www.patreon.com/dint999/posts)!

</details>

<details>
  <summary>Hoods Extension/Refactor</summary>

  An overhaul to the current Lowerable Hoods feature. In the current implementation, Hoods are tracked through two form lists that have to be a one to one for the list of hoods that can be "lowerable" and a list of hoods that represent the "lowered" version. 

  I want to change this to utilize an external JSON file that makes it easier see the hood and lowered hood associations. I want to also provide an extension to the MCM menu that lets you manipulate this list. For compatibility the scripts will merge JSON files following a naming convention so mod authors can provide their own patches easily without having to overwrite the main JSON file. Changes from the MCM will be saved to a custom JSON file so they persist between saves.

  The naming convention will be something like "{UNIQUE NAME}_RTRHoods.json". Provided JSON files will be "Vanilla_RTRHoods.json" and "CUSTOM_RTRHoods.json". Any MCM changes are saved in the "CUSTOM_RTRHoods.json" file.

  Example JSON format:

  ```json
  {
    hoods: [
      { 
        "hood": {
          "editorId": "ArmorThievesGuildHelmetPlayer",
          "plugin": "Skyrim.esm",
          "formId": "0xD3AC5",
        },
        "lowered": {
          "editorId": "RTR_Lowered_ArmorThievesGuildHelmetVar",
          "plugin": "ReadTheRoom.esp",
          "formId": "0x936",
        }
      },
      { 
        "hood": {
          "editorId": "EnchClothesRobesMageHoodAdept",
          "plugin": "Skyrim.esm",
          "formId": "0x10DD3C",
        },
        "lowered": {
          "editorId": "RTR_Lowered_ClothesRobesMageAdeptHood",
          "plugin": "ReadTheRoom.esp",
          "formId": "0x93B",
        }
      },
    ]
  }
  ```

  **NOTE** It is possible I might not use JSON but instead follow some similar formatting that other popular frameworks use like SPID, KID, FLM, etc... but we'll cross that bridge when I get around to this feature.

</details>

<details>
  <summary>Let your hair down integration</summary>

  I personally don't use "Let your hair down" so I would need to test to see what kind of incompatibilities need to be handled given that the two are so similar.

</details>

## Won't Fix

### Broken Hip/Hand models for mod added items. 
  
  RTR uses the ground / inventory models for the items so if a mod uses a bad mesh for the ground models or the inventory that doesn't represent what the item should look like on your character this will appear to float or be broken when attached through IED.
  
  Your options are:
  
  - Create a new working gnd mesh that fits the item model and set it in a new esp patch
  - Once the "RTRNoAnimation" keyword tweak is added you can skip the animations and hip attachment for the modded items by adding the keyword to the item in the `ReadTheRoom_Exclusions_KID.ini` file
  - Add the item to the `ReadTheRoom_Exclusions_KID.ini` provided in this mod so it is ignored


# Disclaimer: Sometimes I suck

I am somewhat notorious for starting projects and abandoning them. Life gets busy, I move onto other projects, I get bored... many things might happen.
As such all my mods are public on github so if my ADHD gets the better of me and I run off into a field chasing butterflies anyone willing can pick up where I leave off.

Apologies for this part of my personality. 
