ScriptName ReadTheRoomFollowerMonitor extends ActiveMagicEffect

; Strippped current folloewr functionality to avoid bugs while testing scripting for the player
; My Plan for overhauling the follower monitor is to have it triggered from an SKSE ModEvent triggered by the PlayerMonitor
; The events will simply be "RTR_ModEquip" an "RTR_ModUnequip". These will trigger the follower with this perk added
; to equip or unequip the item. Followers should "Read The Room" exactly the same as the player
