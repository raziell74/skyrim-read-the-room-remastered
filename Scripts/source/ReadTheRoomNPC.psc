ScriptName ReadTheRoomNPC extends ActiveMagicEffect

; ReadTheRoomNPC
; OnCombatStateChanged will only report combat state changes for NPCs, not the player
; So this is a tiny script to rely NPC combat state changes to the player

; Versioning
GlobalVariable property RTR_Version auto

; Player Reference
Actor property PlayerRef auto

; Event OnCombatStateChanged
; Send a mod event to the player when the NPC combat state changes and their target is the player
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    SendModEvent("ReadTheRoomCombatStateChanged", akTarget.GetActorBase().GetName(), aeCombatState as Float)
EndEvent

; Event OnDeath
; Send a simulated CombatStateChanged mod event to the player when the NPC dies with the state as 0 (not in combat)
Event OnDeath(Actor akKiller)
    SendModEvent("ReadTheRoomCombatStateChanged", "npcDeathState", 0.0)
EndEvent
