extends Camera2D

var zoom_levels = [
	Vector2(1, 1),
	Vector2(2, 2),
	Vector2(3, 3),
	Vector2(4, 4),
]

var current_zoom_index = 2

func _ready() -> void:
	zoom = zoom_levels[current_zoom_index]

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_out()

func zoom_in():
	if current_zoom_index < zoom_levels.size() - 1:
		current_zoom_index += 1
		zoom = zoom_levels[current_zoom_index]
		print("Zooming in")
		print(zoom_levels[current_zoom_index])
		print("Zoom index: ", current_zoom_index)

func zoom_out():
	if current_zoom_index > 0:
		current_zoom_index -= 1
		zoom = zoom_levels[current_zoom_index]
		print("Zooming out")
		print(zoom_levels[current_zoom_index])
		print("Zoom index: ", current_zoom_index)
