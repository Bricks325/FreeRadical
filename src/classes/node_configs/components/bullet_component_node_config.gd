@tool
extends NodeConfig
class_name BulletComponentNodeConfig
## 子弹组件节点配置资源。
##
## [BulletComponentNodeConfig] 用于存储 [BulletComponent] 的可配置数据。


## 飞行轨迹资源。
@export var trajectory: BulletTrajectory = null
## 飞行动画组。
@export var flight_animation: FacingAnimationSet = null
## 影响资源。
@export var influence: Influence = null:
	set(v):
		SignalUtils.reconnect_resource_changed(influence, v, emit_changed)
		influence = v
		emit_changed()

@export_group("Rotation")
## 子弹旋转速度。
@export_range(-1440.0, 1440.0, 1.0, "radians_as_degrees", "or_less", "or_greater", "suffix: °/s") var rotation_speed: float = 0.0
## 是否启用看向目标点，启用后会忽略 [member rotation_speed]。
@export var facing_enabled: bool = true:
	set(v):
		facing_enabled = v
		notify_property_list_changed()

@export_group("Hit")
## 是否可以到达目标位置。
@export var can_arrived: bool = true
## 击中目标的阈值。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var hit_distance: float = 30.0
## 击中目标后是否移除子弹实体。
@export var hit_remove: bool = true
## 击中目标后造成影响的延迟（帧）。
@export_custom(PROPERTY_HINT_NONE, "suffix: frames") var hit_delay_frames: float = 0.0
## 击中目标后播放的动画组。
@export var hit_animation: FacingAnimationSet = null
## 击中目标后播放的音效组。
@export var hit_sfx: AudioGroup = null
## 击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var hit_payloads: PackedStringArray

@export_group("Miss")
## 未击中目标时是否移除子弹实体。
@export var miss_remove: bool = true
## 未击中目标时是否也造成影响。
@export var miss_influence_enabled: bool = true
## 未击中目标时造成影响的延迟（帧）。
@export_custom(PROPERTY_HINT_NONE, "suffix: frames") var miss_delay_frames: float = 0.0
## 未击中目标时播放的动画组。
@export var miss_animation: FacingAnimationSet = null
## 未击中目标时播放的音效组。
@export var miss_sfx: AudioGroup = null
## 未击中目标时创建的实体场景路径列表。
@export_file("*.tscn") var miss_payloads: PackedStringArray


func _init() -> void:
	super()
		
	SignalUtils.try_connect_resource_changed(flight_animation, emit_changed)
	SignalUtils.try_connect_resource_changed(influence, emit_changed)


func _validate_property(property: Dictionary):
	if property.name == "left" and rotation_speed:
		property.usage = PROPERTY_USAGE_NONE