extends Camera3D

@export var drag_speed := 0.05
@export var zoom_speed := 10
@export var max_zoom := 300.0
@export var min_zoom := 50
@export var grid_map: GridMap
@export var highlight: Node3D

var dragging := false
var last_mouse_pos := Vector2.ZERO
var hover_poi_button = false
var selected_poi_button = null


#@onready var highlight: Node3D = $Highlight #old camera implementation
func _process(_delta: float) -> void:
	if GameController.allow_highlighter_move:
		var mouse_pos = get_viewport().get_mouse_position()
		#cast ray from camera from where the mouse is currently at
		var from = self.project_ray_origin(mouse_pos)
		var to = from + self.project_ray_normal(mouse_pos) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		#query.exclude = [self] # exclude self to avoid self-intersection
		query.collision_mask = 2
		var result = space_state.intersect_ray(query)
		if result:
			var hit_pos = result.position
			var local_pos_gridmap = grid_map.to_local(hit_pos)
			#convert mouse global pos to a cell position
			var cell = grid_map.local_to_map(local_pos_gridmap)
			var poi_button = GameController.poi_positions
			if cell in poi_button:
				hover_poi_button = true
				selected_poi_button = cell
			else:
				hover_poi_button = false
				selected_poi_button = null
			highlight.position = grid_map.map_to_local(cell) + Vector3(0, 1, 0)
			highlight.visible = true
		else:
			highlight.visible = false


func _input(event):
	if not GameController.allow_highlighter_move:
		return
	zoom(event)
	camera_movement(event)


func zoom(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			self.size = min(max_zoom, self.size + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			self.size = max(min_zoom, self.size - zoom_speed)
		elif event.is_action_pressed("left_click") and hover_poi_button:
			GameController.poi_button_pressed.emit(hover_poi_button, selected_poi_button)
		elif event.is_action_pressed("left_click") and !hover_poi_button:
			GameController.poi_button_pressed.emit(hover_poi_button, selected_poi_button)


func camera_movement(event):
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		var cam_right = self.global_transform.basis.x
		var cam_forward = (
			Vector3(-self.global_transform.basis.z.x, 0, -self.global_transform.basis.z.z)
			. normalized()
		)
		var move_dir = cam_right * delta.x + cam_forward * -delta.y
		grid_map.translate(move_dir * drag_speed)
