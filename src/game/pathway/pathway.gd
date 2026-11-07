#@tool
extends Path2D
class_name Pathway
## 路径。


## 是否禁用当前路径。
@export var disabled: bool = false

## 路径索引。
var index: int = Constants.UNSET
## 子路径数组。
var sub_pathways: Array[SubPathway] = []


func _ready() -> void:
	_create_sub_pathways()
	PathwayManager.insert_pathway(self)
	

#region 私有方法
## 创建子路径。
func _create_sub_pathways() -> void:
	var sub_pathway_count: int = PathwayManager.sub_pathway_count
	var sub_pathway_spacing: float = PathwayManager.sub_pathway_spacing
	var half_total_spacing: float = (sub_pathway_count - 1) * sub_pathway_spacing / 2

	for sub_pathway_index: int in sub_pathway_count:
		var sub_pathway := SubPathway.new()
		var follow := PathFollow2D.new()
		follow.loop = false
		sub_pathway.add_child(follow)
		sub_pathway.follow = follow
		sub_pathway.curve = _create_offset_curve(half_total_spacing - (sub_pathway_spacing * sub_pathway_index))
		sub_pathway.length = sub_pathway.curve.get_baked_length()
		sub_pathway.pathway_index = index
		sub_pathway.index = sub_pathway_index
		sub_pathway.nodes = _get_equally_spaced_nodes(sub_pathway)

		sub_pathways.append(sub_pathway)
		add_child(sub_pathway)


## 创建偏移曲线
func _create_offset_curve(offset: float) -> Curve2D:
	var new_curve := Curve2D.new()
	var curve_length: float = curve.get_baked_length()
	var sample_step: float = 2.0
	var sample_count: int = maxi(2, int(curve_length / sample_step) + 1)
	var end_sample_index: int = sample_count - 1

	for sample_index: int in sample_count:
		var distance: float = curve_length if sample_index == end_sample_index else sample_index * sample_step
		var sample_transform: Transform2D = curve.sample_baked_with_rotation(distance, true)
		var offset_point: Vector2 = sample_transform.origin + sample_transform.y * offset
		new_curve.add_point(offset_point)

	return new_curve


## 获取等距的节点列表
func _get_equally_spaced_nodes(sub_pathway: SubPathway) -> Array[PathwayNode]:
	var nodes_list: Array[PathwayNode] = []
	var point_spacing: float = sub_pathway.length / (PathwayManager.sub_pathway_node_count - 1)
	
	for node_index: int in PathwayManager.sub_pathway_node_count:
		var distance: float = node_index * point_spacing
		
		var node := PathwayNode.new()
		node.pathway_index = sub_pathway.pathway_index
		node.sub_pathway_index = sub_pathway.index
		node.index = node_index
		node.global_position = to_global(sub_pathway.curve.sample_baked(distance))
		node.ratio = clampf(distance / sub_pathway.length, 0, 1)
		node.progress = distance
		nodes_list.append(node)

		PathwayManager.all_nodes.append(node)
	
	return nodes_list
#endregion
