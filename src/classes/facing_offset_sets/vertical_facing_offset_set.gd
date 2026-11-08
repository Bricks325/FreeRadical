@tool
extends FacingOffsetSet
class_name VerticalFacingOffsetSet
## 垂直双方向偏移组。
##
## 上、下每个 180 度表示一个偏移。


## 上方向的偏移。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var up := Vector2.ZERO:
	set(v):
		up = v
		emit_changed()
## 下方向的偏移。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var down := Vector2.ZERO:
	set(v):
		down = v
		emit_changed()
## 是否启用朝向左方向时镜像。
@export var flip_on_left: bool = false:
	set(v):
		flip_on_left = v
		notify_property_list_changed()


func get_offset_toward_point(center: Vector2, point: Vector2) -> Vector2:
	var direction: Enums.Direction = MathUtils.get_quadrant_direction(center, point)
	var offset := Vector2.ZERO

	match direction:
		Enums.Direction.LEFT_UP, Enums.Direction.RIGHT_UP:
			offset = up
		Enums.Direction.LEFT_DOWN, Enums.Direction.RIGHT_DOWN:
			offset = down

	if flip_on_left and direction & Enums.Direction.LEFT:
		offset *= Vector2(-1, 1)
	return offset


func to_dict() -> Dictionary[String, Vector2]:
	return {
		"up": up,
		"down": down,
	}
