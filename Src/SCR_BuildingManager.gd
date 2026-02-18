extends Node
class_name BuildManager
static var instance = self

static var CheckPositions = [Vector3(1,0,1),Vector3(0,0,1),Vector3(-1,0,1),
							Vector3(1,0,0),Vector3(0,0,0),Vector3(-1,0,0),
							Vector3(1,0,-1),Vector3(0,0,-1),Vector3(-1,0,-1)]

@export var Cursor:Node3D
@export var CursorMesh:MeshInstance3D
@export var OverlapTestingArea:Area3D
var BuildingCursorPosition:Vector3

var ClickPos:Vector3

@export var DragDeadzone:float = 1.0
var DragStart:Vector3
var DragEnd:Vector3

@export var BuildingGridmap:GridmapPlus
@export var RoomParent:Node3D

@export var FoundationTool:FoundationManager
@export var FoundationToolUI:Control
@export var PropTool:PropPlacer
@export var PropToolUI:Control

var SelectedSpaces:Array[Vector3]
var CurrentDragSpaces:Array[Vector3]

var OccupiedGridSquares:Array[Vector3] = []

var BuildingPoints:Array[Vector3] = []
var OverlappingBuildPoints:Array[Vector3] = []

var PERMANENTPLACEMENTS:Array[Vector3] = []

enum SELECTEDTOOL {FOUNDATION,PROP,PUZZLE}
var SelectedTool:SELECTEDTOOL = SELECTEDTOOL.FOUNDATION

var MinimumSizeReached:bool = false
var DoorwayPlaced:bool = false

@export var BuildRequirementsLabel:RichTextLabel
@export var BuildRequirementsText:String
@export var FinalizeRoomButton:Button

var SquaresNeedingRebuilding:Array[Vector3]
var SquaresNeedingRebuildingIDX:Array[int]

var Rooms:Array[RoomResource]

var CurrentRoom:RoomResource = RoomResource.new()
var CurrentRoomScene:RoomScene

var Labels:Array[Label3D]


# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	instance = self
	pass # Replace with function body.

func _ready() -> void:
	FoundationTool.FoundationPlaced.connect(UpdateRequirementsPanel)
	FoundationTool.DoorwayPlaced.connect(UpdateRequirementsPanel)
	CreateNewRoom()

func _process(delta: float) -> void:
	if !GLOBALS.CanInteract:
		return
	match (SelectedTool):
		SELECTEDTOOL.FOUNDATION:
			pass
		SELECTEDTOOL.PROP:
			pass
		SELECTEDTOOL.PUZZLE:
			pass
	MoveCursor(mouse_position(true))

	if Input.is_action_just_pressed("DEBUG_REFRESHBUILD"):
		for i in Labels.size():
			Labels[i].queue_free()
		Labels.clear()
		RebuildGridSquares(FoundationTool.instance.SelectedTool == FoundationTool.SELECTED_TOOL.ERASE)

func UpdateRequirementsPanel():
	MinimumSizeReached = BuildingPoints.size() >= 8
	DoorwayPlaced = CurrentRoom.HasDoor
		
	FinalizeRoomButton.disabled = (MinimumSizeReached and !DoorwayPlaced)
		
	var MinSizeColor = "green" if MinimumSizeReached else "red"
	var DoorwayColor = "green" if DoorwayPlaced else "red"
	BuildRequirementsLabel.text = "[b]Requirements[/b]\n" + "[color=" + str(MinSizeColor) + "]" + str("Minimum build size: 3x3\n") + "[color=" + str(DoorwayColor) + "]" + str("Door Placed\n")

