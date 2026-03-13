extends Label

var currentday: int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = "Current Day: 0"


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:


func _on_next_day_pressed() -> void:
	currentday += 1
	text = "Current Day: " + str(currentday)
