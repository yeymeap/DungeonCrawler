extends Area2D

@onready var visual = $ColorRect
@onready var collision_shape = $CollisionShape2D
@onready var timer = $Timer

@export var ignite_duration = 2.0
@export var cooldown_duration = 2.0
@export var damage_amount = 20

var is_ignited = false
var damage_timer = 0.0
var damage_interval = 0.5

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	monitoring = true
	monitorable = false
	
	set_fire_state(false)
	
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	timer.start(cooldown_duration)
	
	print("Fire obstacle created at:", global_position)

func _physics_process(delta):
	if not is_ignited:
		return
		
	damage_timer += delta
	
	if damage_timer >= damage_interval:
		damage_timer = 0.0

		var overlapping = get_overlapping_bodies()
		for body in overlapping:
			if body.has_method("take_damage"):
				print("Fire damaging:", body.name)
				body.take_damage(damage_amount)

func _on_timer_timeout():
	if is_ignited:
		set_fire_state(false)
		timer.start(cooldown_duration)
		print("Fire OFF at:", global_position)
	else:
		set_fire_state(true)
		timer.start(ignite_duration)
		print("Fire ON at:", global_position)

func set_fire_state(ignited: bool):
	is_ignited = ignited
	damage_timer = 0.0
	
	if ignited:
		visual.color = Color(1, 0.3, 0, 0.9)
		visual.show()
		collision_shape.disabled = false
	else:
		visual.color = Color(0.3, 0.1, 0, 0.2)
		visual.show()
		collision_shape.disabled = true
