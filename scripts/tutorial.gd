extends Node2D

@onready var instruction_label = $TutorialUI/InstructionPanel/VBoxContainer/InstructionLabel
@onready var title_label = $TutorialUI/InstructionPanel/VBoxContainer/TitleLabel
@onready var player = $Player
@onready var pause_menu = $PauseMenu
@onready var room_trigger = $RoomTrigger

var current_step = -1
var tutorial_paused = false
var entered_next_room = false

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_welcome()
	
	room_trigger.body_entered.connect(_on_room_entered)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if tutorial_paused:
			return
		if get_tree().paused:
			pause_menu.resume_game()
		else:
			pause_menu.pause_game()
	
	if event.is_action_pressed("ui_accept") and tutorial_paused:
		continue_tutorial()

func start_welcome():
	tutorial_paused = true
	get_tree().paused = true
	title_label.text = "WELCOME TO THE TUTORIAL"
	instruction_label.text = "Learn the basics of movement and combat.

Press SPACE to begin!"

func show_completion():
	tutorial_paused = true
	get_tree().paused = true
	instruction_label.text = "Tutorial Complete!

Press SPACE to return to main menu"
	current_step = 99

func continue_tutorial():
	tutorial_paused = false
	get_tree().paused = false
	
	if current_step == 99:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	if current_step == -1:
		current_step = 0
		title_label.text = "TUTORIAL"
		show_instruction("Move to the next room using WASD or Arrow Keys")

func _on_room_entered(body: Node2D):
	if body.has_method("take_damage"):
		print("Player entered next room!")
		entered_next_room = true

func _physics_process(delta):
	if tutorial_paused:
		return
	
	check_tutorial_progress()

func check_tutorial_progress():
	if current_step == 0:
		if entered_next_room:
			current_step = 1
			show_instruction("Great! Now press SPACE to attack nearby enemies")
	
	elif current_step == 1:
		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy.has_method("was_just_hit") and enemy.was_just_hit():
				current_step = 2
				show_instruction("Nice! Defeat all enemies to complete the tutorial")
				break
	
	elif current_step == 2:
		var remaining_enemies = get_tree().get_nodes_in_group("enemies")
		if remaining_enemies.size() == 0:
			show_completion()

func freeze_and_show(text: String, next_step: int):
	tutorial_paused = true
	get_tree().paused = true
	instruction_label.text = text
	await get_tree().create_timer(0.1).timeout
	current_step = next_step

func show_instruction(text: String):
	instruction_label.text = text
