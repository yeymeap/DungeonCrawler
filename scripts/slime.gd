extends CharacterBody2D

const MAX_HEALTH = 100

@export_enum("Horizontal", "Vertical") var move_axis: String = "Horizontal"
@export var can_move: bool = true 
@export var speed: float = 60
@export var chase_range = 200
@export var health = MAX_HEALTH

var direction: int = 1
var just_hit = false
var player = null

@onready var ray_up = $RayCastUp
@onready var ray_down = $RayCastDown
@onready var ray_left = $RayCastLeft
@onready var ray_right = $RayCastRight
#@onready var player = get_node("/root/Game/Player")
@onready var health_bar = $EnemyHealthBar

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE # pausable
	health_bar.initialize(MAX_HEALTH)
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		print("Warning: No player found in 'player' group")
	#take_damage(20) # debug
	
func _physics_process(delta):
	if player == null or not is_instance_valid(player):
		return
	
	var to_player = player.global_position - global_position
	var distance = to_player.length()
	
	if distance < chase_range:
		velocity = to_player.normalized() * speed
	else:
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
	
	move_and_slide()  # Call only once at the end

func take_damage(amount: int):
	health -= amount
	health = clamp(health, 0, MAX_HEALTH)
	health_bar.update_health(health, MAX_HEALTH)
	just_hit = true
	
	if health <= 0:
		die()
	
func was_just_hit() -> bool:
	if just_hit:
		just_hit = false
		return true
	return false
	
func die():
	print("Enemy died")
	queue_free()
	
