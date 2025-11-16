extends Control
class_name DEBUGTOOLS

static var instance:DEBUGTOOLS

var IsDebugVisible:bool = true

var ViewPort:Viewport

@export var Tabs:Array[Control]

@export var Gyro:Node3D

@export var FPSText:RichTextLabel
@export var SystemInfoText:RichTextLabel

func _enter_tree() -> void:
	instance = self
	ToggleDebugMenu()
func _ready() -> void:
	ViewPort = get_tree().root.get_viewport()
	SystemInfoText.text = "Operating System: " + OS.get_name() + "\n" + "GPU: " + RenderingServer.get_video_adapter_name() + "\n" + "CPU: " + OS.get_processor_name() + "\n" + "Motherboard: " + OS.get_model_name()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if IsDebugVisible:
		FPSText.text = "FPS: " + str(Engine.get_frames_per_second())
		
	if Input.is_action_just_pressed("DEBUG_TOGGLE"):
		IsDebugVisible = !IsDebugVisible
		ToggleDebugMenu()
	pass

func ToggleDebugMenu():
	visible = IsDebugVisible
	GLOBALS.CanInteract = !IsDebugVisible
	pass


func On_Views_Button_Clicked(index: int, at_position: Vector2, mouse_button_index: int) -> void:
	match(index):
		0: # DEFAULT
			ViewPort.debug_draw = Viewport.DEBUG_DRAW_DISABLED
			pass
		1: # WIREFRAME
			ViewPort.debug_draw = Viewport.DEBUG_DRAW_WIREFRAME
			pass
		2: # OVERDRAW
			ViewPort.debug_draw = Viewport.DEBUG_DRAW_OVERDRAW
			pass
		3: # NORMALS
			ViewPort.debug_draw = Viewport.DEBUG_DRAW_NORMAL_BUFFER
			pass
		_: # UNKNOWN
			ViewPort.debug_draw = Viewport.DEBUG_DRAW_DISABLED
			pass
	pass # Replace with function body.


func OnDebugTabPressed(tab: int) -> void:
	print(tab)
	for i in Tabs.size():
		Tabs[i].visible = false
	Tabs[tab].visible = true
	pass # Replace with function body.
