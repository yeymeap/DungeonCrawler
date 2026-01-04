extends Area2D

@onready var timer = $Timer
var damage_amount := 20
var player_in_zone = null

func _ready():
	process_mode = Node.PROCESS_MODE_PAUSABLE
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		print("Player entered killzone!")
		player_in_zone = body
		body.take_damage(damage_amount)  # Immediate first hit
		timer.start()  # Start repeating damage

func _on_body_exited(body: Node2D) -> void:
	if body == player_in_zone:
		print("Player left killzone!")
		player_in_zone = null
		timer.stop()

func _on_timer_timeout() -> void:
	# Damage again if player still in zone
	if player_in_zone != null and is_instance_valid(player_in_zone):
		print("Continuous damage!")
		player_in_zone.take_damage(damage_amount)
