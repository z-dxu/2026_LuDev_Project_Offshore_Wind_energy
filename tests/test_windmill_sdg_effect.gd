extends GdUnitTestSuite
## Integration test: windmil_logic._apply_effect() reduces food SDG score
## by 2 on the center cell, spreads to neighbor cells in range, and ignores
## cells not present in GameController.sdg_data.

var grid_map: GridMap
var windmil_logic: Node3D


func before_test() -> void:
	GameController.sdg_data.clear()

	# Create GridMap with script — never add to tree, _ready() won't fire
	grid_map = auto_free(GridMap.new())
	grid_map.set_script(load("res://Scripts/grid_map.gd"))
	# _get_cell_in_range uses sdg_range which is set on the script
	# It doesn't need scene tree access

	# Create windmil_logic — never add to tree
	windmil_logic = auto_free(Node3D.new())
	windmil_logic.set_script(load("res://Scripts/windmil_logic.gd"))
	# Manually set gridmap reference since _ready() won't fire
	windmil_logic.gridmap = grid_map
	windmil_logic.sdg_data = GameController.sdg_data

	# Populate test SDG data: 5x5 grid of food scores around center
	var center = Vector3i(10, 0, 10)
	for x in range(center.x - 2, center.x + 3):
		for z in range(center.z - 2, center.z + 3):
			GameController.sdg_data[Vector3i(x, 0, z)] = {"food": {"score": 10}}


func test_windmill_placement_reduces_food_score() -> void:
	var center = Vector3i(10, 0, 10)
	var score_before = GameController.sdg_data[center]["food"]["score"]

	windmil_logic._apply_effect(center)

	var score_after = GameController.sdg_data[center]["food"]["score"]
	assert_int(score_after).is_equal(score_before - 2)


func test_windmill_effect_spreads_to_neighbors() -> void:
	var center = Vector3i(10, 0, 10)
	var neighbor = Vector3i(8, 0, 8)
	var neighbor_before = GameController.sdg_data[neighbor]["food"]["score"]

	windmil_logic._apply_effect(center)

	var neighbor_after = GameController.sdg_data[neighbor]["food"]["score"]
	assert_int(neighbor_after).is_equal(neighbor_before - 2)


func test_windmill_effect_ignores_empty_cells() -> void:
	var empty_cell = Vector3i(50, 0, 50)
	assert_bool(GameController.sdg_data.has(empty_cell)).is_false()

	var center = Vector3i(10, 0, 10)
	windmil_logic._apply_effect(center)

	assert_bool(GameController.sdg_data.has(empty_cell)).is_false()
