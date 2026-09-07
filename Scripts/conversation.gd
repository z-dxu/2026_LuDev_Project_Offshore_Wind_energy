class_name Conversation
extends Control

signal lmb_clicked
signal dialogue_finished
signal option_chosen(option_index: int)

const SYSTEM_SPEAKER := "System"

@export_file("*.json") var dialogue_path := "res://assets/Story/Opening.json"
@export_file("*.tscn") var next_scene_path := ""
@export var start_on_ready := false
@export var close_on_finish := false
@export var block_gameplay_input := false
@export_dir var portrait_folder := "res://assets/Story/portraits"
#var state: State = State.IDLE

var dialogue_json
var tween
var previous_highlighter_move := true
var _choice_skip_to := -1
var _choice_branch_end := -1
var _choice_active := false
var _choice_buttons: Array[TextureButton] = []
var _dialogue_running = false
@onready var background: NinePatchRect = $DialoguePanel/Background
@onready var panel_dim: ColorRect = $DialoguePanel/Dim
@onready var speaker_name_label: Label = $DialoguePanel/Background/SpeakerName
#@onready var name_frame: TextureRect = $DialoguePanel/NameFrame
@onready var portrait_container: Control = $DialoguePanel/Background/PortraitContainer
@onready var portrait_pic: TextureRect = $DialoguePanel/Background/PortraitContainer/Portrait
@onready var dialogue_text: RichTextLabel = $DialoguePanel/Background/DialogueText
@onready var choice_container: VBoxContainer = $DialoguePanel/Background/ChoiceContainer
@onready var dialogue_panel: CanvasLayer = $DialoguePanel
@onready var choice_panel: CanvasLayer = $ChoicePanel
@onready var half_dialogue_text: RichTextLabel = $DialoguePanel/Background/HalfDialogueText


func _ready() -> void:
	half_dialogue_text.visible = false
	if block_gameplay_input:
		previous_highlighter_move = GameController.allow_highlighter_move
		GameController.allow_highlighter_move = false
	dialogue_panel.visible = false
	choice_panel.visible = false
	dialogue_json = _load_dialogue_json(dialogue_path)

	# Wire up the pre-designed choice buttons
	_ready_choice_buttons()

	# Apply the portrait mask shader with profile_place.png as the mask
	var mat: ShaderMaterial = portrait_pic.material as ShaderMaterial
	if mat:
		var mask_tex := load("res://assets/dialogue_ui/profile_place.png") as Texture2D
		if mask_tex:
			mat.set_shader_parameter("mask_texture", mask_tex)

	if dialogue_json == null or dialogue_json.is_empty():
		push_error("Dialogue file is empty or invalid: " + dialogue_path)
		return


func _input(event) -> void:
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

	if advance_pressed and not _choice_active:
		#get_viewport().set_input_as_handled()
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
	await get_tree().process_frame
	if _dialogue_running:
		print("a dialogue is already running")  #Only 1 dialogue should be running
		return
	_dialogue_running = true
	half_dialogue_text.visible = false
	# Show the dialogue panel background elements
	dialogue_panel.visible = true
	panel_dim.visible = false
	background.visible = true
	portrait_container.visible = true
	portrait_pic.visible = true
	speaker_name_label.visible = true
	choice_container.visible = false

	# Main dialogue loop — while loop allows index jumping for choices
	_choice_skip_to = -1
	_choice_branch_end = -1
	var idx := 0

	while idx < txt_script.size():
		var entry = txt_script[idx]

		# Branch jumping: if we've passed the chosen option's branch end, jump to merge point
		if _choice_skip_to >= 0 and idx > _choice_branch_end:
			if _choice_skip_to > _choice_branch_end:
				idx = _choice_skip_to
			else:
				idx = _choice_branch_end + 1
			_choice_skip_to = -1
			_choice_branch_end = -1
			continue

		var entry_type = entry.get("type", "character")

		if entry_type == "choice":
			_choice_active = true
			var chosen_idx = await _show_choice_page(entry)
			var chosen = entry["options"][chosen_idx]
			_choice_skip_to = chosen.get("skip_to", -1)
			_choice_branch_end = chosen.get("branch_end", -1)
			store_flags(chosen)
			_hide_choice_page()
			_choice_active = false
			idx += 1
			continue

		_update_speaker_display(entry)
		_show_dialogue_text(entry.get("text", ""), dialogue_text)

		# Append to global dialogue history
		await get_tree().process_frame  # prevent skipping the first idx
		await lmb_clicked
		# Render character or system entry
		if entry_type == "flag":  # no choices but has a flag (to continue story)
			store_flags(entry)
		GameController.dialogue_history.append(entry.duplicate())
		GameController.dialogue_history_updated.emit()
		idx += 1

	# Cleanup
	background.visible = false
	portrait_container.visible = false
	portrait_pic.visible = false
	speaker_name_label.visible = false
	choice_container.visible = false
	_dialogue_running = false
	if block_gameplay_input:
		GameController.allow_highlighter_move = previous_highlighter_move
	dialogue_finished.emit()
	if next_scene_path != "":
		get_tree().change_scene_to_file(next_scene_path)
	elif close_on_finish:
		queue_free()


