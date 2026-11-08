@tool
extends VBoxContainer
class_name TrackEditorRightTrackToolBarItem


## 擦除轨道请求。
signal erase_track_request(track_index: int)


@export var erase_track_button: Button


func _ready() -> void:
	erase_track_button.pressed.connect(_on_erase_track_button_pressed)


func _on_erase_track_button_pressed() -> void:
	erase_track_request.emit(get_index())
