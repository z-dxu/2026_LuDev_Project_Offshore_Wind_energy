extends GdUnitTestSuite

var grid


func before_test() -> void:
	grid = preload("res://Scripts/grid_map.gd").new()
	add_child(grid)
	grid.test_mode = true
	print("before test")


func test_apply_effect_updates_only_in_range():
	grid.sdg_data = {}
	var food_pos = [
		Vector3i(23, 1, -21),
		Vector3i(23, 1, -20),
		Vector3i(22, 1, -20),
		Vector3i(23, 1, -19),
	]
	for pos in food_pos:
		grid._add_sdg_to_tile(pos, "food")

	grid._apply_effect(Vector3i(27, 1, -20))

	# all food sdg should be -2
	for pos in food_pos:
		assert_int(grid.sdg_data[pos]["food"]["score"]).is_equal(-2)

	grid._apply_effect(Vector3i(28, 1, -20))  # add another building
	assert_int(grid.sdg_data[Vector3i(22, 1, -20)]["food"]["score"]).is_equal(-2)
	assert_int(grid.sdg_data[Vector3i(23, 1, -21)]["food"]["score"]).is_equal(-4)
	assert_int(grid.sdg_data[Vector3i(23, 1, -20)]["food"]["score"]).is_equal(-4)
	assert_int(grid.sdg_data[Vector3i(23, 1, -19)]["food"]["score"]).is_equal(-4)


func test_add_sdg_to_tile():
	grid.sdg_data = {}
	var pos = Vector3i(1, 0, 1)
	grid._add_sdg_to_tile(pos, "food")
	assert_bool(grid.sdg_data.has(pos)).is_true()

	assert_bool(grid.sdg_data.has(pos)).is_true()
	var tile = grid.sdg_data[pos]
	assert_bool(tile.has("food")).is_true()
	assert_int(grid.sdg_data[pos]["food"]["score"]).is_equal(0)


func after_test():
	if grid:
		if GameController.spawn_building.is_connected(grid._spawn_building):
			GameController.spawn_building.disconnect(grid._spawn_building)

		grid.queue_free()
		grid = null
