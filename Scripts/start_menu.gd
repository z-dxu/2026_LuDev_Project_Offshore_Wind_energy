extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	print(delta)


func _on_start_game_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/map.tscn")


func _on_settings_pressed() -> void:
	var overlay := preload("res://Scenes/settings_overlay.tscn").instantiate()
	add_child(overlay)


func _on_exit_pressed() -> void:
	get_tree().quit()
