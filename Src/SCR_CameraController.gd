extends Node3D
class_name CameraController

static var instance

var threshold = 1
var step = 0.3

var LerpSpeed:float = 12.0
var TargetPosition:Vector3 = Vector3.ZERO
var TargetRotation:Vector3 = Vector3(0,-45,0)

var viewport_size = Vector2(1280,720)
var viewport:Viewport

var CurrentScroll:float = 0.0
var RotateTween:Tween

@export var DragDeadzone:float = 1.0
var DragValue:Vector2

@export var CameraPositionRoot:Node3D
@export var CameraHolder:Node3D
@export var Camera:Camera3D

var delta:float

var Movespeed:float = 0.3

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	viewport = get_viewport()
	viewport_size = viewport.get_visible_rect().size
	print(viewport.name)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	delta = _delta
	MoveCam()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			CurrentScroll += 1.0
			CurrentScroll = clamp(CurrentScroll,-1.0,3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			CurrentScroll += -1.0
			CurrentScroll = clamp(CurrentScroll,-1.0,3.0)
			
	if event is InputEventMouseMotion:
		if Input.is_action_pressed("RClick"):
			DragValue = (event.relative * Movespeed * 0.1)
			TargetPosition += ( global_basis.x * -DragValue.x)
			TargetPosition += ( global_basis.z * -DragValue.y )
			print(DragValue)
		

func MoveCam():
	CameraHolder.position = lerp(CameraHolder.position,Vector3(0,-CurrentScroll*1.5,-CurrentScroll* 0.5),LerpSpeed*delta)
	
	CameraHolder.rotation_degrees.x = lerp(CameraHolder.rotation_degrees.x,-CurrentScroll * 8, LerpSpeed * delta)
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		TargetPosition += direction * Movespeed
	
	var local_mouse_pos = viewport.get_mouse_position()
	if local_mouse_pos.x < threshold:
		#TargetPosition.z -= step
		#TargetPosition.x -= step
		TargetPosition -= Camera.global_basis.x * Movespeed
	elif local_mouse_pos.x >= viewport_size.x - threshold:
		#TargetPosition.z += step
		#TargetPosition.x += step
		TargetPosition += Camera.global_basis.x * step
	if local_mouse_pos.y < threshold:
		#TargetPosition.x += step
		#TargetPosition.z -= step
		TargetPosition -= global_basis.z * Movespeed
	elif local_mouse_pos.y >= viewport_size.y - threshold:
		#TargetPosition.x -= step
		#TargetPosition.z += step
		TargetPosition += global_basis.z * Movespeed
	global_position = lerp(global_position, TargetPosition, LerpSpeed * delta)
	
	rotation.y = lerp_angle(rotation.y,deg_to_rad(TargetRotation.y),LerpSpeed* delta)
	
	if Input.is_action_just_released("RClick"):
		DragValue = Vector2.ZERO
	
	if Input.is_action_just_pressed("rotate_camera_left"):
		RotateCam(-1)
	if Input.is_action_just_pressed("rotate_camera_right"):
		RotateCam(1)

func RotateCam(_value:int):
	TargetRotation.y += 90 * _value
	pass
	
