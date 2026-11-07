extends CheckButton
class_name DebugDrawCheckButton


@export var drawer_type: DebugDrawer.Type = DebugDrawer.Type.NONE


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	DebugDrawManager.set_drawer_visible(drawer_type, button_pressed)
