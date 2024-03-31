extends TileMap

signal track_updated(track_positions_arr)

# @onready var tile_map : TileMap = $"."

var train_path_scene_ref = preload("res://scenes/train_path_curve.tscn")

var train_path : Node2D

var placement_layer := 1
var source_id := 0
var prev_placed_pos : Vector2i
var current_dir : Vector2i
var prev_dir : Vector2i
var first_track_placed : bool = false
var track_positions_arr : Array
var world_positions_arr : Array

var _placement_mode = true

# atlas coords of track pieces
var track_dict = {
	"NS": Vector2i(7,0),
	"EW": Vector2i(12,0),
	"NW": Vector2i(8,0),
	"NE": Vector2i(10,0),
	"SW": Vector2i(11,0),
	"SE": Vector2i(9,0),
}

func _input(_event): 
	# TODO: make sure the path if valid first
	if Input.is_action_just_pressed("ui_accept") && _placement_mode:
		spawn_train_and_path()
		return
	
	if Input.is_action_just_pressed("ui_cancel") && !_placement_mode:
		reset_train()
		return
	
	if !_placement_mode:
		return
	
	var mouse_pos = get_global_mouse_position()
	var current_pos = local_to_map(mouse_pos)
	
	if Input.is_action_pressed("primary"):
		if !first_track_placed:
			# TODO: check for valid position
			first_track_placed = true
			prev_dir = Vector2i(1,0)
			current_dir = Vector2i(1,0)
			place_track(current_pos)
			# push to tiles array
		else: if _get_placement_mode(current_pos):
			current_dir = current_pos - prev_placed_pos
			replace_prev_track(current_pos)
			place_track(current_pos)
	else: if Input.is_action_just_pressed("ui_undo"):
		undo_last_track()

func place_track(pos: Vector2i):
	var lookup_name
	if current_dir.x != 0:
		lookup_name = "EW"
	
	if current_dir.y != 0:
		lookup_name = "NS"
	
	set_cell(placement_layer, pos, source_id, track_dict.get(lookup_name))
	
	track_positions_arr.push_back(pos)
	prev_placed_pos = pos
	prev_dir = current_dir
	track_updated.emit(track_positions_arr)

func undo_last_track():
	# only undo placement if we have any placed tracks
	if track_positions_arr.size() > 0:
		var pos = track_positions_arr.pop_back()
		erase_cell(placement_layer, pos)
		
		var index = track_positions_arr.size() - 1
		# we deleted the last track
		if index < 0:
			first_track_placed = false
			track_updated.emit(track_positions_arr)
			return
		
		prev_placed_pos = track_positions_arr[index]
		# if we've only placed one track, we know the direction was 1,0
		if index == 0:
			prev_dir = Vector2i(1,0)
		# otherwise calculate the previous dir
		else:
			prev_dir = prev_placed_pos - track_positions_arr[index-1]
		track_updated.emit(track_positions_arr)

func replace_prev_track(current_pos):
	var track_name = _get_track()
	set_cell(placement_layer, prev_placed_pos, source_id, track_dict.get(track_name))
	
func spawn_train_and_path():
	world_positions_arr = convert_positions_to_world(track_positions_arr)
	_placement_mode = false
	
	train_path = train_path_scene_ref.instantiate()
	train_path.points = world_positions_arr
	call_deferred("add_child",train_path)

func reset_train():
	train_path.queue_free()
	world_positions_arr.clear()
	_placement_mode = true
	

func convert_positions_to_world(tile_positions:Array):
	var world_positions : Array = []
	for position:Vector2i in tile_positions:
		world_positions.push_back(map_to_local(position))
	
	return world_positions

func _get_placement_mode(current_pos:Vector2i):
	var diff = current_pos - prev_placed_pos
	
	var cells = get_used_cells(placement_layer)
	if(cells.has(current_pos)):
		return false
	
	if diff.length() > 1 || diff.length() == 0:
		return false
		
	return true

func _get_track():
	if prev_dir.y > 0:
		if current_dir.x > 0:
			return "NE"
		if current_dir.x < 0:
			return "NW"
		if current_dir.x == 0:
			return "NS"
	if prev_dir.y < 0:
		if current_dir.x > 0:
			return "SE"
		if current_dir.x < 0:
			return "SW"
		if current_dir.x == 0:
			return "NS"
	
	if prev_dir.x > 0: 
		if current_dir.y > 0:
			return "SW"
		if current_dir.y < 0:
			return "NW"
		if current_dir.y == 0:
			return "EW"
	if prev_dir.x < 0:
		if current_dir.y > 0:
			return "SE"
		if current_dir.y < 0:
			return "NE"
		if current_dir.y == 0:
			return "EW"
