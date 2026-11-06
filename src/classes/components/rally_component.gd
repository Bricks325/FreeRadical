@tool
@icon("res://assets/dpi_textures/at-icons/node2d/location.svg")
extends Component
class_name RallyComponent
## 集结组件。
##
## [RallyComponent] 可以让实体移动到指定位置，并支持阵型排列。


const navigation_agent_path: NodePath = ^"NavigationAgent2D"


@export var config: RallyComponentNodeConfig = null:
	set(v): 
		SignalUtils.reconnect_resource_changed(config, v, _on_config_changed)
		config = v
		update_configuration_warnings()
		queue_redraw()

## 集结中心全局位置。
var rally_center_global_position := Vector2.ZERO

## 导航代理节点引用。
@onready var navigation_agent: NavigationAgent2D = get_node_or_null(navigation_agent_path)


func _ready() -> void:
	super()
	
	child_order_changed.connect(_on_child_order_changed)


func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = super()

	if not navigation_agent:
		warnings.append("请增加一个 NavigationAgent2D 子节点用作导航，否则实体无法移动到指定位置。")

	return warnings


## 设置新的集结全局位置。
func new_rally_global_position(
		entity: Entity,
		new_global_position: Vector2, 
		center: Vector2 = new_global_position,
		play_sfx: bool = true
	) -> void:
	if entity.state & Entity.State.WAITING:
		entity.state |= Entity.State.INTERRUPT_WAIT
	
	entity.state = Entity.State.RALLY
	navigation_agent.target_position = new_global_position
	rally_center_global_position = center
	
	if play_sfx:
		AudioManager.play_sfx(config.motion_sfx)


func _on_child_order_changed() -> void:
	navigation_agent = get_node_or_null(navigation_agent_path)
