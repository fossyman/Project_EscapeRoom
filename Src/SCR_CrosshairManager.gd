extends Node3D
class_name CursorManager

@export var CrosshairNorthPin:Node3D
@export var CrosshairSouthPin:Node3D
@export var CrosshairEastPin:Node3D
@export var CrosshairWestPin:Node3D

@export var MeshParent:Node3D

@export var PropPlacement:MeshInstance3D

@export var CrosshairSpacing:float

@export var Frequency:float = 10
@export var Amplification:float = 0.1

var SineTime:float = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	SineTime += delta
	var sine = sin(SineTime * Frequency)* Amplification
	CrosshairNorthPin.position.z = CrosshairSpacing + sine
	CrosshairSouthPin.position.z = -CrosshairSpacing + -sine

	CrosshairEastPin.position.x = CrosshairSpacing + sine
	CrosshairWestPin.position.x = -CrosshairSpacing + -sine
	pass
