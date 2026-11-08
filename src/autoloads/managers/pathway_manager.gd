extends Node
## 路径管理器。
## 
## [PathwayManager] 负责管理路径与相关操作。


## 所有路径上的节点列表。
var all_nodes: Array[PathwayNode] = []
## 子路径总数量。
var sub_pathway_count: int = 5
## 子路径间距。
var sub_pathway_spacing: float = 20.0
## 一条子路径的节点数量。
var sub_pathway_node_count: int = 256
## 路径节点相交距离阈值。
var intersect_dist_threshold: float = 10.0
## 路径列表。
var _pathways: Array[Pathway] = []
## 下一个路径索引。
var _next_pathway_index: int = 0


## 清理路径管理器。
func cleanup() -> void:
	all_nodes.clear()
	_pathways.clear()
	_next_pathway_index = 0
	
	
## 插入路径。
func insert_pathway(pathway: Pathway) -> void:
	pathway.index = _next_pathway_index
	_next_pathway_index += 1
	_pathways.append(pathway)


## 获取路径数量。
func get_pathway_count() -> int:
	return _pathways.size()


## 获取指定索引的路径。
func get_pathway(pathway_index: int) -> Pathway:
	return _pathways[pathway_index]


## 获取指定索引的子路径。
func get_sub_pathway(pathway_index: int, sub_pathway_index: int) -> SubPathway:
	var pathway: Pathway = _pathways[pathway_index]
	return pathway.sub_pathways[sub_pathway_index]


## 获取指定索引的节点。
func get_pathway_node(pathway_index: int, sub_pathway_index: int, index: int) -> PathwayNode:
	var pathway: Pathway = _pathways[pathway_index]
	var sub_pathway: SubPathway = pathway.sub_pathways[sub_pathway_index]
	return sub_pathway.nodes[index]
	

## 获取中间的子路径索引。
func get_middle_sub_pathway_index() -> int:
	return roundi(sub_pathway_count / 2.0)


## 获取启用的路径。
func get_enabled_pathways() -> Array[Pathway]:
	return _pathways.filter(func(pathway: Pathway): return not pathway.disabled)


## 获取随机路径。
func get_random_pathway() -> Pathway:
	return _pathways.pick_random()


## 获取随机路径索引。
func get_random_pathway_index() -> int:
	return randi_range(0, get_pathway_count() - 1)


## 获取指定路径上的随机子路径索引。[br][br]
## [param pathway_index]: 路径索引。路径索引为 -1 时获取随机路径。
func get_random_sub_pathway(pathway_index: int = -1) -> SubPathway:
	if pathway_index == -1:
		pathway_index = get_random_pathway_index()

	var pathway: Pathway = _pathways[pathway_index]
	return pathway.sub_pathways.pick_random()


## 根据路程计算路程比率。
func calculate_progress_ratio(pathway_index: int, sub_pathway_index: int, progress: float) -> float:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
	var delta: float = progress / sub_pathway.length
	return clampf(delta, 0, 1)
	

## 获取指定路径比率上的全局位置。
func get_ratio_global_position(pathway_index: int, sub_pathway_index: int, ratio: float) -> Vector2:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)	
	var path_follow: PathFollow2D = sub_pathway.follow
	path_follow.progress_ratio = ratio
	
	return path_follow.global_position


## 根据路程比率获取路程。
func get_progress_by_ratio(pathway_index: int, sub_pathway_index: int, ratio: float) -> float:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)	
	return sub_pathway.length * ratio
	

## 获取指定路程上的全局位置。
func get_progress_global_position(pathway_index: int, sub_pathway_index: int, progress: float) -> Vector2:
	var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
	var path_follow: PathFollow2D = sub_pathway.follow
		
	path_follow.progress = progress
	return path_follow.global_position
	

## 预判目标全局位置。
func predict_target_global_position(target: Entity, predict_time: float) -> Vector2:
	var predicted_global_position: Vector2 = target.global_position

	var nav_path_c: NavPathComponent = target.get_node_or_null(Constants.NAV_PATH_COMPONENT_NODE_PATH)
	if nav_path_c and target.state & Entity.State.NAV_PATH_WALK:
		var progress: float = nav_path_c.progress
		var walk_lenth: float = nav_path_c.config.speed * predict_time
		
		if nav_path_c.config.reversed_enabled:
			progress -= walk_lenth
		else:
			progress += walk_lenth
	
		predicted_global_position = nav_path_c.get_progress_global_position(
			progress
		)
	
	return predicted_global_position
	

## 获取指定路径上按距离排序的节点列表。[br][br]
## [param pathway_indexes]: 路径索引列表。默认搜索所有路径。[br]
## [param sub_pathway_indexes]: 子路径索引列表。默认搜索所有子路径。[br]
## [param only_valid]: 是否只搜索已启用的路径。[br][br]
## [b]注意[/b]: 如果只需要一个最近的节点，为了性能请使用 [method find_nearest_node_at_global_position]。
func find_nearest_nodes_at_global_position(
		search_global_position: Vector2, 
		pathway_indexes: Array, 
		sub_pathway_indexes: Array = [],
		only_valid: bool = true
	) -> Array[PathwayNode]:
	if pathway_indexes.is_empty():
		pathway_indexes = range(get_pathway_count())

	if sub_pathway_indexes.is_empty():
		sub_pathway_indexes = range(sub_pathway_count)

	var nodes: Array[PathwayNode] = []
	for pathway_index: int in pathway_indexes:
		if only_valid and get_pathway(pathway_index).is_disabled():
			continue

		for sub_pathway_index: int in sub_pathway_indexes:
			var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
			for node: PathwayNode in sub_pathway.nodes:
				node.dist_squared = node.global_position.distance_squared_to(search_global_position)
				nodes.append(node)

	nodes.sort_custom(
		func(p1: PathwayNode, p2: PathwayNode): 
			return p1.dist_squared < p2.dist_squared
	)
	return nodes
	

## 获取全局位置上最近的路径上的一个节点。[br][br]
## [param pathway_indexes]: 路径索引列表。默认搜索所有路径。[br]
## [param sub_pathway_indexes]: 子路径索引列表。默认搜索所有子路径。[br]
## [param only_valid]: 是否只搜索已启用的路径。[br][br]
## 如果只需要多个最近的节点，请使用 [method find_nearest_nodes_at_global_position]。
func find_nearest_node_at_global_position(
		search_global_position: Vector2, 
		pathway_indexes: Array = [], 
		sub_pathway_indexes: Array = [],
		only_valid: bool = true
	) -> PathwayNode:
	if pathway_indexes.is_empty():
		pathway_indexes = range(get_pathway_count())

	if sub_pathway_indexes.is_empty():
		sub_pathway_indexes = range(sub_pathway_count)

	var nearest_node: PathwayNode = null
	for pathway_index: int in pathway_indexes:
		if only_valid and get_pathway(pathway_index).is_disabled():
			continue
		
		for sub_pathway_index: int in sub_pathway_indexes:
			var sub_pathway: SubPathway = get_sub_pathway(pathway_index, sub_pathway_index)
			for node: PathwayNode in sub_pathway.node_list:
				var dist_squared: float = node.global_position.distance_squared_to(search_global_position)
				node.dist_squared = dist_squared
				if (
					not nearest_node
					or dist_squared < nearest_node.dist_squared
				):
					nearest_node = node

	return nearest_node
