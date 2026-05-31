extends Control

signal closed

const FADE_DURATION := 0.25

var _is_in_game := false

@onready var dim: ColorRect = $BackgroundDim
@onready var panel_container: PanelContainer = $PanelContainer
@onready var panel_vbox: VBoxContainer = $PanelContainer/VBoxContainer
@onready var close_button: TextureButton = panel_vbox.get_node("HeaderBar/CloseButton")
@onready var content: VBoxContainer = panel_vbox.get_node("ScrollContainer/Content")
@onready
var fullscreen_check: CheckButton = content.get_node("DisplaySection/FullscreenRow/FullscreenCheck")
@onready var volume_slider: HSlider = content.get_node("AudioSection/VolumeRow/HSlider")
@onready var volume_label: Label = content.get_node("AudioSection/VolumeRow/VolumeValue")
@onready var return_button: TextureButton = content.get_node("GameSection/ReturnButton")
@onready var version_label: Label = content.get_node("AboutSection/VBoxContainer/VersionLabel")


func _ready() -> void:
	_is_in_game = get_tree().current_scene.scene_file_path == "res://Scenes/map.tscn"

	# Only show Return to Menu when in-game
	return_button.visible = _is_in_game

	# Read version from file
	version_label.text = "ARCADIA " + _read_version()

	# Set initial fullscreen state
	var is_fs := DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	fullscreen_check.button_pressed = is_fs

	# Set initial volume
	var master_idx := AudioServer.get_bus_index("Master")
	var current_db := AudioServer.get_bus_volume_db(master_idx)
	volume_slider.value = current_db
	volume_label.text = str(current_db) + " dB"

	# Connect signals
	close_button.pressed.connect(_close)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	volume_slider.value_changed.connect(_on_volume_changed)
	return_button.pressed.connect(_on_return_to_menu)

	# Entrance animation
	dim.modulate = Color(0, 0, 0, 0)
	panel_container.modulate = Color(1, 1, 1, 0)

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dim, "modulate", Color(0, 0, 0, 0.5), FADE_DURATION)
	tween.tween_property(panel_container, "modulate", Color(1, 1, 1, 1), FADE_DURATION)


func _close() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(dim, "modulate", Color(0, 0, 0, 0), FADE_DURATION)
	tween.tween_property(panel_container, "modulate", Color(1, 1, 1, 0), FADE_DURATION)
	await tween.finished
	closed.emit()
	queue_free()


func _read_version() -> String:
	var file := FileAccess.open("res://version.txt", FileAccess.READ)
	if file == null:
		return "v0.0.0"
	return file.get_line().strip_edges()


func _on_fullscreen_toggled(button_pressed: bool) -> void:
	if button_pressed:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_volume_changed(value: float) -> void:
	var master_idx := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_idx, value)
	volume_label.text = str(value) + " dB"


func _on_return_to_menu() -> void:
	await _close()
	if _is_in_game:
		SceneTransition.change_scene("res://Scenes/start_menu.tscn")
