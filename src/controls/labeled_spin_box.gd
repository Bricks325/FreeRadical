@tool
extends HBoxContainer
class_name LabeledSpinBox


signal value_changed(value: float)


@export_category("Label")
## 标签文本。
@export var text: String = "":
	set(v): 
		text = v
		if label:
			label.text = v
		
@export_category("SpinBox")
## 数值调节框前缀。
@export var prefix: String = "":
	set(v): 
		prefix = v
		if spin_box:
			spin_box.prefix = v
## 数值调节框后缀。
@export var suffix: String = "":
	set(v): 
		suffix = v
		if spin_box:
			spin_box.suffix = v
## 数值调节框步长。
@export var step: float = 0.0:
	set(v): 
		step = v
		if spin_box:
			spin_box.step = v
## 数值调节框值。
@export var value: float = 0.0:
	set(v): 
		value = v
		if spin_box:
			spin_box.value = v

@export_group("Reference")
## 数值调节框引用。
@export var spin_box: SpinBox = null
## 标签引用。
@export var label: Label = null


func _ready():
	spin_box.value_changed.connect(_on_value_changed)

	label.text = text
	spin_box.prefix = prefix
	spin_box.suffix = suffix
	spin_box.step = step
	spin_box.value = value


func _on_value_changed(p_value: float) -> void:
	value_changed.emit(p_value)
