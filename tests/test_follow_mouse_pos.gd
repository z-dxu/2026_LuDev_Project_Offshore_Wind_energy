class_name TestFollowMousePos extends GdUnitTestSuite

var follow_node: Node2D


func before_test() -> void:
	follow_node = auto_free(load("res://Scripts/follow_mouse_pos.gd").new())
	var child_mock = Node2D.new()
	follow_node.add_child(child_mock)


func test_input_left_click() -> void:
	pass


func test_process_follows_mouse_when_hidden() -> void:
	pass


func test_process_ignores_mouse_when_visible() -> void:
	pass


func test_on_popup_mouse_exited() -> void:
	pass
