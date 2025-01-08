extends Block

func _on_player_bottom_bump(player: Player):
	queue_free()
