extends Control

const SIDEBAR_WIDTH := 320.0
const SLIDE_DURATION := 0.3

# Colors matching the dialogue system
const ROLE_ACCENTS := {
	"system": Color(0.35, 0.72, 1.0),
	"coordinator": Color(0.56, 0.65, 0.74),
	"fisher_representative": Color(0.78, 0.58, 0.28),
	"environmental_activist": Color(0.36, 0.65, 0.43),
	"shipping_representative": Color(0.32, 0.44, 0.66),
}

var is_open := false
var tween: Tween

@onready var panel_container: PanelContainer = $PanelContainer
@onready var history_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/HistoryList
@onready var close_button: Button = $PanelContainer/VBoxContainer/Header/CloseButton


func _ready() -> void:
	# Start hidden off-screen to the left
	await get_tree().process_frame

	var viewport_size := get_viewport_rect().size
	position = Vector2(-SIDEBAR_WIDTH, 0)
	size = Vector2(SIDEBAR_WIDTH, viewport_size.y)

	close_button.pressed.connect(_toggle)

	# Populate from any history already captured
	_rebuild_list()

	# Listen for new entries
	GameController.dialogue_history_updated.connect(_on_history_updated)


func _toggle() -> void:
	if is_open:
		_slide_out()
	else:
		_slide_in()


func _slide_in() -> void:
	is_open = true
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", Vector2(0, 0), SLIDE_DURATION)


func _slide_out() -> void:
	is_open = false
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", Vector2(-SIDEBAR_WIDTH, 0), SLIDE_DURATION)


func _on_history_updated() -> void:
	# Append only the latest entry (incremental, avoids full rebuild)
	var entry: Dictionary = GameController.dialogue_history.back()
	_add_entry_row(entry)


func _rebuild_list() -> void:
	# Clear existing rows
	for child in history_list.get_children():
		child.queue_free()

	# Rebuild from the global history
	for entry in GameController.dialogue_history:
		_add_entry_row(entry)


func _add_entry_row(entry: Dictionary) -> void:
	var entry_type: String = entry.get("type", "system")

	if entry_type == "character":
		_add_character_row(entry)
	else:
		_add_system_row(entry)


func _add_system_row(entry: Dictionary) -> void:
	var accent: Color = ROLE_ACCENTS.get("system", Color(0.35, 0.72, 1.0))

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 4)

	# Accent line
	var accent_line := ColorRect.new()
	accent_line.custom_minimum_size = Vector2(0, 2)
	accent_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accent_line.color = accent
	container.add_child(accent_line)

	# Title
	var title_label := Label.new()
	title_label.text = entry.get("title", "System")
	title_label.add_theme_color_override("font_color", accent)
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(title_label)

	# Body text
	var text_label := Label.new()
	text_label.text = entry.get("text", "")
	text_label.add_theme_color_override("font_color", Color(0.78, 0.82, 0.85))
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(text_label)

	# Separator
	var sep := HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.1)
	container.add_child(sep)

	history_list.add_child(container)


func _add_character_row(entry: Dictionary) -> void:
	var speaker_id: String = entry.get("speaker_id", "")
	var speaker_name: String = entry.get("speaker_name", "Speaker")
	var text: String = entry.get("text", "")
	var accent: Color = ROLE_ACCENTS.get(speaker_id, Color(0.62, 0.66, 0.72))

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 3)

	# Speaker name (color-coded tag)
	var tag_container := HBoxContainer.new()
	var tag := PanelContainer.new()
	var tag_style := StyleBoxFlat.new()
	tag_style.bg_color = Color(accent.r, accent.g, accent.b, 0.85)
	tag_style.corner_radius_top_left = 4
	tag_style.corner_radius_top_right = 4
	tag_style.corner_radius_bottom_right = 4
	tag_style.corner_radius_bottom_left = 4
	tag_style.content_margin_left = 6
	tag_style.content_margin_right = 6
	tag_style.content_margin_top = 2
	tag_style.content_margin_bottom = 2
	tag.add_theme_stylebox_override("panel", tag_style)

	var name_label := Label.new()
	name_label.text = speaker_name
	name_label.add_theme_color_override("font_color", Color(0.04, 0.05, 0.06))
	name_label.add_theme_font_size_override("font_size", 12)
	tag.add_child(name_label)
	tag_container.add_child(tag)
	container.add_child(tag_container)

	# Dialogue text
	var text_label := Label.new()
	text_label.text = text
	text_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.88))
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(text_label)

	# Separator
	var sep := HSeparator.new()
	sep.modulate = Color(1, 1, 1, 0.08)
	container.add_child(sep)

	history_list.add_child(container)
