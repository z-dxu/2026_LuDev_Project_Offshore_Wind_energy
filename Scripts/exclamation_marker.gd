extends Node3D
@export_file("*.json") var quest_path := "res://assets/Story/Example.json"

@onready var area_3d: Area3D = $Area3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false


func clicked():
	print("quest clicked on: " + quest_path)
	var txt_script = ConversationManager._load_dialogue_json(quest_path)
	if txt_script:
		ConversationManager._start_dialogue(txt_script)
	else:
		print("no txt script found " + str(quest_path))


#
func _on_visibility_changed() -> void:
	if !area_3d:
		return
	# make it ray pickable depending if its visible
	area_3d.monitoring = visible
	area_3d.monitorable = visible
	if visible:
		area_3d.collision_layer = 8
	else:
		area_3d.collision_layer = 0
