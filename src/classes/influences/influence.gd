@tool
extends Resource
class_name Influence
## 影响资源，基类。
##
## [Influence] 用于定义如何影响目标，例如治疗、造成伤害、给予修改器等。


## 取值模式枚举。
enum GetValueMode {
	## 取值模式：随机值，根据范围随机取值。
	RANDOM,
	## 取值模式：根据距离衰减。
	ELLIPTICAL_FALLOFF,
}

## 最小影响值。
@export var min_value: float = 0.0
## 最大影响值。
@export var max_value: float = 0.0
## 取值模式。
@export var get_value_mode: GetValueMode = GetValueMode.RANDOM

@export_group("Extra")
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var extra_enabled: bool = false
## 为每个目标给予的修改器路径列表。
@export_file("*.tscn") var mods: PackedStringArray
## 为每个目标给予的光环路径列表。
@export_file("*.tscn") var auras: PackedStringArray
## 创建的实体场景路径列表，只会创建一次。
@export_file("*.tscn") var payloads: PackedStringArray

@export_group("Area")
## 是否启用范围影响。
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var area_enabled: bool = false
## 搜索中心是否为基础目标的位置，而非释放者的位置。
@export var center_at_target: bool = false
## 搜索资源，用于搜索目标。
@export var searcher: Searcher = null:
	set(v): 
		SignalUtils.reconnect_resource_changed(searcher, v, emit_changed)
		searcher = v
		emit_changed()

## 当前值，根据取值模式计算，已有值跳过计算。
var value: float = Constants.UNSET


func _init() -> void:
	resource_local_to_scene = true
	
	SignalUtils.try_connect_resource_changed(searcher, emit_changed)


@warning_ignore_start("unused_parameter")
## 每次影响实体时调用。
func _take(source: Entity, target: Entity, is_area: bool) -> void: pass
@warning_ignore_restore("unused_parameter")


## 对实体造成影响。
func take_influence(source: Entity, base_target: Entity = null) -> Array[Entity]:
	var center: Vector2 = base_target.global_position if center_at_target else source.global_position
	var targets: Array[Entity] = []
	if area_enabled:
		targets = searcher.search_targets(center, source)
	else:
		targets.append(base_target)

	var source_id: int = source.id
	for target: Entity in targets:
		var target_id: int = target.id

		_take(source, target, area_enabled)

		if extra_enabled:
			EntityManager.create_modifiers(target_id, mods, source_id)
			EntityManager.create_auras(target_id, auras, source_id)

	EntityManager.create_entities_at_global_position(payloads, center)

	return targets


## 绘制影响范围。
func draw_influence_range(drawer: CanvasItem, center: Vector2) -> void:
	if searcher:
		searcher.draw_search_range(drawer, center)


func get_value(source: Entity, target: Entity) -> float:
	if Utils.is_valid_number(value):
		return value
		
	match get_value_mode:
		GetValueMode.RANDOM:
			return randf_range(min_value, max_value)
		GetValueMode.ELLIPTICAL_FALLOFF:
			return MathUtils.remap_to_elliptical_annulus(
				source.global_position, 
				target.global_position, 
				searcher.max_radius,
				searcher.min_radius,
				max_value,
				min_value
			)
		
	return 0
