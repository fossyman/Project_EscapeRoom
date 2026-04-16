extends MeshInstance3D
class_name CarManager

@export var CarMeshes:Array[Mesh]

@export var Movespeed:float = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += transform.basis.z * Movespeed * delta
	pass

func RefreshCar(_NewTransform:Transform3D):
	mesh = CarMeshes.pick_random()
	global_transform = _NewTransform
	Movespeed = randf_range(40,60)
