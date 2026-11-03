@abstract
extends Object
class_name Utils
## 工具函数库。
##
## [Utils] 用于存储通用工具函数。


## 检查是否是有效数字。
static func is_valid_number(n: float) -> bool:
	return n != Constants.UNSET