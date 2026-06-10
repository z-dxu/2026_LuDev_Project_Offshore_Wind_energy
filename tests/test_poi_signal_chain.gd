extends GdUnitTestSuite
## Tests GameController POI signal infrastructure: poi_button_pressed emits
## with correct hover/cell data, poi_positions are valid Vector3i at y=0,
## and food_pos matches the four expected hardcoded cells.

var _poi_hover := false
var _poi_cell := Vector3i.ZERO


func before_test() -> void:
	GameController.allow_highlighter_move = true
	GameController.dialogue_history.clear()
	GameController.sdg_data.clear()


func _on_poi_pressed(hover: bool, cell: Vector3i) -> void:
	_poi_hover = hover
	_poi_cell = cell


func test_poi_button_pressed_signal_fires_with_correct_data() -> void:
	_poi_hover = false
	_poi_cell = Vector3i.ZERO
	GameController.poi_button_pressed.connect(_on_poi_pressed)

	var test_cell = Vector3i(23, 0, -16)
	GameController.poi_button_pressed.emit(true, test_cell)

	assert_bool(_poi_hover).is_true()
	assert_that(_poi_cell).is_equal(test_cell)

	GameController.poi_button_pressed.emit(false, Vector3i.ZERO)
	assert_bool(_poi_hover).is_false()


func test_poi_positions_are_valid() -> void:
	var positions = GameController.poi_positions
	assert_int(positions.size()).is_greater(0)

	for pos in positions:
		assert_bool(pos is Vector3i).is_true()
		assert_int(pos.y).is_equal(0)


func test_food_positions_match_expected() -> void:
	var food = GameController.food_pos
	assert_int(food.size()).is_equal(4)

	assert_that(food[0]).is_equal(Vector3i(23, 1, -21))
	assert_that(food[1]).is_equal(Vector3i(23, 1, -20))
	assert_that(food[2]).is_equal(Vector3i(22, 1, -20))
	assert_that(food[3]).is_equal(Vector3i(23, 1, -19))
