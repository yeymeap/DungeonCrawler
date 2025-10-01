extends Node2D

@export_enum("Horizontal", "Vertical") var move_axis: String = "Horizontal"
@export var speed: float = 60

var direction: int = 1

@onready var ray_up = $RayCastUp
@onready var ray_down = $RayCastDown
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight

func _process(delta):
	if move_axis == "Horizontal":
		if ray_right.is_colliding(): direction = -1
		elif ray_left.is_colliding(): direction = 1
		position.x += direction * speed * delta
	else:
		if ray_down.is_colliding(): direction = -1
		elif ray_up.is_colliding(): direction = 1
		position.y += direction * speed * delta
