@tool
extends AtlasToolkitGenerator
class_name AtlasToolkitAtlasTextureGenerator
## [AtlasTexture] 资源生成器。


## 生成 [AtlasTexture] 资源。
func generate(
	root_dir: String, 
	atlas_stem: String, 
	textures_data: Dictionary, 
	atlas: Texture2D
) -> void:
	for texture_relative_path_stem: String in textures_data:
		var texture_data: Dictionary = textures_data[texture_relative_path_stem]
		var original_texture: AtlasTexture = restore_original_texture(atlas, texture_data)

		var save_path: String = "%s/%s/atlas_textures/%s.tres" % [root_dir, atlas_stem, texture_relative_path_stem]
		DirAccess.make_dir_recursive_absolute(save_path)
		ResourceSaver.save(original_texture, save_path)
		Log.info("生成 AtlasTexture: %s" % save_path)
