extends Node

var width: int = 9
var height: int = 9
var mine_count = 10

var tile_size: int = 30
var auto_size_tiles = true

var min_tile_size = 30

enum WorldValues {
	HIDDEN = -1,
	FLAG = -2,
	BOMB = -3,
	EMPTY = -4
}

var offsets = Vector2(50, 100 + 25 if OS.get_name() == 'iOS' else 0)
