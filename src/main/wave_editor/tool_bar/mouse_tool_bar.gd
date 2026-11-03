@tool
extends MouseToolBar


## 波次编辑器引用。
@export var wave_editor: WaveEditor = null

@onready var track_editors: Array[TrackEditor] = [
	wave_editor.wave_track_editor,
	wave_editor.sub_wave_track_editor,
	wave_editor.spawn_track_editor,
]


func _ready() -> void:
	super()
	mode_changed.connect(_on_mode_changed)
	flags_changed.connect(_on_flags_changed)


func _on_mode_changed(p_mode: Mode) -> void:
	for track_editor: TrackEditor in track_editors:
		track_editor.mouse_tool_bar.mode = p_mode 


func _on_flags_changed(p_flags: int) -> void:
	for track_editor: TrackEditor in track_editors:
		track_editor.mouse_tool_bar.flags = p_flags
