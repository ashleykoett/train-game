extends Node2D

signal track_updated(track_positions_arr)

@onready var tile_map : TileMap = $Base_TileMap

var placement_layer := 1
var source_id := 0
var prev_placed_pos : Vector2i
var current_dir : Vector2i
var prev_dir : Vector2i
var first_track_placed : bool = false
var track_positions_arr : Array

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
	var mouse_pos = get_global_mouse_position()
	var current_pos = tile_map.local_to_map(mouse_pos)
	
	if Input.is_action_pressed("primary"):
		if !first_track_placed:
			# TODO: check for valid position
			first_track_placed = true
			prev_dir = Vector2i(1,0)
			current_dir = Vector2i(1,0)
			place_track(current_pos)
			# push to tiles array
		else: if _get_can_place(current_pos):
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
	
	tile_map.set_cell(placement_layer, pos, source_id, track_dict.get(lookup_name))
	
	track_positions_arr.push_back(pos)
	prev_placed_pos = pos
	prev_dir = current_dir
	track_updated.emit(track_positions_arr)

func undo_last_track():
	# only undo placement if we have any placed tracks
	if track_positions_arr.size() > 0:
		var pos = track_positions_arr.pop_back()
		tile_map.erase_cell(placement_layer, pos)
		
		var index = track_positions_arr.size() - 1
		# we deleted the last track
		if index < 0:
			first_track_placed = false
			track_updated.emit(track_positions_arr)
		
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
	tile_map.set_cell(placement_layer, prev_placed_pos, source_id, track_dict.get(track_name))

func _get_can_place(current_pos:Vector2i):
	var diff = current_pos - prev_placed_pos
	
	var cells = tile_map.get_used_cells(placement_layer)
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
