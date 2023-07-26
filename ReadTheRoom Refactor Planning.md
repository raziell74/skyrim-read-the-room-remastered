PRIORITY

Go through CC content and generate ground meshes for equipment. Start with CC_Fishing

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

## Lowerable Hoods - Overhaul 

~~IED Attachment~~ *scrapped the IED plans because some lowered hoods will likely have Havoc, specially if they have been modded by Modernize or added from a mod like  H2135's Fantasy Series 6

~~Lowerable hoods is a half baked feature with very limited functionality. The current implementation doesn't even follow the same processes as the rest of the helmet management. Lowered Hood models were custom made for the vanilla hoods and they are equipped instead of attached via IED. This is because no valid ground meshes were ever made for these items. ~~

There is also no real way to manage the hoods or add new compatibility for mod added hoods. Hoods that can be "lowered" are identified through a FormList called `LowerableHoods`. These share a 1 to 1 relation to another FormList that holds a list of `LoweredHoods`. So if a hood is in the Lowerable list it will look at the same array index to get the armor item to swap to that represents the Lowered version of the hood.

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

## New props - Requires New Game/Clean Save until Version updating is implemented

SheathWeaponsForAnimation
RTR_Version

### Monk Hoods

RTR_Lowered_ClothesMonkHoodBlack "Lowered Cowl - Black" [ARMO:FE000930]
RTR_Lowered_ClothesMonkHoodBlue "Lowered Cowl - Blue" [ARMO:FE00093F]
RTR_Lowered_ClothesMonkHoodBrown "Lowered Cowl - Brown" [ARMO:FE00092E]
RTR_Lowered_ClothesMonkHoodGreen "Lowered Cowl - Green" [ARMO:FE00092B]
RTR_Lowered_ClothesMonkHoodGrey "Lowered Cowl - Grey" [ARMO:FE00092D]
RTR_Lowered_ClothesMonkHoodRed "Lowered Cowl - Red" [ARMO:FE00092C]
RTR_Lowered_ClothesMonkHoodYellow "Lowered Cowl - Yellow" [ARMO:FE00092F]
RTR_Lowered_ClothesMonkHoodNecromancer "Lowered Cowl - Necromancer" [ARMO:FE000940]

### Mage Hoods

RTR_Lowered_ClothesRobesMageHoodNovice "Lowered Mage Hood - Novice" [ARMO:FE000932]
RTR_Lowered_ClothesRobesMageHoodApprentice "Lowered Mage Hood - Apprentice" [ARMO:FE000931]
RTR_Lowered_ClothesRobesMageHoodAdept "Lowered Mage Hood - Adept" [ARMO:FE00093B]

### Dunmer Hoods

RTR_Lowered_ClothesDunmerHoodBlue "Lowered Dunmer Cowl - Blue" [ARMO:FE000942]
RTR_Lowered_ClothesDunmerHoodBrown "Lowered Dunmer Cowl - Brown" [ARMO:FE000941]
RTR_Lowered_ClothesDunmerHoodRed "Lowered Dunmer Cowl - Red" [ARMO:FE000943]

### Unique Hoods

RTR_Lowered_GreybeardHood "Lowered Greybeard Hood" [ARMO:FE00093A]
RTR_Lowered_ClothesRobesArchmageHood "Lowered Archmage Hood" [ARMO:FE00093C]
RTR_Lowered_MythicDawnHood "Lowered Mythic Dawn Cowl" [ARMO:FE000938]
RTR_Lowered_PsiijicHood "Lowered Psiijic Cowl" [ARMO:FE000939]
RTR_Lowered_ThalmorHood "Lowered Thalmor Hood" [ARMO:FE00093E]

### Faction Hoods

RTR_Lowered_NightingaleHood "Lowered Nightingale Hood" [ARMO:FE00093D]
RTR_Lowered_DarkBrotherhoodShroudedHood "Lowered Shrouded Hood" [ARMO:FE000933]
RTR_Lowered_ThievesGuildHoodBrown "Lowered Thieves Guild Hood - Brown" [ARMO:FE000936]
RTR_Lowered_ThievesGuildHoodGrey "Lowered Thieves Guild Hood - Grey" [ARMO:FE000934]
RTR_Lowered_ThievesGuildHoodGuildMaster "Lowered Thieves Guild Hood - Guild Master" [ARMO:FE000935]
RTR_Lowered_KarliahHood "Lowered Karliah's Hood" [ARMO:FE000937]

