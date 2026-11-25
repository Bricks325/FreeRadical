extends Behavior
class_name BarrackBehavior
## 兵营行为。
##
## [BarrackBehavior] 负责处理拥有 [BarrackComponent] 的实体。


func _on_insert(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(StringConstants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return true

	var barrack_record: BarrackRecord = barrack.get_node_or_null(StringConstants.BARRACK_RECORD_NODE_PATH)
	if not barrack_record.rally_center_global_position:
		barrack_record.rally_center_global_position = barrack.to_global(barrack_record.default_rally_center_position)

	_spawn_all_soldiers(barrack, barrack_c, barrack_record)

	return true


func _on_remove(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(StringConstants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return true

	var barrack_record: BarrackRecord = barrack.get_node_or_null(StringConstants.BARRACK_RECORD_NODE_PATH)
	var soldier_ids: PackedInt32Array = barrack_record.soldier_ids
	for soldier_id: int in soldier_ids:
		var soldier: Entity = EntityManager.get_entity_by_id(soldier_id)
		EntityManager.queue_remove_entity(soldier)

	return true


func _on_update(barrack: Entity) -> bool:
	var barrack_c: BarrackComponent = barrack.get_node_or_null(StringConstants.BARRACK_COMPONENT_NODE_PATH)
	if not barrack_c:
		return false

	if barrack_c.config.disabled:
		return false

	var barrack_record: BarrackRecord = barrack.get_node_or_null(StringConstants.BARRACK_RECORD_NODE_PATH)
	if TimeManager.has_elapsed(barrack_c.spawn_timestamp, barrack_c.config.spawn_interval):
		_spawn_by_time(barrack, barrack_c, barrack_record)
		return true

	return false


## 创建士兵。
func _create_soldier(
		barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord
	) -> Entity:
	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	var soldier: Entity = EntityManager.create_entity(barrack_c_config.soldier_scene)
	soldier.source_id = barrack.id
	soldier.source_type = Entity.SourceType.BARRACK_SOLDIER
	soldier.entity_removing.connect(_on_soldier_removing.bind(soldier, barrack_c, barrack_record))

	var barrack_global_position: Vector2 = barrack.global_position
	var soldier_global_position: Vector2 = barrack_global_position
	if barrack_c_config.spawn_offsets:
		soldier_global_position += barrack_c_config.spawn_offsets.get_offset_toward_point(
			barrack_global_position, barrack.facing_global_position
		)
	soldier.global_position = soldier_global_position

	EntityManager.queue_insert_entity(soldier)

	return soldier


## 根据重生时间生成士兵。
func _spawn_by_time(barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	var soldier_ids: PackedInt32Array = barrack_record.soldier_ids
	barrack_c.spawn_timestamp = TimeManager.tick_timestamp

	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	if soldier_ids.size() >= barrack_c_config.max_soldier_count:
		return

	var animated_sprite_c: AnimatedSpriteComponent = barrack.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

	var spawn_startup_and_recovery: StartupAndRecovery = barrack_c_config.spawn_startup_and_recovery
	if spawn_startup_and_recovery:
		if await spawn_startup_and_recovery.do_startup(barrack, animated_sprite_c):
			return

	var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
	soldier_ids.append(soldier.id)
	barrack_c.need_reset_rally_center_global_position = true

	if spawn_startup_and_recovery:
		if await spawn_startup_and_recovery.do_recovery(barrack, animated_sprite_c):
			return


## 生成所有士兵。
func _spawn_all_soldiers(barrack: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	var barrack_c_config: BarrackComponentNodeConfig = barrack_c.config
	var old_soldier_ids: PackedInt32Array = barrack_record.soldier_ids
	var new_soldier_ids := PackedInt32Array()

	# 先替换存活的士兵
	if old_soldier_ids:
		for old_soldier_id: int in old_soldier_ids:
			var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
			var old_soldier: Entity = EntityManager.get_entity_by_id(old_soldier_id)
			new_soldier_ids.append(soldier.id)

			soldier.global_position = old_soldier.global_position
			soldier.facing_global_position = old_soldier.facing_global_position

			if old_soldier.state & Entity.State.RALLY:
				continue

			var old_rally_c: RallyComponent = old_soldier.get_node_or_null(StringConstants.RALLY_COMPONENT_NODE_PATH)
			if old_rally_c:
				var rally_c: RallyComponent = soldier.get_node_or_null(StringConstants.RALLY_COMPONENT_NODE_PATH)
				if rally_c:
					rally_c.rally_center_global_position = old_rally_c.rally_center_global_position

			var old_melee_c: MeleeComponent = old_soldier.get_node_or_null(StringConstants.MELEE_COMPONENT_NODE_PATH)
			if old_melee_c:
				var melee_c: MeleeComponent = soldier.get_node_or_null(StringConstants.MELEE_COMPONENT_NODE_PATH)
				if melee_c:
					melee_c.block_global_position = old_melee_c.block_global_position

					for target_id: int in old_melee_c.target_ids:
						var target: Entity = EntityManager.get_entity_by_id(target_id)
						melee_c.block_target(soldier, target)

	barrack_record.soldier_ids = new_soldier_ids
	var old_soldier_ids_size: int = old_soldier_ids.size()
	if old_soldier_ids_size < barrack_c_config.max_soldier_count:
		var animated_sprite_c: AnimatedSpriteComponent = barrack.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

		var spawn_startup_and_recovery: StartupAndRecovery = barrack_c_config.spawn_startup_and_recovery
		if spawn_startup_and_recovery:
			if await spawn_startup_and_recovery.do_startup(barrack, animated_sprite_c):
				return

		var max_soldier_count: int = barrack_c_config.max_soldier_count
		for _soldier_index: int in range(old_soldier_ids_size, max_soldier_count):
			var soldier: Entity = _create_soldier(barrack, barrack_c, barrack_record)
			new_soldier_ids.append(soldier.id)

		if spawn_startup_and_recovery:
			if await spawn_startup_and_recovery.do_recovery(barrack, animated_sprite_c):
				return

		await get_tree().physics_frame
	barrack_c.need_reset_rally_center_global_position = true

func _on_soldier_removing(soldier: Entity, barrack_c: BarrackComponent, barrack_record: BarrackRecord) -> void:
	barrack_record.soldier_ids.erase(soldier.id)
	barrack_c.need_reset_rally_center_global_position = true
