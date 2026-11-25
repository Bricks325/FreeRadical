@tool
extends AtlasToolkitGenerator
class_name AtlasToolkitSpriteFramesGenerator
## [SpriteFrames] 资源生成器。


## 图集数据文件夹。
const DIR_SPRITE_FRAMES_DATAS: String = "res://tools/generate_texture/sprite_frames_datas/"


var animations: Dictionary[String, AnimationData] = {}


func generate(
	root_dir: String, 
	atlas_stem: String, 
	frames_data: Dictionary, 
	atlas: Texture2D
) -> void:
	for frame_relative_path_stem: String in frames_data:
		var frame_data: Dictionary = frames_data[frame_relative_path_stem]
		var original_texture: AtlasTexture = restore_original_texture(atlas, frame_data)
		animations[frame_relative_path_stem] = original_texture

		for alias: String in frame_data.alias:
			animations[alias] = original_texture

	_build_all_sprite_frames()
	_generate_sprite_frames()


## 从精灵帧数据构建 [SpriteFrames] 资源。
func _build_all_sprite_frames() -> void:
	for dir_name: String in FileUtils.open_directory(DIR_SPRITE_FRAMES_DATAS).get_directories():
		var dir_path: String = DIR_SPRITE_FRAMES_DATAS.path_join(dir_name)
		for sprite_frames_data_file_name: String in FileUtils.open_directory(dir_path).get_files():
			if sprite_frames_data_file_name.get_extension() != "tres":
				continue

			var full_path: String = dir_path.path_join(sprite_frames_data_file_name)
			var sprite_frames_data: SpriteFramesData = load(full_path)
			var animation_dict: Dictionary[String, SpriteFramesAnimationData] = sprite_frames_data.animation_dict
			
			var layer_count: int = sprite_frames_data.layer_count
			if layer_count > 0:
				for layer_index: int in range(1, layer_count + 1):
					var layer_sprite_frames_name: String = "%s%d" % [sprite_frames_name, layer_index]
					var sprite_frames: SpriteFrames = _create_sprite_frames(layer_sprite_frames_name, animation_dict)
					sprite_frames_dict[layer_sprite_frames_name] = SpriteFramesItem.new(sprite_frames, dir_name)
			else:
				var sprite_frames: SpriteFrames = _create_sprite_frames(animation_dict)
				sprite_frames_dict[sprite_frames_name] = SpriteFramesItem.new(sprite_frames, dir_name)


## 创建 [SpriteFrames] 资源。
func _create_sprite_frames(sprite_frames_name: String, animation_dict: Dictionary[String, SpriteFramesAnimationData]) -> SpriteFrames:
	var sprite_frames := SpriteFrames.new()
	sprite_frames.remove_animation("default")
		
	for animation_name: String in animation_dict:
		sprite_frames.add_animation(animation_name)
		Log.verbose("增加动画: sprite_frames=%s animation=%s" % [sprite_frames_name, animation_name])

		var animation_data: SpriteFramesAnimationData = animation_dict[animation_name]
		sprite_frames.set_animation_speed(animation_name, animation_data.fps)
		sprite_frames.set_animation_loop_mode(animation_name, animation_data.loop_mode)

		for frame_index: int in range(animation_data.from, animation_data.to + 1):
			var atlas_texture_name: String = "%s_%04d" % [sprite_frames_name, frame_index]
			if atlas_texture_name not in sprite_frames_texture_db:
				Log.error("未找到精灵帧纹理: %s" % atlas_texture_name)
				continue

			var frame: AtlasTexture = sprite_frames_texture_db[atlas_texture_name]
			sprite_frames.add_frame(animation_name, frame)

	return sprite_frames


## 生成 [SpriteFrames] 资源。
func _generate_sprite_frames() -> void:
	for sprite_frames_name: String in sprite_frames_dict:
		var sprite_frames_item: SpriteFramesItem = sprite_frames_dict[sprite_frames_name]

		var dir_path: String = "res://assets/atlas/sprite_frames/%s/" % sprite_frames_item.category
		_ensure_directory(dir_path)
		var save_path: String = dir_path.path_join(sprite_frames_name + ".tres")

		ResourceSaver.save(sprite_frames_item.sprite_frames, save_path)
		Log.info("生成 SpriteFrames: %s" % save_path)