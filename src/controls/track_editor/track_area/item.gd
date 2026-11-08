@tool
extends Control
class_name TrackEditorItem


## 被点击时发出。
signal clicked(item: TrackEditorItem)
## 拖拽时发出。
signal drag_moved(item: TrackEditorItem, delta_x: float)
## 拖拽结束时发出。
signal drag_finished(item: TrackEditorItem)
## 擦除项请求。
signal erase_request(item: TrackEditorItem)


## 以刻度为单位的位置标签。
@export var tick_position_label: Label
## 项顺序标签。
@export var order_label: Label

## 以刻度为单位的位置。
var tick_position: float = 0.0
## 所属轨道索引。
var track_index: int = -1
## 项索引。
var index: int = -1
## 上一次排序时的项索引。
var last_sort_index: int = -1
## 是否选中。
var is_selected: bool = false
## 上次拖拽全局 X 位置。
var last_drag_global_position_x: float = 0.0
## 是否正在拖拽中。
var is_draging: bool = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			clicked.emit(self)
			is_draging = true
			return

		if is_draging:
			drag_finished.emit(self)
			is_draging = false
		return

	if event is InputEventMouseMotion:
		if not is_draging:
			return

		var global_position_x: float = event.global_position.x
		var offset_x: float = global_position_x - last_drag_global_position_x

		drag_moved.emit(self, offset_x)	
		return

	if event.is_action_pressed("track_editor_erase_item"):
		erase_request.emit(self)
		return


func refresh_order_label() -> void:
	order_label.text = str(index + 1)


func refresh_tick_position_label() -> void:
	tick_position_label.text = "%.2f" % tick_position


func refresh_modulate() -> void:
	modulate = Color.SKY_BLUE if is_selected else Color.WHITE
