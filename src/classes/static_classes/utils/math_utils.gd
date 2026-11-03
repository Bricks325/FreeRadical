@abstract
extends Object
class_name MathUtils
## 数学工具函数库。
##
## [MathUtils] 用于存储与数学相关的工具函数。


#region 直线相关工具函数。
## 根据距离与时间计算直线速度。
static func initial_linear_velocity(from: Vector2, to: Vector2, time: float) -> Vector2:
	var x: float = (to.x - from.x) / time
	var y: float = (to.y - from.y) / time

	return Vector2(x, y)


## 根据时间与速度计算位于直线上的位置。
static func position_in_linear(velocity: Vector2, from: Vector2, time: float) -> Vector2:
	var x: float = velocity.x * time + from.x
	var y: float = velocity.y * time + from.y

	return Vector2(x, y)
#endregion


#region 抛物线相关工具函数。
## 根据距离与时间计算抛物线速度。
static func initial_parabola_velocity(from: Vector2, to: Vector2, time: float, gravity: float) -> Vector2:
	var dx: float = to.x - from.x
	var dy: float = to.y - from.y
	var x: float = dx / time
	var y: float = (dy - time ** 2 / 2 * gravity) / time

	return Vector2(x, y)


## 根据时间与速度计算位于抛物线上的位置。
static func get_position_in_parabola(velocity: Vector2, from: Vector2, time: float, gravity: float) -> Vector2:
	var x: float = from.x + velocity.x * time
	var y: float = from.y + velocity.y * time + time ** 2 / 2 * gravity

	return Vector2(x, y)
#endregion


#region 圆相关工具函数。
## 判断点是否在圆中，包含圆的边界上的点。
static func is_in_circle(center: Vector2, point: Vector2, radius: float) -> bool:
	return center.distance_squared_to(point) <= radius ** 2


## 判断点是否在圆环内，包含圆环的边界上的点。
static func is_in_annulus(center: Vector2, point: Vector2, inner_radius: float, outer_radius: float) -> bool:
	var dist_squared: float = center.distance_squared_to(point)
	return (
		dist_squared <= outer_radius ** 2
		and (is_zero_approx(inner_radius) or dist_squared > inner_radius ** 2)
	)


## 映射点到圆环内，包含圆环的边界上的点。
static func remap_to_annulus(
		center: Vector2,
		point: Vector2,
		outer_radius: float,
		inner_radius: float = 0.0,
		from: float = 1.0,
		to: float = 0.0
	) -> float:
	var dist: float = point.distance_to(center)
	return remap(dist, inner_radius, outer_radius, from, to)


## 以 [param center] 为极点、按极坐标 ([param radius], [param angle]) 偏移，返回对应的笛卡尔坐标点。
static func point_at_polar_offset(center: Vector2, radius: float, angle: float) -> Vector2:
	return Vector2(
		center.x + radius * cos(angle),
		center.y + radius * sin(angle)
	)
#endregion


#region 椭圆相关工具函数。
## 计算点到椭圆中心的归一化距离。
static func ellipse_distance_normalized(dx: float, dy: float, radius: float, aspect: float = 0.7) -> float:
	return (dx / radius) ** 2 + (dy / radius * aspect) ** 2


## 判断点是否位于椭圆中，包含椭圆的边界上的点。
static func is_in_ellipse(center: Vector2, point: Vector2, radius: float, aspect: float = 0.7) -> bool:
	var a: float = radius
	var b: float = radius * aspect
	var dx: float = point.x - center.x
	var dy: float = point.y - center.y

	return (dx / a) ** 2 + (dy / b) ** 2 <= 1


## 判断点是否位于椭圆环内，包含椭圆环的边界上的点。
static func is_in_elliptical_annulus(
		center: Vector2, point: Vector2, outer_radius: float, inner_radius: float = 0.0, aspect: float = 0.7
	) -> bool:
	var dx: float = point.x - center.x
	var dy: float = point.y - center.y

	return (
		ellipse_distance_normalized(dx, dy, outer_radius, aspect) <= 1
		and (is_zero_approx(inner_radius) or ellipse_distance_normalized(dx, dy, inner_radius, aspect) > 1)
	)


