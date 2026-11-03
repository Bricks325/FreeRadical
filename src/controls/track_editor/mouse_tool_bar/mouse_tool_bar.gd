@tool
extends HBoxContainer
class_name MouseToolBar


## 模式变化时发出。
signal mode_changed(mode: Mode)
## 标志变化时发出。
signal flags_changed(flags: int)


## 模式枚举。
enum Mode {
	## 模式：选择。
	SELECT,
	## 模式：平移。
	PAN,
	## 模式：添加。
	ADD,
	## 模式：擦除。
	ERASE,
	## 模式：移动。
	MOVE,
}


## 标志枚举。
enum Flag {
	## 标志：轨道吸附。
	SNAP = 1,
}


## 模式按钮组。
@export var mode_button_group: ButtonGroup = null

## 当前模式。
var mode: Mode = Mode.SELECT:
	set(v):
		mode = v
		mode_changed.emit(v)
## 当前标志。
var flags: int = Flag.SNAP:
	set(v):
		flags = v
		flags_changed.emit(v)
## 临时切换模式前打开的模式。
var mode_before_temporary_switched: Mode = Mode.SELECT
## 临时切换标志前打开的标志。
var flag_before_temporary_switched: int = 0
## 所有模式按钮。
var mode_buttons: Dictionary[Mode,MouseToolBarModeButton]
## 所有标志按钮。
var flag_buttons: Dictionary[Flag,MouseToolBarFlagButton]


func _ready() -> void:
	mode_button_group.pressed.connect(_on_mode_button_pressed)

	for child: Control in get_children():
		if child is MouseToolBarModeButton:
			mode_buttons[child.mode] = child
			child.button_group = mode_button_group
			continue

		if child is MouseToolBarFlagButton:
			flag_buttons[child.flag] = child

	for mode_button: MouseToolBarModeButton in mode_buttons.values():
		mode_button.temporary_switched_pressed.connect(_on_mode_temporary_switched_pressed)
		mode_button.temporary_switched_released.connect(_on_mode_temporary_switched_released)
	
	for flag_button: MouseToolBarFlagButton in flag_buttons.values():
		flag_button.toggled.connect(_on_flag_button_toggled.bind(flag_button.flag))
		flag_button.temporary_switched_pressed.connect(_on_flag_temporary_switched_pressed)
		flag_button.temporary_switched_released.connect(_on_flag_temporary_switched_released)


func _on_mode_button_pressed(mode_button: MouseToolBarModeButton) -> void:
	mode = mode_button.mode

	Log.info("打开模式: mode=%d" % mode)


func _on_mode_temporary_switched_pressed(button: MouseToolBarModeButton) -> void:
	mode_before_temporary_switched = mode
	button.button_pressed = true

	Log.info("临时切换模式: mode=%d, before_mode=%d" % [button.mode, mode_before_temporary_switched])


func _on_mode_temporary_switched_released(button: MouseToolBarModeButton) -> void:
	mode_buttons[mode_before_temporary_switched].button_pressed = true
	button.button_pressed = false

	Log.info("还原临时切换模式: before_mode=%d" % mode_before_temporary_switched)


func _on_flag_button_toggled(is_toggled: bool, p_flag: Flag) -> void:
	if not is_toggled:
		Log.info("关闭标志: flag=%d" % p_flag)
		flags &= ~p_flag
		return

	flags |= p_flag
	Log.info("打开标志: flag=%d" % p_flag)


func _on_flag_temporary_switched_pressed(button: MouseToolBarFlagButton) -> void:
	flag_before_temporary_switched = flags
	button.button_pressed = true

	Log.info("临时切换标志: flag=%d, before_flag=%d" % [flags, flag_before_temporary_switched])


func _on_flag_temporary_switched_released(_button: MouseToolBarFlagButton) -> void:
	for flag: Flag in flag_buttons.keys():
		var flag_button: MouseToolBarFlagButton = flag_buttons[flag]
		flag_button.button_pressed = flag & flag_before_temporary_switched

	Log.info("还原临时切换标志: before_flag=%d" % flag_before_temporary_switched)
	
