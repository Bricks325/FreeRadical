@tool
@abstract
@icon("res://assets/dpi_textures/at-icons/node2d/jigsaw_piece.svg")
extends Node2D
class_name Component
## 组件基类。
##
## [Component] 是所有组件的基类，组件用于存储实体的数据与相关工具方法。


## 组件所属的实体，仅用于辅助编辑器编辑中。
@onready var parent := get_parent()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	
	DebugDrawManager.drawer_visible_changed.connect(_on_drawer_visible_changed)
	

func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = NodeConfigManager.get_common_configuration_warnings(self)
	
	return warnings


func _on_config_changed() -> void:
	queue_redraw()


func _on_drawer_visible_changed(_drawer: DebugDrawer) -> void:
	queue_redraw()
