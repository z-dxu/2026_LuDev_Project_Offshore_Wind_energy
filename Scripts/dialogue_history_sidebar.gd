extends Control

const SIDEBAR_WIDTH_RATIO := 0.25
const SLIDE_DURATION := 0.3

const ROLE_ACCENTS := {
	"system": Color(0.35, 0.72, 1.0),
	"coordinator": Color(0.56, 0.65, 0.74),
	"fisher_representative": Color(0.78, 0.58, 0.28),
	"environmental_activist": Color(0.36, 0.65, 0.43),
	"shipping_representative": Color(0.32, 0.44, 0.66),
	"fishers_guild": Color(0.78, 0.58, 0.28),
	"featherwings": Color(0.36, 0.65, 0.43),
	"legal_advisor": Color(0.62, 0.66, 0.72),
	"aquanautilus": Color(0.28, 0.60, 0.72),
	"blue_arcadia": Color(0.30, 0.50, 0.78),
}

var is_open := false
var tween: Tween
var _current_width := 0.0

@onready var panel_container: PanelContainer = $PanelContainer
@onready var history_list: VBoxContainer = $PanelContainer/VBoxContainer/ScrollContainer/HistoryList
@onready var close_button: TextureButton = $PanelContainer/VBoxContainer/Header/CloseButton


func _ready() -> void:
	await get_tree().process_frame

	_current_width = _compute_width()
	position = Vector2(-_current_width, 0)
	size = Vector2(_current_width, get_viewport_rect().size.y)

	close_button.pressed.connect(_toggle)

	# Recalculate on window resize
	get_tree().root.size_changed.connect(_on_window_resized)

	_rebuild_list()
	GameController.dialogue_history_updated.connect(_on_history_updated)


func _compute_width() -> float:
	return get_viewport_rect().size.x * SIDEBAR_WIDTH_RATIO


func _on_window_resized() -> void:
	_current_width = _compute_width()
	var viewport_height := get_viewport_rect().size.y
	size = Vector2(_current_width, viewport_height)
	if not is_open:
		position = Vector2(-_current_width, 0)


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
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if tween:
		tween.kill()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", Vector2(-_current_width, 0), SLIDE_DURATION)


func _on_history_updated() -> void:
	var entry: Dictionary = GameController.dialogue_history.back()
	_add_entry_row(entry)


func _rebuild_list() -> void:
	for child in history_list.get_children():
		child.queue_free()

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

	var accent_line := ColorRect.new()
	accent_line.custom_minimum_size = Vector2(0, 2)
	accent_line.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accent_line.color = accent
	container.add_child(accent_line)

	var title_label := Label.new()
	title_label.text = entry.get("title", "System")
	title_label.add_theme_color_override("font_color", accent)
	title_label.add_theme_font_size_override("font_size", 13)
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(title_label)

	var text_label := Label.new()
	text_label.text = entry.get("text", "")
	text_label.add_theme_color_override("font_color", Color(0.15, 0.2, 0.25))
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(text_label)

	var sep := HSeparator.new()
	sep.modulate = Color(0, 0, 0, 0.1)
	container.add_child(sep)

	history_list.add_child(container)


func _add_character_row(entry: Dictionary) -> void:
	var speaker_id: String = entry.get("speaker_id", "")
	var speaker_name: String = entry.get("speaker_name", "Speaker")
	var text: String = entry.get("text", "")
	var accent: Color = ROLE_ACCENTS.get(speaker_id, Color(0.62, 0.66, 0.72))

	var container := VBoxContainer.new()
	container.add_theme_constant_override("separation", 3)

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

	var text_label := Label.new()
	text_label.text = text
	text_label.add_theme_color_override("font_color", Color(0.1, 0.15, 0.2))
	text_label.add_theme_font_size_override("font_size", 12)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	container.add_child(text_label)

	var sep := HSeparator.new()
	sep.modulate = Color(0, 0, 0, 0.08)
	container.add_child(sep)

	history_list.add_child(container)
