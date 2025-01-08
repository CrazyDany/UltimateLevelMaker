extends StaticBody2D

class_name Block

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $BlockCollision
@onready var bottom_collision: Area2D = $BottomArea

@export var givable_item: Item

func _on_bottom_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		_on_player_bottom_bump(area.get_parent())

func _on_player_bottom_bump(player: Player):
	pass

func _ready() -> void:
	self.sprite.animation = "default"
	if givable_item != null:
		givable_item.matchable = false
		self.givable_item.sprite.visible = false
