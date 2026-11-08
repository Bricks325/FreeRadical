extends CanvasLayer
class_name MainUICanvasLayer


## 设置画布层。
@export var setting_canvas_layer: SettingCanvasLayer


func _on_setting_button_pressed() -> void:
	setting_canvas_layer.show_setting()
