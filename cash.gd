class_name cash extends Label

var rentTax: float = 10


func _ready() -> void:
	_update_cash()

func _process(delta: float) -> void:

	_update_cash()

func _update_cash():
	text = "cash: " + str(GLOBALS.money)
