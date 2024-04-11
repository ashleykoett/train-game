extends PathFollow2D

class_name TrainFollow

var train_ref = preload("res://scenes/map/train_path/follow/train.tscn")
var engine_spritesheet_ref = preload("res://resources/sprites/train_anim-Sheet.png")
var car_spritesheet_ref = preload("res://resources/sprites/train_car_anim-sheet.png")

var speed = 50
var is_engine = false
var _start_motion = false

func _ready():
	var train : Train = train_ref.instantiate()
	call_deferred("add_child", train)
	var sprite : Sprite2D = train.get_node("Sprite2D")
	if is_engine:
		sprite.set_texture(engine_spritesheet_ref)
	else:
		sprite.set_texture(car_spritesheet_ref)
	
	loop = false
	if is_engine:
		# spawn an engine
		pass
	else:
		# spawn a train car
		pass

func _process(delta):
	if !_start_motion: return
	progress += delta * speed
	

func start_motion():
	_start_motion = true
