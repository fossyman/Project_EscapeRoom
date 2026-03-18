extends Control
class_name PropEditMenuManager

var SelectedProp:PropScene

@export var PropIcon:TextureRect
@export var PropTitleText:RichTextLabel
@export var PropKeyLocationButton:Button
@export var PropActivationButton:Button

@export var HeightSlider:VSlider

@export var PropRotationText:RichTextLabel

@export var PropTransformerButton:TextureButton
@export var PropTransformerCenter:Control
@export var PropTransformerBase:Control
signal OffsetAdjusted

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
	
	PropRotationText.text = str(SelectedProp.MeshContainer.rotation_degrees.y)

	visible = true
	pass
	
func CloseMenu():
	visible = false
	SelectedProp = null
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if PropTransformerButton.button_pressed:
			PropTransformerCenter.global_position = (event.position)
			PropTransformerCenter.position = (PropTransformerCenter.position.snapped(Vector2(10.0,10.0)).limit_length(45.0))
			SetPropOffset( (PropTransformerCenter.position * 0.01))
			
func SetPropHeight(_value:float):
	SelectedProp.MeshContainer.position.y = HeightSlider.value
	pass

func SetPropOffset(_value:Vector2):
	print(_value)
	SelectedProp.MeshContainer.position.x = _value.x
	SelectedProp.MeshContainer.position.z = _value.y
	pass

func AddPropRotation(_amount:float):
	SelectedProp.MeshContainer.rotation_degrees.y += _amount
	SelectedProp.MeshContainer.rotation_degrees.y = wrap(SelectedProp.MeshContainer.rotation_degrees.y,0,360)
	PropRotationText.text = str(SelectedProp.MeshContainer.rotation_degrees.y).trim_suffix(".0")


func RemoveProp() -> void:
	BuildManager.instance.CurrentRoom.PlacedProps.erase(SelectedProp)
	SelectedProp.queue_free()
	CloseMenu()
	pass # Replace with function body.
