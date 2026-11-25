extends SelectMenuButton
class_name SelectMenuUpgradeSkillButton


## 升级的技能索引
@export var upgrade_skill_index: int = Constants.UNSET

@export_group("Reference")
@export var price_tag: TextureRect

@onready var price_tag_label: Label = price_tag.get_node("Label")
