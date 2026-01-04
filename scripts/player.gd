extends CharacterBody2D

const SPEED = 130.0
const MAX_HEALTH = 100

var health = MAX_HEALTH
var spawn_position: Vector2

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar := $CanvasLayer/HealthBar
@onready var sprite = $AnimatedSprite2D

@onready var melee_attack = $MeleeAttack
var attack_damage = 25
var is_attacking = false
var attack_cooldown = 0.5
var can_attack = true

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE # pausable
	health_bar.max_value = MAX_HEALTH
	health_bar.value = health
	melee_attack.monitoring = false
	
func _input(event):
	if event.is_action_pressed("ui_accept") and can_attack:
		perform_attack()

func perform_attack():
	if is_attacking:
		return
		
	is_attacking = true
	can_attack = false

	var tween = create_tween()
	tween.tween_property(sprite, "scale", sprite.scale * 1.3, 0.1)
	tween.tween_property(sprite, "scale", sprite.scale, 0.1)
	
	print("360° attack!")

	melee_attack.monitoring = true
	
	await get_tree().create_timer(0.03).timeout

	var bodies = melee_attack.get_overlapping_bodies()
	
	#print("Bodies detected:", bodies.size())
	for body in bodies:
		if body.has_method("take_damage") and body != self:
			#print("DEALING DAMAGE to:", body.name)
			body.take_damage(attack_damage)

	await get_tree().create_timer(0.2).timeout
	melee_attack.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false
	can_attack = true

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
	
	set_physics_process(false)
	
	Engine.time_scale = 0.3
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(sprite, "modulate:a", 0.0, 1.5)
	
	tween.tween_property(sprite, "scale", Vector2(0.1, 0.1), 1.5).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "rotation", deg_to_rad(360), 1.5)
	
	await tween.finished
	
	Engine.time_scale = 1.0
	
	await get_tree().create_timer(0.5).timeout
	
	print("Reloading scene")
	get_tree().reload_current_scene()
