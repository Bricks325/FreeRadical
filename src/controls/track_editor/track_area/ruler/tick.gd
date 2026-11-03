@tool
extends HBoxContainer
class_name TrackEditorTick


@export var tick_number: Label


func refresh_tick_number(p_tick_number: int) -> void:
	tick_number.text = str(p_tick_number)
