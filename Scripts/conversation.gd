extends Control

signal lmb_clicked
signal dialogue_finished

@export_file("*.json") var dialogue_path := "res://assets/Story/Example.json"
@export_file("*.tscn") var next_scene_path := ""
@export var start_on_ready := false
@export var close_on_finish := false
@export var block_gameplay_input := false

var dialogue_json
var tween
var ui_bg = []
var ui_label = []
var multi_speaker_mode = false
var previous_highlighter_move := true
@onready var p_1_label: Label = $Person1_layer/P1_label
@onready var p_2_label: Label = $Person2_layer/P2_label
@onready var text_bubble_label: Label = $text_bubble/text_bubble_label
@onready var person_2: PanelContainer = $Person2_layer/Person2
@onready var person_1: PanelContainer = $Person1_layer/Person1
@onready var p_1_pic: TextureRect = $Person1_layer/P1_pic
@onready var p_2_pic: TextureRect = $Person2_layer/P2_pic


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	if block_gameplay_input:
		previous_highlighter_move = GameController.allow_highlighter_move
		GameController.allow_highlighter_move = false

	dialogue_json = _load_dialogue_json(dialogue_path)
	for child in find_children("*"):
		if child is CanvasLayer:
			continue
		child.visible = false
		if child is PanelContainer:
			ui_bg.append(child)
		if child is Label:
			child.text = ""
			child.visible = false
			ui_label.append(child)
		if child is TextureRect:
			child.visible = false

	if dialogue_json == null or dialogue_json.is_empty():
		push_error("Dialogue file is empty or invalid: " + dialogue_path)
		return

	if start_on_ready:
		_start_dialogue(dialogue_json)
	else:
		await lmb_clicked
		_start_dialogue(dialogue_json)


func _input(event) -> void:
	if (
		event is InputEventMouseButton
		or event is InputEventMouseMotion
		or event is InputEventKey
	):
		get_viewport().set_input_as_handled()

	var advance_pressed = (
		(event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed)
		or (event is InputEventKey and event.keycode == KEY_ENTER and event.pressed and not event.echo)
	)

	if advance_pressed:
		lmb_clicked.emit()


func _load_dialogue_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open dialogue file: " + path)
		return []
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	return data


func _start_dialogue(txt_script):
	var speakers = _get_unique_speakers(txt_script)
	multi_speaker_mode = speakers.size() > 2

	for child in ui_bg:
		pop_effect(child)
	for child in ui_label:
		child.visible = true

	if multi_speaker_mode:
		person_2.visible = false
		p_2_label.visible = false
		p_1_pic.visible = false
		p_2_pic.visible = false
	else:
		p_1_label.text = speakers[0]
		p_2_label.text = speakers[1] if speakers.size() > 1 else ""
		pop_effect(p_1_pic)
		pop_effect(p_2_pic)

	for line in txt_script:
		if multi_speaker_mode:
			p_1_label.text = line["speaker"]
		show_character(line["speaker"])
		_show_dialogue_text(text_bubble_label, line["text"])
		await lmb_clicked

	for child in find_children("*"):
		if child is CanvasLayer:
			continue
		child.visible = false
	if block_gameplay_input:
		GameController.allow_highlighter_move = previous_highlighter_move
	dialogue_finished.emit()
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	elif close_on_finish:
		queue_free()


func _get_unique_speakers(txt_script):
	var speakers = []
	for line in txt_script:
		var speaker = line.get("speaker", "")
		if speaker != "" and not speakers.has(speaker):
			speakers.append(speaker)
	return speakers


func show_character(speaker_name: String):
	if multi_speaker_mode:
		person_1.self_modulate.a = 1
		return
	if p_1_label.text == speaker_name:
		print("plyer 1 speakign")
		p_1_pic.self_modulate.a = 1
		person_1.self_modulate.a = 1
		p_2_pic.self_modulate.a = 0.5
		person_2.self_modulate.a = 0.5
	elif p_2_label.text == speaker_name:
		print("plyer 2 speakign")
		person_2.self_modulate.a = 1
		p_2_pic.self_modulate.a = 1
		p_1_pic.self_modulate.a = 0.5
		person_1.self_modulate.a = 0.5
	else:
		print("No speaker found")


func _show_dialogue_text(txt_label: Label, text: String):
	txt_label.text = ""  #prev txt not seen
	txt_label.visible = true
	txt_label.visible_ratio = 1
	txt_label.text = text


func pop_effect(object):  # open pop effect
	object.visible = true
	object.pivot_offset = Vector2(size.x / 2, size.y / 2)
	object.scale = Vector2(0.01, 0.01)
	tween = create_tween()
	(
		tween
		. tween_property(object, "scale", Vector2(1.05, 1.05), 0.15)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)  # pop effect
	tween.tween_property(object, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_BACK).set_ease(
		Tween.EASE_IN
	)
	await tween.finished


func close_pop_effect(object):  # close the object / clear the object
	object.visible = true
	object.pivot_offset = Vector2(size.x / 2, size.y / 2)
	object.scale = Vector2(0.01, 0.01)
	tween = create_tween()
	(
		tween
		. tween_property(object, "scale", Vector2(1.2, 1.2), 0.15)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_OUT)
	)  # pop effect
	(
		tween
		. tween_property(object, "scale", Vector2(0.1, 0.1), 0.15)
		. set_trans(Tween.TRANS_BACK)
		. set_ease(Tween.EASE_IN)
	)
	await tween.finished
