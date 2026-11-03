extends Node2D
## 输入管理器
## 
## [InputManager] 负责管理输入与相关操作。


## 鼠标全局位置。
var mouse_global_position := Vector2.ZERO


func _input(event: InputEvent) -> void:
	if event is InputEventMouse:
		mouse_global_position = get_global_mouse_position()
		
	if event is InputEventMouseButton and event.pressed:
		Log.debug("点击: position=%s button_index=%d" % [mouse_global_position, event.button_index])
