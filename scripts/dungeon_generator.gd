extends Node2D

@onready var background_tilemaplayer: TileMapLayer = $Background
@onready var floor_tilemaplayer: TileMapLayer = $Floor
@onready var wall_tilemaplayer: TileMapLayer = $Wall
@onready var enemy_scene = preload("res://scenes/slime.tscn")

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

const FLOOR_TILE = Vector2i(1, 14)
#const WALL_TILE = Vector2i(2, 14)
const WALL_TILE = Vector2i(7, 0)

const CORRIDOR_WIDTH = 3
const WALL_THICKNESS = 1

func _ready():
	pass

func generate_dungeon():
	fill_background()
	place_rooms()
	corridors = prim_mst()
	create_corridors()
	#print(corridors)
	print(room_centers)

func fill_background() -> void: # fill with background tiles
	for y in range(-100, 100):
		for x in range(-100, 100):
			background_tilemaplayer.set_cell(Vector2i(x, y), 0, bg_tile_id)

func place_rooms() -> void:
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

func generate_room(origin: Vector2i) -> bool: # generate rooms
	var room_height = randi_range(room_height_min, room_height_max)
	var room_width = randi_range(room_width_min, room_width_max)
	var room_padding = 10
	
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

func overlaps_room(rectangle: Rect2i) -> bool:
	for room in rooms:
		if room.intersects(rectangle):
			return true
	return false

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

func create_corridors() -> void:
	for conn in corridors:
		var start = conn[0]
		var end = conn[1]
		connect_rooms(start, end)
		
func connect_rooms(start: Vector2i, end: Vector2i) -> void:
	var threshold = 5
	var dx = abs(end.x - start.x)
	var dy = abs(end.y - start.y)
	#print("dx: ", dx)
	#print("dy: ", dy)
	if dx <= threshold or dy <= threshold:
		create_straight_corridor(start, end)
	else:
		draw_L(start, end)

func create_straight_corridor(start: Vector2i, end: Vector2i) -> void:
	var is_horizontal = abs(end.x - start.x) >= abs(end.y - start.y)
	if is_horizontal:
		#print("Straight horizontal corridor")
		var x_min = min(start.x, end.x)
		var x_max = max(start.x, end.x)
		var y = start.y
		for x in range(x_min, x_max + 1):
			carve_straight_segment(Vector2i(x, y), true)
	else:
		#print("Straight vertical corridor")
		var y_min = min(start.y, end.y)
		var y_max = max(start.y, end.y)
		var x = start.x
		for y in range(y_min, y_max + 1):
			carve_straight_segment(Vector2i(x, y), false)
	
func carve_straight_segment(center: Vector2i, is_horizontal: bool) -> void:
	var half_width = CORRIDOR_WIDTH / 2
	
	if is_horizontal:
		for dy in range(-half_width, half_width + 1):
			var tile_pos = Vector2i(center.x, center.y + dy)
			floor_tilemaplayer.set_cell(tile_pos, 0, FLOOR_TILE)
			wall_tilemaplayer.erase_cell(tile_pos)
	else:
		for dx in range(-half_width, half_width + 1):
			var tile_pos = Vector2i(center.x + dx, center.y)
			floor_tilemaplayer.set_cell(tile_pos, 0, FLOOR_TILE)
			wall_tilemaplayer.erase_cell(tile_pos)
	
	for dx in range(-half_width - 1, half_width + 2):
		for dy in range(-half_width - 1, half_width + 2):
			if abs(dx) <= half_width and abs(dy) <= half_width:
				continue
			
			var wall_pos = Vector2i(center.x + dx, center.y + dy)
			if not is_floor_tile(wall_pos):
				wall_tilemaplayer.set_cell(wall_pos, 0, WALL_TILE)
				
func draw_L(start: Vector2i, end: Vector2i) -> void:
	#print("L corridor")
	var choice = randf() < 0.5
	var corner: Vector2i
	if choice:
		corner = Vector2i(end.x, start.y)
		create_straight_corridor(start, corner)
		create_straight_corridor(corner, end)
	else:
		corner = Vector2i(start.x, end.y)
		create_straight_corridor(start, corner)
		create_straight_corridor(corner, end)
	fill_corner(corner)

func fill_corner(corner: Vector2i):
	var half_width = CORRIDOR_WIDTH / 2
	
	for dx in range(-half_width, half_width + 1):
		for dy in range(-half_width, half_width + 1):
			var tile_pos = Vector2i(corner.x + dx, corner.y + dy)
			floor_tilemaplayer.set_cell(tile_pos, 0, FLOOR_TILE)
			wall_tilemaplayer.erase_cell(tile_pos)
	
	for dx in range(-half_width - 1, half_width + 2):
		for dy in range(-half_width - 1, half_width + 2):
			if abs(dx) <= half_width and abs(dy) <= half_width:
				continue
			var wall_pos = Vector2i(corner.x + dx, corner.y + dy)
			if not is_floor_tile(wall_pos): #and not is_wall_tile(wall_pos):
				wall_tilemaplayer.set_cell(wall_pos, 0, WALL_TILE)

func is_floor_tile(pos: Vector2i) -> bool:
	var tile_data = floor_tilemaplayer.get_cell_tile_data(pos)
	return tile_data != null
	
func is_wall_tile(pos: Vector2i) -> bool:
	var tile_data = wall_tilemaplayer.get_cell_tile_data(pos)
	return tile_data != null

func spawn_enemy():
	for room in rooms:
		if randf() < 0.6:
			var x = randi_range(room.position.x + 1, room.position.x + room.size.x - 2)
			var y = randi_range(room.position.y + 1, room.position.y + room.size.y - 2)
			var spawn_pos = Vector2i(x, y)
			spawn_enemy_at(spawn_pos)
			print("Enemy spawn at: ", spawn_pos)

func spawn_enemy_at(tile_pos: Vector2i) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.position = floor_tilemaplayer.map_to_local(tile_pos)
	add_child(enemy)
