extends Control

@export var NPCScene:PackedScene


@export var NPCSpawnCountText:RichTextLabel
var NPCSpawnCount:int = 0


func _ready() -> void:
	visible = false
	pass
	
func ChangeMenuVisibility():
	visible = !visible

func ChangeNPCSpawnAmount(_amount:int = 0):
	NPCSpawnCount += _amount
	NPCSpawnCount = clamp(NPCSpawnCount,1,4)
	NPCSpawnCountText.text = str(NPCSpawnCount)
	pass

func SpawnNPC():
	var SpawnPoint = GLOBALS.CURRENTROOT.NPCSpawnPoints.pick_random().global_position
	for i in NPCSpawnCount:
		var _spawn = NPCScene.instantiate()
		GLOBALS.CURRENTROOT.add_child(_spawn)
		_spawn.global_position = SpawnPoint
	pass

func AssignNPCsToLatestRoom():
	
	pass


func SendNPCToRoom() -> void:
	var Npcs = GameManager.instance.ReturnNPCsByGroup()
	if Npcs.is_empty():
		return
	
	for i in Npcs:
		i.CurrentRoom = BuildManager.instance.Rooms[0]
		i.AI_TICK()
	pass # Replace with function body.
