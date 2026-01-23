extends Node
class_name GameManager

static var instance:GameManager

var Rooms:Array[RoomResource]

var CurrentRoom:RoomResource = null

func _enter_tree() -> void:
	instance = self


func CreateNewRoom():
	CurrentRoom = RoomResource.new()
	pass
	
func FinalizeRoom(_buildpoints:Array[Vector3]):
	CurrentRoom.RoomSquares.append_array(_buildpoints)
	CurrentRoom.RoomArea = AABB(CurrentRoom.RoomSquares[0],CurrentRoom.RoomSquares[CurrentRoom.RoomSquares.size()-1])
	
	var average = Vector3.ZERO
	for i in CurrentRoom.RoomSquares.size():
		average += CurrentRoom.RoomSquares[i]
	average /= CurrentRoom.RoomSquares.size()
	
	Rooms.append(CurrentRoom)
	CurrentRoom = null
