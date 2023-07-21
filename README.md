# Read The Room - Remastered

***RTR Remastered*** is a complete overhaul and remaster of the original [Read The Room - Immersive and Animated Helmet Management](https://www.nexusmods.com/skyrimspecialedition/mods/77605) mod. Every script and feature has been carefully investigated and rewritten for speed and code cleanliness. The remaster often takes a completely different approach to the implementation of some features while other times it takes an implementation and enhances its stability and reliability.

## Required Dependencies

- [Read The Room - Immersive and Animated Helmet Management](https://www.nexusmods.com/skyrimspecialedition/mods/77605)
- [Immersive Equipment Displays](https://www.nexusmods.com/skyrimspecialedition/mods/62001)
- [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089)
- [Keyword Item Distributor (KID)](https://www.nexusmods.com/skyrimspecialedition/mods/55728)
- [Spell Perk Item Distributor (SPID)](https://www.nexusmods.com/skyrimspecialedition/mods/36869)
- [FormList Manipulator - FLM](https://www.nexusmods.com/skyrimspecialedition/mods/74037)
- [Skyrim Script Extender (SKSE64)](https://www.nexusmods.com/skyrimspecialedition/mods/30379)
- [Nemesis Unlimited Behavior Engine](https://www.nexusmods.com/skyrimspecialedition/mods/60033)
- [powerofthree's Tweaks](https://www.nexusmods.com/skyrimspecialedition/mods/51073)
- [PapyrusUtil SE - Modders Scripting Utility Functions](https://www.nexusmods.com/skyrimspecialedition/mods/13048)

## Installation/Updating

**TBD** Need to write this section

## Uninstall

**TBD** Need to write this section

## Compatibility

**TBD** Need to write this section

## Frequently Asked Questions

### My helmet doesn't appear in my hands or hip during the RTR animations, what's going on?

The most likely cause is that you're missing some of the Dependencies. Please refer to the Dependencies section and ensure you have everything needed for RTR Remastered to function correctly.

### Why does my character T-pose when ever RTR equips or unequips my helmet?

You forgot to run Nemesis, please refer to the Installation section.

### My enchanted gear doesn't work after RTR equips them!

This is actually a bug in the Skyrim engine and also happens when attempting equipping an enchanted piece of gear directly from a container.
Installing [Equip Enchantment Fix](https://www.nexusmods.com/skyrimspecialedition/mods/42839) will fix the problem.

Kudos to [FSb992014](https://www.nexusmods.com/skyrimspecialedition/users/14132185) for figuring this one out and posting the solution!

### HELP! My helmet floats around my character or is invisible when RTR unequips it! WWWWWWAAAAAAAAAAA!!!!

This is typically due to improperly generated ground meshes in modded armors. 

If you come across any items that don't seem to be working correctly please report them on the "Bugs" tab with the name of the item and a link to the mod that it came from, and I will do my best to get around to making a patch for it. Until then you can add the item/mod to the `ReadTheRoom_Exclusions_KID.ini` file so RTR doesn't try to process it.

If I'm moving to slowly for you, below are some Technical Details on why some items break and how to fix them.

<details>
  <summary>Technical Details</summary>

  RTR utilizes [Immersive Equipment Displays](https://www.nexusmods.com/skyrimspecialedition/mods/62001) for attaching items to the body (hands/hip). the Armor pieces require a proper ground (GND) mesh. This is the mesh that shows up when you drop an item into the world or view it in the inventory. If that mesh isn't correctly generated with the right collisions then IED struggles to attach the model to the characters body. 
  
  If the item is completely invisible that means that the ground mesh either wasn't provided by the mods plugin or a non-ground mesh was given. if the item appears to float that means that a ground mesh was made but the item was not centered in the collision box.

  Generating proper GND meshes is simple with [Bodyslide and Outfit Studio](https://www.nexusmods.com/skyrimspecialedition/mods/201) but can be very tedious. Which is why tons of Armor mods don't even bother *COUGH* wig mods *COUGH* *COUGH*.

  Here is a fantastic youtube tutorial on how to create proper ground meshes just in case you don't want to wait for me and would like to create patches for your self. 

  [How to Create Your Own Skyrim Ground Meshes (Easiest Way)](https://www.youtube.com/watch?v=K2gI-_nFchA&ab_channel=SunJeongCh.)

  I really would love to attempt an xEdit script that generates these but it gets REAL complicated and the only mod I know of that successfully built an xEdit script that generates meshes was AllGud. If I find myself with some extra time I may attempt this but don't hold me to it.

</details>

### Why wont Read The Room work on {Insert Custom Follower Name Here}?!?!? IT'S BROKEN!!!

The default behavior of Read The Room attempts to identify followers by checking if the NPC is a part of the PotentialFollowerFaction and will only process NPCs that are an active member of the CurrentFollowerFaction. A lot of custom followers will use their own follower framework and never actually enter either of these factions.

RTR - Remastered adds a new keyword (RTR_CustomFollowerKW) which is distributed by the `ReadTheRoom_CustomFollowers_DIST.ini` SPID file which you'll find in Misc Downloads.

This file will add the RTR_FollowerKW keyword to any followers that might not have it, the RTR_FollowerKW is what SPID uses to distribute the RTR_FollowerPerk which applys all the follower scripts, and will distribute the RTR_CustomFollowerKW keyword to any follower that never enters the CurrentFollowerFaction. RTR will force its self on those NPCs regardless of if they are actively following you or not. Just think of it as "peer pressure" :P

It comes preset with various other popular followers already added. Just add the name of the follow you want to have affected by RTR to the lists for `RTR_FollowerKW` and `RTR_CustomFollowerKW` to get them working.

## Future Plans

==Located in FuturePlans.md==

## Known Bugs

==Located in KnownBugs.md==

## Change Log

==Located in ChangeLog.md==

## Tools Used

- [HKanno64](https://www.nexusmods.com/skyrimspecialedition/mods/54244) and [SkyrimGulid Annotation Tool](https://www.skyrim-guild.com/guides/skyrimannotationtool) for all the annotation updates on the Original RTR animation files
- [Bodyslide and Outfit Studio](https://www.nexusmods.com/skyrimspecialedition/mods/201) to create the ground meshes for the various armor mods
- [xEdit](http://tes5edit.github.io/) for almost all my `esp` work, wrote a lot of small scripts that helped in handling large data changes like identifying EVERY circlet and hood in my (rather sizable) load order...

## Special Thanks

**TBD** Need to write this section
