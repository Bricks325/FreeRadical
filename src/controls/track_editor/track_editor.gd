@tool
extends PanelContainer
class_name TrackEditor
## 轨道编辑器。
##
## TrackEditor 适用于时间轴可视化编辑等场景。


#region 信号
## 项创建后发出。
signal item_created(item: TrackEditorItem)
## 项选中后发出。
signal item_selected(item: TrackEditorItem)
## 项取消选中后发出。
signal item_deselected(item: TrackEditorItem)
## 项擦除后发出。
signal item_erased(item: TrackEditorItem)
## 项移动后发出。
signal item_moved(item: TrackEditorItem)
## 项移动完毕后发出。
signal item_move_finished(item: TrackEditorItem)
## 轨道创建后发出。
signal track_created(track: TrackEditorTrack)
## 轨道擦除后发出。
signal track_erased(track: TrackEditorTrack)
#endregion


const STYLE_TYPE_NAME: StringName = &"TrackEditor"

#region 导出属性
## 是否启用鼠标工具栏。
@export var mouse_tool_bar_enabled: bool = false:
	set(v):
		mouse_tool_bar_enabled = v
		if mouse_tool_bar:
			_set_mouse_tool_bar_visible(v)

	#region 轨道属性
@export_group("Track")
## 是否启用多轨道模式。
@export var multiple_track_enabled: bool = true:
	set(v):
		multiple_track_enabled = v
		if add_track_button:
			_set_multiple_track_section_visible(v)
## 项拖动时的吸附阈值。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var snap_threshold: float = 4.0

		#region 轨道刻度长度属性
@export_subgroup("Tick Length")
## 轨道刻度像素长度。
@export_custom(PROPERTY_HINT_NONE, "suffix: px") var tick_length_pixel: float = 75.0:
	set(v):
		tick_length_pixel = v
		if ruler:
			_refresh_ruler()
## 最小轨道刻度长度。
@export var min_tick_length: float = 0.1:
	set(v):
		min_tick_length = v
		if tick_length_spin_box:
			tick_length_spin_box.min_value = v
		if tick_length_slider:
			tick_length_slider.min_value = v
## 最大轨道刻度长度。
@export var max_tick_length: float = 100.0:
	set(v):
		max_tick_length = v
		if tick_length_spin_box:
			tick_length_spin_box.max_value = v
		if tick_length_slider:
			tick_length_slider.max_value = v
## 轨道刻度长度步长。
@export var tick_length_step: float = 0.1:
	set(v):
		tick_length_step = v
		if tick_length_spin_box:
			tick_length_spin_box.step = v
		if tick_length_slider:
			tick_length_slider.step = v
## 轨道刻度长度。
@export var tick_length: float = 10:
	set(v):
		tick_length = v
		if tick_length_spin_box:
			tick_length_spin_box.value = v
		if tick_length_slider:
			tick_length_slider.value = v
		#endregion
	#endregion
#endregion

#region 引用
@export_group("Reference")
## 轨道刻度长度旋钮引用。
@export var tick_length_spin_box: SpinBox
## 轨道刻度长度滑块引用。
@export var tick_length_slider: Slider
## 添加轨道按钮引用。
@export var add_track_button: Button
## 鼠标工具栏引用。
@export var mouse_tool_bar: MouseToolBar
## 轨道区域引用。
@export var track_area: TrackEditorTrackArea
## 轨道刻度尺容器引用。
@export var ruler: TrackEditorRuler
## 轨道自适应滚动容器引用。
@export var track_v_external_scroll_container: TrackEditorTrackVExternalScrollContainer
## 轨道容器引用。
@export var track_v_box_container: VBoxContainer
## 左轨道工具栏引用。
@export var left_track_tool_bar: VBoxContainer
## 右轨道工具栏引用。
@export var right_track_tool_bar: VBoxContainer
## 左轨道工具栏垂直滚动容器引用。
@export var left_track_tool_v_external_scroll_container: ExternalScrollContainer
## 右轨道工具栏垂直滚动容器引用。
@export var right_track_tool_v_external_scroll_container: ExternalScrollContainer
## 水平滚动条引用。
@export var h_scroll_bar: HScrollBar
## 垂直滚动条引用。
@export var v_scroll_bar: VScrollBar


