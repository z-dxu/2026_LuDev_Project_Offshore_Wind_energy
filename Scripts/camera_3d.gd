extends Camera3D

@export var drag_speed := 0.05
@export var zoom_speed := 10
@export var max_zoom := 300.0
@export var min_zoom := 50
@export var grid_map: GridMap
@export var highlight: Node3D
@export var min_bounds := Vector3(-50, 0, -50)
@export var max_bounds := Vector3(50, 0, 50)
var dragging := false
var last_mouse_pos := Vector2.ZERO
var hover_poi_button = false
var selected_poi_button = null
var hovered_cell: Vector3i = Vector3i.ZERO
var quest_marker = null

@onready var grid_map_helper: Node3D = $"../GridMapHelper"


func _process(_delta: float) -> void:
	if GameController.allow_highlighter_move:
		var mouse_pos = get_viewport().get_mouse_position()

		# cast ray from camera from where the mouse is currently at
		var from = project_ray_origin(mouse_pos)
		var to = from + project_ray_normal(mouse_pos) * 1000
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		# query.exclude = [self] # exclude self to avoid self-intersection
		query.collide_with_areas = true  # Questmarker
		#query.collision_mask = 2 # gridcells for highlighter
		query.collision_mask = 2 | 28  #Gridmap_helper checks
		var result = space_state.intersect_ray(query)
		if result:
			quest_marker = null
			if result.collider is Area3D:
				var area: Area3D = result.collider
				quest_marker = area.get_parent()  # parent has the script ( the node3d)

			# DEBUG function to show where the cells are by using mouse click
			#var hit_pos = result.position
			#var local_pos_gridmap = grid_map.to_local(hit_pos)
			## convert mouse global pos to a cell position
			#var cell = grid_map.local_to_map(local_pos_gridmap)
			#hovered_cell = cell
			#
			#var poi_button = GameController.poi_positions
			#if cell in poi_button:
			#hover_poi_button = true
			#selected_poi_button = cell
			#else:
			#hover_poi_button = false
			#selected_poi_button = null
			#
			#highlight.position = grid_map.map_to_local(cell) + Vector3(0, 1, 0)
			#highlight.visible = true
			#else:
			#highlight.visible = false


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
			size = min(max_zoom, size + zoom_speed)

		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			size = max(min_zoom, size - zoom_speed)

		elif event.is_action_pressed("left_click"):
			#DEBUG Function to help check what ui element the mouse is clicking on
			#print("hovering on this control: " + str(get_viewport().gui_get_hovered_control()))
			if quest_marker:
				quest_marker.clicked()
				quest_marker = null
			#DEBUG FUNCTION : to help getting the cell vector3i
			#print("Left click at hovered cell: ", hovered_cell)


func camera_movement(event):
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		last_mouse_pos = event.position

		var cam_right = global_transform.basis.x
		var cam_forward = (
			Vector3(-global_transform.basis.z.x, 0, -global_transform.basis.z.z).normalized()
		)

		var move_dir = cam_right * delta.x + cam_forward * -delta.y
		grid_map.translate(move_dir * drag_speed)
		grid_map_helper.translate(move_dir * drag_speed)
		clamp_world_position(grid_map)
		clamp_world_position(grid_map_helper)


func clamp_world_position(node: Node3D):
	var pos = node.global_position

	pos.x = clamp(pos.x, min_bounds.x, max_bounds.x)
	pos.z = clamp(pos.z, min_bounds.z, max_bounds.z)

	node.global_position = pos
