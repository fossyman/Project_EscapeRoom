extends Node
class_name GameManager

static var instance:GameManager

func _enter_tree() -> void:
	instance = self
