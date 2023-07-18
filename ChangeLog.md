# Read The Room - Fixes and Tweaks

## Version 1.0

Massive Overhaul and Refactor to all logic and functionality.

### Bugs Squashed

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

### Optimizations and Refactors

- Added P.O.C. (Proof of Concept) for adding new Lowerable Hoods from mods using [FLM - Form List Manipulator](https://www.nexusmods.com/skyrimspecialedition/mods/74037). Added hoods from [H2135's Fantasy Series6](https://www.patreon.com/posts/sse-h2135s-cbbe-39697683). *I'll be taking requests for more hoods*. Please note that hoods that do not have a "lowered" version might take a while longer since a custom mesh would have to be created. 
- Added empty `ReadTheRoom_Exclusions_KID.ini` file with an example of how to add items to the exclusion list
- Animation event handling. RTR now uses its own animation events added using [Behavior Data Injector](https://www.nexusmods.com/skyrimspecialedition/mods/78146). While RTR animations don't produce audible "sound" they use the annotations for "SoundPlay.NPCCombatIdleA" which will create a sound while sneaking that alerts enemies. It also triggers any events from other mods using the same annotations. I added Several new animation events that are unique to RTR and updated the annotations in the originals animations. The Immersive Equipment Display attachments are also optimized to use these new animation events to reduce lag time as much as possible for attaching the item to the hand or hip.
- Debug Mode. For my own use I added debug outputs for virtually every papyrus function. This outputs into the console and is togglable through the MCM
- 