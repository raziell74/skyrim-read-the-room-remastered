scriptName ReadTheRoomInt extends Quest

Perk property ReadTheRoomPerk auto
Actor player

Event Oninit()
	utility.Wait(1 as Float)
	player = game.getplayer()
	if player.hasperk(ReadTheRoomPerk) == false
		player.addperk(ReadTheRoomPerk)
	endif
	
	utility.Wait(10 as Float)
	if player.hasperk(ReadTheRoomPerk) == false
		player.addperk(ReadTheRoomPerk)
	endif	
EndEvent