extends Node2D

@onready var player = $Player
@onready var dungeon = $DungeonGenerator
@onready var camera = $Player/Camera2D

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Player position:", player.global_position)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_R:
			reset_game()
func _ready():
	dungeon.generate_dungeon()
	if dungeon.room_centers.size() > 0:
		var tile_size = Vector2(16, 16)
		camera.position_smoothing_enabled = false
		var spawn_pos = Vector2(dungeon.spawn_room.position + dungeon.spawn_room.size / 2)
		player.global_position = dungeon.global_position + spawn_pos * tile_size
		await get_tree().process_frame
		camera.position_smoothing_enabled = true
		print("Player spawned at:", player.global_position)
		dungeon.spawn_enemy()
	else:
		print("No room centers generated!")
func reset_game():
	get_tree().reload_current_scene()