@export_subgroup("Scenes")
## 项场景引用。
@export var item_scene: PackedScene
## 轨道场景引用。
@export var track_scene: PackedScene
## 左轨道工具栏项场景引用。
@export var left_track_tool_bar_item_scene: PackedScene
## 右轨道工具栏项场景引用。
@export var right_track_tool_bar_item_scene: PackedScene
#endregion

## 选中的项引用。
var selected_item: TrackEditorItem = null
## 项列表。
var item_list: Array[TrackEditorItem] = []


func _ready() -> void:
	_set_range_control_properties(tick_length_spin_box, min_tick_length, max_tick_length, tick_length_step, tick_length)
	_set_range_control_properties(tick_length_slider, min_tick_length, max_tick_length, tick_length_step, tick_length)

	_set_mouse_tool_bar_visible(mouse_tool_bar_enabled)
	_set_multiple_track_section_visible(multiple_track_enabled)

	tick_length_spin_box.value_changed.connect(set_tick_length)
	tick_length_slider.value_changed.connect(set_tick_length)
	add_track_button.pressed.connect(create_track)
	track_area.refresh_cursor_position_request.connect(_on_refresh_cursor_position_request)
	track_v_external_scroll_container.drag_moved.connect(_on_track_v_external_scroll_container_drag_moved)

	create_track()
	call_deferred("_refresh_ruler")


#region 项
## 获取项。
func get_item(index: int) -> TrackEditorItem:
	return item_list[index]


## 设置项 X 位置。
func set_item_position_x(item: TrackEditorItem, position_x: float) -> void:
	if mouse_tool_bar.flags & MouseToolBar.Flag.SNAP:
		position_x = snap_item_position_to_tick(position_x, snap_threshold)

	var max_x: float = ruler.size.x
	position_x = clampf(position_x, 0, max_x)
	item.position.x = position_x
	item.tick_position = position_to_tick_position(position_x)
	item.refresh_tick_position_label()
	item.last_drag_global_position_x = item.global_position.x


## 吸附项到轨道刻度。[br][br]
## [param p_snap_threshold] 吸附阈值，为 -1.0 时将会吸附到最近的刻度。
func snap_item_position_to_tick(position_x: float, p_snap_threshold: float = -1.0) -> float:
	var step: float = position_x / tick_length_pixel
	var front_position_x: float = ceili(step) * tick_length_pixel
	var back_position_x: float = floori(step) * tick_length_pixel

	if p_snap_threshold == -1.0:
		if abs(front_position_x - position_x) <= abs(back_position_x - position_x):
			position_x = front_position_x
		else:
			position_x = back_position_x
	else:
		if abs(front_position_x - position_x) <= p_snap_threshold:
			position_x = front_position_x
		elif abs(back_position_x - position_x) <= p_snap_threshold:
			position_x = back_position_x

	return position_x


## 将位置转换为以刻度为单位的位置。
func position_to_tick_position(position_x: float) -> float:
	return position_x / get_pixel_per_tick()


## 将以刻度为单位的位置转换为位置。
func tick_position_to_position(tick_position: float) -> float:
	return tick_position * get_pixel_per_tick()


## 计算项以刻度为单位位置相对于另一个项的相对值。
func calculate_item_tick_gap(item: TrackEditorItem) -> float:
	var tick_position: float = item.tick_position
	var index: int = item.index
	if index == 0:
		return tick_position

	return tick_position - item_list[index - 1].tick_position


## 创建项到指定位置。
func create_item(track_index: int, position_x: float, emit_signal_enabled: bool = true) -> TrackEditorItem:
	var track: TrackEditorTrack = get_track(track_index)
	var item: TrackEditorItem = item_scene.instantiate()
	item.position.y = track.item_container.size.y / 2
	item.track_index = track_index
	set_item_position_x(item, position_x)

	track.item_container.add_child(item)
	item_list.append(item)
	refresh_item_list()

	item.clicked.connect(_on_item_clicked)
	item.drag_moved.connect(_on_item_drag_moved)
	item.drag_finished.connect(_on_item_drag_finished)
	item.erase_request.connect(_on_item_erase_request)

	Log.info("创建项 track_index=%d" % track_index)
	if emit_signal_enabled:
		item_created.emit(item)

	return item


