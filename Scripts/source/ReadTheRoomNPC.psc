ScriptName ReadTheRoomNPC extends ActiveMagicEffect

; @Note Disabling this script until other refactors have completed

; GlobalVariable property CombatEquip auto
; MagicEffect property RTR_CombatEffect auto 
; Perk property ReadTheRoomPerk auto
; Spell property RTR_CombatSpell auto

; Event OnCombatStateChanged(Actor akTarget, int aeCombatState)
; 	if CombatEquip.GetValueInt() == 1
; 		if aeCombatState == 1 && akTarget.HasPerk(ReadTheRoomPerk) && !akTarget.HasMagicEffect(RTR_CombatEffect)
; 			RTR_CombatSpell.Cast(akTarget, akTarget)
; 		endif
; 	endif
; EndEvent