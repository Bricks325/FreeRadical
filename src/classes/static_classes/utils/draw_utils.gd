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
		min_radius: float,
		max_radius: float,
		color := Color(0, 1, 0, 0.2),
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	for i: int in 2:
		var radius: float = min_radius if i == 0 else max_radius
		var minor: float = radius * aspect

		drawer.draw_ellipse(
			position,
			radius,
			minor,
			color,
			false,
			width
		)
		drawer.draw_ellipse(
			position,
			radius,
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
		min_radius: float,
		max_radius: float,
		color := Color(0, 1, 0, 0.2),
		width: float = 3,
		aspect: float = 0.7
	) -> void:
	for i: int in 2:
		var radius: float = min_radius if i == 0 else max_radius
		var minor: float = radius * aspect
		drawer.draw_ellipse(
			position,
			radius,
			minor,
			color,
			false,
			width
		)
		drawer.draw_ellipse(
			position,
			radius,
			minor,
			color
		)