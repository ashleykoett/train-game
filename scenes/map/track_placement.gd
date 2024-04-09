extends TileMap

const placement_layer := 1
const highlight_layer := 2
const source_id := 0
const total_track_pieces = 30

@onready var track_count_label = $CanvasLayer/TrackCountLabel
var train_path_scene_ref = preload("res://scenes/map/train_path/train_path_curve.tscn")

var train_path : Node2D # hold the train node once it is spawned
var prev_highlight_pos : Vector2i = Vector2(0,0)
var prev_placed_pos : Vector2i = Vector2(0,0)
var current_dir : Vector2i = Vector2i(1,0)
var prev_dir : Vector2i = Vector2i(1,0)
var first_track_placed : bool = false
var highlight_placed = false
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

func _ready():
	update_label()

func _process(_delta):
	var mouse_pos = get_global_mouse_position()
	var current_pos = local_to_map(mouse_pos)
	
	# erase last highlight if we move to a new cell, or there is already a highlight placed
	if current_pos != prev_highlight_pos && highlight_placed:
		erase_highlight()
	
	# make sure we're in placement mode and not in the same position
	if  !_placement_mode || prev_highlight_pos == current_pos:
		return
	
	if !first_track_placed && !get_used_cells(placement_layer).has(current_pos):
		place_highlight(current_pos)
	else: if _get_can_place(current_pos):
		current_dir = current_pos - prev_placed_pos
		place_highlight(current_pos)
	
	prev_highlight_pos = current_pos
	highlight_placed = true

func _unhandled_input(_event): 
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
			place_track(current_pos)
			# push to tiles array
		else: if _get_can_place(current_pos):
			current_dir = current_pos - prev_placed_pos
			replace_prev_track()
			place_track(current_pos)
	else: if Input.is_action_pressed("seconday") && current_pos == prev_placed_pos:
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
	
	erase_highlight()
	update_label()

func place_highlight(pos: Vector2i):
	var lookup_name
	if current_dir.x != 0:
		lookup_name = "EW"
	
	if current_dir.y != 0:
		lookup_name = "NS"
	
	set_cell(highlight_layer, pos, source_id, track_dict.get(lookup_name))

	prev_highlight_pos = pos

func erase_highlight():
	erase_cell(highlight_layer, prev_highlight_pos)
	highlight_placed = false

func undo_last_track():
	# only undo placement if we have any placed tracks
	if track_positions_arr.size() > 0:
		var pos = track_positions_arr.pop_back()
		erase_cell(placement_layer, pos)
		
		var index = track_positions_arr.size() - 1
		# we deleted the last track
		if index < 0:
			first_track_placed = false
			return
		
		prev_placed_pos = track_positions_arr[index]
		# if we've only placed one track, we know the direction was 1,0
		if index == 0:
			prev_dir = Vector2i(1,0)
		# otherwise calculate the previous dir
		else:
			prev_dir = prev_placed_pos - track_positions_arr[index-1]
		
		update_label()

func replace_prev_track():
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

func update_label():
	track_count_label.text = "x" + str(total_track_pieces - track_positions_arr.size())

func convert_positions_to_world(tile_positions:Array):
	var world_positions : Array = []
	for pos:Vector2i in tile_positions:
		world_positions.push_back(map_to_local(pos))
	
	return world_positions

func _get_can_place(current_pos:Vector2i):
	if(total_track_pieces - track_positions_arr.size() == 0): return
	
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
