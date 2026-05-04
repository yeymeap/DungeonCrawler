extends Node2D

const TILE_SIZE = 16

func _draw():
	var parent = get_parent()
	var parent_corridors = parent.corridors
	var room_centers = parent.room_centers
	
	for c in parent_corridors:
		var start = c[0] * TILE_SIZE
		var end = c[1] * TILE_SIZE
		draw_line(start, end, Color(1, 0, 0), 3)
	
	for center in room_centers:
		var pos = center * TILE_SIZE
		draw_circle(pos, 5, Color(0.6, 0.0, 1.0))
