class_name llButton extends Button

@onready var settings = $"../../../Pausemenu"

func _on_pressed() -> void:
	settings.visible = true
	pass # Replace with function body.
