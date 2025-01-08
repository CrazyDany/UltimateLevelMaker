extends AnimatableBody2D
class_name Item

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: Area2D = $Collision

@export var matchable:bool = true

func _on_matched(player: Player):
	pass
	
func _on_body_entered(body: Node):
	if body is Player:
		if matchable:
			_on_matched(body)

func _ready() -> void:
	pass
