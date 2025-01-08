extends Item

func _on_matched(player: Player):
	player.score+= 1000
	queue_free()
	player.scale *= 2
