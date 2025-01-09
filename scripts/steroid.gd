extends Item

func _on_matched(player: Player):
	player.score+= 1000
	player.scale *= 1.3
	player.is_big = true
	
	queue_free()
