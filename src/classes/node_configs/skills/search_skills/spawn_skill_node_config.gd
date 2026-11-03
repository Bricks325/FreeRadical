@tool
extends SearchSkillNodeConfig
class_name SpawnSkillNodeConfig
## 生成实体技能节点配置资源。
##
## [SpawnSkillNodeConfig] 用于存储 [SpawnSkill] 的可配置数据。


## 生成的实体场景名称数组。
@export_file("*.tscn") var spawns: PackedStringArray
## 生成的实体初始位置偏移组。
@export var spawn_offsets: FacingOffsetSet = null:
	set(v):
		SignalUtils.reconnect_resource_changed(spawn_offsets, v, emit_changed)
		spawn_offsets = v
		emit_changed()


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(searcher, emit_changed)
	SignalUtils.try_connect_resource_changed(spawn_offsets, emit_changed)