## 创建项到以刻度为单位的指定位置。
func create_item_at_tick_position(track_index: int, tick_position: float, emit_signal_enabled: bool = true) -> TrackEditorItem:
	var position_x: float = tick_position_to_position(tick_position)
	return create_item(track_index, position_x, emit_signal_enabled)


## 删除项。
func erase_item(item: TrackEditorItem, emit_signal_enabled: bool = true) -> void:
	Log.info("删除项: index=%d track_index=%d tick_position=%.2f" % [item.index, item.track_index, item.tick_position])

	item.queue_free()
	item_list.erase(item)
	refresh_item_list()
	if item == selected_item:
		deselect_item()

	if emit_signal_enabled:
		item_erased.emit(item)


## 选中项。
func select_item(item: TrackEditorItem) -> void:
	deselect_item()

	Log.info("选择项 index=%d track_index=%d tick_position=%.2f" % [item.index, item.track_index, item.tick_position])
	selected_item = item
	item.is_selected = true
	item.refresh_modulate()
	item.last_drag_global_position_x = item.global_position.x
	track_area.refresh_position(item.position.x)
	item_selected.emit(item)


## 取消选中项。
func deselect_item() -> void:
	if not selected_item:
		return

	selected_item.is_selected = false
	selected_item.refresh_modulate()

	Log.debug("取消选中项 index=%d track_index=%d tick_position=%.2f" % [selected_item.index, selected_item.track_index, selected_item.tick_position])
	item_deselected.emit(selected_item)
	selected_item = null


## 移动项。
func move_item(item: TrackEditorItem, new_position_x: float) -> void:
	Log.verbose("移动项: index=%d track_index=%d new_position_x=%.2f" % [item.index, item.track_index, new_position_x])

	set_item_position_x(item, new_position_x)
	track_area.refresh_position(item.position.x)
	item_moved.emit(item)


## 刷新所有项列表。
func refresh_item_list() -> void:
	item_list.sort_custom(
		func(a: TrackEditorItem, b: TrackEditorItem) -> bool:
			var a_tick_position: float = a.tick_position
			var b_tick_position: float = b.tick_position

			if a_tick_position == b_tick_position:
				return a.track_index < b.track_index
			else:
				return a_tick_position < b_tick_position
	)

	for item_index: int in item_list.size():
		var item: TrackEditorItem = item_list[item_index]
		item.last_sort_index = item.index
		item.index = item_index
		item.refresh_order_label()
#endregion


#region 轨道
func set_tick_length(value: float) -> void:
	tick_length = value
	tick_length_spin_box.set_value_no_signal(value)
	tick_length_slider.set_value_no_signal(value)
	
	_refresh_ruler()

	Log.info("设置刻度长度: tick_length=%d" % tick_length)
	for item: TrackEditorItem in item_list:
		item.position.x = item.tick_position * get_pixel_per_tick()


## 获取刻度单位的像素长度。
func get_pixel_per_tick() -> float:
	return tick_length_pixel / tick_length


## 获取轨道。
func get_track(track_index: int) -> TrackEditorTrack:
	return track_v_box_container.get_child(track_index)


## 创建轨道。
func create_track() -> void:
	var track: TrackEditorTrack = track_scene.instantiate()
	track_v_box_container.add_child(track)
	var track_index: int = track.get_index()

	track.clicked.connect(_on_track_clicked)
	track.create_item_request.connect(_on_track_create_item_request)

	Log.info("创建轨道: track_index=%d" % track_index)

	if multiple_track_enabled:
		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar_item_scene.instantiate()
		left_track_tool_bar_item.set_track_order_label(track_index)
		left_track_tool_bar.add_child(left_track_tool_bar_item)

		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar_item_scene.instantiate()
		right_track_tool_bar_item.erase_track_request.connect(_on_erase_track_request)
		right_track_tool_bar.add_child(right_track_tool_bar_item)

	track_created.emit(track)


