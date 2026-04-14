extends Area2D

@onready var polygon = $Polygon2D

func _ready():
	monitoring = true
	body_entered.connect(_on_body_entered)
	
	polygon.polygon = _make_circle(16, 32)
	polygon.color = Color(0.4, 0.75, 1.0, 0.9)

	
	var tween = create_tween().set_loops()
	tween.tween_property(polygon, "rotation", TAU, 2.0)
	
func _make_circle(radius: float, points: int) -> PackedVector2Array:
	var verts = PackedVector2Array()
	for i in points:
		var angle = (TAU / points) * i
		verts.append(Vector2(cos(angle), sin(angle)) * radius)
	return verts

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Next level!")
		get_tree().call_group_flags(SceneTree.GROUP_CALL_DEFERRED, "dungeon", "next_level")
