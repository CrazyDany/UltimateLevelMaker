extends StaticBody2D

class_name Block

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var collision: CollisionShape2D = $BlockCollision
@onready var bottom_collision: Area2D = $BottomArea

@onready var init_y: float = self.position.y

func _on_bottom_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		_on_player_bottom_bump(area.get_parent())
		self.position.y -= 5

func _on_player_bottom_bump(player: Player):
	pass

func _ready() -> void:
	self.sprite.animation = "default"

func _physics_process(delta):
	self.position.y = lerp(self.position.y, init_y, 0.2)
