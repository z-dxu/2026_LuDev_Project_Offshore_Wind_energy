extends GridMap

const TILE_GRASS := 11
const TILE_WATER_BEACH_CONCAVE := 49
const TILE_WATER_BEACH_CONVEX := 50
const TILE_WATER_BEACH_STRAIGHT := 51
const TILE_WATER := 56
const TILE_ROAD_BRIDGE_COAST := 28
const TILE_ROAD_BRIDGE_GRASS := 29
const TILE_ROAD_BRIDGE_RAMP := 31
const TILE_ROAD_BRIDGE_WATER := 34

const ARCADIA_PORT_CELL := Vector3i(25, 1, -22)
const KALYMERA_PORT_CELL := Vector3i(37, 1, -36)

const KALYMERA_BRIDGE_HIDDEN_CELLS = [
	{"cell": Vector3i(31, 0, -14), "item": TILE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -15), "item": TILE_WATER_BEACH_CONCAVE, "orientation": 10},
	{"cell": Vector3i(31, 0, -16), "item": TILE_WATER_BEACH_CONVEX, "orientation": 10},
	{"cell": Vector3i(31, 0, -17), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -18), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -19), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -20), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -21), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -22), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -23), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -24), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -25), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -26), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -27), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -28), "item": TILE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -29), "item": TILE_WATER_BEACH_STRAIGHT, "orientation": 0},
	{"cell": Vector3i(31, 0, -30), "item": TILE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -31), "item": TILE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -32), "item": TILE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -33), "item": TILE_GRASS, "orientation": 0},
]

const KALYMERA_BRIDGE_BUILT_CELLS = [
	{"cell": Vector3i(31, 0, -14), "item": TILE_ROAD_BRIDGE_RAMP, "orientation": 10},
	{"cell": Vector3i(31, 0, -15), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -16), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -17), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -18), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -19), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -20), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -21), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -22), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -23), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -24), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -25), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -26), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -27), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -28), "item": TILE_ROAD_BRIDGE_WATER, "orientation": 0},
	{"cell": Vector3i(31, 0, -29), "item": TILE_ROAD_BRIDGE_COAST, "orientation": 0},
	{"cell": Vector3i(31, 0, -30), "item": TILE_ROAD_BRIDGE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -31), "item": TILE_ROAD_BRIDGE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -32), "item": TILE_ROAD_BRIDGE_GRASS, "orientation": 0},
	{"cell": Vector3i(31, 0, -33), "item": TILE_ROAD_BRIDGE_RAMP, "orientation": 0},
]

@export var windmill_scene: PackedScene
@export var harbor_scene: PackedScene
@export var cargo_ship: PackedScene
#@export var sdg_offset:Vector3 = Vector3(0,21,0)
@export var building_range = 5
@export var sdg_range: int = 5

# Vector3i -> {
#	"sdg_name" -> {"score": 0}
#}
var harbors_list = []
var placed_windmills := {}
var placed_harbors := {}
var kalymera_bridge_built := false
var port_relocated_to_kalymera := false
var left_side_bar_node = null
var ship = null
@onready var harbor_pathing: Node = $Harbor/Harbor_pathing

@onready var highlight: Node3D = $Highlight

@onready var windmil_logic: Node3D = $Windmil_logic

@onready var windmill_editor := $"../GUI/WindmillEditor"


