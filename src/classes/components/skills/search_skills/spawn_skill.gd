@tool
extends SearchSkill
class_name SpawnSkill
## 生成实体技能节点。
##
## [SpawnSkill] 会生成一个实体。


@export var config: SpawnSkillNodeConfig:
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
		if config.spawn_offsets:
			config.spawn_offsets.draw_offset_group(self)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	if config.searcher:
		target = search_target(config, entity)
		if not target:
			return

	start_cooldown(config)

	var spawn_global_position: Vector2 = target.global_position if config.searcher else entity.global_position
	if config.spawn_offsets:
		spawn_global_position += config.spawn_offsets.get_offset_toward_point(entity.global_position, spawn_global_position)
	entity.facing_global_position = spawn_global_position
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

	if await config.startup_and_recovery.do_startup(entity, animated_sprite_c):
		compensate_cooldown(config)
		return

	var config_func: Callable = func(new_entity: Entity) -> void:
		new_entity.set_global_position_with_components(spawn_global_position)
		new_entity.source_id = entity.id

	if config.searcher:
		if not target:
			target = search_target(config, entity)
			if target:
				spawn_global_position = target.global_position
				if config.spawn_offsets:
					spawn_global_position += config.spawn_offsets.get_offset_toward_point(entity.global_position, spawn_global_position)

		if not target:
			compensate_cooldown(config)
		else:
			entity.facing_global_position = spawn_global_position
			EntityManager.create_entities(config.spawns, config_func)
	else:
		EntityManager.create_entities(config.spawns, config_func)

	if await config.startup_and_recovery.do_recovery(entity, animated_sprite_c):
		return

	animated_sprite_c.play_idle_animation(entity)