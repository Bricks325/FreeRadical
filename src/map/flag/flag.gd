@tool
extends Node2D


## 关卡场景路径。
@export_file("*.tscn") var level_scene_path: String:
	set(v):
		level_scene_path = v
		update_configuration_warnings()

@export_group("Reference")
@export var animated_sprite: AnimatedSprite2D
@export var area: Area2D


func _ready() -> void:
	area.input_event.connect(_on_input_event)
	
	animated_sprite.play("unlocked_idle")


func _get_configuration_warnings() -> PackedStringArray:
	var warnings := PackedStringArray()
		
	if not level_scene_path:
		warnings.append("请在 level_scene_path 中设置一个关卡场景路径，否则点击旗帜不会进入关卡。")
		
	return warnings


func _on_input_event(_viewport: Node, event: InputEvent, _shape_index: int):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			ChangeSceneManager.enter_scene(level_scene_path)
