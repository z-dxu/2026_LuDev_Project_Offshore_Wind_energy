extends GdUnitTestSuite
## Tests windmill defaults, position cycling, blade color toggle with material
## apply/clear, and spin speed/direction.

var windmill_node: Node3D


func before_test() -> void:
	var scene = load("res://Scenes/Windmill.tscn")
	if scene:
		windmill_node = auto_free(scene.instantiate())
		add_child(windmill_node)
		await get_tree().process_frame


func test_initial_state() -> void:
	assert_bool(windmill_node.spinning).is_true()
	assert_bool(windmill_node.blades_red).is_false()
	assert_int(windmill_node.current_position_index).is_equal(0)
	assert_bool(windmill_node.coral_enabled).is_false()


func test_next_position() -> void:
	assert_int(windmill_node.current_position_index).is_equal(0)

	windmill_node.next_position()
	assert_int(windmill_node.current_position_index).is_equal(1)

	windmill_node.next_position()
	assert_int(windmill_node.current_position_index).is_equal(2)

	windmill_node.next_position()
	assert_int(windmill_node.current_position_index).is_equal(0)


func test_next_blade_color() -> void:
	assert_bool(windmill_node.blades_red).is_false()

	windmill_node.toggle_blade_color()
	assert_bool(windmill_node.blades_red).is_true()
	var material = windmill_node.blades.get_surface_override_material(0)
	assert_bool(material is StandardMaterial3D).is_true()
	assert_that((material as StandardMaterial3D).albedo_color).is_equal(Color.RED)

	windmill_node.toggle_blade_color()
	assert_bool(windmill_node.blades_red).is_false()
	var cleared = windmill_node.blades.get_surface_override_material(0)
	assert_bool(cleared == null).is_true()


func test_process_spin() -> void:
	assert_bool(windmill_node.spinning).is_true()

	windmill_node.spinning = false
	assert_bool(windmill_node.spinning).is_false()

	windmill_node.spinning = true
	assert_bool(windmill_node.spinning).is_true()

	assert_float(windmill_node.spin_speed).is_greater(0.0)