func ChangeSelectedTool(_tool:SELECTEDTOOL):
	SelectedTool = _tool
	FoundationTool.process_mode = Node.PROCESS_MODE_DISABLED
	PropTool.process_mode = Node.PROCESS_MODE_DISABLED
	if FoundationToolUI:
		FoundationToolUI.visible = false
	PropToolUI.visible = false
	match (SelectedTool):
		SELECTEDTOOL.FOUNDATION:
			FoundationTool.process_mode = Node.PROCESS_MODE_INHERIT
			if FoundationToolUI:
				FoundationToolUI.visible = true
			UpdateRequirementsPanel()
			pass
		SELECTEDTOOL.PROP:
			PropTool.process_mode = Node.PROCESS_MODE_INHERIT
			PropToolUI.visible = true
			pass
		SELECTEDTOOL.PUZZLE:
			pass

func mouse_position(_SnapToGrid:bool = false) -> Vector3:
	#Created with help from https://www.reddit.com/r/godot/comments/xd7lcx/how_to_turn_mouse_coordinates_in_world/
	#And https://docs.godotengine.org/en/stable/tutorials/physics/ray-casting.html
	
	var Cam = CameraController.instance.Camera
	var mouse_position:Vector2 = Cam.get_viewport().get_mouse_position()
	var from:Vector3 = Cam.global_position
	var to:Vector3 = Cam.project_position(mouse_position,1000)
	var State = PhysicsRayQueryParameters3D.create(from,to)
	var space_state = get_tree().root.world_3d.direct_space_state
	var result = space_state.intersect_ray(State)
	if result:
		#result.collider #gets object
		#result.position #gets position
		if _SnapToGrid:
			return snapped(result.position,BuildingGridmap.cell_size/2)
		return result.position
	else:
		return Vector3.ZERO

func CreateNewRoom():
	CurrentRoom = RoomResource.new()
	var NewRoom:RoomScene = RoomScene.new()
	CurrentRoomScene = NewRoom
	RoomParent.add_child(NewRoom,true)
	pass
	
func FinalizeRoom():
	CurrentRoom.RoomSquares.append_array(BuildingPoints)
	CurrentRoom.RoomArea = AABB(CurrentRoom.RoomSquares[0],CurrentRoom.RoomSquares[CurrentRoom.RoomSquares.size()-1])
	
	var average = Vector3.ZERO
	for i in CurrentRoom.RoomSquares.size():
		average += CurrentRoom.RoomSquares[i]
	average /= CurrentRoom.RoomSquares.size()
	
	Rooms.append(CurrentRoom)
	CurrentRoom = null
	
	var ye = CollisionShape3D.new()
	add_child(ye)
	OccupiedGridSquares.clear()
	OccupiedGridSquares.append_array(BuildingPoints)
	PERMANENTPLACEMENTS.append_array(OccupiedGridSquares)
	BuildingPoints.clear()

func MoveCursor(_movement:Vector3):
	BuildingCursorPosition = _movement
	Cursor.global_position = BuildingCursorPosition
	##print(Cursor.global_position)
	pass

func EdgeCheckPoint(_point:Vector3,_array:Array[Vector3]) -> int:
	var count:int
	for x in CheckPositions.size():
		if _array.has(_point + CheckPositions[x]) && _point + CheckPositions[x] != _point:
			count += 1
	return count
	
func CheckBorderingGridAverage(_position:Vector3,CornerFix:bool = false) -> Vector3:
	var EmptyPoints:Array[Vector3]
	var val:Vector3
	var avg:Vector3
	for i in CheckPositions.size():
		if BuildingPoints.has(_position + CheckPositions[i]):
			EmptyPoints.append( (CheckPositions[i]) )
			
	for i in EmptyPoints.size():
		val += EmptyPoints[i]
		
	avg = val / EmptyPoints.size()
	if CornerFix:
		return (avg*5).round()
	return avg.round()
	

