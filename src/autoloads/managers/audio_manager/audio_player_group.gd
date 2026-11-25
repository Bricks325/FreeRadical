extends Node
class_name AudioPlayerGroup
## 音频播放器组。


## 播放器总线。
var bus: StringName
## 播放器总数。
var player_count: int
## 播放器列表。
var players: Array[AudioStreamPlayer] = []

## 下一个播放器索引。
var _next_index: int = 0


func _init(p_player_count: int, p_bus: StringName) -> void:
	player_count = p_player_count
	bus = p_bus


func _ready() -> void:
	players.fill(player_count)
	for player_index: int in player_count:
		var sound_player := AudioStreamPlayer.new()
		add_child(sound_player)
		players[player_index] = sound_player


func cleanup() -> void:
	_next_index = 0
	stop_all()


## 停止所有播放器。
func stop_all() -> void:
	for player in get_children():
		player.stop()
	

## 获取下一个可用播放器。
func get_next_player() -> AudioStreamPlayer:
	var player: AudioStreamPlayer = players[_next_index]
	_next_index = (_next_index + 1) % player_count
	return player
