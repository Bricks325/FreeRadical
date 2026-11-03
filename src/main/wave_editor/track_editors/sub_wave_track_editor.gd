@tool
extends WaveEditorTrackEditorBase


func _ready() -> void:
	super()
	track_erased.connect(_on_track_erased)


func _on_item_selected(item: TrackEditorItem) -> void:
	var sub_wave: SubWave = wave_editor.get_sub_wave(item.index)
	wave_editor.selected_sub_wave = sub_wave
	var spawn_track_editor: TrackEditor = wave_editor.spawn_track_editor
	spawn_track_editor.clear_tracks(false)
	spawn_track_editor.create_track()

	var current_time: float = 0.0
	var spawn_list: Array[WaveSpawn] = sub_wave.spawn_list
	for spawn_index: int in spawn_list.size():
		var spawn: WaveSpawn = spawn_list[spawn_index]
		current_time += spawn.interval
		spawn_track_editor.create_item_at_tick_position(0, current_time, false)

	spawn_track_editor.visible = true


func _on_item_deselected(_item: TrackEditorItem) -> void:
	hide_spawn_track_editor()


func _on_item_created(item: TrackEditorItem) -> void:
	var sub_wave := SubWave.new()
	var index: int = item.index
	sub_wave.index = index
	sub_wave.delay = item.tick_position_x
	wave_editor.selected_wave.sub_wave_list.insert(index, sub_wave)
	
	_refresh_delay()


func _on_item_erased(item: TrackEditorItem) -> void:
	wave_editor.selected_wave.sub_wave_list.remove_at(item.index)
	for sub_wave_index: int in item_list.size():
		var sub_wave: SubWave = wave_editor.get_sub_wave(sub_wave_index)
		sub_wave.index = sub_wave_index
	
	_refresh_delay()


func _on_item_move_finished(item: TrackEditorItem) -> void:
	var sub_wave: SubWave = wave_editor.get_sub_wave(item.index)
	sub_wave.delay = item.tick_position_x
	
	var item_list_size: int = item_list.size()
	var new_sub_wave_list: Array[SubWave] = []
	new_sub_wave_list.resize(item_list_size)
	for item_index: int in item_list_size:
		var sub_wave_item: TrackEditorItem = item_list[item_index]
		var last_sub_wave: SubWave = wave_editor.get_sub_wave(sub_wave_item.last_sort_index)
		last_sub_wave.index = item_index
		new_sub_wave_list[item_index] = last_sub_wave

	wave_editor.selected_wave.sub_wave_list = new_sub_wave_list
	_refresh_delay()


func _on_track_erased(track: TrackEditorTrack) -> void:
	wave_editor.selected_wave.sub_wave_list.remove_at(track.get_index())


func hide_spawn_track_editor() -> void:
	wave_editor.spawn_track_editor.visible = false
	wave_editor.spawn_data_vbox_container.visible = false


func _refresh_delay() -> void:
	for item_index: int in item_list.size():
		var item: TrackEditorItem = item_list[item_index]
		var sub_wave: SubWave = wave_editor.get_sub_wave(item_index)
		sub_wave.delay = calculate_item_tick_gap(item)
