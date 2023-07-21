ScriptName ReadTheRoomNPC extends ActiveMagicEffect

; ReadTheRoomNPC
; OnCombatStateChanged will only report combat state changes for NPCs, not the player
; So this is a tiny script to rely NPC combat state changes to the player

Actor property PlayerRef auto

; Event OnCombatStateChanged
; Send a mod event to the player when the NPC combat state changes and their target is the player
Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
    if akTarget == PlayerRef
	    SendModEvent("ReadTheRoomCombatStateChanged", akTarget.GetActorBase().GetName(), aeCombatState as Float)
    endIf

    if aeCombatState == 0
        SendModEvent("ReadTheRoomCombatStateChanged", akTarget.GetActorBase().GetName(), 0.0)
    endIf
EndEvent

; Event OnDeath
; Send a simulated CombatStateChanged mod event to the player when the NPC dies with the state as 0 (not in combat)
Event OnDeath(Actor akKiller)
    SendModEvent("ReadTheRoomCombatStateChanged", "npcDeathState", 0.0)
EndEvent
