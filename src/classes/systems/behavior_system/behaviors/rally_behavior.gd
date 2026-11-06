extends Behavior
class_name RallyBehavior
## 集结点行为。
##
## [RallyBehavior] 负责处理拥有 [RallyComponent] 的实体。


func _on_update(entity: Entity) -> bool:
	var rally_c: RallyComponent = entity.get_node_or_null(Constants.RALLY_COMPONENT_NODE_PATH)
	if not rally_c:
		return false
		
	if not entity.state & Entity.State.RALLY:
		return false
		
	if rally_c.navigation_agent.is_navigation_finished():
		entity.state = Entity.State.IDLE
		return false

	var next_path_position: Vector2 = rally_c.navigation_agent.get_next_path_position()
	var direction: Vector2 = entity.global_position.direction_to(next_path_position)
	var velocity: Vector2 = (
		direction 
		* rally_c.config.speed 
		* TimeManager.frame_length
	)
	var distance_squared: float = entity.global_position.distance_squared_to(next_path_position)
	if velocity.length_squared() > distance_squared:
		velocity = velocity.limit_length(sqrt(distance_squared))
	
	var next_global_position: Vector2 = entity.global_position + velocity
	entity.facing_global_position = next_global_position
	var animated_sprite_c: AnimatedSpriteComponent = entity.get_node_or_null(Constants.ANIMATED_SPRITE_COMPONENT_NODE_PATH)
	animated_sprite_c.play_animation(entity, rally_c.config.motion_animation, &"walk")
	entity.global_position = next_global_position
	entity.facing_global_position = next_global_position + velocity
	
	return true
