extends Control

@onready var popup: Panel = $Popup
@onready var windmill: Button = $Popup/windmill


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	popup.visible = false
	for child in find_children("*"):  #look at all children
		if child is Button:
			#send which button is pressed
			child.pressed.connect(_on_building_button_press.bind(child))


func _input(event: InputEvent) -> void:
	if not GameController.allow_highlighter_move:
		return
	# TODO: need to add a check if the mouse is currently hovering over a tile
	if event.is_action_pressed("E") and !get_child(0).visible:
		position = get_global_mouse_position()
		get_child(0).visible = true
		GameController.allow_highlighter_move = false


func _process(_delta: float) -> void:
	#if get_child(0).visible == false:
	#position = get_global_mouse_position()
	# this does not need to be constantly called,
	#the ui gets visible by either left click or leaving the area
	pass


func _on_popup_mouse_exited() -> void:
	#get_child(0).visible = false
	# TODO: it turns invisible when hovering over a button inside this popup here

	pass


func _on_building_button_press(button: Button):
	var data = BuildingData.new()
	data.building_name = str(button.name)
	GameController.spawn_building.emit(data)  # for now send the button name
	get_child(0).visible = false
	print("button pressed " + str(data.building_name))
	GameController.allow_highlighter_move = true
