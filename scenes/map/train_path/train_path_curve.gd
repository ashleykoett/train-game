extends Path2D

class_name TrainPath

@onready var path_follow : PathFollow2D = $train_path_follow
var follow_ref = preload("res://scenes/map/train_path/follow/train_path_follow.tscn")

const total_train_cars : int = 6
var points : Array
var spawn_time : float = 0.5
var time : float = 0.0
var instances : Array = []

func _ready():
	curve.clear_points()
	
	for point: Vector2i in points: 
		curve.add_point(point)
	
	spawn_follow()

func _process(delta):
	time += delta
	if time >= spawn_time && instances.size() < total_train_cars:
		spawn_follow()
		time = 0

# Spawns a TrainFollow, which will follow the curve
func spawn_follow():
	var follow : TrainFollow = follow_ref.instantiate()
	call_deferred("add_child",follow)
	follow.start_motion()
	
	if instances.size() == 0:
		follow.is_engine = true;
	
	instances.push_back(follow)
