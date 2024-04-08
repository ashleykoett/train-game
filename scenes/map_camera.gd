extends Camera2D

const MIN_ZOOM : float = 0.5
const MAX_ZOOM : float = 2.0
const ZOOM_INCREMENT : float = 0.1
const ZOOM_RATE : float = 9.0
const MOVEMENT_RATE : float = 3.0

const MAX_MOUSE_DELTA_X : float = 100.0
const MAX_MOUSE_DELTA_Y : float = 100.0

var target_zoom : float = 1.0
var mouse_pos : Vector2

func _physics_process(delta):
	# lerp zoom to target zoom
	zoom = lerp(zoom, target_zoom * Vector2.ONE, ZOOM_RATE * delta)
	# only do physics process if we haven't yet reached the target zoom
	set_physics_process(not is_equal_approx(zoom.x, target_zoom))

func _process(delta):
	var mouse_delta = get_local_mouse_position() - mouse_pos
	
	if(not is_equal_approx(mouse_delta.x, 0) && not is_equal_approx(mouse_delta.y, 0)):
		position += mouse_delta * delta * MOVEMENT_RATE

func _unhandled_input(event : InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_out()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_in()

func zoom_in() -> void:
	target_zoom = max(target_zoom - ZOOM_INCREMENT, MIN_ZOOM)
	set_physics_process(true)

func zoom_out() -> void:
	target_zoom = min(target_zoom + ZOOM_INCREMENT, MAX_ZOOM)
	set_physics_process(true)
