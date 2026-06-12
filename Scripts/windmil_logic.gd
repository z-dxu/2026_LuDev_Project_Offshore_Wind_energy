extends Node3D

var sdg_effects = {"food": func(_score): return -2}
var gridmap: GridMap


func _ready() -> void:
	gridmap = get_parent()


func spawn_windmill(windmill_scene: PackedScene, build_pos):
	var building = windmill_scene.instantiate()
	self.add_child(building)
	GameController.all_windmills.append(building)
	building.find_child("WorldEnvironment").queue_free()
	building.position = build_pos
	return building


func clear_windmills() -> void:
	for child in get_children():
		child.queue_free()

## apply windmill negative effects to surroundings
#func _apply_effect(current_cel_pos: Vector3i):
#for pos in gridmap._get_cell_in_range(current_cel_pos):
#if not sdg_data.has(pos):
#continue
#for type in sdg_data[pos].keys():
#var effect_score = sdg_effects[type].call(0)  # argument for future, if special formula score
#sdg_data[pos][type]["score"] += effect_score
