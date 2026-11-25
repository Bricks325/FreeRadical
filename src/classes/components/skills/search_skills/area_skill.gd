@tool
extends SearchSkill
class_name AreaSkill
## 范围技能节点。
##
## [AreaSkill] 会以目标实体为中心造成影响。


@export var config: AreaSkillNodeConfig:
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

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.RANGE):
		if config.influence:
			config.influence.draw_influence_range(self, position)


func _use_skill(entity: Entity, target: Entity = null) -> void:
	if config.searcher:
		target = search_target(config, entity)
		if not target:
			return

	start_cooldown(config)

	entity.facing_global_position = target.global_position
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

	if await config.startup_and_recovery.do_startup(entity, animated_sprite_c):
		compensate_cooldown(config)
		return

	if config.searcher:
		if not target:
			target = search_target(config, entity)

		if not target:
			compensate_cooldown(config)
		else:
			entity.facing_global_position = target.global_position
			config.influence.take_influence(entity, target)
	else:
		config.influence.take_influence(entity, entity)

	if await config.startup_and_recovery.do_recovery(entity, animated_sprite_c):
		return

	animated_sprite_c.play_idle_animation(entity)
