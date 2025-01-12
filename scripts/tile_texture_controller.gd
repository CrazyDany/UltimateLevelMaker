extends TileMapLayer

@export var tile: TileMapLayer
@export var cur_world: String = "underground"

var texture

func _process(delta):
	tile.tile_set.get_source(2).texture = texture
	
	if cur_world == "base":
		texture = load("res://assets/tiles/BaseFloorTilemap.png")
	elif cur_world == "overworld":
		texture = load("res://assets/tiles/OverworldFloorTilemap.png")
	elif cur_world == "underground":
		texture = load("res://assets/tiles/UndergroundFloorTilemap.png")
