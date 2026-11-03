@abstract
extends Object
class_name DrawUtils
## 绘制工具函数库。
##
## [DrawUtils] 用于存储与绘制相关的工具函数。


## 绘制范围圆，包含最小范围和最大范围的填充圆。[br][br]
## [param position] 为局部空间位置。[br]
## [param width] 为轮廓的宽度。
static func draw_annulus(
		drawer: CanvasItem,
		position: Vector2,
		min_range: float,
		max_range: float,
		color := Color(0, 1, 0, 0.2),
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	var ranges := PackedFloat32Array([
		min_range,
		max_range
	])

	for radius: float in ranges:
		var minor: float = radius * aspect
		var major: float = radius

		drawer.draw_ellipse(
			position,
			major,
			minor,
			color,
			false,
			width
		)
		drawer.draw_ellipse(
			position,
			major,
			minor,
			color,
		)


## 绘制范围椭圆，包含最小范围和最大范围的填充椭圆。[br][br]
## [param position] 为局部空间位置。[br]
## [param color] 为椭圆轮廓与填充的颜色。[br]
## [param width] 为椭圆轮廓的宽度。
static func draw_elliptical_annulus(
		drawer: CanvasItem,
		position: Vector2,
		min_range: float,
		max_range: float,
		color := Color(0, 1, 0, 0.2),
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	var range_list := PackedFloat32Array([
		min_range,
		max_range
	])

	for radius: float in range_list:
		var minor: float = radius * aspect
		# 绘制轮廓
		drawer.draw_ellipse(
			position,
			radius,
			minor,
			color,
			false,
			width
		)
		# 绘制填充椭圆
		drawer.draw_ellipse(
			position,
			radius,
			minor,
			color
		)