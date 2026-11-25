@tool
extends Skill
class_name MeleeSkill
## 近战技能节点。
##
## [MeleeSkill] 与 [AreaSkill] 唯一区别的就是没有搜索目标这一步，需要被传入目标。[br]
## 主要用于 [MeleeComponent] 与 [DodgeComponent] 进行近战技能。


@export var config: MeleeSkillNodeConfig:
	set(v):
		SignalUtils.reconnect_resource_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()


func _draw() -> void:
	if not config:
		return

	if DebugDrawManager.is_drawer_visible(DebugDrawer.Type.RANGE):
		if config.influence:
			config.influence.draw_influence_range(self, position)


func can_use(entity: Entity, _config: SkillNodeConfig, target: Entity = null) -> bool:
	if not super(entity, config, target):
		return false

	var target_interact_policy_c: InteractPolicyComponent = target.get_node_or_null(StringConstants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	if not target_interact_policy_c:
		return true

	var target_interact_policy_c_config: InteractPolicyComponentNodeConfig = target_interact_policy_c.config
	if target_interact_policy_c_config.skill_type_bans & config.skill_types:
		return false

	if config.entity_flag_bans & target_interact_policy_c_config.entity_flags:
		return false

	var target_scene_uid: String = target.scene_file_uid
	if target_scene_uid in config.scene_path_bans:
		return false

	var scene_path_allows: PackedStringArray = config.scene_path_allows
	if scene_path_allows and target_scene_uid not in scene_path_allows:
		return false

	var entity_interact_policy_c: InteractPolicyComponent = entity.get_node_or_null(StringConstants.INTERACT_POLICY_COMPONENT_NODE_PATH)
	if not entity_interact_policy_c:
		return true

	if entity_interact_policy_c.is_banned_either(target_interact_policy_c, entity.scene_file_uid, target.scene_file_uid):
		return false

	return true


func _use_skill(entity: Entity, target: Entity = null) -> void:
	start_cooldown(config)

	entity.facing_global_position = target.global_position
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(StringConstants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)

	if await config.startup_and_recovery.do_startup(entity, animated_sprite_c):
		compensate_cooldown(config)
		return

	if (
			not target
			or not target.state & Entity.State.MELEE
			or not entity.state & Entity.State.MELEE
	):
		compensate_cooldown(config)
	else:
		entity.facing_global_position = entity.global_position
		config.influence.take_influence(entity, target)

	if await config.startup_and_recovery.do_recovery(entity, animated_sprite_c):
		return

	animated_sprite_c.play_idle_animation(entity)