func CheckBorderingGridCorners(_position:Vector3,_snap:bool = true) -> Vector3:
	var val:Vector3
	var avg:Vector3
	var FoundCorners:Array[Vector3]
	
	var dir:Vector3
	
	for i in CheckPositions.size():
		if BuildingPoints.has(_position + CheckPositions[i]) and !PERMANENTPLACEMENTS.has(_position + CheckPositions[i]):
			FoundCorners.append(CheckPositions[i])

	if FoundCorners.is_empty():
		#print("NO CORNERS FOUND")
		return Vector3.ZERO
		
	var sum = FoundCorners.reduce(func(acc, num): return acc + num)
	var average:Vector3 = sum / FoundCorners.size()*1
	
	
	#print("RETURNING CORNER VALUE OF :: " + str(average))
	return average.snappedf(0.1) if _snap else average
	
func UpdateGridSquare(_gridlayer:int,_gridsquare:Vector3,_erasing = false):
	var LabelColor:Color = Color.WHITE
	var Dir
	var EdgeCount = 0
	var EdgeCheck:Array[Vector3]
	var CornerCheck:Array[Vector3]
	print("erase-0?")
	if !_erasing:
		if PERMANENTPLACEMENTS.has(_gridsquare) or !BuildingPoints.has(_gridsquare):
			print("erase0?")
			return
	
	
	
	for x in CheckPositions.size():
		print("erase1?")
		if _erasing:
			print("erase3?")
			print("ERASER")
			if ( (BuildingPoints.has(_gridsquare + (CheckPositions[x])) or PERMANENTPLACEMENTS.has(_gridsquare + (CheckPositions[x]))  ) && (_gridsquare + (CheckPositions[x]) ) != _gridsquare):
				print("ERASER HAS: " + str(CheckPositions[x]))
				EdgeCount+=1
		else:
			print("erase4?")
			if (BuildingPoints.has(_gridsquare + (CheckPositions[x])) ) && (_gridsquare + (CheckPositions[x]) ) != _gridsquare:
				#print("HAS: " + str(CheckPositions[x]))
				EdgeCount+=1
	
		if x == 1 or x == 3 or x == 5 or x == 7:
			EdgeCheck.append((CheckPositions[x]))
		elif x == 0 or x == 2 or x == 6 or x == 8:
			CornerCheck.append((CheckPositions[x]))
			
	SquaresNeedingRebuilding.append(_gridsquare)
	SquaresNeedingRebuildingIDX.append(EdgeCount)
	
	#var lab = Label3D.new()
	#add_child(lab)
	#if _erasing:
		#lab.position = _gridsquare + (Vector3.UP * 2)
	#else:
		#lab.position = _gridsquare + Vector3.UP
	#lab.text = str(EdgeCount)
	#lab.no_depth_test = true
	#lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	#Labels.append(lab)

