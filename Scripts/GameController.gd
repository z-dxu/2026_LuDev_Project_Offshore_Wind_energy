extends Node
#signal that every script can read cuz this is a global script set by me -zdxu
signal spawn_building(building_name: String)
# caller: camera3d.
# Listener: LeftSideBar,Gridmap
signal poi_button_pressed(hover: bool)
signal get_poi_score(requester)

var allow_highlighter_move := true  #allows the highlighter to move around
var poi_total_score: int = 0  # helper variable for leftSideBar
# Gridmap.gd variables
var food_pos = [
	Vector3i(23, 1, -21),
	Vector3i(23, 1, -20),
	Vector3i(22, 1, -20),
	Vector3i(23, 1, -19),
]

var poi_positions = [Vector3i(23, 0, -16)]
var sdg_data = {}
# Vector3i -> {
#	"sdg_name" -> {"score": 0}
#}
var sdg_imgs = {
	"food": preload("res://assets/SDG_imgs/E_WEB_INVERTED_02-removebg-preview.png"),
}


func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
