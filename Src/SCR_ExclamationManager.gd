extends Node3D
class_name ExclamationManager

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Use():
	GameManager.instance.AddMoney(50)
	queue_free()
	pass
