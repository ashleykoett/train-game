extends Node2D

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		SceneSwitcher.switch_scene("res://scenes/control_cabin/control_cabin.tscn", false)
