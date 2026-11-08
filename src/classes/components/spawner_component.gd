@tool
extends Component
class_name SpawnerComponent
## 生成器组件。
##
## [SpawnerComponent] 可以让实体生成其他实体。


@export var config: SpawnerComponentNodeConfig:
	set(v):
		SignalUtils.reconnect_resource_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()
