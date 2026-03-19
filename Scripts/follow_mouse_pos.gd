extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.



func _input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click") :
		get_child(0).visible = true;
	if event is InputEventMouseMotion:
		if(event.relative.is_zero_approx() == false):
			get_child(0).visible = false;

		
	
func _process(delta: float) -> void:
	position = get_global_mouse_position();
	
	
