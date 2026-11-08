@tool
extends FacingAnimationSet
class_name HorizontalFacingAnimationSet
## 水平双方向动画组。
##
## 左、右每个 180 度表示一个动画名称。


## 右方向的动画名。
@export var right: StringName = &""
## 朝左时是否镜像播放右方向的动画（而非使用独立的左动画）。[br][br]
## [b]注意[/b]：如果启用此选项，左方向的动画名将被忽略。
@export var flip_right_for_left: bool = false:
	set(v):
		flip_right_for_left = v
		notify_property_list_changed()
## 左方向的动画名。
@export var left: StringName = &""


func _validate_property(property: Dictionary):
	if property.name == "left" and flip_right_for_left:
		property.usage = PROPERTY_USAGE_NONE


func get_animation_name_toward_point(center: Vector2, point: Vector2) -> AnimationData:
	var animation_data := AnimationData.new()
	var animation_name: StringName = &""
	var direction: Enums.Direction = MathUtils.get_quadrant_direction(center, point)
	match direction:
		Enums.Direction.LEFT_UP, Enums.Direction.LEFT_DOWN:
			if flip_right_for_left:
				animation_name = right
				animation_data.flip_h = true
			else:
				animation_name = left
		Enums.Direction.RIGHT_UP, Enums.Direction.RIGHT_DOWN:
			animation_name = right
			
	animation_data.animation_name = animation_name
	animation_data.direction = direction

	return animation_data
