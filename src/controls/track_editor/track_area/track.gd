@tool
extends PanelContainer
class_name TrackEditorTrack


## 点击轨道后发出。
signal clicked(track: TrackEditorTrack, event: InputEvent)
## 创建项请求。
signal create_item_request(track: TrackEditorTrack, event: InputEvent)


@export var item_container: HSeparator = null


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		clicked.emit(self, event)
		return

	if event.is_action_pressed("track_editor_create_item"):
		create_item_request.emit(self, event)
