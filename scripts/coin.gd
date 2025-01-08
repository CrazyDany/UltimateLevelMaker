extends Item

func _on_matched(player: Player):
	queue_free()
	#player.scale *= 0.925
	#player.srun_max_speed*= 1.5
	#player.run_max_speed*= 1.25
	#player.walk_max_speed*=1.05
	#player.max_jump_height*= 1.1
	
func _ready():
	animator.play("rotate")
	
