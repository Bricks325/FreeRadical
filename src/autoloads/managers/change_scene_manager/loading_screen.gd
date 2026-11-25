extends Control


## 进度条值补间动画持续时间。
@export_custom(PROPERTY_HINT_NONE, "suffix: s") var value_tween_duration: float = 0.1

@export_group("Reference")
## 进度条引用。
@export var progress_bar: TextureProgressBar = null

## 进度条值补间动画引用。
var _value_tween: Tween = null
## 是否加载完毕。
var _is_loading_finished: bool = false


func _ready() -> void:
	ChangeSceneManager.loading_progress_changed.connect(_on_loading_progress_changed)
	ChangeSceneManager.loading_finished.connect(_on_loading_finished)
	progress_bar.value = 0.0


func _on_loading_progress_changed(progress: float) -> void:
	if _value_tween:
		_value_tween.kill()

	_value_tween = create_tween()
	_value_tween.tween_property(progress_bar, "value", progress, value_tween_duration)

	if not _is_loading_finished:
		return

	await _value_tween.finished
	ChangeSceneManager.progress_bar_value_tween_finished.emit()


func _on_loading_finished() -> void:
	_is_loading_finished = true


