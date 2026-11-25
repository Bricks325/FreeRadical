extends Node
## 音频管理器。
##
## [AudioManager] 负责管理音频与相关操作。


## 音频播放模式枚举。
enum AudioPlayMode {
	## 音频播放模式：随机播放音频列表中的音频。
	RANDOM,
	## 音频播放模式：按顺序选择并播放音频列表中的音频。
	SEQUENCE,
	## 音频播放模式：并行播放音频列表中的音频。
	CONCURRENCY
}


## 音频播放器组类型枚举。
enum PlayerGroupType {
	## 播放器组类型: 音乐。
	MUSIC,
	## 播放器组类型: 音效。
	SOUND,
	## 播放器组类型: 语音。
	VOICE,
	## 播放器组类型: 环境音。
	AMBIENT
}


## 主音频总线。
const MASTER_BUS: StringName = &"Master"
## 音乐总线。
const MUSIC_BUS: StringName = &"Music"
## 音效总线。
const SOUND_BUS: StringName = &"Sound"
## 语音总线。
const VOICE_BUS: StringName = &"Voice"
## 环境音总线。
const AMBIENT_BUS: StringName = &"Ambient"

## 音频播放器组配置。
const _PLAYER_GROUP_CONFIG: Dictionary[PlayerGroupType, Array] = {
	PlayerGroupType.MUSIC: [1, MUSIC_BUS],
	PlayerGroupType.SOUND: [16, SOUND_BUS],
	PlayerGroupType.VOICE: [4, VOICE_BUS],
	PlayerGroupType.AMBIENT: [8, AMBIENT_BUS],
}


#region 属性
## 音频资源缓存。
var _audio_resources_caches: Dictionary[String, AudioStream] = {}
## 音频播放器组。
var _player_groups: Dictionary[PlayerGroupType, AudioPlayerGroup] = {}
#endregion


func _ready() -> void:
	for player_group_type: PlayerGroupType in _PLAYER_GROUP_CONFIG.keys():
		var config: Array = _PLAYER_GROUP_CONFIG[player_group_type]
		var player_count: int = config[0]
		var bus: StringName = config[1]

		var player_group := AudioPlayerGroup.new(player_count, bus)
		_player_groups[player_group_type] = player_group
		add_child(player_group)


#region 公开方法
## 清理音频管理器。
func cleanup() -> void:
	for player_group: AudioPlayerGroup in _player_groups.values():
		player_group.cleanup()

	_audio_resources_caches.clear()


## 停止指定的播放器组中的所有播放器。
func stop_all_player_group(player_group_type: PlayerGroupType) -> void:
	var player_group: AudioPlayerGroup = _player_groups[player_group_type]
	player_group.stop_all()


## 停止所有播放器组中的所有播放器。
func stop_all() -> void:
	for player_group_type: PlayerGroupType in _player_groups.keys():
		stop_all_player_group(player_group_type)


## 播放音频数据内的音频。
func play_audio(audio_data: AudioGroup) -> void:
	var play_stream_paths := PackedStringArray()
	var paths: PackedStringArray = audio_data.list
	match audio_data.play_mode:
		AudioPlayMode.RANDOM:
			var stream_path: String = ArrayUtils.pick_random(paths)
			play_stream_paths = [stream_path]

		AudioPlayMode.SEQUENCE:
			var play_index: int = audio_data.played_index + 1
			play_index %= paths.size()

			var stream_path: String = paths[play_index]
			audio_data.played_index = play_index

			play_stream_paths = [stream_path]
		AudioPlayMode.CONCURRENCY:
			play_stream_paths = paths

	var player_group: AudioPlayerGroup = _player_groups[audio_data.player_group_type]
	var player: AudioStreamPlayer = player_group.get_next_player()
	var bus: StringName = player_group.bus
	for stream_path: String in play_stream_paths:
		var stream: AudioStream = load(stream_path)
		_audio_resources_caches[stream_path] = stream
		player.stream = stream
		player.volume_db = audio_data.volume_db
		player.volume_linear = audio_data.volume_linear
		player.bus = bus
		player.play()
#endregion
