@tool
extends HBoxContainer
class_name TrackEditorRuler


@export var tick_scene: PackedScene

## 轨道刻度像素长度。
var _tick_length_pixel: float
## 轨道刻度长度。
var _tick_length: float
## 水平滚动位置。
var _scroll_horizontal: int
## 轨道页面可以显示的刻度数量。
var _page_tick_count: int
var _tick_pool: Array[TrackEditorTick] = []


func _draw() -> void:
	while _tick_pool.size() < _page_tick_count:
		var tick: TrackEditorTick = tick_scene.instantiate()
		_tick_pool.append(tick)
		add_child(tick)
	
	var tick_from_index: int = floori(_scroll_horizontal / _tick_length_pixel)
	var frontmost_position: float = tick_from_index * _tick_length_pixel
	for index: int in range(tick_from_index, tick_from_index + _page_tick_count):
		var tick: TrackEditorTick = _tick_pool[index - tick_from_index]
		tick.offset_transform_position.x = frontmost_position
		tick.custom_minimum_size.x = _tick_length_pixel
		tick.refresh_tick_number(int(index * _tick_length))


## 刷新刻度尺。
func refresh_ruler(p_tick_length_pixel: float, p_tick_length: float, p_scroll_horizontal: int, track_area_page_width: float) -> void:
	_tick_length_pixel = p_tick_length_pixel
	_tick_length = p_tick_length
	_scroll_horizontal = p_scroll_horizontal
	_page_tick_count = ceili(track_area_page_width / _tick_length_pixel) + 1	# 多绘制一个刻度确保填充满页面

	queue_redraw()
