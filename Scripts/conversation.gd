extends Control

signal lmb_clicked

var is_typing = false
var skip_requested = false
var dialogue_json
var tween
var ui_bg = []
var ui_label = []
@onready var p_1_label: Label = $Person1_layer/P1_label
@onready var p_2_label: Label = $Person2_layer/P2_label
@onready var text_bubble_label: Label = $text_bubble/text_bubble_label
@onready var person_2: PanelContainer = $Person2_layer/Person2
@onready var person_1: PanelContainer = $Person1_layer/Person1
@onready var p_1_pic: TextureRect = $Person1_layer/P1_pic
@onready var p_2_pic: TextureRect = $Person2_layer/P2_pic


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialogue_json = _load_dialogue_json("res://assets/Story/Example.json")
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

	await lmb_clicked
	_start_dialogue_two(dialogue_json, dialogue_json[0]["speaker"], dialogue_json[1]["speaker"])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _input(event) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if is_typing:
			skip_requested = true
		else:
			lmb_clicked.emit()


func _load_dialogue_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	var data = JSON.parse_string(content)
	return data


func _start_dialogue_two(txt_script, name_1: String, name_2: String):
	for child in ui_bg:
		pop_effect(child)
	for child in ui_label:
		child.visible = true
	p_1_label.text = name_1
	p_2_label.text = name_2
	pop_effect(p_1_pic)
	pop_effect(p_2_pic)
	for line in txt_script:
		show_character(line["speaker"])
		await _typewriting_animation(text_bubble_label, line["text"])
		await lmb_clicked
	for child in find_children("*"):
		if child is CanvasLayer:
			continue
		child.visible = false


func show_character(speaker_name: String):
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


func _typewriting_animation(txt_label: Label, text: String):
	txt_label.text = ""  #prev txt not seen
	txt_label.visible = true
	txt_label.visible_ratio = 0
	txt_label.text = text

	is_typing = true
	skip_requested = false

	tween = create_tween()
	tween.tween_property(txt_label, "visible_ratio", 1, 3)
	while tween.is_running():
		if skip_requested:
			tween.kill()
			txt_label.visible_ratio = 1
			break
		await get_tree().process_frame
	is_typing = false

	#await tween.finished # this only works if you call function with await


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
