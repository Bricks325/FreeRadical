@tool
@icon("res://assets/dpi_textures/at-icons/node2d/sword.svg")
extends Component
class_name MeleeComponent
## 近战组件
##
## [MeleeComponent] 可以让实体可以拦截目标然后使用 [MeleeSkill] 攻击被拦截的目标，近战技能以子节点的形式存在。[br][br]
##


@warning_ignore_start("unused_signal")
## 近战技能释放后发出。
signal melee_skill_used(skill: MeleeSkill)
## 近战技能冷却后发出。
signal start_melee_skill_cooldown(skill: MeleeSkill)
@warning_ignore_restore("unused_signal")


## 状态枚举。
enum State {
	## 状态：已到达原始位置。
	ORIGINAL_POSITION_ARRIVED,
	## 状态：返回原始位置中。
	ORIGINAL_POSITION_MOVING,
	## 状态：已到达拦截位置。
	BLOCK_POSITION_ARRIVED,
	## 状态：前往拦截位置中。
	BLOCK_POSITION_MOVING,
}


#region 属性
@export var config: MeleeComponentNodeConfig:
	set(v):
		SignalUtils.reconnect_resource_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 是否是拦截者。
var is_blocker: bool = false
## 状态。
var state: State = State.ORIGINAL_POSITION_ARRIVED
## 被拦截的目标数量，包含拦截成本。
var target_count: int
## 被拦截的目标 ID 列表。
var target_ids: PackedInt32Array
## 原始全局位置。
var original_global_position: Vector2
## 拦截全局位置。
var block_global_position: Vector2
## 是否额外拦截者。
var is_extra_blocker: bool = false
#endregion


func _draw() -> void:
	if not config:
		return

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.RANGE):
		if config.searcher:
			config.searcher.draw_search_range(self, position)

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.OFFSET):
		if config.block_position_offsets:
			config.block_position_offsets.draw_offset_group(self)

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.POINT):
		if block_global_position:
			var original_position: Vector2 = to_local(original_global_position)
			var block_position: Vector2 = to_local(block_global_position)
			draw_circle(
				original_position,
				9,
				Color.RED,
				true
			)
			draw_circle(
				block_position,
				9,
				Color.RED,
				true
			)
			draw_dashed_line(
				original_position,
				block_position,
				Color.RED,
				2
			)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not get_children():
		warnings.append("请至少增加一个 MeleeSkill 或其类型的子节点，否则实体无法释放近战技能。")

	return warnings


## 拦截目标。
func block_target(entity: Entity, target: Entity) -> void:
	var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	var target_melee_c_config: MeleeComponentNodeConfig = target_melee_c.config
	target_melee_c.target_ids.append(entity.id)
	target_melee_c.target_count += config.block_cost
	target.state = Entity.State.MELEE

	target_ids.append(target.id)
	target_count += target_melee_c_config.block_cost
	entity.state = Entity.State.MELEE


## 单向解除拦截目标。
func unblock_target(entity: Entity, target: Entity) -> void:
	var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	target_melee_c.target_ids.erase(entity.id)
	target_melee_c.target_count -= config.block_cost


## 解除双方拦截的目标。
func unblock_target_both(entity: Entity, target: Entity) -> void:
	var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	unblock_target(entity, target)

	target_ids.erase(target.id)
	target_count -= target_melee_c.config.block_cost


## 解除所有拦截目标。
func unblock_all_targets(entity: Entity) -> void:
	for target_id: int in target_ids:
		var target: Entity = EntityManager.get_entity_by_id(target_id)
		var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		target_melee_c.target_ids.erase(entity.id)
		target_melee_c.target_count -= config.block_cost

	target_ids.clear()
	target_count = 0
	state = State.ORIGINAL_POSITION_MOVING
