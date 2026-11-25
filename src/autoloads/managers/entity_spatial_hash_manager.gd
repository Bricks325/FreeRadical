extends Node
## 实体空间哈希管理器。
##
## [EntitySpatialHashManager] 用于通过实体坐标快速查找实体。


#region 属性
## 空间哈希的网格大小。
var cell_size: int = 100
## 空间哈希的网格最大行数。
var grid_max_x: int = 26
## 空间哈希的网格最大列数。
var grid_max_y: int = 15
## 空间哈希网格。
var grid: Array[SpaceIndexCell] = []
#endregion


func _physics_process(_delta: float) -> void:
	_grouping_entities()


#region 公开方法
## 初始化实体空间哈希管理器。
func init() -> void:
	var cell_count: int = grid_max_x * grid_max_y
	grid.resize(cell_count)
	for cell_index: int in cell_count:
		grid[cell_index] = SpaceIndexCell.new()


## 清理实体空间哈希管理器，这通常用于清除实体空间哈希管理器中的所有引用。
func cleanup() -> void:
	grid.clear()


## 全局位置转换单元格索引，见 [method grid_position_to_cell_index] 。
func global_position_to_cell_index(global_position: Vector2) -> int:
	var grid_x: int = floori(global_position.x / cell_size)
	var grid_y: int = floori(global_position.y / cell_size)

	return grid_position_to_cell_index(grid_x, grid_y)


## 网格坐标转换单元格索引。
func grid_position_to_cell_index(grid_x: int, grid_y: int) -> int:
	return grid_y * grid_max_x + grid_x


## 单元格索引转换单元格网格坐标。
func cell_index_to_grid_position(index: int) -> Vector2i:
	var grid_x: int = index % grid_max_x
	var grid_y: int = floori(float(index) / grid_max_x)
	return Vector2i(grid_x, grid_y)


## 根据单元格索引获取单元格。如果单元格不存在则返回 [code]null[/code]。
func get_cell_by_index(index: int) -> SpaceIndexCell:
	if index < 0 or index >= grid.size():
		return null

	return grid.get(index)


## 根据全局位置获取单元格。如果单元格不存在则返回 [code]null[/code]，见 [method get_cell_by_index] 。
func get_cell_by_global_position(global_position: Vector2) -> SpaceIndexCell:
	var cell_index: int = global_position_to_cell_index(global_position)
	return get_cell_by_index(cell_index)


## 根据网格坐标获取单元格。如果单元格不存在则返回 [code]null[/code]，见 [method get_cell_by_index] 。
func get_cell_by_grid_position(grid_x: int, grid_y: int) -> SpaceIndexCell:
	var cell_index: int = grid_position_to_cell_index(grid_x, grid_y)
	return get_cell_by_index(cell_index)


## 通过空间哈希网格搜索椭圆环范围内目标。
func search_entities_in_elliptical_annulus(
		search_global_position: Vector2,
		outer_radius: float,
		inner_radius: float,
		faction: InteractPolicyComponent.Faction,
		entity_type: InteractPolicyComponent.EntityType,
		aspect: float = 0.7
	) -> Array[Entity]:
	var entities: Array[Entity] = []

	var range_min_x: int = max(0, floori((search_global_position.x - outer_radius) / cell_size))
	var range_max_x: int = ceili((search_global_position.x + outer_radius) / cell_size)
	var range_min_y: int = max(0, floori((search_global_position.y - outer_radius) / cell_size))
	var range_max_y: int = ceili((search_global_position.y + outer_radius) / cell_size)

	for grid_x: int in range(range_min_x, range_max_x + 1):
		for grid_y: int in range(range_min_y, range_max_y + 1):
			var cell: SpaceIndexCell = get_cell_by_grid_position(grid_x, grid_y)
			if not cell:
				continue

			var pending_entities: Array[Entity] = cell.get_entity_group(faction, entity_type)
			for entity: Entity in pending_entities:
				if not MathUtils.is_in_elliptical_annulus(search_global_position, entity.global_position, outer_radius, inner_radius, aspect):
					continue
					
				entities.append(entity)

	return entities


## 通过空间哈希网格搜索椭圆环范围内目标。[br][br]
## [param filter]: 过滤函数。返回 [code]false[/code] 表示被过滤。[br][br]
## 与 [method EntityManager.search_entities_in_elliptical_annulus] 不同的是，支持过滤函数。
func search_entities_in_elliptical_annulus_filtered(
		search_global_position: Vector2,
		outer_radius: float,
		inner_radius: float,
		faction: InteractPolicyComponent.Faction,
		entity_type: InteractPolicyComponent.EntityType,
		filter := Callable(),
		aspect: float = 0.7
	) -> Array[Entity]:
	var entities: Array[Entity] = []

	var range_min_x: int = max(0, floori((search_global_position.x - outer_radius) / cell_size))
	var range_max_x: int = ceili((search_global_position.x + outer_radius) / cell_size)
	var range_min_y: int = max(0, floori((search_global_position.y - outer_radius) / cell_size))
	var range_max_y: int = ceili((search_global_position.y + outer_radius) / cell_size)

	for grid_x: int in range(range_min_x, range_max_x + 1):
		for grid_y: int in range(range_min_y, range_max_y + 1):
			var cell: SpaceIndexCell = get_cell_by_grid_position(grid_x, grid_y)
			if not cell:
				continue

			var pending_entities: Array[Entity] = cell.get_entity_group(faction, entity_type)
			for entity: Entity in pending_entities:
				if not MathUtils.is_in_elliptical_annulus(search_global_position, entity.global_position, outer_radius, inner_radius, aspect):
					continue
					
				if not filter.call(entity):
					continue
					
				entities.append(entity)

	return entities
#endregion


#region 私有方法
## 分组实体。
func _grouping_entities() -> void:
	for cell: SpaceIndexCell in grid:
		cell.clear()

	for entity: Entity in EntityManager.get_valid_entities():
		var cell: SpaceIndexCell = get_cell_by_global_position(entity.global_position)
		if not cell:
			continue
		
		var interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(StringConstants.INTERACT_POLICY_COMPONENT_NODE_PATH)
		if not interact_policy_c:
			continue
		
		var interact_policy_c_config: InteractPolicyComponentNodeConfig = interact_policy_c.config
		var interact_policy_c_config_entity_type: InteractPolicyComponent.EntityType = interact_policy_c_config.entity_type
		for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
			if not entity_type & interact_policy_c_config_entity_type:
				continue

			var group_key: int = interact_policy_c_config.faction << Constants.INT64_LEN_HALF | entity_type
			cell.entity_groups[group_key].append(entity)
#endregion


#region 类
## 空间哈希网格单元。
class SpaceIndexCell extends RefCounted:
	## 网格内的实体组。
	var entity_groups: Dictionary[int, Array] = {}

	func _init() -> void:
		for faction: InteractPolicyComponent.Faction in InteractPolicyComponent.Faction.values():
			var shifted_faction: int = faction << Constants.INT64_LEN_HALF
			for entity_type: InteractPolicyComponent.EntityType in InteractPolicyComponent.EntityType.values():
				var entity_group: Array[Entity] = []
				entity_groups[shifted_faction | entity_type] = entity_group

	func get_entity_group(faction: InteractPolicyComponent.Faction, entity_type: InteractPolicyComponent.EntityType) -> Array[Entity]:
		var group_key: int = faction << Constants.INT64_LEN_HALF | entity_type
		return entity_groups[group_key]

	func clear() -> void:
		for entity_group: Array[Entity] in entity_groups.values():
			entity_group.clear()
#endregion
