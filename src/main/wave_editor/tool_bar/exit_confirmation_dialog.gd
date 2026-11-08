extends ConfirmationDialog


## 主场景路径。
@export_file("*.tscn") var main_scene_path: String


func _ready() -> void:
	confirmed.connect(_on_confirmed)


func _on_confirmed() -> void:
	ChangeSceneManager.enter_scene(main_scene_path)
