@tool
@abstract
extends Node2D
class_name DebugDrawer
## 调试绘制器。
## 
## [DebugDrawer] 负责绘制调试信息。


## 调试绘制器类型。
enum Type {
	## 调试绘制器类型：无。
	NONE,
	## 调试绘制器类型：血量。
	HEALTH,
	## 调试绘制器类型：路径。
	PATHWAY,
	## 调试绘制器类型：偏移量。
	OFFSET,
	## 调试绘制器类型：范围。
	RANGE,
	## 调试绘制器类型：点位。
	POINT,
	## 调试绘制器类型：实体空间哈希网格。
	ENTITY_SPATIAL_HASH_GRID,
}


## 调试绘制器类型。
@export var drawer_type: Type = Type.NONE


func ready() -> void:
	pass
