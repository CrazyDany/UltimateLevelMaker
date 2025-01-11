extends Block

func _on_player_collide(player: Player):
	player.queue_free()

func _process(delta: float) -> void:
	self.sprite.rotate(deg_to_rad(1))
