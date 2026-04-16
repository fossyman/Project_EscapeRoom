extends Node
class_name RoomResource

var RoomArea:AABB
var RoomSquares:Array[Vector3]
var PlacedProps:Array[PropScene]
var HasDoor:bool = false

var AssignedNPCs:Array[BasicAI]


func ClearRoom():
	for i in AssignedNPCs:
		i.CharacterState = i.CHARACTERSTATE.LEAVING
		i.SetTarget(GLOBALS.CURRENTROOT.NPCSpawnPoints.pick_random().global_position)
	AssignedNPCs.clear()
	var avg = Vector3.ZERO
	for i in RoomSquares:
		avg += i
	avg = avg / RoomSquares.size()
	
	GameManager.instance.SpawnExclamation(avg+ (Vector3.UP*5))
