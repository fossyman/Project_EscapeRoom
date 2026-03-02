extends Node
class_name BuildManager
static var instance = self

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
var SelectedProp:RES_PropData
var CurrentlyEditedProp:PropScene
@export_flags_3d_physics var PropCollisionLayer
@export var PreviewBuildMesh:MeshInstance3D
var CanPlaceFoundations:bool = true
# Called when the node enters the scene tree for the first time.
@export var Chunksize = 64

@export var FoundationMeshArray:MeshLibrary

signal FoundationPlaced

func _enter_tree() -> void:
	instance = self
	pass # Replace with function body.

func _ready() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if !GLOBALS.CanInteract:
		return
		
	if Input.is_action_just_pressed("Lclick"):
		BuildManager.instance.ClickPos = mouse_position(true)
		match(SelectedTool):
			SELECTEDTOOL.FOUNDATION:
				pass
			SELECTEDTOOL.PROP:
				PlaceProp(BuildManager.instance.mouse_position(true))
	if Input.is_action_pressed("Lclick"):

		var MousePos = BuildManager.instance.mouse_position(true)
		if MousePos.distance_to(BuildManager.instance.ClickPos) > BuildManager.instance.DragDeadzone:
			match(SelectedTool):
				_:
					BuildManager.instance.DragStart = BuildManager.instance.ClickPos
					BuildManager.instance.DragEnd = MousePos
					PreviewBuildMesh.visible = true
					BuildVisualiser.DrawBuildRect(PreviewBuildMesh,BuildManager.instance.DragStart,BuildManager.instance.DragEnd)

	if Input.is_action_just_released("Lclick"):
		if !BuildManager.instance.CurrentRoom:
			BuildManager.instance.CurrentRoom = RoomResource.new()
			
		var StartX = (BuildManager.instance.DragStart.x if BuildManager.instance.DragStart.x < BuildManager.instance.DragEnd.x else BuildManager.instance.DragEnd.x)
		var StartZ = (BuildManager.instance.DragStart.z if BuildManager.instance.DragStart.z < BuildManager.instance.DragEnd.z else BuildManager.instance.DragEnd.z)
		
		var EndX = (BuildManager.instance.DragEnd.x if BuildManager.instance.DragEnd.x > BuildManager.instance.DragStart.x else BuildManager.instance.DragStart.x) + 1
		var EndZ = (BuildManager.instance.DragEnd.z if BuildManager.instance.DragEnd.z > BuildManager.instance.DragStart.z else BuildManager.instance.DragStart.z) + 1
		match SelectedTool:
			#SELECTEDTOOL.ERASE:
				#EraseArea(1,Vector3(StartX,0,StartZ),Vector3(EndX,0,EndZ))
				#pass
			_:
				BuildSelectedSection(1,Vector3(StartX,0,StartZ),Vector3(EndX,0,EndZ))
		PreviewBuildMesh.visible = false

func BuildSelectedSection(_layer:int,StartCorner:Vector3,EndCorner:Vector3):
	if !CanPlaceFoundations:
		return
		
	if (StartCorner.x < 0 or StartCorner.x > 100) or ( StartCorner.z < 0 or StartCorner.z > 100):
		printerr("PAST START AREA")
		return
		
	if (EndCorner.x < 0 or EndCorner.x > 100) or ( EndCorner.z < 0 or EndCorner.z > 100):
		printerr("PAST END AREA")
		return
	
	CanPlaceFoundations = false
		
	for d in Labels.size():
		Labels[d].queue_free()
	Labels.clear()
	
	if BuildManager.instance.DragEnd == BuildManager.instance.DragStart:
		return
		
	var NewPoints:Array[Vector3]
	var Borders:Array[Vector3]
	var _border:int = 1
	
	for BX in range(StartCorner.x - _border,EndCorner.x + _border):
		for BZ in range(StartCorner.z - _border,EndCorner.z + _border):
			if BX in range(StartCorner.x,EndCorner.x) and BZ in range(StartCorner.z,EndCorner.z) and !BuildManager.instance.BuildingPoints.has(Vector3(BX,0,BZ)):
				if !BuildManager.instance.PERMANENTPLACEMENTS.has(Vector3(BX,0,BZ)):
					NewPoints.append(Vector3(BX,0,BZ))
			if !BuildManager.instance.OverlappingBuildPoints.has(Vector3(BX,0,BZ)):
				BuildManager.instance.OverlappingBuildPoints.append(Vector3(BX,0,BZ))

	for i in NewPoints.size():
		if BuildManager.instance.OccupiedGridSquares.has(NewPoints[i]):
			continue
		BuildManager.instance.OccupiedGridSquares.append(NewPoints[i])
		if !BuildManager.instance.BuildingPoints.has(NewPoints[i]):
			BuildManager.instance.BuildingPoints.append_array(NewPoints)

	if NewPoints.is_empty():
		BuildManager.instance.OverlappingBuildPoints.clear()
		return
	
	await get_tree().process_frame
	
	var ChunkCounter:int = 0
	if !BuildManager.instance.OverlappingBuildPoints.is_empty():
		for i in BuildManager.instance.OverlappingBuildPoints.size():
			BuildManager.instance.UpdateGridSquare(_layer,BuildManager.instance.OverlappingBuildPoints[i])
			ChunkCounter +=1
			if ChunkCounter >= Chunksize:
				ChunkCounter = 0
				await get_tree().process_frame
	
	BuildManager.instance.RebuildGridSquares()
	BuildManager.instance.OverlappingBuildPoints.clear()
	FoundationPlaced.emit()
	CanPlaceFoundations = true

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

