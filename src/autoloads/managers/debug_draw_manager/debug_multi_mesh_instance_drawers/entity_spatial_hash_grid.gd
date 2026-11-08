@tool
extends DebugMultiMeshInstanceDrawer


func ready() -> void:
	var cell_count: int = EntitySpatialHashManager.grid.size()

	var multi_mesh = multi_mesh_instance.multimesh
	multi_mesh.instance_count = cell_count

	var quad_mesh: QuadMesh = multi_mesh.mesh
	var cell_size: int = EntitySpatialHashManager.cell_size
	quad_mesh.size = Vector2(cell_size, cell_size)

	for cell_index: int in cell_count:
		var grid_position: Vector2i = EntitySpatialHashManager.cell_index_to_grid_position(cell_index)
		var instance_global_position := Vector2(
			grid_position.x * cell_size + cell_size / 2.0,
			grid_position.y * cell_size + cell_size / 2.0
		)
		var instance_transform := Transform2D(0, to_local(instance_global_position))
		multi_mesh.set_instance_transform_2d(cell_index, instance_transform)
		var h: float = 0.0
		if grid_position.y % 2:
			if grid_position.x % 2:
				h = 0.33
		else:
			if not grid_position.x % 2:
				h = 0.33
		var color := Color.from_hsv(h, 0.8, 0.8, 0.5)
		multi_mesh.set_instance_color(cell_index, color)
