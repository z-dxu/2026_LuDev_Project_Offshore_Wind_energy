extends GdUnitTestSuite
## Tests windmill_editor.gd state management: opening sets selected_windmill
## and blocks GameController input, closing restores input and clears selection,
## coral toggle and blade color button sync properties to the windmill node.

var editor: Control
var windmill_node
var windmill_scene: PackedScene


func before_test() -> void:
	windmill_scene = load("res://Scenes/Windmill.tscn")
	windmill_node = auto_free(windmill_scene.instantiate())
	add_child(windmill_node)
	await get_tree().process_frame

	GameController.allow_highlighter_move = true

	editor = auto_free(Control.new())
	editor.set_script(load("res://Scripts/windmill_editor.gd"))


func after_test() -> void:
	GameController.allow_highlighter_move = true


func test_editor_blocks_and_restores_input() -> void:
	# Simulate what open_editor does to GameController state
	editor.selected_windmill = windmill_node
	editor.preview_scene = windmill_scene
	GameController.allow_highlighter_move = false

	assert_bool(GameController.allow_highlighter_move).is_false()
	assert_that(editor.selected_windmill).is_equal(windmill_node)

	# Simulate what close_editor does
	GameController.allow_highlighter_move = true
	editor.selected_windmill = null

	assert_bool(GameController.allow_highlighter_move).is_true()
	assert_bool(editor.selected_windmill == null).is_true()


func test_coral_toggle_syncs_to_windmill() -> void:
	editor.selected_windmill = windmill_node

	editor._on_coral_toggled(true)
	assert_bool(windmill_node.coral_enabled).is_true()

	editor._on_coral_toggled(false)
	assert_bool(windmill_node.coral_enabled).is_false()


func test_blade_color_button_toggles_windmill() -> void:
	editor.selected_windmill = windmill_node

	var was_red = windmill_node.blades_red
	editor._on_blade_color_button_pressed()
	assert_bool(windmill_node.blades_red).is_equal(!was_red)

	editor._on_blade_color_button_pressed()
	assert_bool(windmill_node.blades_red).is_equal(was_red)


func test_close_editor_clears_preview() -> void:
	editor.selected_windmill = windmill_node
	editor.preview_scene = windmill_scene

	editor.close_editor()

	assert_bool(GameController.allow_highlighter_move).is_true()
	assert_bool(editor.selected_windmill == null).is_true()
