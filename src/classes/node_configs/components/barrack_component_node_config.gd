@tool
extends NodeConfig
class_name BarrackComponentNodeConfig
## 兵营组件节点配置资源。
##
## [BarrackComponentNodeConfig] 用于存储 [BarrackComponent] 的可配置数据。


## 是否禁用。
@export var disabled: bool = false
## 选择菜单集结按钮数据。
@export var select_menu_rally_button_data: SelectMenuButtonData = null

@export_group("Rally")
## 最小集结范围。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var rally_min_radius: float = 0.0:
	set(v):
		rally_min_radius = v
		emit_changed()
## 最大集结范围。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var rally_max_radius: float = 300:
	set(v):
		rally_max_radius = v
		emit_changed()
## 阵型半径，影响士兵到集结点的距离。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var formation_radius: float = 30.0:
	set(v):
		formation_radius = v
		emit_changed()
## 集结音效组。
@export var rally_sfx: AudioGroup = null

@export_group("Spawn")
## 士兵场景路径。
@export_file("*.tscn") var soldier_scene: String
## 生成士兵间隔（秒）。
@export_custom(PROPERTY_HINT_NONE, "suffix: s") var spawn_interval: float = 10.0
## 士兵生成偏移组。
@export var spawn_offsets: FacingOffsetSet = null:
	set(v):
		SignalUtils.reconnect_resource_changed(spawn_offsets, v, emit_changed)
		spawn_offsets = v
		emit_changed()
## 最大士兵数量。
@export var max_soldier_count: int = 3:
	set(v):
		max_soldier_count = v
		emit_changed()
## 生成士兵的前后摇资源。
@export var spawn_startup_and_recovery: StartupAndRecovery


func _init() -> void:
	super()

	SignalUtils.try_connect_resource_changed(spawn_offsets, emit_changed)