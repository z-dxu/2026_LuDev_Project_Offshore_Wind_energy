class_name TestCamera3D extends GdUnitTestSuite

var camera_node: Camera3D


func before_test() -> void:
	camera_node = auto_free(load("res://Scripts/camera_3d.gd").new())


func test_zoom_input() -> void:
	pass


func test_drag_input() -> void:
	pass


func test_raycast_highlight_hit() -> void:
	pass


func test_raycast_highlight_miss() -> void:
	pass
