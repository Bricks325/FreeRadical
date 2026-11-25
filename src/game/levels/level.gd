extends Node2D
class_name Level
## 关卡节点。


## 初始金币。
@export var cash: int = 200
## 初始生命。
@export var life: int = 20
## 默认塔位样式。
@export_file("*.tscn") var default_tower_holder: String

@export_group("Music")
## 准备阶段播放的音乐数据。
@export var preparation_music: AudioGroup
## 战斗阶段播放的音乐数据。
@export var battling_music: AudioGroup


func _enter_tree() -> void:
	NodeConfigManager.init()
	EntityManager.init()
	EntitySpatialHashManager.init()
		
	GameManager.default_tower_holder = default_tower_holder


func _ready() -> void:
	DebugDrawManager.ready()
	WaveManager.first_wave_sended.connect(_on_first_wave_sended)

	GameManager.cash = cash
	GameManager.life = life
	
	if GameManager.is_battling:
		AudioManager.play_audio(battling_music)
	else:
		AudioManager.play_audio(preparation_music)


func _exit_tree() -> void:
	GameManager.cleanup()
	PathwayManager.cleanup()
	EntityManager.cleanup()
	EntitySpatialHashManager.cleanup()
	GridManager.cleanup()
	SelectManager.cleanup()
	PathwayManager.cleanup()
	WaveManager.cleanup()
	NodeConfigManager.cleanup()
	DamageManager.cleanup()
	DebugDrawManager.cleanup()

	get_tree().paused = false
	Engine.time_scale = 1.0
		

func _on_first_wave_sended() -> void:
	GameManager.is_battling = true
	AudioManager.play_audio(battling_music)