func RebuildGridSquares(_erasing:bool = false):
	var Dir
	if SquaresNeedingRebuilding.is_empty():
		return
	if _erasing:
		for i in SquaresNeedingRebuilding.size():
			match SquaresNeedingRebuildingIDX[i]:
				#CORNER
				2:
					#print("CORNER")
					var ye = CheckBorderingGridAverage(SquaresNeedingRebuilding[i],true)
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)
				5:
					var ye = CheckBorderingGridAverage(SquaresNeedingRebuilding[i],true)
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false)
					print("NUMBER 5:::::: " + str(noAVG) + " || " + str(noAVG))
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)

				3:
					var EdgesDirection = round(SquaresNeedingRebuildingIDX[i])
					var CurrentEdgeCount:int = SquaresNeedingRebuildingIDX[i]
					var no = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i])
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					Dir = EdgesDirection
					print("::EDGECOUNT:: " + str(CurrentEdgeCount))
					match CurrentEdgeCount:
						3:
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,no)
						5:
							print("5's NORMAL CHECK:: at ")
							match SquaresNeedingRebuildingIDX[i]:
								Vector3(Vector3.FORWARD*0.5),Vector3(Vector3.LEFT*0.5),Vector3(Vector3.RIGHT*0.5),Vector3(Vector3.BACK*0.5):
									BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
								_:
									BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
						6:
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
						_:
							print("SHOULD BE SOMETHING HERE AT")
							pass
				8:
					#BuildingGridmap.clear_cell_item(1,_gridsquare)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],2,0)
				7:
					var check2 = CheckBorderingGridCorners(SquaresNeedingRebuilding[i],false)
					#printerr(str(CurrentEdgeCount) + " 1VS1 " + str(check2))
				
					var no = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false,Vector3.ZERO,7)
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true,Vector3.ZERO,7)

					match SquaresNeedingRebuildingIDX[i]:
						Vector3(Vector3.FORWARD),Vector3(Vector3.LEFT),Vector3(Vector3.RIGHT),Vector3(Vector3.BACK),Vector3(0,0,0.1):
							#print("attempting to determine :: " + str(CheckBorderingGridAverage(_gridsquare,true)))

							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
							#print("WOAH" + str(noAVG))
						_:
							#print("AVERAGE RETURN FOR 7 IS :: " + str(noAVG))
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],3,noAVG)
							#print("NOAH" + str(noAVG))
				_:
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],-1,0)

			#var lab = Label3D.new()
			#add_child(lab)
			#lab.position = SquaresNeedingRebuilding[i] + Vector3.UP
			#var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false)
			#
			#lab.text = str(SquaresNeedingRebuildingIDX[i]) + "\n" + str(noAVG)
			#lab.no_depth_test = true
			#lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			#Labels.append(lab)
	else:
		for i in SquaresNeedingRebuilding.size():
			match SquaresNeedingRebuildingIDX[i]:
				#CORNER
				3:
					#print("CORNER")
					var ye = CheckBorderingGridAverage(SquaresNeedingRebuilding[i],false)
					Dir = ye
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)
				4:
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)

				5,6:
					var EdgesDirection = round(SquaresNeedingRebuildingIDX[i])
					var CurrentEdgeCount:int = SquaresNeedingRebuildingIDX[i]
					var no = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i])
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					Dir = EdgesDirection
					print("::EDGECOUNT:: " + str(CurrentEdgeCount))
					match CurrentEdgeCount:
						1:
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,no)
						5:
							print("5's NORMAL CHECK:: at ")
							match SquaresNeedingRebuildingIDX[i]:
								Vector3(Vector3.FORWARD*0.5),Vector3(Vector3.LEFT*0.5),Vector3(Vector3.RIGHT*0.5),Vector3(Vector3.BACK*0.5):
									BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
								_:
									BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
						6:
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
						_:
							print("SHOULD BE SOMETHING HERE AT")
							pass
				8:
					#BuildingGridmap.clear_cell_item(1,_gridsquare)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],2,0)
				7:
					var check2 = CheckBorderingGridCorners(SquaresNeedingRebuilding[i],false)
					#printerr(str(CurrentEdgeCount) + " 1VS1 " + str(check2))
				
					var no = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false,Vector3.ZERO,7)
					var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true,Vector3.ZERO,7)

					match SquaresNeedingRebuildingIDX[i]:
						Vector3(Vector3.FORWARD),Vector3(Vector3.LEFT),Vector3(Vector3.RIGHT),Vector3(Vector3.BACK),Vector3(0,0,0.1):
							#print("attempting to determine :: " + str(CheckBorderingGridAverage(_gridsquare,true)))

							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],1,noAVG)
							#print("WOAH" + str(noAVG))
						_:
							#print("AVERAGE RETURN FOR 7 IS :: " + str(noAVG))
							BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],3,noAVG)
							#print("NOAH" + str(noAVG))
				_:
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],-1,0)
					pass
				
			#var lab = Label3D.new()
			#add_child(lab)
			#lab.position = SquaresNeedingRebuilding[i] + Vector3.UP
			#var noAVG = GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
			#
			#lab.text = str(SquaresNeedingRebuildingIDX[i]) + "\n" + str(noAVG)
			#lab.no_depth_test = true
			#lab.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			#Labels.append(lab)
		
	SquaresNeedingRebuilding.clear()
	SquaresNeedingRebuildingIDX.clear()
	
		
