extends Node2D

const TILE_SIZE = 16

func _draw():
	var parent_corridors = get_parent().corridors
	print("Drawing")
	for c in parent_corridors:
		var start = c[0] * TILE_SIZE
		var end = c[1] * TILE_SIZE
		draw_line(start, end, Color(1, 0, 0), 3)
