extends Node3D

var poi_positions = GameController.poi_positions
var gridmap: GridMap = null
var selected_poi_pos = null
var left_side_bar_node = null
var sdg_data = null

@onready var highlight: Node3D = $"../Highlight"
@onready var highlight_folder: Node3D = $Highlight_folder
@onready var poi_mesh: MeshInstance3D = $POI_buttons_folder/POIMesh
@onready var poi_buttons_folder: Node3D = $POI_buttons_folder


func _ready() -> void:
	GameController.poi_button_pressed.connect(_poi_highlight_range)
	GameController.get_poi_score.connect(_left_side_bar)
	sdg_data = GameController.sdg_data
	gridmap = self.get_parent()


# spawning point of interests buttons on the map
func _spawn_poi_buttons():
	if not poi_mesh:
		return
	var new_poi = poi_mesh.duplicate()
	for cel_pos in poi_positions:
		var img_pos = gridmap.map_to_local(cel_pos)
		new_poi.position = img_pos + Vector3(-1, 1, 0)
		new_poi.visible = true
		poi_buttons_folder.add_child(new_poi)


# debounce for point of interest button
func _poi_highlight_range(hover: bool, cel_pos):
	if hover:
		selected_poi_pos = cel_pos
		_increase_highlight_range(5)
	elif poi_buttons_folder.get_child_count() > 0:
		for child in highlight_folder.get_children():
			child.queue_free()


#The whole highlight for where the poi works
func _increase_highlight_range(range: int):
	var highlight_pos = to_local(highlight.global_position)
	var cel_pos: Vector3i = gridmap.local_to_map(highlight_pos)
	var mat: StandardMaterial3D = StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.CYAN

	for z in range(cel_pos.z - range, cel_pos.z + range + 1):
		var dupe_mesh: MeshInstance3D = highlight.find_child("TopMesh").duplicate()
		var cel = Vector3i(cel_pos.x - range, cel_pos.y, z)
		dupe_mesh.position = gridmap.map_to_local(cel) + Vector3(-4.8, 0, 0)
		highlight_folder.add_child(dupe_mesh)
		dupe_mesh.material_override = mat

		var dupe_mesh2: MeshInstance3D = highlight.find_child("BotMesh").duplicate()
		dupe_mesh2.material_override = mat
		var cel2 = Vector3i(cel_pos.x + range, cel_pos.y, z)
		dupe_mesh2.position = gridmap.map_to_local(cel2) + Vector3(4.3, 0, 0)
		highlight_folder.add_child(dupe_mesh2)

	for x in range(cel_pos.x - range, cel_pos.x + range + 1):
		var dupe_mesh: MeshInstance3D = highlight.find_child("RightMesh").duplicate()
		dupe_mesh.material_override = mat
		var cel = Vector3i(x, cel_pos.y, cel_pos.z + range)
		dupe_mesh.position = gridmap.map_to_local(cel) + Vector3(0, 0, 5.2)
		highlight_folder.add_child(dupe_mesh)

		var dupe_mesh2: MeshInstance3D = highlight.find_child("LeftMesh").duplicate()
		dupe_mesh2.material_override = mat
		var cel2 = Vector3i(x, cel_pos.y, cel_pos.z - range)
		dupe_mesh2.position = gridmap.map_to_local(cel2) + Vector3(0, 0, -5.2)
		highlight_folder.add_child(dupe_mesh2)


func _left_side_bar(sender):
	var send_data = {}
	left_side_bar_node = sender
	gridmap.left_side_bar_node = sender
