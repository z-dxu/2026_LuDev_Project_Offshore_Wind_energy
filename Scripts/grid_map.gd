extends GridMap

@export var windmill_scene: PackedScene
# @export var sdg_offset:Vector3 = Vector3(0,21,0)
@export var building_range = 5
@export var sdg_range = 5

var test_mode = false
var sdg_data = GameController.sdg_data
# Vector3i -> {
#	"sdg_name" -> {"score": 0}
# }

var sdg_effects = {"food": func(_score): return -2}
var food_pos = GameController.food_pos
var poi_positions = GameController.poi_positions
var selected_poi_pos = null
var left_side_bar_node = null
var placed_windmills := {}

@onready var highlight: Node3D = $Highlight
@onready var highlight_folder: Node3D = $Highlight_folder

@onready var sdg_2_food: Sprite3D = $SDG2_food
@onready var sdg_images: Node3D = $SDG_images
@onready var number_mesh: MeshInstance3D = $Number_mesh
@onready var sdg_text_meshes: Node3D = $SdgTextMeshes

# Point of interest
@onready var poi_mesh: MeshInstance3D = $POI_buttons_folder/POIMesh
@onready var poi_buttons_folder: Node3D = $POI_buttons_folder

# Windmill editor in GUI
@onready var windmill_editor := $"../GUI/WindmillEditor"


func _ready() -> void:
	if test_mode:
		return
	if Engine.is_editor_hint():
		return

	GameController.spawn_building.connect(_spawn_building)
	GameController.poi_button_pressed.connect(_poi_highlight_range)
	GameController.get_poi_score.connect(_left_side_bar)

	_spawn_sdg_goals()
	_spawn_poi_buttons()


func _poi_highlight_range(hover: bool, cel_pos):
	if hover:
		selected_poi_pos = cel_pos
		_increase_highlight_range(5)
	elif poi_buttons_folder.get_child_count() > 0:
		for child in highlight_folder.get_children():
			child.queue_free()


func _normalize_cell(cell: Vector3i) -> Vector3i:
	return Vector3i(cell.x, 0, cell.z)


func _spawn_building(building_name: String):
	# current highlight position
	var highlight_pos = to_local(highlight.global_position)
	var cel_pos = local_to_map(highlight_pos)

	# get local pos for building. The building is a child of this node
	var build_pos = map_to_local(cel_pos) + Vector3(-4, 0, 0)

	print("building... ", building_name, " Building on cell: ", cel_pos)

	match building_name:
		"windmill":
			var building = windmill_scene.instantiate()
			add_child(building)
			building.position = build_pos

			if building.has_node("WorldEnvironment"):
				building.get_node("WorldEnvironment").queue_free()

			var normalized_cell = _normalize_cell(cel_pos)
			placed_windmills[normalized_cell] = building
			print("Stored windmill at cell: ", normalized_cell, " -> ", building.name)

			_apply_effect(cel_pos)

			if left_side_bar_node != null:
				left_side_bar_node._update_sdg_scores()

			# show the score
			for pos in _get_cell_in_range(cel_pos):
				if not sdg_data.has(pos):
					continue

				var mesh_name = "food " + str(pos)
				var mesh_exist = sdg_text_meshes.find_child(mesh_name, false, false)

				if mesh_exist:
					(mesh_exist.mesh as TextMesh).text = str(sdg_data[pos]["food"]["score"])
					continue

				# avoid number change for all meshes
				var mesh_dupe: TextMesh = number_mesh.mesh.duplicate()
				var new_mesh_inst = MeshInstance3D.new()
				new_mesh_inst.mesh = mesh_dupe

				var mesh_pos = map_to_local(pos)
				new_mesh_inst.position = mesh_pos
				new_mesh_inst.rotation_degrees = Vector3(-90, 0, 0)
				new_mesh_inst.name = mesh_name
				mesh_dupe.text = str(sdg_data[pos]["food"]["score"])
				sdg_text_meshes.add_child(new_mesh_inst)
				new_mesh_inst.visible = true


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


