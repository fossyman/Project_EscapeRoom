extends CharacterBody3D
class_name BasicAI

@export var Nav:NavigationAgent3D
@export var CharacterMesh:Node3D
@export var TargetPosition:Vector3
@export var CharacterStatistics:Stats
@export var SearchedClues:Array[int]

@export var PartyContainer:Node#THIS WILL BE FOR SIGNALLING OTHER NPCS THAT CLUES HAVE BEEN FOUND

@export var TargetProp:PropScene

@export var CurrentRoom:RoomResource
@export var CurrentScene:RoomScene

@export var ReactionSpeechBubble:Sprite3D
@export var ReactionLabel:Label3D

@export var LookAtPoint:Marker3D

@export_category("customisation")
@export var HeadRoot:MeshInstance3D
@export var BodyRoot:MeshInstance3D
@export var HeadPieces:Array[Mesh]
@export var BodyPieces:Array[Mesh]

@export var Reactions:Array[String]

var GroupID:int = -1

signal FoundClue
signal UsedClue

enum CHARACTERSTATE{SEARCHING,INVESTIGATING,LEAVING}
var CharacterState:CHARACTERSTATE = CHARACTERSTATE.SEARCHING

@export var HeldClue:Resource #THIS WILL BE FOR FIGURING OUT WHAT CLUE IS HELD

var WanderingEyes:bool = true

var TestSearchTime:float = 1.0
var tick:float
func _ready() -> void:
	Nav.velocity_computed.connect(_VelocityComputed)
	Nav.target_reached.connect(_TargetReached)
	TestSearchTime = randf_range(1,5)
	GenerateDesign()
	SetTarget(GLOBALS.CURRENTROOT.WaitingArea.global_position)
	pass
	
func _physics_process(delta: float) -> void:
	tick += delta
	if tick >= TestSearchTime:
		tick = 0
		AI_TICK()
		
	var next_path_position: Vector3 = Nav.get_next_path_position()
	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * 10.0
	if Nav.avoidance_enabled:
		Nav.set_velocity(new_velocity)
	else:
		_VelocityComputed(new_velocity)
	
	HeadRoot.rotation_degrees = HeadRoot.rotation_degrees.slerp(LookAtPoint.global_position - HeadRoot.global_position,2*delta)
	#HeadRoot.look_at(LookAtPoint.global_position,Vector3.UP,false)
	
	pass

func SetTarget(_target:Vector3):
	Nav.target_position = _target
	
	WanderingEyes = false
	LookAtPoint.global_position = _target

func _VelocityComputed(_velocity:Vector3):
	velocity = _velocity
	if velocity != Vector3.ZERO:
		CharacterMesh.rotation.y = lerp_angle(CharacterMesh.rotation.y,atan2(-velocity.x,-velocity.z),12 * GLOBALS.DELTA)
	move_and_slide()
	pass

func _TargetReached():
	if CharacterState == CHARACTERSTATE.LEAVING:
		LeaveMap()
	if TargetProp:
		InvestigateProp(CurrentRoom.PlacedProps[0])
	WanderingEyes = true
	pass

func AI_TICK():
	if CharacterState == CHARACTERSTATE.LEAVING:
		return
		
	if WanderingEyes:
		LookAtPoint.position = -transform.basis.z + Vector3.UP + Vector3(randf_range(-15,15),randf_range(-15,15),randf_range(-5,5))
	if CurrentRoom:
		ScanforProps()
	pass
	
func InvestigateProp(_prop:PropScene):
	DisplayEmotion()
	pass

func ScanforProps():
	var NextSearchID = randi_range(0,CurrentRoom.PlacedProps.size()-1)
	TargetProp = CurrentRoom.PlacedProps[NextSearchID]
	SetTarget(CurrentRoom.PlacedProps[NextSearchID].global_position)
	print("PROP FOUND")
	pass
	
func DisplayEmotion():
	ReactionSpeechBubble.visible = true
	var idx = Reactions.pick_random()
	ReactionLabel.text = idx
	await get_tree().create_timer(2.0).timeout
	ReactionSpeechBubble.visible = false

func GenerateDesign(_head:int = -1, _body = -1):
	var _RandomHead = HeadPieces.pick_random() if _head == -1 else _head
	var _RandomBody = BodyPieces.pick_random() if _body == -1 else _body
	HeadRoot.mesh = _RandomHead
	BodyRoot.mesh = _RandomBody
	pass

func LeaveMap():
	GameManager.instance.CurrentNPCs.erase(self)
	queue_free()
