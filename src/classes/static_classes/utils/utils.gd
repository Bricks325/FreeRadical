@abstract
extends Object
class_name Utils
## 工具函数库。
##
## [Utils] 用于存储通用工具函数。


## 检查是否是有效数字。
static func is_valid_number(n: float) -> bool:
	return n != Constants.UNSET


## 秒转换为帧。
static func seconds_to_frames(seconds: float) -> float:
	return seconds * Constants.FPS


## 帧转换为秒。
static func frames_to_seconds(frames: float) -> float:
	return frames / Constants.FPS