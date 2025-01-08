extends Block

var used:bool = false

func _on_player_bottom_bump(player: Player):
	if self.givable_item != null and not self.used:
		self.givable_item.matchable = true
		self.givable_item.sprite.visible = true
		self.used = true
		self.sprite.animation = "used"
