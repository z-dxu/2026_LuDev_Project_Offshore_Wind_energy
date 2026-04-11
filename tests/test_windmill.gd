extends GdUnitTestSuite

var windmill_node: Node3D


func before_test() -> void:
	var scene = load("res://Scenes/Windmill.tscn")
	if scene:
		windmill_node = auto_free(scene.instantiate())


func test_initial_state() -> void:
	pass


func test_next_position() -> void:
	pass


func test_next_size() -> void:
	pass


func test_next_blade_color() -> void:
	pass


func test_process_spin() -> void:
	pass
