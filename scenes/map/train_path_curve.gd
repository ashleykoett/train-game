extends Path2D

class_name TrainPath

@onready var path_follow : PathFollow2D = $train_path_follow

var points : Array

func _ready():
	curve.clear_points()
	
	for point: Vector2i in points: 
		curve.add_point(point)
	
	path_follow.start_motion()
