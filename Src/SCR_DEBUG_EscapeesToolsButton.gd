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
	var NPCs:Array[BasicAI]
	for i in NPCSpawnCount:
		var _spawn = NPCScene.instantiate()
		GLOBALS.CURRENTROOT.add_child(_spawn)
		_spawn.global_position = SpawnPoint
		NPCs.append(_spawn)
	GameManager.instance.AssignNewNPCs(NPCs)

func AssignNPCsToLatestRoom():
	
	pass


func SendNPCToRoom() -> void:
	var Npcs = GameManager.instance.ReturnNPCsByGroup(1)
	print(Npcs.size())
	if Npcs.is_empty():
		return
	if BuildManager.instance.Rooms.is_empty():
		return
		
	for i in Npcs:
		i.CurrentRoom = BuildManager.instance.Rooms[0]
		print(i.CurrentRoom)
		i.AI_TICK()
		
	BuildManager.instance.Rooms[0].AssignedNPCs = Npcs
	GameManager.instance.CreateNewRunTimer(0)
	pass # Replace with function body.
