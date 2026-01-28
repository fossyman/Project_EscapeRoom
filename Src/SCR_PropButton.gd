extends Button
class_name PropButton

@export var Propdata:RES_PropData

func _ready() -> void:
	pressed.connect(BuildManager.instance.PropTool.SetSelectedProp.bind(Propdata))
