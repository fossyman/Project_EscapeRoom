extends CharacterBody3D
class_name BasicAI

@export var Nav:NavigationAgent3D

@export var TargetPosition:Vector3
@export var CharacterStatistics:Stats
@export var SearchedClues:Array[int]

@export var PartyContainer:Node#THIS WILL BE FOR SIGNALLING OTHER NPCS THAT CLUES HAVE BEEN FOUND

@export var CurrentRoom:RoomResource

signal FoundClue
signal UsedClue

enum CHARACTERSTATE{SEARCHING,INVESTIGATING}
var CharacterState:CHARACTERSTATE = CHARACTERSTATE.SEARCHING

@export var HeldClue:Resource #THIS WILL BE FOR FIGURING OUT WHAT CLUE IS HELD

var TestSearchTime:float = 1.0
var tick:float
func _ready() -> void:
	Nav.velocity_computed.connect(_VelocityComputed)
	Nav.target_reached.connect(_TargetReached)
	TestSearchTime = randf_range(1,5)
	CurrentRoom = GLOBALS.CURRENTROOT.BuildManager.Rooms[0]
	ScanforProps()
	pass
	
func _physics_process(delta: float) -> void:
	tick += delta
	if tick >= TestSearchTime:
		tick = 0
		ScanforProps()
		
	var next_path_position: Vector3 = Nav.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * 10.0
	if Nav.avoidance_enabled:
		Nav.set_velocity(new_velocity)
	else:
		_VelocityComputed(new_velocity)
		
	pass

func SetTarget(_target:Vector3):
	Nav.target_position = _target

func _VelocityComputed(_velocity:Vector3):
	velocity = _velocity
	move_and_slide()
	pass

func _TargetReached():
	pass
	
func InvestigateProp(_prop:PropScene):
	pass

func ScanforProps():
	var NextSearchID = randi_range(0,CurrentRoom.PlacedProps.size()-1)

	SetTarget(CurrentRoom.PlacedProps[NextSearchID].global_position)
	print("PROP FOUND")
	pass
