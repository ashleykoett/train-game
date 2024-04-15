extends Area2D

@export var highlight_texture : Texture2D
@export var scene_to_open = ""

@onready var sprite : Sprite2D = $SpriteComp

var normal_texture : Texture2D
var selected = false

# Called when the node enters the scene tree for the first time.
func _ready():
	normal_texture = sprite.texture

func _process(delta):
	if Input.is_action_just_pressed("primary") && selected:
		unselect()
		# switch scene
		SceneSwitcher.switch_scene(scene_to_open, false)

func select():
	selected = true
	sprite.texture = highlight_texture

func unselect():
	selected = false
	sprite.texture = normal_texture

func _on_mouse_entered():
	select()


func _on_mouse_exited():
	unselect()
