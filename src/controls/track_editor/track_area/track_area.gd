@tool
extends ExternalScrollContainer
class_name TrackEditorTrackArea


## 更新游标位置请求。
signal refresh_cursor_position_request(position_x: float)


var cursor_position_x: float = 100

var _marker_texture: Texture2D
var _marker_texture_color: Color
var _marker_texture_offset: Vector2
var _guide_line: StyleBox
var _guide_line_offset: Vector2


func _ready() -> void:
	_cache_theme_resources()
	theme_changed.connect(_cache_theme_resources)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		refresh_cursor_position_request.emit(event.position.x)


func _draw() -> void:
	var draw_position: Vector2 = Vector2(cursor_position_x, 0)
	draw_texture(_marker_texture, draw_position + _marker_texture_offset, _marker_texture_color)
	draw_style_box(_guide_line, Rect2(draw_position + _guide_line_offset, size))


func refresh_position(position_x: float) -> void:
	cursor_position_x = position_x
	queue_redraw()


func _cache_theme_resources() -> void:
	_marker_texture = get_theme_icon("cursor_marker_texture", TrackEditor.STYLE_TYPE_NAME)
	_marker_texture_color = get_theme_color("cursor_marker_texture_color", TrackEditor.STYLE_TYPE_NAME)
	_marker_texture_offset = Vector2(
		get_theme_constant("cursor_marker_texture_offset_x", TrackEditor.STYLE_TYPE_NAME),
		get_theme_constant("cursor_marker_texture_offset_y", TrackEditor.STYLE_TYPE_NAME)
	)
	_guide_line = get_theme_stylebox("cursor_guide_line", TrackEditor.STYLE_TYPE_NAME)
	_guide_line_offset = Vector2(
		get_theme_constant("cursor_guide_line_offset_x", TrackEditor.STYLE_TYPE_NAME),
		get_theme_constant("cursor_guide_line_offset_y", TrackEditor.STYLE_TYPE_NAME)
	)
