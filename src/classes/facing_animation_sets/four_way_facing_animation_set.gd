@tool
extends FacingAnimationSet
class_name FourWayFacingAnimationSet
## 四方向动画组。
##
## 上、下、左、右每个 90 度表示一个动画名称。


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
## 上方向的动画名。
@export var up: StringName = &""
## 下方向的动画名。
@export var down: StringName = &""


func _validate_property(property: Dictionary):
	if property.name == "left" and flip_right_for_left:
		property.usage = PROPERTY_USAGE_NONE


func get_animation_name_toward_point(center: Vector2, point: Vector2) -> AnimationData:
	var animation_data := AnimationData.new()
	var angle: float = center.angle_to_point(point)
	var animation_name: StringName = &""
	var direction: Enums.Direction = MathUtils.get_cardinal_direction(angle)
	match direction:
		Enums.Direction.UP:
			animation_name = up
		Enums.Direction.DOWN:
			animation_name = down
		Enums.Direction.LEFT:
			if flip_right_for_left:
				animation_name = right
				animation_data.flip_h = true
			else:
				animation_name = left
		Enums.Direction.RIGHT:
			animation_name = right
			
	animation_data.animation_name = animation_name
	animation_data.direction = direction

	return animation_data
