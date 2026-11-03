@tool
extends ExternalScrollContainer
class_name TrackEditorTrackVExternalScrollContainer


## 拖拽时发出。
signal drag_moved(offset: Vector2)


## 是否正在拖拽中。
var is_draging: bool = false
## 上次拖拽全局位置。
var last_drag_global_position := Vector2.ZERO


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			last_drag_global_position = event.global_position
			is_draging = true
			return

		is_draging = false
		return

	if event is InputEventMouseMotion:
		if not is_draging:
			return

		var offset: Vector2 = event.global_position - last_drag_global_position
		last_drag_global_position = event.global_position

		drag_moved.emit(offset)
