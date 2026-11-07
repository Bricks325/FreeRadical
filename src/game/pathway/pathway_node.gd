extends Resource
class_name PathwayNode
## 路径节点资源。
##
## [PathwayNode] 用于表示 [Pathway] 上的一个子路径的节点。


## 路径索引。
var pathway_index: int
## 子路径索引。
var sub_pathway_index: int
## 路径节点索引。
var index: int
## 节点全局位置。	
var global_position: Vector2
## 位于的路径比率。
var ratio: float
## 位于的路径位置。
var progress: float
## 距离平方。
var dist_squared: float
## 与另一个路径相交的节点索引列表。
var intersecting_node_index_list: Array[int] = []


#region 公开方法
## [method PathwayManager.get_subpath] 的简写，已传递 [param pi], [param spi]
func get_subpath() -> Path2D:
	return PathwayManager.get_subpath(pathway_index, sub_pathway_index)


## [method PathwayManager.calculate_progress_ratio] 的简写，已传递 [param pi], [param spi]
func calculate_progress_ratio(p_progress: float = -1.0) -> float:
	if p_progress == -1.0:
		p_progress = progress
	return PathwayManager.calculate_progress_ratio(pathway_index, sub_pathway_index, p_progress)
	

## [method PathwayManager.get_ratio_global_position] 的简写，已传递 [param pi], [param spi]
func get_ratio_global_position(p_ratio: float = -1.0) -> Vector2:
	if p_ratio == -1.0:
		p_ratio = ratio
	return PathwayManager.get_ratio_global_position(pathway_index, sub_pathway_index, p_ratio)
	

## [method PathwayManager.get_progress_global_position] 的简写，已传递 [param pi], [param spi]
func get_progress_global_position(p_progress: float = -1.0) -> Vector2:
	if p_progress == -1.0:
		p_progress = progress
	return PathwayManager.get_progress_global_position(pathway_index, sub_pathway_index, p_progress)


## [method PathwayManager.get_progress_by_ratio] 的简写，已传递 [param pi], [param spi]
func get_progress_by_ratio(p_ratio: float = -1.0) -> float:
	if p_ratio == -1.0:
		p_ratio = ratio
	return PathwayManager.get_progress_by_ratio(pathway_index, sub_pathway_index, p_ratio)


## [method PathwayManager.get_pathway_node] 的简写，已传递 [param pathway_index], [param sub_pathway_index]
func get_pathway_node(p_index: int = -1) -> PathwayNode:
	if p_index == -1:
		p_index = index
	return PathwayManager.get_pathway_node(pathway_index, sub_pathway_index, p_index)
#endregion
