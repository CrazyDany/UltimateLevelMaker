extends Item

func _on_matched(player: Player):
	queue_free()
	player.scale *= 2
