extends VBoxContainer
class_name WaveEditorSpawnDataVBoxContainer


@export_group("Reference")
@export var spawn_interval: LabeledSpinBox
@export var entity: LabeledOptionButton
@export var pathway: LabeledSpinBox
@export var sub_pathway: LabeledSpinBox
@export var count: LabeledSpinBox
@export var enable_reversed: CheckButton
@export var enable_loop: CheckButton
@export var wave_editor: WaveEditor

var spawn: WaveSpawn = null


func _ready() -> void:
	spawn_interval.value_changed.connect(_on_spawn_interval_changed)
	entity.item_selected.connect(_on_entity_changed)
	pathway.value_changed.connect(_on_pathway_changed)
	sub_pathway.value_changed.connect(_on_sub_pathway_changed)
	count.value_changed.connect(_on_count_changed)
	enable_reversed.toggled.connect(_on_enable_reversed_toggled)
	enable_loop.toggled.connect(_on_enable_loop_toggled)


func set_spawn_data(new_spawn: WaveSpawn) -> void:
	spawn = new_spawn

	spawn_interval.value = spawn.spawn_interval

	entity.option_button.select(wave_editor.enemy_index_dict[spawn.entity])
	pathway.value = spawn.pathway_index
	sub_pathway.value = spawn.sub_pathway_index
	count.value = spawn.count
	spawn_interval.value = spawn.spawn_interval
	enable_reversed.button_pressed = spawn.reversed_enabled
	enable_loop.button_pressed = spawn.loop_enabled


func _on_spawn_interval_changed(value: float) -> void:
	spawn.spawn_interval = value


func _on_entity_changed(index: int) -> void:
	spawn.entity = wave_editor.enemy_scene_dict[index]


func _on_pathway_changed(value: int) -> void:
	spawn.pathway_index = value


func _on_sub_pathway_changed(value: int) -> void:
	spawn.sub_pathway_index = value


func _on_count_changed(value: int) -> void:
	spawn.count = value 


func _on_enable_reversed_toggled(toggled_on: bool) -> void:
	spawn.enable_reversed = toggled_on


func _on_enable_loop_toggled(toggled_on: bool) -> void:
	spawn.enable_loop = toggled_on
