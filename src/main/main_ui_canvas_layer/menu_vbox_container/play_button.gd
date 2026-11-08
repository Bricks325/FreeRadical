extends Button


## 地图场景路径。
@export_file("*.tscn") var map_scene_path: String


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	ChangeSceneManager.enter_scene(map_scene_path)
