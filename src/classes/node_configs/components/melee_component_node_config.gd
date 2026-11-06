@tool
extends NodeConfig
class_name MeleeComponentNodeConfig
## 近战组件节点配置资源。
##
## [MeleeComponentNodeConfig] 用于存储 [MeleeComponent] 的可配置数据。


## 是否启用被动实体，被动实体不会前往拦截位置，通常用于障碍物。
@export var passive_enabled: bool = false
## 移动速度。
@export var speed: float = 100.0
## 移动动画组。
@export var motion_animation: FacingAnimationSet = null
## 近战位置偏移组。
@export var block_position_offsets: FacingOffsetSet = null:
	set(v):
		SignalUtils.reconnect_resource_changed(block_position_offsets, v, emit_changed)
		block_position_offsets = v
		emit_changed()
## 拦截成本。
@export var block_cost: int = 1

@export_group("Blocker")
## 搜索资源，用于搜索目标。
@export var searcher: Searcher:
	set(v):
		SignalUtils.reconnect_resource_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()
## 最大可以拦截的目标数量。
@export var max_target_count: int = 1


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(block_position_offsets, emit_changed)
	SignalUtils.try_connect_resource_changed(searcher, emit_changed)