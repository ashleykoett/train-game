@tool
extends Node2D

var _initial_pos : Vector2

func _process(delta) -> void:
	if Input.is_action_just_pressed("primary"):
		_initial_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_pressed("primary"):
		queue_redraw()

func _draw() -> void:
	var mousePos = get_viewport().get_mouse_position()
	draw_line(_initial_pos, mousePos, Color.BLUE)