func _ready() -> void:
	if Engine.is_editor_hint():
		return

	GameController.spawn_building.connect(_spawn_building)
	GameController.relocate_wind_park.connect(_relocate_wind_park)
	GameController.build_kalymera_bridge.connect(_build_kalymera_bridge)
	GameController.relocate_port_to_kalymera.connect(_relocate_port_to_kalymera)
	_hide_kalymera_bridge()
	#_spawn_sdg_goals()
	# arcadia's port
	var h1 = BuildingData.new()
	h1.building_name = "harbor"
	h1.build_position = ARCADIA_PORT_CELL
	_spawn_building(h1)

	#Melonia's port
	var h2 = BuildingData.new()
	h2.building_name = "harbor"
	h2.build_position = Vector3i(55, 1, -8)
	_spawn_building(h2)

	#BabyLonia
	var h3 = BuildingData.new()
	h3.building_name = "harbor"
	h3.build_position = Vector3i(33, 1, -62)
	_spawn_building(h3)

	var ship2 = BuildingData.new()
	ship2.building_name = "ship"
	ship2.build_position = h1.build_position
	_spawn_building(ship2)
	#if harbor_pathing.get_script() != null:
	harbor_pathing.set_ship(ship)
	#harbor_pathing.go_to(h1.build_position)
	#harbor_pathing.append_path(h3.build_position)
	_rebuild_harbor_routes()
	if GameController.story_flags.get("port_relocated_to_kalymera", false):
		_relocate_port_to_kalymera()


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

	match building_name:
		"windmill":
			var windmill = windmil_logic.spawn_windmill(windmill_scene, build_pos)
			placed_windmills[_normalize_cell(cel_pos)] = windmill
			if left_side_bar_node != null:
				left_side_bar_node._update_sdg_scores()
		"harbor":
			harbors_list.append(data)
			var building = harbor_scene.instantiate()
			self.add_child(building)
			var harbor_pos = cel_pos  # grid cel number
			building.position = _harbor_position_for_cell(harbor_pos)
			placed_harbors[_normalize_cell(cel_pos)] = building
			GameController.harbor_pos.append(Vector3i(cel_pos))
		"ship":
			var building = cargo_ship.instantiate()
			self.add_child(building)
			ship = building
			for child in building.find_children("*"):
				if child is GPUParticles3D:
					child.emitting = true  # doesnt work well with map movement
			var ship_offset = Vector3(4, 0, -2)  # fit in the tile square
			var harbor_pos = cel_pos
			build_pos = map_to_local(harbor_pos)
			building.position = build_pos
			GameController.harbor_pos.append(Vector3i(cel_pos))


func _to_cell(raw_position) -> Vector3i:
	return Vector3i(raw_position[0], raw_position[1], raw_position[2])


func _harbor_position_for_cell(cell: Vector3i) -> Vector3:
	return map_to_local(cell) + Vector3(0, -1, 0)


func _rebuild_harbor_routes() -> void:
	harbor_pathing.path.clear()
	harbor_pathing.harbor_pos_list.clear()
	for i in range(harbors_list.size() - 1):
		harbor_pathing.append_path(
			harbors_list[i].build_position, harbors_list[i + 1].build_position
		)
		if i + 1 == harbors_list.size() - 1:
			harbor_pathing.append_path(
				harbors_list[i + 1].build_position, harbors_list[0].build_position
			)


func _relocate_port_to_kalymera() -> void:
	if port_relocated_to_kalymera:
		return
	port_relocated_to_kalymera = true
	GameController.story_flags["port_relocated_to_kalymera"] = true

	var old_key := _normalize_cell(ARCADIA_PORT_CELL)
	var new_key := _normalize_cell(KALYMERA_PORT_CELL)
	if not placed_harbors.has(old_key):
		return

	var harbor = placed_harbors[old_key]
	harbor.position = _harbor_position_for_cell(KALYMERA_PORT_CELL)
	placed_harbors.erase(old_key)
	placed_harbors[new_key] = harbor

	for data in harbors_list:
		if data.build_position == ARCADIA_PORT_CELL:
			data.build_position = KALYMERA_PORT_CELL
			break
	for i in range(GameController.harbor_pos.size()):
		if GameController.harbor_pos[i] == ARCADIA_PORT_CELL:
			GameController.harbor_pos[i] = KALYMERA_PORT_CELL
			break
	_rebuild_harbor_routes()


func _apply_grid_cells(cells: Array) -> void:
	for entry in cells:
		set_cell_item(entry["cell"], entry["item"], entry["orientation"])


func _hide_kalymera_bridge() -> void:
	if GameController.story_flags.get("kalymera_bridge_built", false):
		_build_kalymera_bridge()
		return
	_apply_grid_cells(KALYMERA_BRIDGE_HIDDEN_CELLS)


func _build_kalymera_bridge() -> void:
	if kalymera_bridge_built:
		return
	kalymera_bridge_built = true
	GameController.story_flags["kalymera_bridge_built"] = true
	_apply_grid_cells(KALYMERA_BRIDGE_BUILT_CELLS)


func _relocate_wind_park(positions: Array) -> void:
	placed_windmills.clear()
	windmil_logic.clear_windmills()
	for raw_position in positions:
		var cell := _to_cell(raw_position)
		var build_pos = map_to_local(cell) + Vector3(-4, 0, 0)
		var windmill = windmil_logic.spawn_windmill(windmill_scene, build_pos)
		placed_windmills[_normalize_cell(cell)] = windmill
	if left_side_bar_node != null:
		left_side_bar_node._update_sdg_scores()


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


func _get_cell_in_range(center: Vector3i):
	var result = []
	for x in range(center.x - sdg_range, center.x + sdg_range + 1):
		for z in range(center.z - sdg_range, center.z + sdg_range + 1):
			var pos = Vector3i(x, center.y, z)
			result.append(pos)
	return result
