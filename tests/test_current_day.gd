extends GdUnitTestSuite

var current_day_node: Label


func before_test() -> void:
	current_day_node = auto_free(load("res://Scripts/current_day.gd").new())


func test_initial_state() -> void:
	pass


func test_on_next_day_pressed() -> void:
	pass
