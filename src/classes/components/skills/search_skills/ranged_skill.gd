@tool
extends SearchSkill
class_name RangedSkill
## 单次远程技能节点。
##
## [RangedSkill] 会生成一个子弹，通过子弹对目标造成影响。


## 子弹生成模式枚举。
enum BulletSpawnMode {
	## 子弹生成模式：随机，子弹会以 [member bullet_angle_range] 范围内的随机角度生成。
	RANDOM,
	## 子弹生成模式：等距，子弹会以 [member bullet_angle_range] 范围内等距的角度生成。
	EQUAL_INTERVAL,
}


@export var config: RangedSkillNodeConfig:
	set(v):
		SignalUtils.reconnect_resource_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if not config:
		return

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.RANGE):
		if config.searcher:
			config.searcher.draw_search_range(self, position)

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.OFFSET):
		if config.bullet_offsets:
			config.bullet_offsets.draw_offset_group(self)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	target = search_target(config, entity)
	if not target:
		return

	start_cooldown(config)

	entity.facing_global_position = target.global_position
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

	if await config.startup_and_recovery.do_startup(entity, animated_sprite_c):
		compensate_cooldown(config)
		return

	if not target:
		target = search_target(config, entity)

	if not target:
		compensate_cooldown(config)
	else:
		entity.facing_global_position = target.global_position

		if config.loop_enabled:
			for loop_index: int in config.loop_count:
				if await config.loop_startup_and_recovery.do_startup(entity, animated_sprite_c):
					_compensate_cooldown_for_loop(loop_index)
					return

				if not target:
					target = search_target(config, entity)

				if not target:
					_compensate_cooldown_for_loop(loop_index)
				else:
					entity.facing_global_position = target.global_position
					_spawn_bullets(entity, target)

				if await config.loop_startup_and_recovery.do_recovery(entity, animated_sprite_c):
					return

			entity.facing_global_position = target.global_position
		else:
			_spawn_bullets(entity, target)

	if await config.startup_and_recovery.do_recovery(entity, animated_sprite_c):
		return

	animated_sprite_c.play_idle_animation(entity)


## 生成子弹。
func _spawn_bullets(
		entity: Entity,
		target: Entity
	) -> void:
	var entity_to_target_angle: float = entity.global_position.angle_to_point(target.global_position)
	var half_angle_range: float = config.bullet_angle_range * 0.5
	var da: float = (config.bullet_angle_range) / config.bullet_count + 1

	for bullet_index: int in config.bullet_count:
		var bullet = EntityManager.create_entity(config.bullet_scene)
		var bullet_c: BulletComponent = bullet.get_node_or_null(StringConstants.BULLET_COMPONENT_NODE_PATH)
		bullet.source_id = entity.id
		bullet_c.target_id = target.id

		var bullet_rotation: float = 0.0
		match config.bullet_spawn_mode:
			BulletSpawnMode.EQUAL_INTERVAL:
				bullet_rotation = entity_to_target_angle + (da * bullet_index + -half_angle_range)
			BulletSpawnMode.RANDOM:
				var random_angle: float = randf_range(
					-half_angle_range, half_angle_range
				)
				bullet_rotation = entity_to_target_angle + random_angle

		bullet.rotation = bullet_rotation
		var bullet_global_position: Vector2 = entity.global_position
		if config.bullet_offsets:
			bullet_global_position += config.bullet_offsets.get_offset_toward_point(
				entity.global_position, entity.facing_global_position
			)
		bullet.global_position = bullet_global_position

		EntityManager.queue_insert_entity(bullet)


## 根据循环次数补偿技能冷却时间。
func _compensate_cooldown_for_loop(loop_index: int) -> void:
	var radio: float = 1 - float(loop_index) / config.loop_count
	timestamp -= config.compensate_cooldown_percent / 100 * radio * config.cooldown
