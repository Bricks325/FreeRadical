@tool
extends NodeConfig
class_name OffsetComponentNodeConfig
## 偏移量组件节点配置。
##
## [OffsetComponentNodeConfig] 用于存储 [OffsetComponent] 的可配置数据。


## 击中位置偏移组。
@export var hit_offsets: FacingOffsetSet = null:
	set(v): 
		SignalUtils.reconnect_resource_changed(hit_offsets, v, emit_changed)
		hit_offsets = v
		emit_changed()
## 光环位置偏移组。
@export var aura_offsets: FacingOffsetSet = null:
	set(v): 
		SignalUtils.reconnect_resource_changed(aura_offsets, v, emit_changed)
		aura_offsets = v
		emit_changed()


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(hit_offsets, emit_changed)
	SignalUtils.try_connect_resource_changed(aura_offsets, emit_changed)
