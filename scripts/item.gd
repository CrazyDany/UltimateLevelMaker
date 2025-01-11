extends AnimatableBody2D
class_name Item

@export var sprite: Node2D
@export var collision: Area2D

@export var matchable:bool = true

func _on_matched(player: Player):
	player.score+= 50
	
func _ready() -> void:
	pass
