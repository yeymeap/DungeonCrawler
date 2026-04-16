extends Node2D

@onready var instruction_label = $TutorialUI/InstructionPanel/VBoxContainer/InstructionLabel
@onready var title_label = $TutorialUI/InstructionPanel/VBoxContainer/TitleLabel
@onready var player = $Player
@onready var pause_menu = $PauseMenu
@onready var room_trigger = $RoomTrigger

var current_step = -1
var tutorial_paused = false
var entered_room2 = false
var picked_up_health = false
var portal = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	start_welcome()
	room_trigger.body_entered.connect(_on_room2_entered)
	
	portal = get_node_or_null("Portal")
	if portal:
		portal.visible = false
		
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
	title_label.text = "WELCOME TO THE DUNGEON!"
	instruction_label.text = "Let's learn the basics before you head in.\nPress SPACE to begin!"

func continue_tutorial():
	tutorial_paused = false
	get_tree().paused = false
	
	if current_step == 99:
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
		return
	
	if current_step == -1:
		current_step = 0
		title_label.text = "TUTORIAL"
		show_instruction("Move to the next room using WASD or Arrow Keys!")

func show_completion():
	tutorial_paused = true
	get_tree().paused = true
	title_label.text = "TUTORIAL COMPLETE!"
	instruction_label.text = "You're ready for the dungeon!\nPress SPACE to return to main menu!"
	current_step = 99

func _on_room2_entered(body: Node2D):
	if body.has_method("take_damage"):
		entered_room2 = true

func _physics_process(delta):
	if tutorial_paused:
		return
	check_tutorial_progress()

func check_tutorial_progress():
	if current_step == 0:
		if entered_room2:
			current_step = 1
			player.take_damage(20)
			show_instruction("You took damage! Pick up the Health Pack to restore your HP!")

	elif current_step == 1:
		var hp = get_node_or_null("HealthPack")
		if picked_up_health or hp == null:
			current_step = 2
			show_instruction("Nice! Now head to the next room.\nWatch out — there's fire blocking the entrance!")

	elif current_step == 2:
		var fire = get_node_or_null("FireObstacle")
		if fire != null:
			var dist = player.global_position.distance_to(fire.global_position)
			if dist < 200:
				current_step = 3
				show_instruction("Fire deals damage over time — time your entrance carefully!\nEnemies are waiting in the next room. Press SPACE to attack!")
		else:
			current_step = 3
			show_instruction("Enemies are waiting! Press SPACE to attack!")

	elif current_step == 3:
		var enemies = get_tree().get_nodes_in_group("enemies")
		for enemy in enemies:
			if enemy.has_method("was_just_hit") and enemy.was_just_hit():
				current_step = 4
				show_instruction("Good! Defeat all enemies to open the portal!")
				break

	elif current_step == 4:
		var remaining = get_tree().get_nodes_in_group("enemies")
		if remaining.size() == 0:
			current_step = 5
			if portal:
				portal.visible = true
			show_instruction("All enemies defeated!\nStep into the portal to complete the tutorial!\nIn the real game, you'll find the portal in the spawn room!")

	elif current_step == 5:
		if portal == null:
			portal = get_node_or_null("Portal")
			return
		var dist = player.global_position.distance_to(portal.global_position)
		if dist < 80:
			await get_tree().create_timer(0.5).timeout
			show_completion()

func show_instruction(text: String):
	instruction_label.text = text
