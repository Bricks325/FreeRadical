@abstract
@tool
extends Node2D
class_name Record
## 记录节点。
##
## [Record] 是所有记录节点的基类，用于存储跨实体的记录信息，当前实体创建实体时会自动传递数据。


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED

	DebugDrawManager.drawer_visible_changed.connect(_on_drawer_visible_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()

	if not get_parent() is RecordComponent:
		warnings.append("请将本节点添加到 RecordComponent 节点。")
	
	return warnings


func _on_drawer_visible_changed(_drawer: DebugDrawer) -> void:
	queue_redraw()
