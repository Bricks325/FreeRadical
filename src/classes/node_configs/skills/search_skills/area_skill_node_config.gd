@tool
extends SearchSkillNodeConfig
class_name AreaSkillNodeConfig
## 范围技能节点配置资源。
##
## [AreaSkillNodeConfig] 用于存储 [AreaSkill] 的可配置数据。


## 影响资源，用于对目标造成伤害或治愈目标。
@export var influence: Influence = null:
	set(v):
		SignalUtils.reconnect_resource_changed(influence, v, emit_changed)
		influence = v
		emit_changed()


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(searcher, emit_changed)
	SignalUtils.try_connect_resource_changed(influence, emit_changed)
