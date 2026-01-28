extends Node
class_name PropPlacer

var SelectedProp:RES_PropData

func PlaceProp(_location:Vector3):
	if !SelectedProp:
		return
	print("Placing Prop")
	var placement = SelectedProp._Scene.instantiate()
	BuildManager.instance.CurrentRoomScene.PropContainer.add_child(placement)
	placement.position = _location
	placement.rotation_degrees = BuildManager.instance.CellRotationToEuler(BuildManager.instance.GetAverageWallRotationIndex(_location,true))
	BuildManager.instance.CurrentRoom.PlacedProps.append(SelectedProp)
	BuildManager.instance.CurrentRoom.PlacedPropLocations.append(_location)
	pass

func SetSelectedProp(_data:RES_PropData):
	SelectedProp = _data
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MASK_LEFT:
			PlaceProp(BuildManager.instance.mouse_position(true))
			pass
