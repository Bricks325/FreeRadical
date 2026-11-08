extends Resource
class_name AudioGroup
## 音频组资源。
## 
## [AudioGroup] 用于存储音频相关的数据。


## 播放模式。
@export var play_mode: AudioManager.AudioPlayMode = AudioManager.AudioPlayMode.SEQUENCE
## 音频路径列表。
@export_file("*.ogg") var list: PackedStringArray
## 音量。
@export_custom(PROPERTY_HINT_NONE, "suffix: db") var volume_db: float = 0.0
## 音量，线性增长而非对数。
@export var volume_linear: float = 1.0
## 延迟（帧）。
@export_custom(PROPERTY_HINT_NONE, "suffix: frame") var delay_frames: float = 0.0

## 当前播放的索引。
var played_index: int
