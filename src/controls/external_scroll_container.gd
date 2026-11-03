@tool
extends Container
class_name ExternalScrollContainer
## 外部滚动容器。
##
## [ExternalScrollContainer] 提供了对子控件的滚动控制。与自带滚动条的 [ScrollContainer] 不同是 [ExternalScrollContainer] 完全由外部 [ScrollBar] 控制滚动。


#region 属性
	#region 导出属性
## 绑定的水平滚动条。
@export var h_scroll_bar: HScrollBar:
	set(v):
		SignalUtils.reconnect_signal(h_scroll_bar, v, "value_changed", _on_h_scroll_bar_value_changed)
		h_scroll_bar = v
		_refresh_scroll_bar_max_values()
		_refresh_scroll_bar_pages()
		horizontal_scroll = -h_scroll_bar.value
		update_configuration_warnings()
## 绑定的垂直滚动条。
@export var v_scroll_bar: VScrollBar:
	set(v):
		SignalUtils.reconnect_signal(v_scroll_bar, v, "value_changed", _on_v_scroll_bar_value_changed)
		v_scroll_bar = v
		_refresh_scroll_bar_max_values()
		_refresh_scroll_bar_pages()
		vertical_scroll = -v_scroll_bar.value
		update_configuration_warnings()
## 水平滚动。
@export var horizontal_scroll: float = 0.0
## 垂直滚动。
@export var vertical_scroll: float = 0.0
## 是否自动调整大小以适应子控件，启用后请通过 [member custom_maximum_size] 来限制滚动容器大小。
@export var auto_adjust_size: bool = false:
	set(v):
		auto_adjust_size = v
		update_minimum_size()
	#endregion

## 第一个子项引用。
@onready var first_child: Control = get_child(0) if get_child_count() > 0 else null:
	set(v):
		SignalUtils.reconnect_signal(first_child, v, "resized", _on_first_child_resized)
		first_child = v
		update_configuration_warnings()
#endregion


#region 回调函数
func _ready() -> void:
	SignalUtils.try_connect_signal(h_scroll_bar, "value_changed", _on_h_scroll_bar_value_changed)
	SignalUtils.try_connect_signal(v_scroll_bar, "value_changed", _on_v_scroll_bar_value_changed)

	resized.connect(_refresh_scroll_bar_pages)
	
	update_minimum_size()
	_refresh_scroll_bar_max_values()
	_refresh_scroll_bar_pages()

	clip_contents = true


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_SORT_CHILDREN: _sort_children()
		NOTIFICATION_CHILD_ORDER_CHANGED: _child_order_changed()


func _get_minimum_size() -> Vector2:
	if first_child and auto_adjust_size:
		return first_child.size

	return Vector2.ZERO

		
func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
	
	if get_child_count() != 1:
		warnings.append("请保证子控件数量为 1 个。")

	if not h_scroll_bar and not v_scroll_bar:
		warnings.append("请绑定一个水平滚动条或垂直滚动条。")
	
	return warnings
#endregion


#region 私有方法
func _sort_children() -> void:
	if not first_child:
		return
	
	var child_min := first_child.get_combined_minimum_size()
	var rect_size := Vector2(
		maxf(size.x, child_min.x),
		maxf(size.y, child_min.y)
	)
	var rect := Rect2(horizontal_scroll, vertical_scroll, rect_size.x, rect_size.y)
	fit_child_in_rect(first_child, rect)


func _child_order_changed() -> void:
	if get_child_count() > 0:
		first_child = get_child(0)


func _try_hide_scroll_bar() -> void:
	if h_scroll_bar:
		if h_scroll_bar.page == h_scroll_bar.max_value:
			h_scroll_bar.hide()
		else:
			h_scroll_bar.show()

	if v_scroll_bar:
		if v_scroll_bar.page == v_scroll_bar.max_value:
			v_scroll_bar.hide()
		else:
			v_scroll_bar.show()


func _refresh_child_position_x() -> void:
	first_child.position.x = horizontal_scroll


func _refresh_child_position_y() -> void:
	first_child.position.y = vertical_scroll


func _refresh_scroll_bar_max_values() -> void:
	var first_child_size: Vector2 = first_child.size
	if h_scroll_bar:
		h_scroll_bar.max_value = first_child_size.x
		_refresh_child_position_x()

	if v_scroll_bar:
		v_scroll_bar.max_value = first_child_size.y
		_refresh_child_position_y()

	_try_hide_scroll_bar()


func _refresh_scroll_bar_pages() -> void:
	if h_scroll_bar:
		h_scroll_bar.page = size.x
		_refresh_child_position_x()

	if v_scroll_bar:
		v_scroll_bar.page = size.y
		_refresh_child_position_y()

	_try_hide_scroll_bar()
#endregion


#region 槽函数
func _on_first_child_resized() -> void:
	update_minimum_size()
	_refresh_scroll_bar_max_values()


func _on_h_scroll_bar_value_changed(value: float) -> void:
	horizontal_scroll = -value
	_refresh_child_position_x()


func _on_v_scroll_bar_value_changed(value: float) -> void:
	vertical_scroll = -value
	_refresh_child_position_y()
#endregion
