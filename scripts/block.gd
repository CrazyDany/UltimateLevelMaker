extends StaticBody2D

class_name Block

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var bottom_collision: Area2D = $BottomArea

signal player_bottom_bump(player: Player)
signal block_breaked

func _on_bottom_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_bottom_bump.emit(area.get_parent())
