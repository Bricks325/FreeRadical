extends CanvasLayer
class_name MapUICanvasLayer


@export var setting_canvas_layer: SettingCanvasLayer


func _on_setting_texture_button_pressed() -> void:
	setting_canvas_layer.show_setting()
