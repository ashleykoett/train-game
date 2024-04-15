extends Node

var current_scene = null
var hidden_loaded_scenes : Array # OF NODES

func _ready() -> void:
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func switch_scene(resource_path:String, unload_previous_scene: bool):
	call_deferred("_deferred_switch_scene", resource_path, unload_previous_scene)

func _deferred_switch_scene(resource_path:String, unload_previous_scene:bool):
	if unload_previous_scene:
		# delete the current scene from memory
		current_scene.free()
	else:
		# store the scene for later and remove it from the tree for now
		hidden_loaded_scenes.push_back(current_scene)
		get_tree().root.remove_child(current_scene)
	
	# check if the scene we want to load is already loaded
	var index = -1
	for i in range(hidden_loaded_scenes.size()):
		if hidden_loaded_scenes[i].scene_file_path == resource_path:
			index = i
			break
	
	if index != -1:
		# add back the scene
		current_scene = hidden_loaded_scenes[index]
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
		hidden_loaded_scenes.remove_at(index)
	# otherwise create a new instance of the scene
	else:
		var s = load(resource_path)
		current_scene = s.instantiate()
		get_tree().root.add_child(current_scene)
		get_tree().current_scene = current_scene