## 映射点到椭圆环内，包含椭圆环的边界上的点。
static func remap_to_elliptical_annulus(
		center: Vector2,
		point: Vector2,
		outer_radius: float,
		inner_radius: float = 0.0,
		from: float = 1.0,
		to: float = 0.0,
		aspect: float = 0.7
	) -> float:
	var dx: float = point.x - center.x
	var dy: float = point.y - center.y
	var point_distance: float = sqrt(dx ** 2 + (dy * aspect) ** 2)

	var angle: float = center.angle_to_point(point)
	var cos_angle: float = cos(angle)
	var sin_angle: float = sin(angle)

	var outer_distance: float = sqrt((outer_radius * cos_angle) ** 2 + (outer_radius * aspect * sin_angle) ** 2)
	var inner_distance: float = (
		0.0 if is_zero_approx(inner_radius)
		else sqrt((inner_radius * cos_angle) ** 2 + (inner_radius * aspect * sin_angle) ** 2)
	)
	
	return remap(point_distance, inner_distance, outer_distance, from, to)


## 以 [param center] 为极点、按椭圆的极坐标 ([param radius], [param angle]) 偏移，返回对应的笛卡尔坐标点。
static func point_at_elliptical_polar_offset(
		center: Vector2, radius: float, angle: float, aspect: float = 0.7
	) -> Vector2:
	var x: float = center.x + radius * cos(angle)
	var y: float = center.y + radius * aspect * sin(angle)

	return Vector2(x, y)
#endregion


## 判断点是否位于扇形中。
static func is_in_sector(
		center: Vector2, point: Vector2, radius: float, angle_range: float, direction_angle: float
	) -> bool:
	if not is_in_circle(center, point, radius):
		return false

	var angle: float = center.angle_to(point)
	var angle_diff: float = abs(angle - direction_angle)

	return angle_diff <= angle_range / 2


## 判断点是否位于线段中。
static func is_in_line(
		center: Vector2, point: Vector2, width: float, length: float, angle: float = 0.0
	) -> bool:
	if is_in_circle(center, point, width):
		return true

	var local_point: Vector2 = point - center
	local_point = local_point.rotated(-angle)
	var local_point_x = local_point.x
	var local_point_y = local_point.y

	return (
		local_point_x <= length
		and local_point_x >= 0
		and local_point_y <= width
		and local_point_y >= -width
	)


## 百分比转换为数字。
static func to_percent(number: float) -> float:
	return number / 100


## 判断点是否到达目标位置。
static func is_at_destination(position: Vector2, target_position: Vector2, threshold: float = 5.0) -> bool:
	return position.distance_to(target_position) <= threshold


## 根据角度获取上/下/左/右四方向中的一个，见 [enum Enums.Direction]。
static func get_cardinal_direction(angle: float) -> Enums.Direction:
	var quarter_45: float = Constants.QUARTER_PI

	if angle >= -3 * quarter_45 and angle < -quarter_45:
		return Enums.Direction.UP

	if angle >= quarter_45 and angle < 3 * quarter_45:
		return Enums.Direction.DOWN

	if angle >= -quarter_45 and angle < quarter_45:
		return Enums.Direction.RIGHT

	return Enums.Direction.LEFT


## 根据目标点相对于中心点的位置获取象限方向，见 [enum Enums.Direction]。
static func get_quadrant_direction(center: Vector2, point: Vector2) -> Enums.Direction:
	var direction: int = Enums.Direction.NONE

	if point.y <= center.y:
		direction |= Enums.Direction.UP
	else:
		direction |= Enums.Direction.DOWN

	if point.x >= center.x:
		direction |= Enums.Direction.RIGHT
	else:
		direction |= Enums.Direction.LEFT

	return direction as Enums.Direction
