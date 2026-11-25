extends Resource
class_name StartupAndRecovery
## 前摇和后摇资源。
##
## [StartupAndRecovery] 用于存储前摇和后摇的动画和音效。


## 前摇动画。
@export var startup_animation: FacingAnimationSet
## 前摇音效。
@export var startup_sfx: AudioGroup = null
## 后摇动画。
@export var recovery_animation: FacingAnimationSet
## 后摇音效。
@export var recovery_sfx: AudioGroup = null


## 进行前摇。[br][br]
## -> 是否被中断。
func do_startup(entity: Entity, animated_sprite_c: AnimatedSpriteComponent) -> bool:
	if startup_sfx:
		AudioManager.play_audio(startup_sfx)
	animated_sprite_c.play_animation(entity, startup_animation)
	return await animated_sprite_c.y_wait_animation(entity, startup_animation)


## 进行后摇。[br][br]
## -> 是否被中断。
func do_recovery(entity: Entity, animated_sprite_c: AnimatedSpriteComponent) -> bool:
	if recovery_sfx:
		AudioManager.play_audio(recovery_sfx)
	animated_sprite_c.play_animation(entity, recovery_animation)
	return await animated_sprite_c.y_wait_animation(entity, recovery_animation)
