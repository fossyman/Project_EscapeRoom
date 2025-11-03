extends Node3D

var threshold = 10
var step = 0.3

var LerpSpeed:float = 12.0
var TargetPosition:Vector3 = Vector3.ZERO
var TargetRotation:Vector3 = Vector3(0,-45,0)

var viewport_size = Vector2(3838,2158)
var viewport:Viewport

var CurrentScroll:float = 0.0
var RotateTween:Tween

@export var CameraPositionRoot:Node3D
@export var CameraHolder:Node3D
@export var Camera:Node3D

var window_size = DisplayServer.window_get_size()

var delta:float

@export var MousePositionText:RichTextLabel
@export var ShouldMoveText:RichTextLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	viewport = get_viewport()
	viewport_size = viewport.get_visible_rect().size
	print(viewport_size)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	delta = delta
	CameraHolder.position = lerp(CameraHolder.position,Vector3(0,-CurrentScroll*1.5,-CurrentScroll* 0.5),LerpSpeed*delta)
	
	CameraHolder.rotation_degrees.x = lerp(CameraHolder.rotation_degrees.x,-CurrentScroll * 8, LerpSpeed * delta)
	var local_mouse_pos = viewport.get_mouse_position()
	MousePositionText.text = str(local_mouse_pos)
	print(viewport_size.x)
	if local_mouse_pos.x < threshold:
		#TargetPosition.z -= step
		#TargetPosition.x -= step
		TargetPosition -= Camera.global_basis.x * step
		ShouldMoveText.text = "TRUE L"
	elif local_mouse_pos.x > viewport_size.x - threshold:
		#TargetPosition.z += step
		#TargetPosition.x += step
		TargetPosition += Camera.global_basis.x * step
		ShouldMoveText.text = "TRUE R"
		
	if local_mouse_pos.y < threshold:
		#TargetPosition.x += step
		#TargetPosition.z -= step
		TargetPosition -= global_basis.z * step
		ShouldMoveText.text = "TRUE U"
	if local_mouse_pos.y > viewport_size.y - threshold:
		#TargetPosition.x -= step
		#TargetPosition.z += step
		TargetPosition += global_basis.z * step
		ShouldMoveText.text = "TRUE D"
	
	global_position = lerp(global_position, TargetPosition, LerpSpeed * delta)
	
	rotation.y = lerp_angle(rotation.y,deg_to_rad(TargetRotation.y),LerpSpeed* delta)
	
	if Input.is_action_just_pressed("rotate_camera_left"):
		RotateCam(-1)
	if Input.is_action_just_pressed("rotate_camera_right"):
		RotateCam(1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			CurrentScroll += 1.0
			CurrentScroll = clamp(CurrentScroll,-1.0,3.0)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			CurrentScroll += -1.0
			CurrentScroll = clamp(CurrentScroll,-1.0,3.0)
		

func MoveCam(_value:Vector2):
	
	pass

func RotateCam(_value:int):
	TargetRotation.y += 90 * _value
	pass
