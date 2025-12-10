extends Area2D

@onready var timer = $Timer
var damage_amount := 20  # how much health this hit does

func _on_body_entered(body: Node2D) -> void:
	# Only affect player
	if body.is_in_group("player"):
		body.take_damage(damage_amount)
