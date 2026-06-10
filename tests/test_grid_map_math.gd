extends GdUnitTestSuite
## Unit tests for _normalize_cell() in grid_map.gd: drops Y component
## to zero for positive, zero, and negative inputs.

var grid_map: Node3D


func before_test() -> void:
	var node = GridMap.new()
	node.set_script(load("res://Scripts/grid_map.gd"))
	grid_map = auto_free(node)


func test_normalize_cell_drops_y() -> void:
	var result = grid_map._normalize_cell(Vector3i(5, 3, -10))
	assert_int(result.x).is_equal(5)
	assert_int(result.y).is_equal(0)
	assert_int(result.z).is_equal(-10)


func test_normalize_cell_zero() -> void:
	var result = grid_map._normalize_cell(Vector3i(0, 0, 0))
	assert_int(result.x).is_equal(0)
	assert_int(result.y).is_equal(0)
	assert_int(result.z).is_equal(0)


func test_normalize_cell_negative() -> void:
	var result = grid_map._normalize_cell(Vector3i(-7, 99, -42))
	assert_int(result.x).is_equal(-7)
	assert_int(result.y).is_equal(0)
	assert_int(result.z).is_equal(-42)
