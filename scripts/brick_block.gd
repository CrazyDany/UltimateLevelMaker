extends Block

func _on_player_bottom_bump(player: Player):
	if player.is_big:
		queue_free()
