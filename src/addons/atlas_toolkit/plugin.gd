@tool
extends EditorPlugin


var dock: Control


func _enter_tree():
	dock = preload("res://addons/atlas_toolkit/dock/dock.tscn").instantiate()
	add_dock(dock)


func _exit_tree():
	remove_dock(dock)
	dock.queue_free()