### New Keyword Records

RTR_Lowered_ClothesMonkHoodBlack [KYWD:FE001810]
RTR_Lowered_ClothesMonkHoodBlue [KYWD:FE001811]
RTR_Lowered_ClothesMonkHoodBrown [KYWD:FE001812]
RTR_Lowered_ClothesMonkHoodGreen [KYWD:FE001813]
RTR_Lowered_ClothesMonkHoodGrey [KYWD:FE001814]
RTR_Lowered_ClothesMonkHoodRed [KYWD:FE001815]
RTR_Lowered_ClothesMonkHoodYellow [KYWD:FE001816]
RTR_Lowered_ClothesMonkHoodNecromancer [KYWD:FE001817]
RTR_Lowered_ClothesRobesMageHoodNovice [KYWD:FE001818]
RTR_Lowered_ClothesRobesMageHoodApprentice [KYWD:FE001819]
RTR_Lowered_ClothesRobesMageHoodAdept [KYWD:FE00181A]
RTR_Lowered_ClothesDunmerHoodBlue [KYWD:FE00181B]
RTR_Lowered_ClothesDunmerHoodBrown [KYWD:FE00181C]
RTR_Lowered_ClothesDunmerHoodRed [KYWD:FE00181D]
RTR_Lowered_GreybeardHood [KYWD:FE00181E]
RTR_Lowered_ClothesRobesArchmageHood [KYWD:FE00181F]
RTR_Lowered_MythicDawnHood [KYWD:FE001820]
RTR_Lowered_PsiijicHood [KYWD:FE001821]
RTR_Lowered_ThalmorHood [KYWD:FE001822]
RTR_Lowered_NightingaleHood [KYWD:FE001823]
RTR_Lowered_DarkBrotherhoodShroudedHood [KYWD:FE001824]
RTR_Lowered_ThievesGuildHoodBrown [KYWD:FE001825]
RTR_Lowered_ThievesGuildHoodGrey [KYWD:FE001826]
RTR_Lowered_ThievesGuildHoodGuildMaster [KYWD:FE001827]
RTR_Lowered_KarliahHood [KYWD:FE001828]

RTR_LoweredHood [KYWD:FE001829]


# New Dependencies

