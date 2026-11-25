extends Node
## 切换场景管理器。
## 
## [ChangeSceneManager] 负责切换场景与相关操作。


## 场景加载进度变化时发出。
signal loading_progress_changed(percent: float)
## 场景加载完毕时发出。
signal loading_finished
## 进度条值补间动画完成时发出。
signal progress_bar_value_tween_finished


@export_group("Reference")
@export var loading_screen_scene: PackedScene

## 目标场景路径。
var _target_scene_path: String
## 场景加载时间戳。
var _load_time_stamp: float


func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED


func _process(_delta: float):
	var progress: Array = []
	var status: int = ResourceLoader.load_threaded_get_status(_target_scene_path, progress)
	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			loading_progress_changed.emit(progress[0])
		ResourceLoader.THREAD_LOAD_LOADED:
			process_mode = Node.PROCESS_MODE_DISABLED

			var load_time: float = Time.get_ticks_msec() - _load_time_stamp
			Log.debug("场景加载完毕：scene_path=%s, load_time=%.2fms" % [ResourceUID.uid_to_path(_target_scene_path), load_time])
			
			loading_finished.emit()
			loading_progress_changed.emit(1.0)
			await progress_bar_value_tween_finished

			var scene: PackedScene = ResourceLoader.load_threaded_get(_target_scene_path)
			Log.debug("切换场景: %s" % ResourceUID.uid_to_path(_target_scene_path))
			get_tree().change_scene_to_packed(scene)


func enter_scene(scene_path: String):
	_load_time_stamp = Time.get_ticks_msec()
	_target_scene_path = scene_path
	
	get_tree().change_scene_to_packed(loading_screen_scene)
	
	process_mode = Node.PROCESS_MODE_INHERIT
	ResourceLoader.load_threaded_request(_target_scene_path, "", true)
	AudioManager.cleanup()
	TimeManager.cleanup()
