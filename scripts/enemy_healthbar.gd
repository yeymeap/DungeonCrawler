extends Node2D

@onready var progress_bar = $ProgressBar

func _ready():
	hide()
	
func initialize(max_hp: int):
	progress_bar.max_value = max_hp
	progress_bar.value = max_hp
	hide()

func update_health(current_hp: int, max_hp: int):
	progress_bar.value = current_hp
	
	if current_hp < max_hp:
		show()
	else:
		hide()
