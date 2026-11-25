@tool
extends SkillNodeConfig
class_name MeleeSkillNodeConfig
## 近战技能节点配置资源。
##
## [MeleeSkillNodeConfig] 用于存储 [MeleeSkill] 的可配置数据。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		SignalUtils.reconnect_resource_changed(influence, v, emit_changed)
		influence = v
		emit_changed()

@export_group("Interact Policy")
## 禁止交互的实体标识。
@export var entity_flag_bans: int = 0
## 禁止交互的实体场景路径。
@export_file("*.tscn") var scene_path_bans: PackedStringArray
## 允许交互的实体场景路径。
@export_file("*.tscn") var scene_path_allows: PackedStringArray


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(influence, emit_changed)


func _validate_property(property: Dictionary) -> void:
	super(property)

	match property.name:
		"entity_flag_bans":
			property.hint_string = "mask_check(%s)" % InteractPolicyComponent.EntityFlag
