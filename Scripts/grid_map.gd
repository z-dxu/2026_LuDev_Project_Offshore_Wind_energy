extends GridMap

@export var windmill_scene: PackedScene
@export var harbor_scene: PackedScene
@export var cargo_ship: PackedScene
#@export var sdg_offset:Vector3 = Vector3(0,21,0)
@export var building_range = 5
@export var sdg_range: int = 5
var sdg_data = GameController.sdg_data
# Vector3i -> {
#	"sdg_name" -> {"score": 0}
#}
var harbors_list = []
var food_pos = GameController.food_pos
var placed_windmills := {}
var left_side_bar_node = null
var ship = null
@onready var harbor_pathing: Node = $Harbor/Harbor_pathing

@onready var highlight: Node3D = $Highlight

@onready var sdg_2_food: Sprite3D = $SDG2_food
@onready var sdg_images: Node3D = $SDG_images
@onready var number_mesh: MeshInstance3D = $Number_mesh
@onready var sdg_text_meshes: Node3D = $SdgTextMeshes

@onready var poi: Node3D = $Points_of_interests
@onready var windmil_logic: Node3D = $Windmil_logic

@onready var windmill_editor := $"../GUI/WindmillEditor"


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	GameController.spawn_building.connect(_spawn_building)
	#_spawn_sdg_goals()
	poi._spawn_poi_buttons()
	var h1 = BuildingData.new()
	h1.building_name = "harbor"
	h1.build_position = Vector3i(25, 1, -22)
	_spawn_building(h1)
	var h2 = BuildingData.new()
	h2.building_name = "harbor"
	h2.build_position = Vector3i(39, 1, -44)
	_spawn_building(h2)
	var h3 = BuildingData.new()
	h3.building_name = "harbor"
	h3.build_position = Vector3i(2, 1, -51)
	_spawn_building(h3)
	var ship2 = BuildingData.new()
	ship2.building_name = "ship"
	ship2.build_position = h1.build_position
	_spawn_building(ship2)
	#if harbor_pathing.get_script() != null:
	harbor_pathing.set_ship(ship)
	#harbor_pathing.go_to(h1.build_position)
	#harbor_pathing.append_path(h3.build_position)
	for i in range(harbors_list.size() - 1):
		harbor_pathing.append_path(
			harbors_list[i].build_position, harbors_list[i + 1].build_position
		)
		if i + 1 == harbors_list.size() - 1:  # loop back
			harbor_pathing.append_path(
				harbors_list[i + 1].build_position, harbors_list[0].build_position
			)


func _normalize_cell(cell: Vector3i) -> Vector3i:
	return Vector3i(cell.x, 0, cell.z)


func _spawn_building(data: BuildingData):
	var building_name = data.building_name
	var cel_pos
	if data.build_position == Vector3i(-999, -999, -999):
		# no build position assigned thus fallback to highlight position
		var highlight_pos = self.to_local(highlight.global_position)
		cel_pos = local_to_map(highlight_pos)
	else:
		cel_pos = data.build_position
	var build_pos = map_to_local(cel_pos) + Vector3(-4, 0, 0)

	print("building... ", building_name, " Building on cell: ", cel_pos)

	match building_name:
		"windmill":
			windmil_logic.spawn_windmill(windmill_scene, build_pos)
			windmil_logic._apply_effect(cel_pos)  #give score to tile
			if left_side_bar_node != null:
				left_side_bar_node._update_sdg_scores()
			#show the score
			#_show_scores_effect(cel_pos)
		"harbor":
			harbors_list.append(data)
			var building = harbor_scene.instantiate()
			self.add_child(building)
			var harbor_pos = cel_pos  # grid cel number
			building.position = build_pos + Vector3(2, -1, 0)
			GameController.harbor_pos.append(Vector3i(cel_pos))
		"ship":
			var building = cargo_ship.instantiate()
			self.add_child(building)
			ship = building
			var ship_offset = Vector3(4, 0, -2)  # fit in the tile square
			var harbor_pos = cel_pos
			build_pos = map_to_local(harbor_pos)
			building.position = build_pos
			GameController.harbor_pos.append(Vector3i(cel_pos))


func get_windmill_at_cell(cell: Vector3i) -> Node3D:
	var normalized_cell = _normalize_cell(cell)

	if placed_windmills.has(normalized_cell):
		print("Windmill found at cell: ", normalized_cell)
		return placed_windmills[normalized_cell]

	print("No windmill at cell: ", normalized_cell)
	return null


func open_windmill_editor_for(windmill: Node3D) -> void:
	print("Opening windmill editor for: ", windmill.name)
	if windmill_editor:
		windmill_editor.open_editor(windmill, windmill_scene)
	else:
		print("Windmill editor node not found")


#
#func _spawn_sdg_goals():
#for cel_pos in food_pos:
#_add_sdg_to_tile(cel_pos, "food")
#
#if not sdg_2_food:
#continue
#
#var food: Sprite3D = sdg_2_food.duplicate()
#var img_pos = map_to_local(cel_pos)
#food.position = img_pos
#food.visible = false
#sdg_images.add_child(food)
#
#
func _get_cell_in_range(center: Vector3i):
	var result = []
	for x in range(center.x - sdg_range, center.x + sdg_range + 1):
		for z in range(center.z - sdg_range, center.z + sdg_range + 1):
			var pos = Vector3i(x, center.y, z)
			result.append(pos)
	return result

#
#
#func _get_total_score_type(cel_pos: Vector3i, type: String):
#var total_score = 0
#for pos in _get_cell_in_range(cel_pos):
#if not sdg_data.has(pos):
#continue
#total_score += sdg_data[pos][type]["score"]
#
#GameController.poi_total_score = total_score
#
#
##after placing windmill down, show the scores nearby
#func _show_scores_effect(cel_pos):
#for pos in _get_cell_in_range(cel_pos):
#if not sdg_data.has(pos):
#continue
#var mesh_name = "food " + str(pos)
#var mesh_exist = sdg_text_meshes.find_child(mesh_name, false, false)
#if mesh_exist:
#(mesh_exist.mesh as TextMesh).text = str(sdg_data[pos]["food"]["score"])
#continue
##avoid number change for all meshes
#var mesh_dupe: TextMesh = number_mesh.mesh.duplicate()
#var new_mesh_inst = MeshInstance3D.new()
#new_mesh_inst.mesh = mesh_dupe
#var mesh_pos = map_to_local(pos)
#new_mesh_inst.position = mesh_pos
#new_mesh_inst.rotation_degrees = Vector3(-90, 0, 0)
#new_mesh_inst.name = mesh_name
#mesh_dupe.text = str(sdg_data[pos]["food"]["score"])
#sdg_text_meshes.add_child(new_mesh_inst)
#new_mesh_inst.visible = true
#
#
#func _add_sdg_to_tile(pos: Vector3i, type: String):
#if not sdg_data.has(pos):
#sdg_data[pos] = {}
#
#if not sdg_data[pos].has(type):
#sdg_data[pos][type] = {"score": 0}
##
