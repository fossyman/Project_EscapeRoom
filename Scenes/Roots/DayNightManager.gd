extends Node
class_name DayNightManager
var instance:DayNightManager


@export var DayEnvironment:Environment
@export var NightEnvironment:Environment
@export var World:WorldEnvironment
@export var Light:DirectionalLight3D

@export var CurrentTime:float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#CurrentTime+=0.5*delta
	#
	#var t = sin(CurrentTime)
	#var Rot = sin(CurrentTime*1.8)*20
	#var lightcolour = lerp(Color.WHITE,Color.BLUE,t)
	#Light.light_color = lightcolour
	#Light.rotation.x = CurrentTime*delta
	#Light.shadow_opacity = -t
	#Light.light_energy = clamp(-t,0.0,1.0)
	#
	#pass
	#
#func SetTime(_Time = 0.0):
	#var LightTween:Tween = create_tween()
	#LightTween.tween_property()
