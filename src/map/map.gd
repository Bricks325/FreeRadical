extends Node2D


## 地图背景音乐。
@export var music: AudioGroup = null


func _ready() -> void:
	AudioManager.play_audio(music)
