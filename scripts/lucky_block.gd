extends Block

var used: bool = false
@export var list_items: Array[PackedScene] = []

func _on_player_bottom_bump(player: Player):
	if not used:
		if list_items.size() > 0:
			var random_index = randi() % list_items.size()
			var item_scene: PackedScene = list_items[random_index]
			if item_scene:
				call_deferred("_spawn_item", item_scene, player)
			used = true
			self.sprite.animation = "used"

func _spawn_item(item_scene: PackedScene, player: Player):
	var item_instance: Item = item_scene.instantiate()
	add_child(item_instance)
	item_instance.position.y -= 12
	if item_instance is Coin:
		item_instance._on_matched(player)

func _ready() -> void:
	self.sprite.animation = "default"
