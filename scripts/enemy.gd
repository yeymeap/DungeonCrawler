extends CharacterBody2D

@export var speed: float = 100.0
var player: Node2D = null

func _ready():
	# find the player in the scene tree
	player = get_tree().get_first_node_in_group("player")

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
