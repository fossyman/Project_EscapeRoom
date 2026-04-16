extends Node
class_name GameManager

static var instance:GameManager

@export var CarPoints:Array[Node3D]

@export var CurrentRoomTimes:Array[Timer]

@export var Exclamation:PackedScene

var CurrentNPCs:Array[BasicAI]
var CurrentNPCGroups:Array[int]
func _enter_tree() -> void:
	instance = self

func AssignNewNPCs(_npcs:Array[BasicAI]):
	CurrentNPCs.append_array(_npcs)
	CurrentNPCGroups.append(CurrentNPCGroups.size())
	var ID = CurrentNPCGroups.size()
	for i in _npcs:
		i.GroupID = ID

func ReturnNPCsByGroup(_id:int = 0) -> Array[BasicAI]:
	var FoundNPCs:Array[BasicAI]
	for i in CurrentNPCs:
		if i == null:
			continue
		if i.GroupID == _id:
			FoundNPCs.append(i)
	return FoundNPCs
	pass


func CarResetAreaEntered(area: Area3D) -> void:
	if area.get_parent() is CarManager:
		area.get_parent().RefreshCar(CarPoints.pick_random().global_transform)
	pass # Replace with function body.

func CreateNewRunTimer(_RoomID:int,_Time:float = 20.0):
	var NewTimer = Timer.new()
	add_child(NewTimer)
	NewTimer.wait_time = _Time
	NewTimer.one_shot = true
	NewTimer.timeout.connect(FinishRun.bind(_RoomID,NewTimer))
	CurrentRoomTimes.append(NewTimer)
	NewTimer.start()

func FinishRun(_RoomID:int,_timer:Timer):
	CurrentRoomTimes.erase(_timer)
	_timer.queue_free()
	BuildManager.instance.Rooms[_RoomID].ClearRoom()
	pass

func SpawnExclamation(_position:Vector3):
	var exc = GameManager.instance.Exclamation.instantiate()
	get_tree().root.add_child(exc)
	exc.global_position = _position

func AddMoney(_amount:float):
	GLOBALS.money += _amount
	cash.instance._update_cash()
	pass
func SubtractMoney(_amount:float):
	GLOBALS.money -= _amount
	cash.instance._update_cash()
	pass
