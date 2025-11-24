extends CharacterBody2D

const SPEED = 130.0
var spawn_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction.x > 0:
		animated_sprite.flip_h = false
	elif direction.x < 0:
		animated_sprite.flip_h = true
	
	if direction.length() == 0:
		animated_sprite.play("default")
	else:
		animated_sprite.play("run")
	velocity = direction * SPEED

	move_and_slide()
	
	#if direction != Vector2.ZERO:
		#print("Velocity: ", velocity, " | Speed: ", velocity.length())
