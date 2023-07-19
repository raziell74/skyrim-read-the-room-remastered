# Future Plans

***Disclaimer: Sometimes I suck***
My brain is a fickle meat lump, riddled with ADHD, and fueled only with a combination of coffee, vodka infused gummy bears, and adderall... with that said I am somewhat notorious for starting projects and abandoning them. Life got busy, I moved onto another project, I got bored, I read a mean comment and got really sad... many things might happen.

Because of this unfortunate personality trait I've opened the permissions on the [GitHub repository](https://github.com/raziell74/skyrim-read-the-room-tweaks). Feel free to make a branch and submit a PR with your changes. Github will tickle my leg via phone notifications so I should manage to get to reviewing your changes in a reasonable amount of time. To ensure an acceptable level of quality, changes require an approved pull request to be merged into the next release

## MCM Uninstall Button

Similar to mods like DynDOLod, there should be an uninstall button that allows players to safely remove the mod with as little footprint left in the game save as possible.

Uninstalling should do the following:

- Removes the RTR Start up Quest
- Halts all active scripts
- Removes RTR perks, spells, and keywords from affected NPCs

## Better Update Process

Script variables and properties are "baked" into save files so if the properties sent to the scripts change in the esp file they do not work correctly from an existing save. I want to implement a version control system, MCM offers some handy tools for version control, so that when updating the scripts can correctly update their properties and function without the need to start a new save or clean your save with ReSaver.

## Optional Hood Animation Replacement

I love the look and feel of the animations used in Chikuwan's [Serana's Hood Fix with Animation](https://www.nexusmods.com/skyrimspecialedition/mods/80336) mod. With his permission I want to add it as an optional replacement for the original equip/unequip hood animations.

## MCM Managed Exclusion List

Players should be able to add items to be excluded from RTR via MCM instead of modifying the `ReadTheRoom_Exclusions_KID.ini` file. I'll be keeping the KID file around though so that patches can be distributed easily so the in game exclusion list would be custom for your own game.

## MCM for tracking managed NPCs

I'd like to add an MCM page where you can view the a current list to Followers/NPCs managed through the mod. 
On this page you should be able to toggle RTR management on/off for each NPC.

## More MCM Debug Options

**Toggle Debug Log Output**
There should be a way to toggle DEBUG output to the console. While making this remaster I added a ton of debug output to the console using [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048). For this initial release I just commented out the debug message code, but I would like to add the ability to toggle it on and off so that players can attempt to investigate issues on their own if they want. Also would be a nice shortcut for myself during play testing.

**Add RTR to NPC under cross hair**
Force add/remove RTR perk to NPC under the cross hair. This would be a quick and intuitive way to add unsupported mod added followers without needing a patch. I will contact MaskedRPGFan (the maker of those awesome Setting Loader mods) and see if i can work with him to have the force added NPCs saved so they get the perk on new games as well.

## Additional Positioning options

Previously the Attachment Node, Item Scale, and inventory requirement were hardcoded into the scripts. These should be adjustable as well, what if a player doesn't want the items on their hip ("NPC Pelvis [Pelv]")? I'll be opening up these as options that you can configure. But keep in mind that the animation will still move the hand to the hip unless you replace that as well. So if you attach the "hip" placement to your foot the animation will still end with the hand going to the hip.

Most players should probably keep to the defaults but can't hurt to give the player more control. Plus these options will be more useful in the next planned feature!

## Custom Immersive Equipment Display anchor positions

The original Read The Room allowed players to make changes the positioning of the helmets IED placements, but some mod armors have GND meshes that might not be centered within the GND collision box as they should be and this can result in "floaty" items in the IED placements. I want to add the ability to add custom positioning for specific pieces.

I'd love to make something to do this while in game but that takes A LOT more work than simply adding it to MCM. For now you'll just have to deal with clunky experience going in and out of MCM.

***Hot Tip!***

Since you're using IED anyway, add a new entry using the awesome IED in game UI with the item you are trying to customize. Then you can visually see the positioning live in game on your character! Once you've got a satisfactory result, jot down the node and positioning you've landed on and update those in the MCM. You should probably disable the IED item you made though, otherwise it will stick there forever. *Note* I really wanted to figure out how to expose RTR's IED placements in the IED GUI but unfortunately IED separates these completely and there is no way to view them through their in game UI :'( 

## Locational "Head Gear" Management

This feature would allow users to set "unequipped" items per location type in the MCM. Followers would of course be included in this MCM allowing you to set default "unequipped" head gear for you and your followers based off of location type.

I use wigs all the time for both my character and followers. I like to have followers in particular have different wigged outfits (manged by NFF) for towns and homes and then wear their helmets while out in the wilderness. I feel like Read the Room is the most logical place for head gear specific locational management. Why should it only be equipping and unequipping? We should be able to assign specific head gear for location types just like we set if we should have a helmet or not per location type.

**Example use cases:**

  - Setting a hat or circlet with a speech enchantment while in town
  - Have a wig that represents your hair being "up" while in town for you or your followers
  - Having a hat or wig for more comfortable locations like home or inns

**Note** I realize this feature is kind of a dumbed down version of the popular [Let Your Hair Down](https://www.nexusmods.com/skyrimspecialedition/mods/81444) mod but it would work better for follower management. I also realize this feature may come with TONS of conflict possibilities with other mods especially those that specialize in outfit management, so this is more for people like me who don't really change outfits that often and just want to "read the room" when it comes to what's on my characters head.  

A shout out to Dint999 for having a KICK ASS selection of hairs that all have corresponding wigs that you can equip. Be sure to check out his [Patreon](https://www.patreon.com/dint999/posts)!