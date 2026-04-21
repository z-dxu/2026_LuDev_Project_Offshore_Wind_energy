extends Control

@export var slide_duration := 0.25
@export var panel_width := 300.0
@export var right_margin := 0.0

var selected_windmill: Node3D = null
var preview_windmill: Node3D = null
var preview_scene: PackedScene = null
var tween: Tween
var shown_pos := Vector2.ZERO
var hidden_pos := Vector2.ZERO

@onready var panel := $Panel
@onready
var preview_anchor = $Panel/VBoxContainer/SubViewportContainer/SubViewport/PreviewRoot/PreviewAnchor
@onready
var preview_camera = $Panel/VBoxContainer/SubViewportContainer/SubViewport/PreviewRoot/Camera3D
@onready var coral_checkbox := $Panel/VBoxContainer/CoralCheckbox
@onready var blade_color_button := $Panel/VBoxContainer/BladeColorButton
@onready var close_button := $Panel/VBoxContainer/CloseButton


func _ready() -> void:
	coral_checkbox.toggled.connect(_on_coral_toggled)
	blade_color_button.pressed.connect(_on_blade_color_button_pressed)
	close_button.pressed.connect(_on_close_pressed)

	await get_tree().process_frame

	var viewport_size := get_viewport_rect().size

	size = Vector2(panel_width, viewport_size.y)
	position = Vector2(viewport_size.x, 0)

	shown_pos = Vector2(viewport_size.x - panel_width - right_margin, 0)
	hidden_pos = Vector2(viewport_size.x, 0)


func open_editor(windmill: Node3D, windmill_scene: PackedScene) -> void:
	selected_windmill = windmill
	preview_scene = windmill_scene
	GameController.allow_highlighter_move = false

	_setup_preview()
	coral_checkbox.button_pressed = selected_windmill.coral_enabled
	_slide_in()


func close_editor() -> void:
	GameController.allow_highlighter_move = true
	selected_windmill = null

	if preview_windmill:
		preview_windmill.queue_free()
		preview_windmill = null

	_slide_out()


func _setup_preview() -> void:
	if preview_windmill:
		preview_windmill.queue_free()

	preview_windmill = preview_scene.instantiate()
	preview_anchor.add_child(preview_windmill)

	if preview_windmill.has_node("WorldEnvironment"):
		preview_windmill.get_node("WorldEnvironment").queue_free()

	preview_windmill.position = Vector3.ZERO
	preview_windmill.rotation = Vector3.ZERO
	preview_windmill.scale = Vector3.ONE
	preview_windmill.set_coral_enabled(selected_windmill.coral_enabled)
	preview_windmill.set_blades_red(selected_windmill.blades_red)

	preview_windmill.rotation.y = -PI / 2
	preview_camera.position = Vector3(0, 6.0, 16.0)
	preview_camera.look_at(Vector3(0, 2.0, 0), Vector3.UP)


func _on_coral_toggled(enabled: bool) -> void:
	if selected_windmill:
		selected_windmill.set_coral_enabled(enabled)

	if preview_windmill:
		preview_windmill.set_coral_enabled(enabled)


func _on_blade_color_button_pressed() -> void:
	if selected_windmill:
		selected_windmill.toggle_blade_color()

	if preview_windmill:
		preview_windmill.toggle_blade_color()


func _on_close_pressed() -> void:
	close_editor()


func _slide_in() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "position", shown_pos, slide_duration)


func _slide_out() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", hidden_pos, slide_duration)
