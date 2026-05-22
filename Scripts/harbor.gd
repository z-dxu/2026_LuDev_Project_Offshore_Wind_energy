extends Node
const WATER_ID = 56
@export var ship: Node3D
@export var speed = 25
var astar: AStarGrid2D = AStarGrid2D.new()
var gridmap: GridMap = null
var path: Array[Vector2i] = []
var path_index: int = 0
var going_back = false
var last_cell: Vector2i = Vector2i.ZERO
var last_direction = Vector3i.ZERO
var target_basis: Basis
var harbor_pos_list = []
var fade_animation = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gridmap = get_parent().get_parent()

	setup_astar()
	set_walkable_paths()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if path.is_empty() or fade_animation:
		return
	#looping
	if path_index >= path.size():
		path_index = path.size() - 1
		going_back = true
	elif path_index < 0:
		path_index = 0
		going_back = false

	# path for the ship
	var target_cell = path[path_index]
	var target_pos = to_world(target_cell)

	var move_dir = target_pos - ship.global_position
	if move_dir.length() > 0.01:
		target_basis = Basis.looking_at(move_dir.normalized(), Vector3.UP)

	var scale = ship.scale
	ship.basis = ship.basis.orthonormalized()
	ship.basis = ship.basis.slerp(target_basis, speed * delta)
	ship.scale = scale

	ship.global_position = ship.global_position.move_toward(target_pos, speed * delta)
	#check if ship reached a position.

	if ship.global_position.distance_to(target_pos) < 10:
		if target_cell in harbor_pos_list:  # arrived at a habor
			last_cell = target_cell
			path_index += 1
			if path_index >= path.size():
				path_index = 1
			handle_ship_arrival()
		if ship.global_position.distance_to(target_pos) < 0.1:
			last_cell = target_cell
			path_index += 1
			if path_index >= path.size():
				path_index = 1


func setup_astar():
	astar.region = get_grid_bounds()
	astar.cell_size = Vector2(1, 1)
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar.update()


func set_walkable_paths():
	for x in range(astar.region.position.x, astar.region.end.x):
		for z in range(astar.region.position.y, astar.region.end.y):
			var cell3d = Vector3i(x, 0, z)
			var item = gridmap.get_cell_item(cell3d)
			if not int(item) == WATER_ID:  # everything not water is not pathable
				astar.set_point_solid(Vector2i(x, z), true)


func go_to(target_cell: Vector3i):
	var local_pos = gridmap.to_local(ship.global_position)
	var start_3d = gridmap.local_to_map(local_pos)
	var start = to_astar(start_3d)
	var end = to_astar(target_cell)
	path = astar.get_id_path(start, end)
	path_index = 0


func append_path(start_cell: Vector3i, target_cell: Vector3i):
	var start = to_astar(start_cell)
	var end = to_astar(target_cell)
	if start not in harbor_pos_list:
		harbor_pos_list.append(start)
	var extra_path = astar.get_id_path(start, end)
	if not extra_path.is_empty():
		extra_path.remove_at(0)  # prevent going inside start tile
	path.append_array(extra_path)


func get_grid_bounds():
	var cells = gridmap.get_used_cells()
	if cells.is_empty():
		return Rect2i(Vector2i.ZERO, Vector2i(1, 1))
	var min_x = cells[0].x
	var max_x = cells[0].x
	var min_z = cells[0].z
	var max_z = cells[0].z

	for c in cells:
		min_x = min(min_x, c.x)
		max_x = max(max_x, c.x)
		min_z = min(min_z, c.z)
		max_z = max(max_z, c.z)
	var size = Vector2i(max_x - min_x + 1, max_z - min_z + 1)
	return Rect2i(Vector2i(min_x, min_z), size)


func to_astar(cell: Vector3i):
	return Vector2i(cell.x, cell.z)


func to_world(cell: Vector2i):
	var ship_offset = Vector3(4, 0, -2)  # fit in grid cel
	var pos = gridmap.to_global(gridmap.map_to_local(Vector3i(cell.x, 0, cell.y)) + ship_offset)

	pos.y = ship.global_position.y
	return pos


func set_ship(ref_ship):
	ship = ref_ship
	target_basis = ship.basis


# Handle Ship arrivals / leaving
func handle_ship_arrival():
	fade_animation = true
	ship.visible = false
	await get_tree().create_timer(1).timeout
	ship.visible = true
	fade_animation = false
