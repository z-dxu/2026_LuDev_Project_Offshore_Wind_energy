extends GridMap

@export var windmill_scene: PackedScene
#@export var sdg_offset:Vector3 = Vector3(0,21,0)
@export var building_range = 5
@export var sdg_range = 5

var test_mode = false
var sdg_data = {}
# Vector3i -> {
#	"sdg_name" -> {"score": 0}
#}
var sdg_effects = {"food": func(_score): return -2}

@onready var highlight: Node3D = $Highlight
@onready var sdg_2_food: Sprite3D = $SDG2_food
@onready var sdg_images: Node3D = $SDG_images
@onready var number_mesh: MeshInstance3D = $Number_mesh
@onready var sdg_text_meshes: Node3D = $SdgTextMeshes


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if test_mode:
		return
	if Engine.is_editor_hint():
		return
	GameController.spawn_building.connect(_spawn_building)
	_spawn_sdg_goals()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _spawn_building(building_name: String):
	#current highlight position
	var highlight_pos = self.to_local(highlight.global_position)
	var cel_pos = local_to_map(highlight_pos)  # get the center of the cell position
	#get local pos for building. The building is a child of this node (no need for global)
	var build_pos = map_to_local(cel_pos) + Vector3(-4, 0, 0)
	print("building... " + str(building_name) + " Building on cell: " + str(cel_pos))
	match building_name:
		"windmill":
			var building = windmill_scene.instantiate()
			self.add_child(building)
			building.position = build_pos
			_apply_effect(cel_pos)  #give score to tile
			#show the score
			for pos in _get_cell_in_range(cel_pos):
				if not sdg_data.has(pos):
					continue
				var mesh_name = "food " + str(pos)
				var mesh_exist = sdg_text_meshes.find_child(mesh_name, false, false)
				print("mesh exist " + str(mesh_exist))
				if mesh_exist:
					print("the mesh exist")
					(mesh_exist.mesh as TextMesh).text = str(sdg_data[pos]["food"]["score"])
					continue
				#avoid number change for all meshes
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


func _spawn_sdg_goals():  # temp
	var food_pos = [
		Vector3i(23, 1, -21),
		Vector3i(23, 1, -20),
		Vector3i(22, 1, -20),
		Vector3i(23, 1, -19),
	]
	for cel_pos in food_pos:
		_add_sdg_to_tile(cel_pos, "food")
		if not sdg_2_food:
			continue
		var food: Sprite3D = sdg_2_food.duplicate()
		var img_pos = map_to_local(cel_pos)  #+ sdg_offset
		food.position = img_pos
		food.visible = true
		food.visible = true
		sdg_images.add_child(food)


func _get_cell_in_range(center: Vector3i):  # get nearby tiles. Square shape check
	var result = []
	for x in range(center.x - sdg_range, center.x + sdg_range + 1):
		for z in range(center.z - sdg_range, center.z + sdg_range + 1):
			var pos = Vector3i(x, center.y, z)
			result.append(pos)
	return result


func _apply_effect(current_cel_pos: Vector3i):
	for pos in _get_cell_in_range(current_cel_pos):
		if not sdg_data.has(pos):
			continue
		for type in sdg_data[pos].keys():
			var effect_score = sdg_effects[type].call(0)  # argument for future, if special formula score
			sdg_data[pos][type]["score"] += effect_score


func _add_sdg_to_tile(pos: Vector3i, type: String):
	if not sdg_data.has(pos):
		sdg_data[pos] = {}
	if not sdg_data[pos].has(type):
		sdg_data[pos][type] = {"score": 0}
