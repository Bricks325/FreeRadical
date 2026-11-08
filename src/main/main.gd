extends Node2D
class_name Main


## 主页背景音乐。
@export var music: AudioGroup = null


func _ready() -> void:
	AudioManager.play_music(music)
