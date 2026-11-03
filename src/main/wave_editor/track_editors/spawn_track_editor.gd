@tool
extends WaveEditorTrackEditorBase


func _on_item_selected(item: TrackEditorItem) -> void:
	var spawn: WaveSpawn = wave_editor.get_spawn(item.index)
	wave_editor.selected_spawn = spawn
	
	var spawn_data_vbox_container: WaveEditorSpawnDataVBoxContainer = wave_editor.spawn_data_vbox_container
	spawn_data_vbox_container.set_spawn_data(spawn)
	spawn_data_vbox_container.visible = true


func _on_item_deselected(_item: TrackEditorItem) -> void:
	hide_spawn_data_editor()


func _on_item_created(item: TrackEditorItem) -> void:
	var new_spawn := WaveSpawn.new()
	var index: int = item.index
	new_spawn.index = index
	new_spawn.entity = wave_editor.enemy_scene_dict[0]
	new_spawn.interval = calculate_item_tick_gap(item)
	wave_editor.selected_sub_wave.spawn_list.insert(index, new_spawn)
	_refresh_interval()


func _on_item_erased(item: TrackEditorItem) -> void:
	wave_editor.selected_sub_wave.spawn_list.remove_at(item.index)
	for item_index: int in item_list.size():
		var spawn: WaveSpawn = wave_editor.get_spawn(item_index)
		spawn.index = item_index

	_refresh_interval()


func _on_item_move_finished(_item: TrackEditorItem) -> void:
	var item_list_size: int = item_list.size()
	var new_spawn_list: Array[WaveSpawn] = []
	new_spawn_list.resize(item_list_size)

	for item_index: int in item_list_size:
		var item: TrackEditorItem = item_list[item_index]
		var spawn: WaveSpawn = wave_editor.get_spawn(item.last_sort_index)
		spawn.index = item_index
		new_spawn_list[item_index] = spawn

	wave_editor.selected_sub_wave.spawn_list = new_spawn_list
	_refresh_interval()


func _refresh_interval() -> void:
	for item_index: int in item_list.size():
		var item: TrackEditorItem = item_list[item_index]
		var spawn: WaveSpawn = wave_editor.get_spawn(item_index)
		spawn.interval = calculate_item_tick_gap(item)


func hide_spawn_data_editor() -> void:
	wave_editor.spawn_data_vbox_container.visible = false