func CastToPropLayer():
	var Cam = CameraController.instance.Camera
	var mouse_position:Vector2 = Cam.get_viewport().get_mouse_position()
	var from:Vector3 = Cam.global_position
	var to:Vector3 = Cam.project_position(mouse_position,1000)
	var State = PhysicsRayQueryParameters3D.create(from,to,PropCollisionLayer)
	var space_state = get_tree().root.world_3d.direct_space_state
	var result = space_state.intersect_ray(State)
	if result:
		print("CLICKED ON PROP")
		return result
	pass

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
	
	
	
	for x in BuildingHelpers.CheckPositions.size():
		print("erase1?")
		if _erasing:
			if ( (BuildingPoints.has(_gridsquare + (BuildingHelpers.CheckPositions[x])) or PERMANENTPLACEMENTS.has(_gridsquare + (BuildingHelpers.CheckPositions[x]))  ) && (_gridsquare + (BuildingHelpers.CheckPositions[x]) ) != _gridsquare):
				EdgeCount+=1
		else:
			print("erase4?")
			if (BuildingPoints.has(_gridsquare + (BuildingHelpers.CheckPositions[x])) ) && (_gridsquare + (BuildingHelpers.CheckPositions[x]) ) != _gridsquare:
				#print("HAS: " + str(CheckPositions[x]))
				EdgeCount+=1
	
		if x == 1 or x == 3 or x == 5 or x == 7:
			EdgeCheck.append((BuildingHelpers.CheckPositions[x]))
		elif x == 0 or x == 2 or x == 6 or x == 8:
			CornerCheck.append((BuildingHelpers.CheckPositions[x]))
			
	SquaresNeedingRebuilding.append(_gridsquare)
	SquaresNeedingRebuildingIDX.append(EdgeCount)


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
					var ye = BuildingHelpers.CheckBorderingGridAverage(SquaresNeedingRebuilding[i],true)
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)
				5:
					var ye = BuildingHelpers.CheckBorderingGridAverage(SquaresNeedingRebuilding[i],true)
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false)
					print("NUMBER 5:::::: " + str(noAVG) + " || " + str(noAVG))
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)

				3:
					var EdgesDirection = round(SquaresNeedingRebuildingIDX[i])
					var CurrentEdgeCount:int = SquaresNeedingRebuildingIDX[i]
					var no = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i])
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
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
					var check2 = BuildingHelpers.CheckBorderingGridCorners(SquaresNeedingRebuilding[i],false)
					#printerr(str(CurrentEdgeCount) + " 1VS1 " + str(check2))
				
					var no = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false,Vector3.ZERO,7)
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true,Vector3.ZERO,7)

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

	else:
		for i in SquaresNeedingRebuilding.size():
			match SquaresNeedingRebuildingIDX[i]:
				#CORNER
				3:
					#print("CORNER")
					var ye = BuildingHelpers.CheckBorderingGridAverage(SquaresNeedingRebuilding[i],false)
					Dir = ye
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)
				4:
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
					BuildingGridmap.set_cell_item(1,SquaresNeedingRebuilding[i],0,noAVG)

				5,6:
					var EdgesDirection = round(SquaresNeedingRebuildingIDX[i])
					var CurrentEdgeCount:int = SquaresNeedingRebuildingIDX[i]
					var no = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i])
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true)
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
					var check2 = BuildingHelpers.CheckBorderingGridCorners(SquaresNeedingRebuilding[i],false)
					#printerr(str(CurrentEdgeCount) + " 1VS1 " + str(check2))
				
					var no = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],false,Vector3.ZERO,7)
					var noAVG = BuildingHelpers.GetAverageWallRotationIndex(SquaresNeedingRebuilding[i],true,Vector3.ZERO,7)

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
		
	SquaresNeedingRebuilding.clear()
	SquaresNeedingRebuildingIDX.clear()

func PlaceProp(_location:Vector3):
	if !SelectedProp:
		return
	print("Placing Prop")
	var placement = SelectedProp._Scene.instantiate()
	BuildManager.instance.CurrentRoomScene.PropContainer.add_child(placement)
	placement.position = _location
	placement.rotation_degrees = BuildingHelpers.CellRotationToEuler(BuildingHelpers.GetAverageWallRotationIndex(_location,true))
	BuildManager.instance.CurrentRoom.PlacedProps.append(SelectedProp)
	BuildManager.instance.CurrentRoom.PlacedPropLocations.append(_location)
	SelectedProp = null
	pass

func SetSelectedProp(_data:RES_PropData):
	SelectedProp = _data
	pass
