@tool
extends WaveEditorTrackEditorBase


func _on_item_selected(item: TrackEditorItem) -> void:
	var wave: Wave = wave_editor.get_wave(item.index)
	wave_editor.selected_wave = wave

	var sub_wave_track_editor: TrackEditor = wave_editor.sub_wave_track_editor
	sub_wave_track_editor.clear_tracks(false)

	var sub_wave_list: Array[SubWave] = wave.sub_wave_list

	if not sub_wave_list:
		sub_wave_track_editor.create_track()
	else:
		sub_wave_list.sort_custom(
			func(a: SubWave, b: SubWave) -> bool:
				return a.delay < b.delay
		)

	var delay_use_count_dict: Dictionary[float, int] = {}
	
	for sub_wave_index: int in sub_wave_list.size():
		var sub_wave: SubWave = sub_wave_list[sub_wave_index]
		var delay: float = sub_wave.delay

		if delay not in delay_use_count_dict:
			delay_use_count_dict[delay] = 0

		delay_use_count_dict[delay] += 1

		var use_count: int = delay_use_count_dict[delay]

		if sub_wave_track_editor.track_vbox_container.get_child_count() < use_count:
			sub_wave_track_editor.create_track()
		
		sub_wave_track_editor.create_item_at_tick_position(use_count - 1, delay, false)

	sub_wave_track_editor.visible = true


func _on_item_deselected(_item: TrackEditorItem) -> void:
	hide_sub_wave_track_editor()


func _on_item_created(item: TrackEditorItem) -> void:
	var wave := Wave.new()
	var index: int = item.index
	wave.index = index
	wave.interval = calculate_item_tick_gap(item)
	wave_editor.wave_group.wave_list.insert(index, wave)
	_refresh_interval()


func _on_item_erased(item: TrackEditorItem) -> void:
	var item_index: int = item.index
	if wave_editor.get_wave(item_index) == wave_editor.selected_wave:
		hide_sub_wave_track_editor()
		
	wave_editor.wave_group.wave_list.remove_at(item_index)
	for wave_index: int in item_list.size():
		var wave: Wave = wave_editor.get_wave(wave_index)
		wave.index = wave_index

	_refresh_interval()


func _on_item_move_finished(_item: TrackEditorItem) -> void:
	var item_list_size: int = item_list.size()
	var new_wave_list: Array[Wave] = []
	new_wave_list.resize(item_list_size)

	for item_index: int in item_list_size:
		var item: TrackEditorItem = item_list[item_index]
		var wave: Wave = wave_editor.get_wave(item.last_sort_index)
		wave.index = item_index
		new_wave_list[item_index] = wave

	wave_editor.wave_group.wave_list = new_wave_list
	_refresh_interval()


func hide_sub_wave_track_editor() -> void:
	wave_editor.sub_wave_track_editor.visible = false
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false
	

func _refresh_interval() -> void:
	for item_index: int in item_list.size():
		var item: TrackEditorItem = item_list[item_index]
		var wave: Wave = wave_editor.get_wave(item_index)
		wave.interval = calculate_item_tick_gap(item)
