extends Control

@onready var transition: ColorRect = $Transition


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	transition.modulate.a = 1
	# reset for new game
	GameController.dialogue_history.clear()  # clear
	GameController.all_windmills.clear()
	GameController.harbor_pos.clear()
	GameController.story_flags = {"phase": 0, "ending": "null", "ending_score": 0}
	var tween = create_tween()
	tween.tween_property(transition, "modulate:a", 0, 0.5)


func _on_start_game_pressed() -> void:
	SceneTransition.change_scene("res://Scenes/map.tscn")


func _on_settings_pressed() -> void:
	var overlay := preload("res://Scenes/settings_overlay.tscn").instantiate()
	add_child(overlay)


func _on_exit_pressed() -> void:
	get_tree().quit()
