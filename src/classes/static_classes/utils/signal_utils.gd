@abstract
extends Object
class_name SignalUtils
## 信号工具函数库。
##
## [SignalUtils] 用于存储与信号相关的工具函数。


## 重新连接资源的 [signal Resource.changed] 信号，断开旧资源的信号连接，连接新资源的信号连接。
static func reconnect_signal(
		old_object: Object, new_object: Object, signal_name: String, callable: Callable
	) -> void:
	if old_object:
		var old_signal: Signal = old_object.get(signal_name)
		if old_signal.is_connected(callable):
			old_signal.disconnect(callable)

	if new_object:
		var new_signal: Signal = new_object.get(signal_name)	
		if not new_signal.is_connected(callable):
			new_signal.connect(callable)


## 尝试为多个属性的资源的 [signal Resource.changed] 信号连接相应的函数。
static func try_connect_signal(object: Object, signal_name: String, callable: Callable) -> void:
	if not object:
		return

	var object_signal: Signal = object.get(signal_name)
	if object_signal.is_connected(callable):
		return

	object_signal.connect(callable)


## 重新连接资源的 [signal Resource.changed] 信号，断开旧资源的信号连接，连接新资源的信号连接。
static func reconnect_resource_changed(
		old_resource: Resource, new_resource: Resource, callable: Callable
	) -> void:
	reconnect_signal(old_resource, new_resource, "changed", callable)


## 尝试为多个属性的资源的 [signal Resource.changed] 信号连接相应的函数。
static func try_connect_resource_changed(resource: Resource, callable: Callable) -> void:
	try_connect_signal(resource, "changed", callable)
