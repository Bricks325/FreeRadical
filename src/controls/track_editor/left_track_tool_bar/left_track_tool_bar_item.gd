@tool
extends VBoxContainer
class_name TrackEditorLeftTrackToolBarItem


## 轨道序号标签引用。
@export var track_order_label: Label


## 设置轨道序号标签。
func set_track_order_label(index: int) -> void:
	track_order_label.text = str(index + 1)
