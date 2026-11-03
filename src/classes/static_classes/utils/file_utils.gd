@abstract
extends Object
class_name FileUtils
## 文件工具函数库。
##
## [FileUtils] 用于存储与文件相关的工具函数。


## 打开文件，会在打开失败时记录错误信息，见 [method FileAccess.open]。
static func open_file(path: String, flags: int) -> FileAccess:
	var file := FileAccess.open(path, flags)
	if not file:
		Log.error("无法打开文件: path=%s error=%s" % [path, error_string(FileAccess.get_open_error())])

	return file


## 打开目录，会在打开失败时记录错误信息，见 [method DirAccess.open]。
static func open_directory(path: String) -> DirAccess:
	var dir := DirAccess.open(path)
	if not dir:
		Log.error("无法打开目录: path=%s error=%s" % [path, error_string(DirAccess.get_open_error())])

	return dir


## 递归获取目录下所有文件。
static func get_files_from_nested_directory(dir_path: String, match_pattern: String = "") -> PackedStringArray:
	var file_path_list := PackedStringArray()
	var dir: DirAccess = open_directory(dir_path)

	dir.list_dir_begin()
	var item: String = dir.get_next()
	while item != "":
		var item_path: String = dir_path.path_join(item)

		if dir.dir_exists(item_path):
			file_path_list.append_array(get_files_from_nested_directory(item_path, match_pattern))
		elif dir.file_exists(item_path) and item_path.match(match_pattern):
			file_path_list.append(item_path)

		item = dir.get_next()
	dir.list_dir_end()

	return file_path_list


#region JSON 工具函数
## 加载 JSON 文件。
static func load_json(path: String) -> Variant:
	var file := open_file(path, FileAccess.READ)
	if not file:
		return null

	var content: String = file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result: int = json.parse(content)
	if parse_result != OK:
		Log.error(
			"JSON 解析错误: path=%s error=line%d, %s" % [path, json.get_error_line(), json.get_error_message()]
		)
		return null

	return json.get_data()


## 保存 JSON 文件。
static func save_json(data: Variant, file_path: String, indent: String = "\t") -> void:
	var file := open_file(file_path, FileAccess.WRITE)
	if not file:
		return

	var json_string: String = JSON.stringify(data, indent)
	file.store_string(json_string)
	file.close()
#endregion


## 保存并加载资源。
static func save_and_load_resource(resource: Resource, save_path: String, type_hint: String = "", cache_mode: int = ResourceLoader.CACHE_MODE_REPLACE) -> Resource:
	ResourceSaver.save(resource, save_path)
	return ResourceLoader.load(save_path, type_hint, cache_mode)
