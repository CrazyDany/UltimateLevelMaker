extends AnimatableBody2D
class_name Item

@onready var sprite = $Sprite
@onready var collision: Area2D = $Collision

@export var matchable:bool = true

func _on_matched(player: Player):
	player.score+= 50
	
func _on_body_entered(body: Node):
	if body is Player:
		if matchable:
			_on_matched(body)

func _ready() -> void:
	pass
