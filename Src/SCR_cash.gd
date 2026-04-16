class_name cash extends Label

static var instance

var rentTax: float = 10


func _ready() -> void:
	instance = self
	_update_cash()

func _process(delta: float) -> void:

	_update_cash()

func _update_cash():
	text = "CAD$: " + str(GLOBALS.money)

func _Tax():
	GLOBALS.money - rentTax
	_update_cash()
