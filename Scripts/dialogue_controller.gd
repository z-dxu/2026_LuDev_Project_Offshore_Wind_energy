extends CanvasLayer

signal dialogue_finished

const ROLE_ACCENTS = {
	"system": Color(0.35, 0.72, 1.0),
	"coordinator": Color(0.56, 0.65, 0.74),
	"fisher_representative": Color(0.78, 0.58, 0.28),
	"environmental_activist": Color(0.36, 0.65, 0.43),
	"shipping_representative": Color(0.32, 0.44, 0.66),
}

@export_file("*.json") var dialogue_path := "res://assets/Story/Opening.json"
@export_dir var portrait_folder := "res://assets/Story/portraits"
@export var close_on_finish := true
@export var block_gameplay_input := true

var dialogue_pages := []
var current_index := 0
var previous_highlighter_move := true

var portrait_texture: TextureRect
var portrait_initials: Label
var speaker_tag: PanelContainer
var speaker_name: Label
var dialogue_text: RichTextLabel
var character_continue: Label
@onready var overlay: ColorRect = $Overlay
@onready var system_panel: PanelContainer = $SystemPanel

@onready var system_title: Label = $SystemPanel/MarginContainer/VBoxContainer/HeaderRow/SystemTitle

@onready var system_accent: ColorRect = $SystemPanel/MarginContainer/VBoxContainer/AccentLine

@onready var system_text: RichTextLabel = $SystemPanel/MarginContainer/VBoxContainer/SystemText

@onready var system_continue: Label = $SystemPanel/MarginContainer/VBoxContainer/ContinueHint

@onready var character_panel: PanelContainer = $CharacterPanel

@onready
var portrait_frame: PanelContainer = $CharacterPanel/MarginContainer/HBoxContainer/PortraitFrame

@onready
var content_column: VBoxContainer = $CharacterPanel/MarginContainer/HBoxContainer/ContentColumn


func _ready() -> void:
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	if block_gameplay_input:
		previous_highlighter_move = GameController.allow_highlighter_move
		GameController.allow_highlighter_move = false

	dialogue_pages = _load_dialogue_json(dialogue_path)
	if dialogue_pages.is_empty():
		push_error("Dialogue file is empty or invalid: " + dialogue_path)
		_finish_dialogue()
		return
	for child in portrait_frame.find_children("*"):
		if child is TextureRect and child.name == "Portrait":
			portrait_texture = child
		elif child is Label and child.name == "Initials":
			portrait_initials = child
	for child in content_column.find_children("*"):
		if child is PanelContainer and child.name == "SpeakerTag":
			speaker_tag = child
			var descendant = speaker_tag.get_child(0)
			if descendant.name == "SpeakerName":
				speaker_name = descendant
		if child is RichTextLabel and child.name == "DialogueText":
			dialogue_text = child
		if child is HBoxContainer and child.name == "BottomRow":
			var desc = child.get_child(1)
			if desc.name == "ContinueHint":
				character_continue = desc
	_show_current_page()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion or event is InputEventKey:
		get_viewport().set_input_as_handled()

	var advance_pressed = (
		(
			event is InputEventMouseButton
			and event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		)
		or (
			event is InputEventKey
			and event.keycode == KEY_ENTER
			and event.pressed
			and not event.echo
		)
	)

	if not advance_pressed:
		return

	current_index += 1
	if current_index >= dialogue_pages.size():
		_finish_dialogue()
	else:
		_show_current_page()


func _load_dialogue_json(path: String) -> Array:
	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Could not open dialogue file: " + path)
		return []

	var data = JSON.parse_string(file.get_as_text())
	return data if data is Array else []


func _show_current_page() -> void:
	var page: Dictionary = dialogue_pages[current_index]
	var page_type = page.get("type", "system")

	if page_type == "character":
		_show_character_page(page)
	else:
		_show_system_page(page)


func _show_system_page(page: Dictionary) -> void:
	var accent = _get_accent("system")
	system_panel.visible = true
	character_panel.visible = false
	system_title.text = page.get("title", "System")
	system_text.text = page.get("text", "")
	system_accent.color = accent
	system_continue.modulate = Color(accent.r, accent.g, accent.b, 0.88)

	var style = system_panel.get_theme_stylebox("panel").duplicate()
	style.border_color = Color(accent.r, accent.g, accent.b, 0.85)
	system_panel.add_theme_stylebox_override("panel", style)


func _show_character_page(page: Dictionary) -> void:
	var speaker_id = page.get("speaker_id", "")
	var accent = _get_accent(speaker_id)
	system_panel.visible = false
	character_panel.visible = true
	speaker_name.text = page["speaker_name"]
	dialogue_text.text = page.get("text", "")
	character_continue.modulate = Color(accent.r, accent.g, accent.b, 0.9)
	_apply_panel_accent(accent)
	_set_portrait(page, speaker_id)


func _apply_panel_accent(accent: Color) -> void:
	var panel_style = character_panel.get_theme_stylebox("panel").duplicate()
	panel_style.border_color = Color(accent.r, accent.g, accent.b, 0.55)
	character_panel.add_theme_stylebox_override("panel", panel_style)

	var tag_style = speaker_tag.get_theme_stylebox("panel").duplicate()
	tag_style.bg_color = Color(accent.r, accent.g, accent.b, 0.9)
	tag_style.border_color = Color(accent.r, accent.g, accent.b, 1.0)
	speaker_tag.add_theme_stylebox_override("panel", tag_style)


func _set_portrait(page: Dictionary, speaker_id: String) -> void:
	var texture = _load_portrait(page, speaker_id)
	portrait_texture.texture = texture
	portrait_texture.visible = texture != null
	portrait_initials.visible = texture == null
	portrait_initials.text = _speaker_initials(
		page.get("speaker_name", _speaker_id_to_name(speaker_id))
	)


func _load_portrait(page: Dictionary, speaker_id: String):
	var candidates = []
	if page.has("portrait_path"):
		var explicit_path = str(page["portrait_path"])
		if ResourceLoader.exists(explicit_path):
			return load(explicit_path)

	candidates.append(speaker_id + ".png")
	candidates.append(speaker_id + "_1.png")
	candidates.append(speaker_id + "_2.png")

	for candidate in candidates:
		var portrait_path = portrait_folder.path_join(candidate)
		if ResourceLoader.exists(portrait_path):
			return load(portrait_path)
	return null


func _get_accent(speaker_id: String) -> Color:
	return ROLE_ACCENTS.get(speaker_id, Color(0.62, 0.66, 0.72))


func _speaker_id_to_name(speaker_id: String) -> String:
	var words = speaker_id.replace("_", " ").split(" ", false)
	for index in words.size():
		words[index] = words[index].capitalize()
	return " ".join(words)


func _speaker_initials(display_name: String) -> String:
	var initials = ""
	for part in display_name.split(" ", false):
		initials += part.substr(0, 1).to_upper()
		if initials.length() >= 2:
			break
	return initials


func _finish_dialogue() -> void:
	if block_gameplay_input:
		GameController.allow_highlighter_move = previous_highlighter_move
	dialogue_finished.emit()
	if close_on_finish:
		queue_free()