## 擦除轨道。
func erase_track(track_index: int, emit_signal_enabled: bool = true) -> void:
	Log.info("擦除轨道: track_index=%d" % track_index)

	var track: TrackEditorTrack = get_track(track_index)
	track_v_box_container.remove_child(track)
	track.queue_free()

	for item: TrackEditorItem in track.item_container.get_children():
		erase_item(item, emit_signal_enabled)

	if multiple_track_enabled:
		var right_track_tool_bar_item: TrackEditorRightTrackToolBarItem = right_track_tool_bar.get_child(track_index)
		right_track_tool_bar.remove_child(right_track_tool_bar_item)
		right_track_tool_bar_item.queue_free()
		var left_track_tool_bar_item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(track_index)
		left_track_tool_bar.remove_child(left_track_tool_bar_item)
		left_track_tool_bar_item.queue_free()

		for item_index: int in left_track_tool_bar.get_child_count():
			var item: TrackEditorLeftTrackToolBarItem = left_track_tool_bar.get_child(item_index)
			item.set_track_order_label(item_index)

	if emit_signal_enabled:
		track_erased.emit(track)


## 清除所有轨道。
func clear_tracks(emit_signal_enabled: bool = true) -> void:
	Log.info("清除所有轨道")

	for track_index in range(track_v_box_container.get_child_count() - 1, -1, -1):
		erase_track(track_index, emit_signal_enabled)
#endregion


#region 私有方法
## 设置 [Range] 的基础属性。
func _set_range_control_properties(range_control: Range, p_min_value: float, p_max_value: float, p_step: float, p_value: float) -> void:
	range_control.min_value = p_min_value
	range_control.max_value = p_max_value
	range_control.step = p_step
	range_control.value = p_value


## 设置鼠标工具栏可见性。
func _set_mouse_tool_bar_visible(p_visible: bool) -> void:
	mouse_tool_bar.visible = p_visible


## 设置多轨道部分可见性。
func _set_multiple_track_section_visible(p_visible: bool) -> void:
	add_track_button.visible = p_visible
	left_track_tool_bar.visible = p_visible
	right_track_tool_bar.visible = p_visible


## 刷新刻度尺。
func _refresh_ruler() -> void:
	ruler.refresh_ruler(tick_length_pixel, tick_length, int(h_scroll_bar.value), track_area.size.x)
#endregion


#region 槽函数
func _on_refresh_cursor_position_request(position_x: float) -> void:
	track_area.refresh_position(position_x)


func _on_item_clicked(item: TrackEditorItem) -> void:
	match mouse_tool_bar.mode:
		MouseToolBar.Mode.SELECT, MouseToolBar.Mode.MOVE:
			select_item(item)
		MouseToolBar.Mode.ERASE:
			erase_item(item)


func _on_item_drag_moved(item: TrackEditorItem, offset_x: float) -> void:
	Log.verbose("拖拽项: index=%d, offset_x=%.2f" % [item.index, offset_x])
		
	match mouse_tool_bar.mode:
		MouseToolBar.Mode.SELECT, MouseToolBar.Mode.MOVE:
			var position_x: float = item.position.x + offset_x
			if mouse_tool_bar.flags & MouseToolBar.Flag.SNAP:
				if Input.is_action_pressed("track_editor_snap_move_item"):
					position_x = snap_item_position_to_tick(position_x)
			
			move_item(item, position_x)


func _on_item_drag_finished(item: TrackEditorItem) -> void:
	refresh_item_list()
	item_move_finished.emit(item)


func _on_item_erase_request(item: TrackEditorItem) -> void:
	erase_item(item)


func _on_track_clicked(track: TrackEditorTrack, event: InputEvent) -> void:
	var track_index: int = track.get_index()
	var position_x: float = event.position.x

	Log.debug("点击轨道: track_index=%d position_x=%.2f" % [track_index, position_x])
	match mouse_tool_bar.mode:
		MouseToolBar.Mode.ADD:
			create_item(track_index, position_x)

	deselect_item()


func _on_track_create_item_request(track: TrackEditorTrack, event: InputEvent) -> void:
	if mouse_tool_bar.mode != MouseToolBar.Mode.SELECT:
		return

	create_item(track.get_index(), event.position.x)


func _on_erase_track_request(track_index: int) -> void:
	erase_track(track_index)


func _on_add_track_button_pressed() -> void:
	create_track()


func _on_track_v_external_scroll_container_drag_moved(offset: Vector2) -> void:
	if mouse_tool_bar.mode != MouseToolBar.Mode.PAN:
		return

	h_scroll_bar.value -= offset.x
	v_scroll_bar.value -= offset.y
#endregion
