extends Block

class_name BrickBlock

func _on_player_bottom_bump(player: Player):
	if player.is_big:
		queue_free()

func _on_player_collide(player: Player):
	if player.in_spinjump:
		queue_free()
