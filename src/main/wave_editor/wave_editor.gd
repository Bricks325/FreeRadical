extends Control
class_name WaveEditor


@export_group("Ref")
@export var entity_scene_path_data: EntitySceneData
@export var wave_track_editor: TrackEditor
@export var sub_wave_track_editor: TrackEditor
@export var spawn_track_editor: TrackEditor
@export var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer
@export var entity_labeled_option_button: LabeledOptionButton

## 敌人场景路径到索引的映射。
var enemy_index_dict: Dictionary[String, int] = {}
## 索引到敌人场景路径的映射。
var enemy_scene_dict: Dictionary[int, String] = {}
## 关卡波次组。
var wave_group: WaveGroup
## 选中的波次。
var selected_wave: Wave = null
## 选中的子波次。
var selected_sub_wave: SubWave = null
## 选中的生成组。
var selected_spawn: WaveSpawn = null


func _ready() -> void:
	var enemy_index: int = 0
	for scene_name: String in entity_scene_path_data.entity_name_to_uid_map.keys():
		if not scene_name.begins_with("enemy_"):
			continue

		var option_item: String = tr(scene_name.to_upper())
		entity_labeled_option_button.option_button.add_item(option_item)
		
		var scene_uid: String = entity_scene_path_data.entity_name_to_uid_map[scene_name]
		enemy_index_dict[scene_uid] = enemy_index
		enemy_scene_dict[enemy_index] = scene_uid
		enemy_index += 1

	wave_track_editor.hide_sub_wave_track_editor()

	wave_group = WaveGroup.new()


## 加载关卡波次组。
func load_wave_group(path: String) -> void:
	Log.info("加载关卡波次组: path=%s" % path)
	wave_track_editor.clear_tracks(false)
	wave_track_editor.create_track()
	wave_group = load(path)

	var wave_list: Array[Wave] = wave_group.wave_list
	var current_time: float = 0.0
	for wave_index: int in wave_list.size():
		var wave: Wave = wave_list[wave_index]
		if wave_index != 0:
			current_time += wave.interval

		wave_track_editor.create_item_at_tick_position(0, current_time, false)

	wave_track_editor.hide_sub_wave_track_editor()


## 保存关卡波次组。
func save_wave_group(path: String) -> void:
	Log.info("保存关卡波次组: path=%s" % path)
	ResourceSaver.save(wave_group, path)


## 获取关卡波次。
func get_wave(wave_index: int) -> Wave:
	return wave_group.wave_list[wave_index]


## 获取子波次。
func get_sub_wave(sub_wave_index: int) -> SubWave:
	return selected_wave.sub_wave_list[sub_wave_index]


## 获取生成组。
func get_spawn(spawn_index: int) -> WaveSpawn:
	return selected_sub_wave.spawn_list[spawn_index]
