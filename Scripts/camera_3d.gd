extends Camera3D
@export var drag_speed := 0.05
@export var zoom_speed := 10
@export var max_zoom := 1000.0
@export var min_zoom := 50
@export var grid_map: GridMap
var dragging := false
var last_mouse_pos := Vector2.ZERO
@onready var highlight: Node3D = $Highlight


func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()

	#cast ray from camera from where the mouse is currently at
	var from = self.project_ray_origin(mouse_pos)
	var to = from + self.project_ray_normal(mouse_pos) * 1000

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	#query.exclude = [self] # exclude self to avoid self-intersection
	query.collision_mask = 2
	var result = space_state.intersect_ray(query)
	#print("raying" + result)
	#print(result)
	if result:
		var pos = result.position
		var cell = grid_map.local_to_map(pos)  # conver mouse global pos to a cell position
		var cell_center = grid_map.map_to_local(cell) + Vector3(0, 1, 0)  # slightly above

		var local_pos = grid_map.map_to_local(cell)  # cell position to a local pos ()
		var global_pos = grid_map.to_global(local_pos)
		#var tile_transform = grid_map.get_cell_item_transform(cell.x, cell.y, cell.z)
		highlight.global_transform = Transform3D(grid_map.global_basis, global_pos)
		#highlight.scale.x = grid_map.cell_size.x
		#highlight.scale.z = grid_map.cell_size.z
		#highlight.scale.y = 1
		highlight.visible = true


func _input(event):
	#if event.is_action_pressed("left_click") :
	#print("pressing something")
	#var global_pos = get_viewport().get_mouse_position()
	#var cell_pos = grid_map.local_to_map(global_pos)
	#print("Clicked cell: ", cell_pos)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			clicked = true
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			last_mouse_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			self.size = min(max_zoom, self.size + zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			self.size = max(min_zoom, self.size - zoom_speed)
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position
		var cam_right = self.global_transform.basis.x
		var cam_forward = -self.global_transform.basis.z  # forward in world XZ plane

		var move_dir = cam_right * -delta.x + cam_forward * -delta.y

		translate(move_dir * drag_speed)
