extends Area2D

@export var heal_amount := 50
@onready var polygon: Polygon2D = $Polygon2D

var base_scale := Vector2.ONE
var time := 0.0

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)
	
	polygon.polygon = create_circle(8, 16)
	polygon.color = Color(0.2, 1, 0.2)
	
	base_scale = scale

func create_circle(radius: float, points: int) -> PackedVector2Array:
	var arr := PackedVector2Array()
	for i in range(points):
		var angle = TAU * i / points
		arr.append(Vector2(cos(angle), sin(angle)) * radius)
	return arr

func _on_body_entered(body):
	if body.has_method("heal"):
		if body.heal(heal_amount):
			queue_free()

func _process(delta):
	time += delta
	
	# Smooth pulse (not jittery like Time.get_ticks)
	var pulse = 1.0 + sin(time * 3.0) * 0.1
	scale = base_scale * pulse
