extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		get_child(0).visible = true
	


func _process(_delta: float) -> void:
	if (get_child(0).visible == false):
		position = get_global_mouse_position()


func _on_popup_mouse_exited() -> void:
	get_child(0).visible = false
