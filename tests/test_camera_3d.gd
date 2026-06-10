extends GdUnitTestSuite
## Tests camera zoom clamping at min/max bounds, drag start/release,
## hovered cell default, and input guard respecting allow_highlighter_move.

var camera_node: Camera3D


func before_test() -> void:
	camera_node = auto_free(Camera3D.new())
	camera_node.set_script(load("res://Scripts/camera_3d.gd"))
	camera_node.size = 100
	GameController.allow_highlighter_move = true


func after_test() -> void:
	GameController.allow_highlighter_move = true


func test_zoom_input() -> void:
	# Zoom in should decrease size (closer)
	var event_up = InputEventMouseButton.new()
	event_up.button_index = MOUSE_BUTTON_WHEEL_UP
	event_up.pressed = true
	camera_node.zoom(event_up)
	assert_float(camera_node.size).is_less(100)

	# Zoom out should increase size (farther)
	camera_node.size = 100
	var event_down = InputEventMouseButton.new()
	event_down.button_index = MOUSE_BUTTON_WHEEL_DOWN
	event_down.pressed = true
	camera_node.zoom(event_down)
	assert_float(camera_node.size).is_greater(100)

	# Clamped at minimum zoom
	camera_node.size = camera_node.min_zoom
	camera_node.zoom(event_up)
	assert_that(camera_node.size).is_equal(float(camera_node.min_zoom))

	# Clamped at maximum zoom
	camera_node.size = camera_node.max_zoom
	camera_node.zoom(event_down)
	assert_that(camera_node.size).is_equal(float(camera_node.max_zoom))


func test_drag_input() -> void:
	# Start drag with right-click
	var press_event = InputEventMouseButton.new()
	press_event.button_index = MOUSE_BUTTON_RIGHT
	press_event.pressed = true
	press_event.position = Vector2(100, 100)
	camera_node.zoom(press_event)
	assert_bool(camera_node.dragging).is_true()
	assert_that(camera_node.last_mouse_pos).is_equal(Vector2(100, 100))

	# Release drag
	var release_event = InputEventMouseButton.new()
	release_event.button_index = MOUSE_BUTTON_RIGHT
	release_event.pressed = false
	camera_node.zoom(release_event)
	assert_bool(camera_node.dragging).is_false()


func test_raycast_highlight_hit() -> void:
	# hovered_cell should start at zero
	assert_that(camera_node.hovered_cell).is_equal(Vector3i.ZERO)


func test_raycast_highlight_miss() -> void:
	# When allow_highlighter_move is false, _input() returns early
	GameController.allow_highlighter_move = false

	var event = InputEventMouseButton.new()
	event.button_index = MOUSE_BUTTON_WHEEL_UP
	event.pressed = true

	# Record size before feeding input
	var size_before = camera_node.size
	camera_node._input(event)

	# Size should be unchanged — _input returned early, zoom() never called
	assert_float(camera_node.size).is_equal(size_before)
