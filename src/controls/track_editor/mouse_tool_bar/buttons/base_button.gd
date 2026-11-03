@tool
@abstract
extends Button
class_name MouseToolBarBaseButton


## 临时切换当前按钮时且是按下事件时发出。
signal temporary_switched_pressed(button: MouseToolBarBaseButton)
## 临时切换当前按钮时且是释放事件时发出。
signal temporary_switched_released(button: MouseToolBarBaseButton)


const STYLE_TYPE_NAME: StringName = &"MouseToolBarBaseButton"

## 临时切换当前按钮的快捷键。
@export var temporary_toggle_shortcut: Shortcut = null


func _ready() -> void:
	toggle_mode = true
	
	if not theme_type_variation:
		theme_type_variation = STYLE_TYPE_NAME


func _shortcut_input(event: InputEvent) -> void:
	if not temporary_toggle_shortcut:
		return

	if not temporary_toggle_shortcut.matches_event(event):
		return
		
	if event.is_pressed():
		temporary_switched_pressed.emit(self)
		return
		
	temporary_switched_released.emit(self)
