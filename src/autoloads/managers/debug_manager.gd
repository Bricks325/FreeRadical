@tool
extends Node
## 调试管理器。
## 
## [DebugManager] 负责管理调试与相关操作。


## 绘制类型枚举。
enum DrawType {
	## 绘制类型：血量。
	HEALTH,
	## 绘制类型：路径。
	PATHWAY,
	## 绘制类型：偏移。
	OFFSET,
	## 绘制类型：范围。
	RANGE,
	## 绘制类型：点位。
	POINT,
	## 绘制类型：实体空间哈希网格。
	ENTITY_SPATIAL_HASH_GRID,
}


## 任意绘制状态发生更改时发出。
signal draw_state_changed(draw_type: DrawType)


## 是否启用绘制血量。
var draw_health_enabled: bool = false:
	set(v):
		draw_health_enabled = v
		draw_state_changed.emit(DrawType.HEALTH)
## 是否启用绘制路径。
var draw_pathway_enabled: bool = false:
	set(v):
		draw_pathway_enabled = v
		draw_state_changed.emit(DrawType.PATHWAY)
## 是否启用绘制偏移。
var draw_offset_enabled: bool = false:
	set(v):
		draw_offset_enabled = v
		draw_state_changed.emit(DrawType.OFFSET)
## 是否启用绘制范围。
var draw_range_enabled: bool = false:
	set(v):
		draw_range_enabled = v
		draw_state_changed.emit(DrawType.RANGE)
## 是否启用绘制点位。
var draw_point_enabled: bool = false:
	set(v):
		draw_point_enabled = v
		draw_state_changed.emit(DrawType.POINT)
## 是否启用绘制实体空间哈希网格。
var draw_entity_spatial_hash_grid_enabled: bool = false:
	set(v):
		draw_entity_spatial_hash_grid_enabled = v
		draw_state_changed.emit(DrawType.ENTITY_SPATIAL_HASH_GRID)


func _ready() -> void:
	if not Engine.is_editor_hint():
		return

	draw_health_enabled = true
	draw_pathway_enabled = true
	draw_offset_enabled = true
	draw_range_enabled = true
	draw_point_enabled = true
	draw_entity_spatial_hash_grid_enabled = true


func cleanup() -> void:
	if not Engine.is_editor_hint():
		draw_health_enabled = false
		draw_pathway_enabled = false
		draw_offset_enabled = false
		draw_range_enabled = false
		draw_point_enabled = false
		draw_entity_spatial_hash_grid_enabled = false
