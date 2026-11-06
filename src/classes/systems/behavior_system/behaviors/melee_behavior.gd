extends Behavior
class_name MeleeBehavior
## 近战行为。
##
## [MeleeBehavior] 负责处理拥有 [MeleeComponent] 的实体。


#region 回调函数
func _on_insert(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return true

	for skill: MeleeSkill in melee_c.get_children():
		skill.start_skill_cooldown.connect(_on_skill_cooldown_start.bind(melee_c, skill))

	return true


func _on_remove(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return true

	melee_c.unblock_all_targets(entity)

	return true


func _on_skip(entity: Entity) -> void:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return

	melee_c.unblock_all_targets(entity)


func _on_update(entity: Entity) -> bool:
	var melee_c: MeleeComponent = entity.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if not melee_c:
		return false

	var interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(Constants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	if interact_policy_c:
		if interact_policy_c.config.faction & InteractPolicyComponent.Faction.FRIENDLY:
			melee_c.is_blocker = true
			_search_and_block_targets(entity, melee_c)
		else:
			melee_c.is_blocker = false

	_cleanup_invalid_block_targets(entity, melee_c)
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	var target_ids: PackedInt32Array = melee_c.target_ids
	if target_ids.size() == 0:
		if melee_c.state == MeleeComponent.State.ORIGINAL_POSITION_ARRIVED:
			return false

		return not _go_original_position(entity, melee_c, animated_sprite_c)

	var target: Entity = EntityManager.get_entity_by_id(target_ids[0])
	if not melee_c.config.passive_enabled:
		if melee_c.state == MeleeComponent.State.BLOCK_POSITION_MOVING:
			if not _go_block_position(entity, melee_c, animated_sprite_c):
				return true

	var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
	if target_melee_c.state != MeleeComponent.State.BLOCK_POSITION_ARRIVED:
		entity.facing_global_position = target.global_position
		animated_sprite_c.play_idle_animation(entity)
		return true

	_try_use_melee_skill(entity, melee_c, target, animated_sprite_c)
	return true
#endregion


#region 移动相关
## 前往近战位置。[br][br]
## -> 是否到达拦截位置。
func _go_block_position(entity: Entity, melee_c: MeleeComponent, animated_sprite_c: AnimatedSpriteComponent) -> bool:
	if _move_to_global_position(entity, melee_c, melee_c.block_global_position, animated_sprite_c):
		melee_c.state = MeleeComponent.State.BLOCK_POSITION_ARRIVED
		return true

	return false


## 前往原始位置。[br][br]
## -> 是否到达原始位置。
func _go_original_position(entity: Entity, melee_c: MeleeComponent, animated_sprite_c: AnimatedSpriteComponent) -> bool:
	if _move_to_global_position(entity, melee_c, melee_c.original_global_position, animated_sprite_c):
		melee_c.state = MeleeComponent.State.ORIGINAL_POSITION_ARRIVED
		entity.state = Entity.State.IDLE
		return true

	return false


## 将实体向指定位置移动。[br][br]
## -> 是否到达位置。
func _move_to_global_position(entity: Entity, melee_c: MeleeComponent, to_global_position: Vector2, animated_sprite_c: AnimatedSpriteComponent) -> bool:
	var is_arrived: bool = false
	var direction: Vector2 = entity.global_position.direction_to(to_global_position)
	var velocity: Vector2 = (
		direction
		* melee_c.config.speed
		* TimeManager.frame_length
	)
	var distance_squared: float = entity.global_position.distance_squared_to(to_global_position)
	if velocity.length_squared() > distance_squared:
		velocity = velocity.limit_length(sqrt(distance_squared))
		is_arrived = true

	var next_global_position: Vector2 = entity.global_position + velocity
	entity.facing_global_position = next_global_position
	animated_sprite_c.play_animation(entity, melee_c.config.motion_animation, &"walk")
	entity.global_position = next_global_position
	entity.facing_global_position = next_global_position + velocity

	return is_arrived
#endregion


#region 私有方法
## 搜索并拦截目标。
func _search_and_block_targets(entity: Entity, melee_c: MeleeComponent) -> void:
	var center: Vector2 = entity.global_position
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if rally_c:
		# 为了保证其他相同集结中心点的实体也能够搜索到目标，需要将集结中心点作为搜索中心
		var rally_center_global_position: Vector2 = rally_c.rally_center_global_position
		if rally_center_global_position:
			center = rally_center_global_position

	var melee_c_config: MeleeComponentNodeConfig = melee_c.config
	var common_filter: Callable = func(_target: Entity, target_melee_c: MeleeComponent) -> bool:
		# 双方都是被动实体时拦截没有意义
		if melee_c_config.passive_enabled and target_melee_c.config.passive_enabled:
			return false

		return true
	var targets: Array[Entity] = []
	if melee_c.is_extra_blocker:
		# 额外拦截者拦截的是已被拦截的目标，优先级低，如果搜索到未被拦截的目标，需要前往拦截
		targets = melee_c_config.searcher.search_targets(
			center,
			entity,
			func(target: Entity) -> bool:
				var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
				if not target_melee_c:
					return false

				if target_melee_c.target_count > 0:
					return false

				return common_filter.call(target, target_melee_c)
		)
		if targets.size() > 0:
			melee_c.is_extra_blocker = false
			melee_c.unblock_all_targets(entity)
	elif melee_c.target_count < melee_c.config.max_target_count:
		targets = melee_c_config.searcher.search_targets(
			center,
			entity,
			func(target: Entity) -> bool:
				var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
				if not target_melee_c:
					return false

				return common_filter.call(target, target_melee_c)
		)

	if targets.size() == 0:
		return

	_block_targets(entity, melee_c, targets)


## 清理无效拦截目标。
func _cleanup_invalid_block_targets(entity: Entity, melee_c: MeleeComponent) -> void:
	var new_target_ids := PackedInt32Array()
	var target_count: int = 0
	var is_stop: bool = false
	for target_id: int in melee_c.target_ids:
		var target: Entity = EntityManager.get_entity_by_id(target_id)
		if is_stop:
			melee_c.unblock_target(entity, target)
			continue

		if not target:
			melee_c.unblock_target(entity, target)
			continue

		if not target.state & Entity.State.MELEE:
			melee_c.unblock_target(entity, target)
			continue

		var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)

		var search_flag: int = melee_c.config.searcher.search_flag if melee_c.is_blocker else target_melee_c.config.searcher.search_flag
		if search_flag & Searcher.SearchFlag.SKIP_DEAD and target.state & Entity.State.DEAD:
			melee_c.unblock_target(entity, target)
			continue

		new_target_ids.append(target_id)
		target_count += target_melee_c.config.block_cost
		if target_count >= melee_c.config.max_target_count:
			is_stop = true

	melee_c.target_ids = new_target_ids
	melee_c.target_count = target_count


## 拦截目标。
func _block_targets(entity: Entity, melee_c: MeleeComponent, targets: Array[Entity]) -> void:
	var melee_c_config: MeleeComponentNodeConfig = melee_c.config
	for target: Entity in targets:
		var target_melee_c: MeleeComponent = target.get_node_or_null(Constants.MELEE_COMPONENT_NODE_PATH)
		var target_melee_c_config: MeleeComponentNodeConfig = target_melee_c.config
		var block_global_position: Vector2 = melee_c.block_global_position
		if melee_c.target_count == 0:
			if target_melee_c.target_count == 0:
				if melee_c_config.passive_enabled:
					block_global_position = entity.global_position
				elif target_melee_c_config.passive_enabled:
					block_global_position = target.global_position
				else:
					var vector_difference: Vector2 = target.global_position - entity.global_position
					var speed_ratio: float = melee_c_config.speed / (melee_c_config.speed + target_melee_c_config.speed)
					block_global_position = entity.global_position + vector_difference.limit_length(vector_difference.length() * speed_ratio)
			else:
				block_global_position = target_melee_c.block_global_position
				if melee_c_config.block_position_offsets:
					block_global_position += melee_c_config.block_position_offsets.get_offset_toward_point(
						block_global_position, entity.global_position
					)
				melee_c.is_extra_blocker = true

			_set_move_state(entity, melee_c, block_global_position)
			melee_c.queue_redraw()
		else:
			if target_melee_c.target_count > 0:
				continue

			# 其他非第一个拦截目标都必须前往拦截位置，被动实体不会前往拦截位置，直接跳过
			if target_melee_c_config.passive_enabled:
				continue

		melee_c.block_target(entity, target)
		var target_block_global_position: Vector2 = block_global_position
		if target_melee_c_config.block_position_offsets:
			target_block_global_position += target_melee_c_config.block_position_offsets.get_offset_toward_point(
				block_global_position, target.global_position
			)
		if not melee_c.is_extra_blocker:
			_set_move_state(
				target,
				target_melee_c,
				target_block_global_position
			)
			target_melee_c.queue_redraw()
		if melee_c.target_count >= melee_c_config.max_target_count:
			break


## 设置移动状态。
func _set_move_state(entity: Entity, melee_c: MeleeComponent, block_global_position: Vector2) -> void:
	melee_c.block_global_position = block_global_position
	if melee_c.config.passive_enabled:
		melee_c.state = MeleeComponent.State.BLOCK_POSITION_ARRIVED
		return

	if melee_c.state == MeleeComponent.State.ORIGINAL_POSITION_ARRIVED:
		melee_c.original_global_position = entity.global_position
	melee_c.state = MeleeComponent.State.BLOCK_POSITION_MOVING


## 尝试释放近战技能。
func _try_use_melee_skill(
		entity: Entity, melee_c: MeleeComponent, target: Entity, animated_sprite_c: AnimatedSpriteComponent
	) -> void:
	entity.facing_global_position = target.global_position
	animated_sprite_c.play_idle_animation(entity)

	for skill: MeleeSkill in melee_c.get_children():
		if not skill.can_use(entity, skill.config, target):
			continue

		skill.use_skill(entity, target)
		melee_c.melee_skill_used.emit(skill)
		break
#endregion


func _on_skill_cooldown_start(melee_c: MeleeComponent, skill: MeleeSkill) -> void:
	melee_c.start_melee_skill_cooldown.emit(skill)
