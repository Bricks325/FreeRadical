@tool
extends SearchSkillNodeConfig
class_name RangedSkillNodeConfig
## 单次远程技能节点配置资源。
##
## [RangedSkillNodeConfig] 用于存储 [RangedSkill] 的可配置数据。


## 拦截目标时是否可以释放远程技能。
@export var with_melee: bool = false

@export_group("Bullet")
## 子弹场景路径。
@export_file("*.tscn") var bullet_scene: String
## 子弹发射数量。
@export var bullet_count: int = 1
## 子弹初始位置偏移组。
@export var bullet_offsets: FacingOffsetSet = null:
	set(v):
		SignalUtils.reconnect_resource_changed(bullet_offsets, v, emit_changed)
		bullet_offsets = v
		emit_changed()
## 子弹发射的角度范围。
@export_range(0, 360, 0.1, "radians_as_degrees") var bullet_angle_range: float = 0.0
## 子弹发射模式。
@export var bullet_spawn_mode: RangedSkill.BulletSpawnMode = RangedSkill.BulletSpawnMode.EQUAL_INTERVAL

@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var loop_enabled: bool = false
## 循环次数。
@export var loop_count: int = 1
## 循环间隔（秒）。
@export_custom(PROPERTY_HINT_NONE, "suffix: s") var loop_interval: float = 0.0
## 循环的前后摇资源。
@export var loop_startup_and_recovery: StartupAndRecovery = null


func _init() -> void:
	super()

	SignalUtils.try_connect_resource_changed(searcher, emit_changed)
	SignalUtils.try_connect_resource_changed(bullet_offsets, emit_changed)
