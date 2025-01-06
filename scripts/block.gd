extends StaticBody2D

var init_y: float 
@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	init_y = sprite.position.y
	
func _physics_process(delta):
	sprite.position.y = lerp(sprite.position.y, init_y, 0.2)

func _on_area_2d_area_entered(area):
	if area.get_parent() is CharacterBody2D:
		sprite.position.y -= 7
