extends Node
class_name GameManager

static var instance:GameManager

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
		if i.GroupID == _id:
			FoundNPCs.append(i)
	return FoundNPCs
	pass
