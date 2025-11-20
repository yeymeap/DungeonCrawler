extends CharacterBody2D

@export_enum("Horizontal", "Vertical") var move_axis: String = "Horizontal"
@export var can_move: bool = true 
@export var speed: float = 60

var direction: int = 1

@onready var ray_up = $RayCastUp
@onready var ray_down = $RayCastDown
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight

func _physics_process(delta):
	if can_move:
		if move_axis == "Horizontal":
			velocity.y = 0
			if ray_right.is_colliding():
				direction = -1
			elif ray_left.is_colliding():
				direction = 1
			velocity.x = direction * speed
		else:
			velocity.x = 0
			if ray_down.is_colliding():
				direction = -1
			elif ray_up.is_colliding():
				direction = 1
			velocity.y = direction * speed

	#move_and_slide()
