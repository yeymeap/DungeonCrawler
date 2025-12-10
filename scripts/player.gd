extends CharacterBody2D

const SPEED = 130.0
const MAX_HEALTH = 100

var health = MAX_HEALTH
var spawn_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar := $CanvasLayer/HealthBar

func _ready():
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	
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

func take_damage(amount):
	print("take_damage called, amount:", amount)
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	health_bar.value = health
	print("Health after damage:", health)
	if health <= 0:
		print("Health is 0 or less, calling player_die()")
		player_die()

func player_die():
	print("player_die() called")
	await get_tree().create_timer(1.0).timeout
	print("Reloading scene")
	get_tree().reload_current_scene()
