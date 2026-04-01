extends Node3D

@export var coral_enabled := false
@export var spin_speed := 2.0
@export var allowed_positions: Array[Vector3] = [
	Vector3(0, 0, 0),
	Vector3(6, 0, 0),
	Vector3(-6, 0, 4),
]
@export var size_options: Array[float] = [0.3, 1.0, 2.0]
@export var blade_colors: Array[Color] = [
	Color.DARK_BLUE,
	Color.DIM_GRAY,
	Color.DARK_GREEN,
]

var spinning := true
var current_position_index := 0
var current_size_index := 0
var current_color_index := 0

@onready var windmill := $Windmill
@onready var blades := $Windmill/Cube_003


func _ready() -> void:
	$Windmill/CoralGroup.visible = coral_enabled


func _process(delta: float) -> void:
	blades.rotation.x += spin_speed * -delta


func next_position() -> void:
	current_position_index = (current_position_index + 1) % allowed_positions.size()
	windmill.position = allowed_positions[current_position_index]


func next_size() -> void:
	current_size_index = (current_size_index + 1) % size_options.size()
	windmill.scale = Vector3.ONE * size_options[current_size_index]


func next_blade_color() -> void:
	current_color_index = (current_color_index + 1) % blade_colors.size()

	var material := StandardMaterial3D.new()
	material.albedo_color = blade_colors[current_color_index]

	if blades is MeshInstance3D and blades.mesh:
		for i in range(blades.mesh.get_surface_count()):
			blades.set_surface_override_material(i, material)


func _on_button_pressed() -> void:
	next_position()


func _on_button_2_pressed() -> void:
	next_size()


func _on_button_3_pressed() -> void:
	next_blade_color()
