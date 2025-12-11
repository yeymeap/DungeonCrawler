extends CanvasLayer

@onready var resume_button = $Control/VBoxContainer/ResumeButton
@onready var main_menu_button = $Control/VBoxContainer/MainMenuButton
@onready var quit_button = $Control/VBoxContainer/QuitButton

func _ready():
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_resume_pressed():
	resume_game()

func _on_main_menu_pressed():
	resume_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

func pause_game():
	show()
	get_tree().paused = true

func resume_game():
	hide()
	get_tree().paused = false
