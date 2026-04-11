extends Node
#signal that every script can read cuz this is a global script set by me -zdxu
signal spawn_building(building_name: String)
# Called when the node enters the scene tree for the first time.
var allow_highlighter_move := true  #allows the highlighter to move around


func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
