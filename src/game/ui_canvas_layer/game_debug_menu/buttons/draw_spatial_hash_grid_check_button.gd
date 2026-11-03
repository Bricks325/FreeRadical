extends CheckButton


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed() -> void:
	DebugManager.draw_entity_spatial_hash_grid_enabled = button_pressed
