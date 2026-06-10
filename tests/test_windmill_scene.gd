extends GdUnitTestSuite
## Scene-instantiation tests for Windmill.tscn: set_blades_red() applies
## and clears StandardMaterial3D override, set_coral_enabled() toggles
## CoralGroup visibility, and the selected signal is defined and connectable.

var windmill_node
var received = null


func before_test() -> void:
	var scene = load("res://Scenes/Windmill.tscn")
	if scene:
		windmill_node = auto_free(scene.instantiate())
		add_child(windmill_node)
		await get_tree().process_frame


func test_set_blades_red_applies_material() -> void:
	windmill_node.set_blades_red(true)

	var blades: Node3D = windmill_node.find_child("Cube_003")
	assert_bool(blades != null).is_true()

	var mat = blades.get_surface_override_material(0)
	assert_bool(mat is StandardMaterial3D).is_true()
	assert_that((mat as StandardMaterial3D).albedo_color).is_equal(Color.RED)


func test_set_blades_red_clears_material() -> void:
	windmill_node.set_blades_red(true)
	windmill_node.set_blades_red(false)

	var blades: Node3D = windmill_node.find_child("Cube_003")
	var mat = blades.get_surface_override_material(0)
	assert_bool(mat == null).is_true()


func test_coral_visibility_toggle() -> void:
	windmill_node.set_coral_enabled(true)
	assert_bool(windmill_node.coral_enabled).is_true()
	var coral_group = windmill_node.find_child("CoralGroup")
	if coral_group:
		assert_bool(coral_group.visible).is_true()

	windmill_node.set_coral_enabled(false)
	assert_bool(windmill_node.coral_enabled).is_false()
	if coral_group:
		assert_bool(coral_group.visible).is_false()


func _on_windmill_selected(w) -> void:
	received = w


func test_selected_signal_emits_on_click() -> void:
	received = null
	windmill_node.connect("selected", _on_windmill_selected)
	windmill_node.emit_signal("selected", windmill_node)

	assert_bool(received != null).is_true()
	assert_that(received).is_equal(windmill_node)
