extends CharacterBody2D

const SPEED = 130.0

func _physics_process(delta: float) -> void:
	# Get a normalized direction vector from input
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Scale it by speed to get velocity
	velocity = direction * SPEED

	# Apply movement with collision
	move_and_slide()
	
	# Debug: print actual speed (length of velocity vector)
	#if direction != Vector2.ZERO:
		#print("Velocity: ", velocity, " | Speed: ", velocity.length())
