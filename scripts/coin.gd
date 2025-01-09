extends Item

class_name Coin

var matched:bool = false
@onready var animator: AnimationPlayer = $AnimationPlayer

func _on_matched(player: Player):
	player.coins+= 1
	player.score+= 100
	
	if not matched:
		var effect_scene = preload("res://assets/nodes/effects/glosses_effect.tscn")
		if effect_scene:
			var effect = effect_scene.instantiate()
			add_child(effect)
			effect.get_node("AnimationPlayer").play("default")
			effect.get_node("AnimationPlayer").speed_scale*= 0.8
			effect.get_node("AnimatedSprite2D").self_modulate.a = 0.7
			effect.position.y -= 5
		else:
			print("Failed to load scene.")
		matched = true
	
func _ready():
	animator.play("rotate")
	
func _process(delta: float) -> void:
	if matched:
		if sprite.self_modulate.a > 0:
			self.sprite.position.y -= 0.25
			self.animator.speed_scale /= 1.15
			sprite.self_modulate.a -= 0.03
		else:
			queue_free()