func _update_speaker_display(entry: Dictionary) -> void:
	var speaker_name = entry.get("speaker_name", entry.get("speaker", SYSTEM_SPEAKER))
	var speaker_id = entry.get("speaker_id", "")
	var is_system = entry.get("type", "character") == "system"
	speaker_name_label.text = speaker_name

	if is_system:
		portrait_pic.texture = null
		portrait_pic.visible = false
		return

	var texture = _load_portrait(speaker_name, speaker_id)
	portrait_pic.texture = texture
	portrait_pic.visible = texture != null


func _load_portrait(speaker_name: String, speaker_id: String) -> Texture2D:
	var candidates: Array[String] = []

	var name_file := _speaker_to_file_name(speaker_name)
	if name_file != "":
		candidates.append(name_file)
		candidates.append(name_file + "_1")
		candidates.append(name_file + "_2")

	if speaker_id != "" and speaker_id != name_file:
		candidates.append(speaker_id)
		candidates.append(speaker_id + "_1")
		candidates.append(speaker_id + "_2")

	for candidate in candidates:
		var portrait_path = portrait_folder.path_join(candidate + ".png")
		if ResourceLoader.exists(portrait_path):
			return load(portrait_path)

	return null


func _get_entry_speaker(entry: Dictionary) -> String:
	if entry.get("type", "character") == "system":
		return SYSTEM_SPEAKER
	return entry.get("speaker_name", entry.get("speaker", ""))


func _speaker_to_file_name(speaker_name: String) -> String:
	return speaker_name.to_lower().replace(" ", "_").replace("-", "_")


# ── Inline choice UI (uses pre-designed scene buttons, not dynamic creation) ──


func _ready_choice_buttons() -> void:
	for idx in range(3):
		var btn_name := "ChoiceButton" if idx == 0 else "ChoiceButton%d" % (idx + 1)
		var btn: TextureButton = choice_container.get_node_or_null(btn_name) as TextureButton
		if btn:
			btn.visible = false
			btn.pressed.connect(_on_option_pressed.bind(idx))
			_choice_buttons.append(btn)


func _show_choice_page(entry: Dictionary) -> int:
	dialogue_text.visible = false
	half_dialogue_text.visible = false
	choice_container.visible = true
	# Show the choice prompt in the dialogue text area
	_show_dialogue_text(entry.get("text", "Please choose:"), half_dialogue_text)
	_show_dialogue_text(entry.get("text", "Please choose:"), dialogue_text)
	half_dialogue_text.visible = true

	var options_arr = entry.get("options", [])
	for idx in _choice_buttons.size():
		var btn := _choice_buttons[idx]
		if idx < options_arr.size():
			# check if the previous choice is already chosen, this is for ramsar path
			if options_arr[idx].get("flag", ""):
				var text = [options_arr[idx]["flag"]["story_flag"]]
				var previous_choice = GameController.story_flags.get("choice_1", "")
				if previous_choice in text:
					continue

			# showing buttons
			btn.visible = true
			var label: Label = btn.get_node_or_null("ChoiceText") as Label
			if label:
				label.text = options_arr[idx].get("label", "")
		else:
			btn.visible = false

	var result = await option_chosen
	return result


func _hide_choice_page() -> void:
	choice_container.visible = false
	for btn in _choice_buttons:
		btn.visible = false
	dialogue_text.visible = true


func _on_option_pressed(opt_idx: int) -> void:
	option_chosen.emit(opt_idx)


func _show_dialogue_text(text: String, txt_box):
	txt_box.text = ""
	txt_box.visible = true
	txt_box.text = text


func store_flags(chosen: Dictionary):
	if chosen.has("windmill_location"):
		GameController.story_flags["windmill_location"] = chosen.get("windmill_location", "")
		GameController.story_flags["build_positions"] = chosen.get("build_positions", [])
		GameController.story_flag_appended.emit()
	if chosen.has("flag"):
		var flag = chosen["flag"]
		var flag_name = flag.get("name")
		var flag_value = flag.get("story_flag")
		GameController.story_flags[flag_name] = flag_value
		GameController.story_flag_appended.emit()
	if chosen.has("signal"):
		match chosen.get("signal"):
			"next_phase":
				GameController.next_phase.emit()


# ── Static helper: instantiate a conversation at any POI ──


static func play_dialogue(parent: Node, path: String) -> void:
	var scene: Control = load("res://Scenes/Conversation.tscn").instantiate()
	scene.dialogue_path = path
	scene.start_on_ready = true
	scene.close_on_finish = true
	scene.block_gameplay_input = true
	parent.add_child(scene)