func GetAverageWallRotationIndex(_position:Vector3,CornerFix:bool = false,_offset:Vector3 = Vector3.ZERO,intcheck:int = -1) -> int:
	var checking:Vector3 = CheckBorderingGridAverage(_position,CornerFix) + _offset
	var CornerChecking = CheckBorderingGridCorners(_position,true)
	print("CHECKING CORNER:::::"+str(CornerChecking))
	if CornerFix:
		match CornerChecking:
			Vector3(-1,0,-1),Vector3(Vector3.FORWARD),Vector3(1,0,-1),Vector3(Vector3.LEFT),Vector3(Vector3.RIGHT),Vector3(Vector3(-1,0,1)),Vector3(Vector3.BACK),Vector3(1,0,1):
				#print("KORNA " + str(CornerChecking))
				match checking:
					Vector3(-1,0,-1):
						return 22
					Vector3(-1.0,0.0,1.0):
						return 0
					Vector3(1,0,-1):
						return 10
					Vector3(1.0,0,1.0):
						return 16
					Vector3(0.0,0,-1.0):
						return 6
					Vector3(0,1,0),Vector3(-1.0,0.0,-1.0):
						return 10
					Vector3(1.0,0,-0.5),Vector3(1.0,0,0.5):
						return 16
					Vector3(1,0,1):
						return 22
					Vector3(-1,0,0.5),Vector3(-1,0,-0.5):
						return 22
					Vector3(0.5,0,-1):
						return 10
					
			_:
				#print("OTHA KORNA " + str(CornerChecking))
				match CornerChecking:
					
					Vector3(-0.5,0,0.5):
						return 10
					
					Vector3(-0.5,0,-0.5):
						return 16
										
					Vector3(0.5,0,0.5):
						return 22
					
					Vector3(0.2,0,0.6):
						return 22
					
					Vector3(-0.1,0,0.3):
						return 10
					Vector3(-0.3,0,0.1),Vector3(-0.3,0,-0.1):
						return 16
					Vector3(0.3,0,0.1):
						return 22
					Vector3(0.1,0,0.3):
						return 10
					Vector3(0.3,0,-0.1):
						return 22
						
					Vector3(-0.1, 0.0, -0.1):
						#print("RETURNING 7S")
						return 22
					Vector3(0.1, 0.0, 0.1):
						#print("RETURNING 7S")
						return 16
					
					Vector3(-0.5,0,0):
						return 16
					Vector3(0.5,0,0):
						return 22
					Vector3(0,0,0.5):
						return 10
						
					Vector3(0.1, 0.0, -0.1):
						#print("RETURNING 7S")
						return 10
					Vector3(0.0, 0.0, 0.1):
						#print("RETURNING 7S")
						return 10
					
					##4
					Vector3(0.6, 0.0, 0.2):
						#print("RETURNING 7S")
						return 22
					Vector3(-0.6, 0.0, -0.2):
						#print("RETURNING 7S")
						return 16
					Vector3(-0.6, 0.0, 0.2):
						#print("RETURNING 7S")
						return 10
					Vector3(-0.2, 0.0, -0.6):
						#print("RETURNING 7S")
						return 16
					Vector3(-0.2, 0.0, 0.6):
						#print("RETURNING 7S")
						return 10
					
	else:
		#print("FINAL KORNAS " + str(checking))
		match checking:
			Vector3.FORWARD:
				return 0
			Vector3.BACK:
				return 10
			Vector3.LEFT:
				return 16
			Vector3.RIGHT:
				return 22
		if intcheck == 7:
			#print("OH MY GOODNESS ITS 7" + str(CornerChecking))
			match CornerChecking:
				pass
	return 0

func CellRotationToEuler(_value:int) -> Vector3:
	#print("CHECKING ::" + str(_value))
	match _value:
		0:
			return Vector3(0,0,0)
		10:
			return Vector3(0,180,0)
		16:
			return Vector3(0,90,0)
		22:
			return Vector3(0,255,0)
		_:
			return Vector3(0,0,0)
	pass
