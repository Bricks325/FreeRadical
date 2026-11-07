extends DebugMultiMeshInstanceDrawer


func ready() -> void:
	var node_total_count: int = PathwayManager.all_nodes.size()
	var multi_mesh: MultiMesh = multi_mesh_instance.multimesh
	multi_mesh.instance_count = node_total_count
	
	for i: int in node_total_count:
		var node: PathwayNode = PathwayManager.all_nodes[i]
		var instance_transform := Transform2D(0, to_local(node.global_position))
		var color := Color.from_hsv(fmod(node.pathway_index * 0.1, 1.0), 1.0, 1.0)
		multi_mesh.set_instance_transform_2d(i, instance_transform)
		multi_mesh.set_instance_color(i, color)
