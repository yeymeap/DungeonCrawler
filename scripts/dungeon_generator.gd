extends Node2D

@onready var background_tilemaplayer: TileMapLayer = $Background
@onready var floor_tilemaplayer: TileMapLayer = $Floor
@onready var wall_tilemaplayer: TileMapLayer = $Wall

@export_enum("L-corridor", "Random Walk") var connect_type: String = "L-corridor"
@export var play_area_min = -50
@export var play_area_max = 50
@export var room_width_min: int = 10
@export var room_width_max: int = 16
@export var room_height_min: int = 10
@export var room_height_max: int = 16
@export var num_rooms: int = 5

@export var bg_tile_id: Vector2i = Vector2i(0, 14)
@export var floor_tile_id: Vector2i = Vector2i(0, 12)
@export var wall_tile_id: Vector2i = Vector2i(7, 0)
@export var padding_tile_id: Vector2i = Vector2i(1, 14)

var rooms: Array[Rect2i] = []
var padded_rooms: Array[Rect2i] = []
var room_centers: Array[Vector2i] = []
var corridors: Array = []

func _ready():
	fill_background()
	place_rooms()
	corridors = prim_mst()
	#generate_corridors()
	print(corridors)

func fill_background(): # fill with background tiles
	for y in range(-100, 100):
		for x in range(-100, 100):
			background_tilemaplayer.set_cell(Vector2i(x, y), 0, bg_tile_id)

func place_rooms():
	var attempts := 0
	var placed := 0
	while placed < num_rooms and attempts < num_rooms * 5:
		var room_pos = Vector2i(randi_range(play_area_min, play_area_max), randi_range(play_area_min, play_area_max))
		if generate_room(room_pos):
			placed += 1
		attempts += 1
	print("Number of rooms: ", rooms.size())

func get_room_center(room: Rect2i) -> Vector2i:
	return room.position + room.size / 2

func generate_room(origin: Vector2i): # generate rooms
	var room_height = randi_range(room_height_min, room_height_max)
	var room_width = randi_range(room_width_min, room_width_max)
	var room_padding = 2
	
	var padded_room = Rect2i(
		origin - Vector2i(room_padding, room_padding),
		Vector2i(room_width + room_padding * 2, room_height + room_padding * 2)
		)
		
	for room in padded_rooms:
		if padded_room.intersects(room):
			return false
			
	padded_rooms.append(padded_room)
	var new_room = Rect2i(origin, Vector2i(room_width, room_height))
	rooms.append(new_room)
	var center = get_room_center(new_room)
	room_centers.append(center)

	for y in range(room_height):
		for x in range(room_width):
			var pos = origin + Vector2i(x, y)
			if x == 0 or y == 0 or x == room_width - 1 or y == room_height - 1:
				wall_tilemaplayer.set_cell(pos, 0, wall_tile_id)
			else:
				floor_tilemaplayer.set_cell(pos, 0, floor_tile_id)
	
	"""for y in range(padded_room.size.y):
		for x in range(padded_room.size.x):
			var pos = padded_room.position + Vector2i(x, y)
			if not new_room.has_point(pos):
				background_tilemaplayer.set_cell(pos, 0, padding_tile_id)"""
				
	return true
	
func distance_between_room_centers(a: Vector2i, b: Vector2i) -> float:
	return a.distance_to(b)

func prim_mst() -> Array:
	var n = room_centers.size()
	var connected = []
	for i in n:
		connected.append(false)
	var mst_edges = []
	
	var connected_indices = []
	connected[0] = true
	connected_indices.append(0)
	
	while connected_indices.size() < n:
		var min_dist = INF
		var from_index = -1
		var to_index = -1
		
		for i in connected_indices:
			for j in range(n):
				if connected[j]:
					continue
				var d = distance_between_room_centers(room_centers[i], room_centers[j])
				if d < min_dist:
					min_dist = d
					from_index = i
					to_index = j
		if to_index == -1:
			break
		
		connected[to_index] = true
		connected_indices.append(to_index)
		mst_edges.append([room_centers[from_index], room_centers[to_index]])
	return mst_edges
	
