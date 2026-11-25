@tool
extends EditorDock


#region 属性
@export_group("Reference")
## 浏览按钮引用。
@export var browse_button: Button
## 文件选择器引用。
@export var file_dialog: EditorFileDialog
## 全选按钮引用。
@export var select_all_button: Button
## 取消全选按钮引用。
@export var deselect_all_button: Button
## 刷新按钮引用。
@export var refresh_button: Button
## 图集列表引用。
@export var atlas_list: ItemList
## 开始处理按钮引用。
@export var start_button: Button
## 生成 AtlasTexture 复选框引用。
@export var generate_atlas_texture_check_box: CheckBox
## 生成 SpriteFrames 复选框引用。
@export var generate_sprite_frames_check_box: CheckBox

var config: Dictionary
var workspace_dir: String = ""
#endregion


func _ready() -> void:
	browse_button.pressed.connect(_on_browse_button_pressed)
	file_dialog.file_selected.connect(_on_file_selected)
		
	select_all_button.pressed.connect(_on_select_all_button_pressed)
	deselect_all_button.pressed.connect(_on_deselect_all_button_pressed)
	refresh_button.pressed.connect(_on_refresh_button_pressed)
	start_button.pressed.connect(_on_start_button_pressed)

	config = FileUtils.load_json("res://addons/atlas_toolkit/config.json")
	workspace_dir = config.workspace_dir

	_refresh_atlas_list()


func _refresh_atlas_list() -> void:
	atlas_list.clear()
	for file: String in FileUtils.open_directory(workspace_dir).get_files():
		if file.get_extension() != "json":
			continue
			
		atlas_list.add_item(file.get_basename())


func _on_browse_button_pressed() -> void:
	file_dialog.visible = true


func _on_file_selected(path: String) -> void:
	workspace_dir = path
	config.workspace_dir = path
	FileUtils.save_json(config, "res://addons/atlas_toolkit/config.json")
	_refresh_atlas_list()


func _on_select_all_button_pressed() -> void:
	for i: int in atlas_list.item_count:
		atlas_list.select(i, false)


func _on_deselect_all_button_pressed() -> void:
	atlas_list.deselect_all()


func _on_refresh_button_pressed() -> void:
	_refresh_atlas_list()


func _on_start_button_pressed() -> void:
	for i: int in atlas_list.get_selected_items():
		var atlas_stem: String = atlas_list.get_item_text(i)
		var atlas_data_file: String = workspace_dir.path_join(atlas_stem + ".json")
		Log.debug("处理图集数据文件: %s" % atlas_data_file)

		var atlas_data: Dictionary = FileUtils.load_json(atlas_data_file)
		# 一张图集可能被拆为多张子图集
		for sub_atlas_stem: String in atlas_data:
			var atlas_file: String = workspace_dir.path_join(sub_atlas_stem + ".png")
			var atlas: Texture2D = load(atlas_file)
			var resource_types: Dictionary = atlas_data[sub_atlas_stem]

			if generate_atlas_texture_check_box.button_pressed:
				AtlasToolkitAtlasTextureGenerator.new().generate(
					workspace_dir, atlas_stem, resource_types.atlas_texture, atlas
				)
			if generate_sprite_frames_check_box.button_pressed:
				AtlasToolkitSpriteFramesGenerator.new().generate(
					workspace_dir, atlas_stem, resource_types.sprite_frames, atlas
				)
