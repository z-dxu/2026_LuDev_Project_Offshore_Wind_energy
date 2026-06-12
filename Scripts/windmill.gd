extends Node3D

signal selected(windmill: Node3D)

@export var coral_enabled := false
@export var spin_speed := 2.0
@export var allowed_positions: Array[Vector3] = [
	Vector3(0, 0, 0),
	Vector3(6, 0, 0),
	Vector3(-6, 0, 4),
]

var spinning := true
var blades_red := false
var current_position_index := 0

@onready var windmill := $Windmill
@onready var blades := $Windmill/Cube_003
@onready var coral_group := $Windmill/CoralGroup


func _ready() -> void:
	set_coral_enabled(coral_enabled)
	set_blades_red(blades_red)


func _process(delta: float) -> void:
	if spinning:
		blades.rotation.x += spin_speed * -delta


func set_coral_enabled(enabled: bool) -> void:
	coral_enabled = enabled
	coral_group.visible = enabled


func set_blades_red(enabled: bool) -> void:
	blades_red = enabled

	if blades is MeshInstance3D and blades.mesh:
		if blades_red:
			var material := StandardMaterial3D.new()
			material.albedo_color = Color.RED
			material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

			for i in range(blades.mesh.get_surface_count()):
				blades.set_surface_override_material(i, material)
		else:
			for i in range(blades.mesh.get_surface_count()):
				blades.set_surface_override_material(i, null)


func shorten_windmill():
	windmill.scale.y = 0.7


func toggle_blade_color() -> void:
	set_blades_red(!blades_red)


func next_position() -> void:
	current_position_index = (current_position_index + 1) % allowed_positions.size()
	windmill.position = allowed_positions[current_position_index]


func _on_button_pressed() -> void:
	next_position()


func _on_static_body_3d_input_event(
	_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int
) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		selected.emit(self)
