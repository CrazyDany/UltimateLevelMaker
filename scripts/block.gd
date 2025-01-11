class_name Block extends RigidBody2D

@export var sprite: Node2D
@export var bottom_collision: Area2D

var init_y: float

func _on_bottom_area_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		_on_player_bottom_bump(area.get_parent())
		self.sprite.position.y -= 5

func _on_player_bottom_bump(player: Player):
	pass

func _on_player_collide(player: Player):
	pass
	
func on_ready() -> void:
	pass

func _ready() -> void:
	assert(sprite, "У блока {path} не определен спрайт".format({"path": self.get_script().get_path()}))
	assert(bottom_collision, "У блока {path} не определена нижняя маска".format({"path": self.get_script().get_path()}))
	bottom_collision.connect("area_entered", _on_bottom_area_area_entered)
	init_y = self.sprite.position.y
	#self.sprite.animation = "default"
	on_ready()
	
func _physics_process(delta):
	self.sprite.position.y = lerp(self.sprite.position.y, init_y, 0.2)

func _init() -> void:
	freeze = true
