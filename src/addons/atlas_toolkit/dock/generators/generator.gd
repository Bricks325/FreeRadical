@tool
@abstract
extends RefCounted
class_name AtlasToolkitGenerator
## 生成器基类。


@abstract
## 生成资源。
func generate(
	root_dir: String, atlas_stem: String, atlas_data: Dictionary, atlas: Texture2D
) -> void


## 从被裁剪透明边的纹理恢复原始纹理。
func restore_original_texture(atlas: Texture2D, texture_data: Dictionary) -> AtlasTexture:
	var original_texture: AtlasTexture = AtlasTexture.new()
	original_texture.atlas = atlas

	var region: Array = texture_data.region
	original_texture.region = Rect2(
		region[0], region[1], region[2], region[3]
	)
	original_texture.filter_clip = true

	var trim: Array = texture_data.trim
	var trim_x: int = trim[0]
	var trim_y: int = trim[1]
	var trim_w: int = trim_x + trim[2]
	var trim_h: int = trim_y + trim[3]
	original_texture.margin = Rect2(trim_x, trim_y, trim_w, trim_h)

	return original_texture