- [PapyrusUtil SE](https://www.nexusmods.com/skyrimspecialedition/mods/13048)
    - Used for the `ScanCellNPCs` function to detect NPCs in a 500 radius around the Player that have the `RTR_Follower` keyword. This should solve the issue with mod added followers not being tracked.
- [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146)
    - Will Inject new unique RTR animation events and animation variables into the behavior graphs
- [Payload Interpreter](https://www.nexusmods.com/skyrimspecialedition/mods/65089)
    - Uses updated animation annotations to trigger updates on the new animation variables

# Placement and positioning

HipPositionX [GLOB:FE00080F]
12.800000
HipPositionY [GLOB:FE000810]
-10.250000
HipPositionZ [GLOB:FE000811]
-0.650000
HipRotationPitch [GLOB:FE000813]
15.000000
HipRotationRoll [GLOB:FE000812]
-52.900002
HipRotationYaw [GLOB:FE000814]
94.449997
HipPositionXCirclet [GLOB:FE000A4B]
12.800000
HipPositionYCirclet [GLOB:FE000A4C]
-10.250000
HipPositionZCirclet [GLOB:FE000A4D]
-0.650000
HipRotationPitchCirclet [GLOB:FE000A4F]
46.000000
HipRotationRollCirclet [GLOB:FE000A4E]
15.000000
HipRotationYawCirclet [GLOB:FE000A50]
68.900002

HandPositionX [GLOB:FE000F5D]
6.800000
HandPositionY [GLOB:FE000F5E]
-11.750000
HandPositionZ [GLOB:FE000F5F]
10.850000
HandRotationPitch [GLOB:FE000F61]
270.600006
HandRotationRoll [GLOB:FE000F60]
0.440000
HandRotationYaw [GLOB:FE000F62]
260.450012
HandPositionXCirclet [GLOB:FE000F63]
-0.200000
HandPositionYCirclet [GLOB:FE000F64]
-11.250000
HandPositionZCirclet [GLOB:FE000F65]
10.850000
HandRotationPitchCirclet [GLOB:FE000F67]
270.600006
HandRotationRollCirclet [GLOB:FE000F66]
22.940001
HandRotationYawCirclet [GLOB:FE000F68]
260.450012

HipPositionXFemale [GLOB:FE000F69]
12.800000
HipPositionYFemale [GLOB:FE000F6A]
-10.250000
HipPositionZFemale [GLOB:FE000F6B]
-0.650000
HipRotationPitchFemale [GLOB:FE000F6D]
-52.900002
HipRotationRollFemale [GLOB:FE000F6C]
15.000000
HipRotationYawFemale [GLOB:FE000F6E]
94.449997
HipPositionXCircletFemale [GLOB:FE000F6F]
12.800000
HipPositionYCircletFemale [GLOB:FE000F70]
-10.250000
HipPositionZCircletFemale [GLOB:FE000F71]
-0.650000
HipRotationRollCircletFemale [GLOB:FE000F72]
15.000000
HipRotationPitchCircletFemale [GLOB:FE000F73]
46.000000
HipRotationYawCircletFemale [GLOB:FE000F74]
68.900002

HandPositionXFemale [GLOB:FE000F75]
8.000000
HandPositionYFemale [GLOB:FE000F76]
-15.000000
HandPositionZFemale [GLOB:FE000F77]
10.850000
HandRotationPitchFemale [GLOB:FE000F79]
260.000000
HandRotationRollFemale [GLOB:FE000F78]
29.000000
HandRotationYawFemale [GLOB:FE000F7A]
245.000000
HandPositionXCircletFemale [GLOB:FE000F7B]
-0.200000
HandPositionYCircletFemale [GLOB:FE000F7C]
-15.000000
HandPositionZCircletFemale [GLOB:FE000F7D]
10.850000
HandRotationPitchCircletFemale [GLOB:FE000F7F]
270.600006
HandRotationRollCircletFemale [GLOB:FE000F7E]
22.940001
HandRotationYawCircletFemale [GLOB:FE000F80]
260.450012

# IED Position Storage Overhaul

***Brain Storming***

- Manage Positioning Purely through JSON
  - Pros
    - Players can easily update positioning in or out of the game
    - Can make PapyrusUtil an optional dependency 
  - Cons
    - JSON loading will require PapyrusUtil as a dependency
    - MCM Position Page would need a major update to support JSON
    - Positional Data will still need to be stored in global variables in some form if we want to keep PapyrusUtil as a soft dependency
    - ESP and JSON positional data storage in variables will have to be solved for custom items
  - Notes
    - See `_GB_HB_AnimFunctions:ReadTransformFromJson()` as an example of how to load the json and check if PapyrusUtil is loaded

JSON Structure *maybe...*

``` MaleHandPositionList.Json
{
	"floatList" : 
	{
		"FormId|Plugin" : // Position by FormId Format
		[
			X,
			Y,
			Z,
			Pitch,
			Roll,
			Yaw,
			Scale
		],
        "Keyword|Plugin" : // Position by Keyword Format
		[
			X,
			Y,
			Z,
			Pitch,
			Roll,
			Yaw,
			Scale
		],
        "Default|ReadTheRoom.esp" : // Default Helmets 
        [ 
            6.8,
			-11.75,
			-10.85,
			270.6,
			0.44,
			260.45,
			1.05
        ],
        "DefaultCirclet|ReadTheRoom.esp" : // Default Circlets
        [
            -0.2,
            -11.25,
            10.85,
            270.6,
            22.94,
            260.45
        ],
		"Helmet|0x00012E4D|Skyrim.esm" : // Custom Positioning using FormId
		[
			6.8,
			-11.75,
			-10.85,
			270.6,
			0.44,
			260.45,
			1.05
		],
        "Helmet|ArmorHelmet|Skyrim.esm" : // Custom Positioning using Keyword
		[
			6.8,
			-11.75,
			-10.85,
			270.6,
			0.44,
			260.45,
			1.05
		]
	}
}
```
