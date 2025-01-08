extends Item

var matched:bool = false
@onready var animator: AnimationPlayer = $AnimationPlayer

func _on_matched(player: Player):
	player.coins+= 1
	player.score+= 100
	#print("coins: ", player.coins)
	if not matched:
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
