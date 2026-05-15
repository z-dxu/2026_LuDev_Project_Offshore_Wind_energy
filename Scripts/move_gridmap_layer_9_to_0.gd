@tool
extends EditorScript


func _run():
	var grid_map := get_scene().get_node("GridMap") as GridMap

	for cell in grid_map.get_used_cells():
		if cell.y == 9:
			var item := grid_map.get_cell_item(cell)
			var orientation := grid_map.get_cell_item_orientation(cell)
			var target := Vector3i(cell.x, 0, cell.z)

			grid_map.set_cell_item(target, item, orientation)
			grid_map.set_cell_item(cell, GridMap.INVALID_CELL_ITEM)

	print("Moved GridMap cells from layer 9 to layer 0")
