@tool
@abstract
extends TrackEditor
class_name WaveEditorTrackEditorBase


@export var wave_editor: WaveEditor = null


func _ready() -> void:
	super()
	item_selected.connect(_on_item_selected)
	item_deselected.connect(_on_item_deselected)
	item_created.connect(_on_item_created)
	item_erased.connect(_on_item_erased)
	item_move_finished.connect(_on_item_move_finished)


@abstract
func _on_item_selected(item: TrackEditorItem) -> void


@abstract
func _on_item_deselected(item: TrackEditorItem) -> void


@abstract
func _on_item_created(item: TrackEditorItem) -> void


@abstract
func _on_item_erased(item: TrackEditorItem) -> void


@abstract
func _on_item_move_finished(item: TrackEditorItem) -> void