func _spawn_sdg_goals():
	for cel_pos in food_pos:
		_add_sdg_to_tile(cel_pos, "food")

		if not sdg_2_food:
			continue

		var food: Sprite3D = sdg_2_food.duplicate()
		var img_pos = map_to_local(cel_pos)
		food.position = img_pos
		food.visible = false
		sdg_images.add_child(food)


func _spawn_poi_buttons():
	if not poi_mesh:
		return

	var new_poi = poi_mesh.duplicate()
	for cel_pos in poi_positions:
		var img_pos = map_to_local(cel_pos)
		new_poi.position = img_pos + Vector3(-1, 1, 0)
		new_poi.visible = true
		poi_buttons_folder.add_child(new_poi)


func _get_cell_in_range(center: Vector3i):
	var result = []
	for x in range(center.x - sdg_range, center.x + sdg_range + 1):
		for z in range(center.z - sdg_range, center.z + sdg_range + 1):
			var pos = Vector3i(x, center.y, z)
			result.append(pos)
	return result


func _left_side_bar(sender):
	var send_data = {}
	left_side_bar_node = sender

	if selected_poi_pos == null:
		selected_poi_pos = Vector3i.ZERO

	for pos in _get_cell_in_range(selected_poi_pos + Vector3i(0, 1, 0)):
		if not sdg_data.has(pos):
			continue

		for type in sdg_data[pos].keys():
			if not send_data.has(type):
				send_data[type] = 0
			send_data[type] += sdg_data[pos][type]["score"]

	sender._get_all_scores(send_data)


func _get_total_score_type(cel_pos: Vector3i, type: String):
	var total_score = 0
	for pos in _get_cell_in_range(cel_pos):
		if not sdg_data.has(pos):
			continue
		total_score += sdg_data[pos][type]["score"]

	GameController.poi_total_score = total_score


func _apply_effect(current_cel_pos: Vector3i):
	for pos in _get_cell_in_range(current_cel_pos):
		if not sdg_data.has(pos):
			continue

		for type in sdg_data[pos].keys():
			var effect_score = sdg_effects[type].call(0)
			sdg_data[pos][type]["score"] += effect_score


func _add_sdg_to_tile(pos: Vector3i, type: String):
	if not sdg_data.has(pos):
		sdg_data[pos] = {}

	if not sdg_data[pos].has(type):
		sdg_data[pos][type] = {"score": 0}


func _increase_highlight_range(range: int):
	var highlight_pos = to_local(highlight.global_position)
	var cel_pos: Vector3i = local_to_map(highlight_pos)

	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.CYAN

	for z in range(cel_pos.z - range, cel_pos.z + range + 1):
		var dupe_mesh: MeshInstance3D = highlight.find_child("TopMesh").duplicate()
		var cel = Vector3i(cel_pos.x - range, cel_pos.y, z)
		dupe_mesh.position = map_to_local(cel) + Vector3(-4.8, 0, 0)
		highlight_folder.add_child(dupe_mesh)
		dupe_mesh.material_override = mat

		var dupe_mesh2: MeshInstance3D = highlight.find_child("BotMesh").duplicate()
		dupe_mesh2.material_override = mat
		var cel2 = Vector3i(cel_pos.x + range, cel_pos.y, z)
		dupe_mesh2.position = map_to_local(cel2) + Vector3(4.3, 0, 0)
		highlight_folder.add_child(dupe_mesh2)

	for x in range(cel_pos.x - range, cel_pos.x + range + 1):
		var dupe_mesh: MeshInstance3D = highlight.find_child("RightMesh").duplicate()
		dupe_mesh.material_override = mat
		var cel = Vector3i(x, cel_pos.y, cel_pos.z + range)
		dupe_mesh.position = map_to_local(cel) + Vector3(0, 0, 5.2)
		highlight_folder.add_child(dupe_mesh)

		var dupe_mesh2: MeshInstance3D = highlight.find_child("LeftMesh").duplicate()
		dupe_mesh2.material_override = mat
		var cel2 = Vector3i(x, cel_pos.y, cel_pos.z - range)
		dupe_mesh2.position = map_to_local(cel2) + Vector3(0, 0, -5.2)
		highlight_folder.add_child(dupe_mesh2)
