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
