extends Control
class_name PropEditMenuManager

var SelectedProp:PropScene

@export var PropIcon:TextureRect
@export var PropTitleText:RichTextLabel
@export var PropKeyLocationButton:Button
@export var PropActivationButton:Button

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if SelectedProp:
		global_position = CameraController.instance.Camera.unproject_position(SelectedProp.global_position)
	pass

func InitializeMenu(_prop:PropScene):
	SelectedProp = _prop
	PropIcon.texture = _prop.Icon
	PropTitleText.text = _prop.Name
	visible = true
	pass
	
func CloseMenu():
	visible = false
	SelectedProp = null
	
