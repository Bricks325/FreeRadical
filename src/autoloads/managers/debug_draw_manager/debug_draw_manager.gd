@tool
extends Node2D
## 调试绘制管理器。
## 
## [DebugDrawManager] 负责管理调试与相关操作。


## 调试绘制器可见性改变时发出。
signal drawer_visible_changed(drawer: DebugDrawer)


## 调试绘制器字典。
var _drawers: Dictionary[DebugDrawer.Type, DebugDrawer] = {}
## 调试绘制器类型到可见性映射。
var _drawer_type_to_visible: Dictionary[DebugDrawer.Type, bool] = {}


func _ready() -> void:
	for drawer_type: DebugDrawer.Type in DebugDrawer.Type.values():
		_drawer_type_to_visible[drawer_type] = false

	for drawer: DebugDrawer in get_children():
		drawer.visible = false
		_drawers[drawer.drawer_type] = drawer


func ready() -> void:
	for drawer: DebugDrawer in _drawers.values():
		drawer.ready()


func cleanup() -> void:
	for drawer_type: DebugDrawer.Type in _drawers.keys():
		set_drawer_visible(drawer_type, false)


## 设置调试绘制器是否可见。
func set_drawer_visible(drawer_type: DebugDrawer.Type, p_visible: bool) -> void:
	if _drawer_type_to_visible[drawer_type] == p_visible:
		return

	var drawer: DebugDrawer = _drawers.get(drawer_type)
	if drawer:
		drawer.visible = p_visible
	
	_drawer_type_to_visible[drawer_type] = p_visible
	drawer_visible_changed.emit(drawer)


## 调试绘制器是否可见。
func is_drawer_visible(drawer_type: DebugDrawer.Type) -> bool:
	return _drawer_type_to_visible[drawer_type]
