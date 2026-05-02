extends CanvasLayer


func change_scene(target: String) -> void:
	$AnimationPlayer.play("dissolve_in")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target)
	$AnimationPlayer.play("dissolve_out")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#If running in cli no need to load graphical stuff
	if DisplayServer.get_name() == "headless":
		return


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
