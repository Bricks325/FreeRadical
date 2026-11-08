@tool
extends FacingAnimationSet
class_name VerticalFacingAnimationSet
## 垂直双方向动画组。
##
## 上、下每个 180 度表示一个动画名称。


## 上方向的动画名。
@export var up: StringName = &""
## 下方向的动画名。
@export var down: StringName = &""
## 是否启用朝向左方向时镜像。
@export var flip_on_left: bool = false


func get_animation_name_toward_point(center: Vector2, point: Vector2) -> AnimationData:
	var animation_data := AnimationData.new()
	var animation_name: StringName = &""
	var direction: Enums.Direction = MathUtils.get_quadrant_direction(center, point)

	if flip_on_left and direction & Enums.Direction.LEFT:
		animation_data.flip_h = true

	match direction:
		Enums.Direction.LEFT_UP, Enums.Direction.RIGHT_UP:
			animation_name = up
		Enums.Direction.LEFT_DOWN, Enums.Direction.RIGHT_DOWN:
			animation_name = down

	animation_data.animation_name = animation_name
	animation_data.direction = direction

	return animation_data
