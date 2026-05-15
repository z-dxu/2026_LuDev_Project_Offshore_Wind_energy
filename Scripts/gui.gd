extends Control


func _on_settings_pressed() -> void:
	var overlay := preload("res://Scenes/settings_overlay.tscn").instantiate()
	add_child(overlay)
