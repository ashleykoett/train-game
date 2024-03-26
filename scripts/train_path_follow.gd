extends PathFollow2D

var speed = 30
var _start_motion = false

func _ready():
	loop = false

func _process(delta):
	if !_start_motion: return
	progress += delta * speed
	

func start_motion():
	_start_motion = true
