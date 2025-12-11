extends Control

@onready var start_button = $VBoxContainer/StartButton
@onready var tutorial_button = $VBoxContainer/TutorialButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/game_procedural.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://scenes/tutorial.tscn")

func _on_quit_pressed():
	get_tree().quit()
