extends HBoxContainer
class_name SpawnListItem


@export_group("Reference")
@export var spawn_entity_label: Label
@export var spawn_count_label: Label

var spawn_entity_text: String = "":
	set(v):
		spawn_entity_text = v
		spawn_entity_label.text = v
var spawn_count_text: String = "":
	set(v):
		spawn_count_text = v
		spawn_count_label.text = v
