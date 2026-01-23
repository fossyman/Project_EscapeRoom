extends Node
class_name BuildingManager
static var instance:BuildingManager


enum BUILDTOOLS{FOUNDATION,PROP}
var SelectedTool:BUILDTOOLS = 0

@export_category("FOUNDATION")
@export var BuildMat:Material
@export var DestroyMat:Material
@export var BuildSizeLabel:Label3D
@export var ShowLabels:bool=false
@export var EdgeColors:bool=false
@export var CornerColors:bool=false
@export var InnerCornerColors:bool=false

@export var BuildingGrid:GridMap

@export var Rooms:Array[RoomResource]

@export var CurrentlyEditingRoom:RoomResource = null

@export var Cursor:Node3D
@export var CursorMesh:MeshInstance3D
@export var OverlapTestingArea:Area3D
var BuildingCursorPosition:Vector3

var ClickPos:Vector3
@export var DragDeadzone:float = 1.0
var DragStart:Vector3
var DragEnd:Vector3

@export var PreviewBuildMesh:MeshInstance3D

var SelectedSpaces:Array[Vector3]
var CurrentDragSpaces:Array[Vector3]

var OccupiedGridSquares:Array[Vector3] = []

var BuildingPoints:Array[Vector3] = []
var OverlappingBuildPoints:Array[Vector3] = []

var PERMANENTPLACEMENTS:Array[Vector3] = []

var PlacedProps:Array[PropScene]=[]

var Labels:Array[Label3D]

static var CheckPositions = [Vector3(1,0,1),Vector3(0,0,1),Vector3(-1,0,1),
							Vector3(1,0,0),Vector3(0,0,0),Vector3(-1,0,0),
							Vector3(1,0,-1),Vector3(0,0,-1),Vector3(-1,0,-1)]

@export_category("PROP")
@export var PropGrid:Node3D
@export var SelectedProp:RES_PropData

@export var Chunksize = 64

var BuildThread:Thread

func _enter_tree() -> void:
	instance = self

func _ready() -> void:
	DEBUGTOOLS.instance.FinalizeRoomButton.connect("pressed",FinalizeRoom)
	DEBUGTOOLS.instance.CreateRoomButton.connect("pressed",CreateNewRoom)


func _process(delta: float) -> void:
	
	if Input.is_key_pressed(KEY_1):
		SelectedTool = BUILDTOOLS.FOUNDATION
		PreviewBuildMesh.material_override = BuildMat
	if Input.is_key_pressed(KEY_2):
		SelectedTool = BUILDTOOLS.PROP
		CursorMesh.mesh = SelectedProp._PreviewMesh
		PreviewBuildMesh.material_override = DestroyMat
	if Input.is_key_pressed(KEY_3):
		SelectedTool = 99
		PreviewBuildMesh.material_override = DestroyMat
	if Input.is_action_just_pressed("DEBUG_REFRESHBUILD"):
		DEBUG_REFRESHBUILD()
		
	if !GLOBALS.CanInteract:
		return
		
	MoveCursor(mouse_position(true))
	
	
	match SelectedTool:
		#region FOUNDATION
		BUILDTOOLS.FOUNDATION:
			if Input.is_action_pressed("Lclick"):
				var MousePos = mouse_position(true)
				if Input.is_action_just_pressed("Lclick"):
					ClickPos = MousePos
					BuildConnector(ClickPos)
				if MousePos.distance_to(ClickPos) > DragDeadzone:
					DragStart = ClickPos
					DragEnd = MousePos
					PreviewBuildMesh.visible = true
					##print("MAKING SQUARE BETWEEN " + str(DragStart) + " AND " + str(DragEnd))
					DrawBuildRect(DragStart,DragEnd)
			BuildSizeLabel.text = str((DragEnd - DragStart).x) + ", " + str((DragEnd - DragStart).z)
			if Input.is_action_just_released("Lclick"):
				if !CurrentlyEditingRoom:
					CurrentlyEditingRoom = RoomResource.new()
				
				var StartX = (DragStart.x if DragStart.x < DragEnd.x else DragEnd.x)
				var StartZ = (DragStart.z if DragStart.z < DragEnd.z else DragEnd.z)
				
				var EndX = (DragEnd.x if DragEnd.x > DragStart.x else DragStart.x) + 1
				var EndZ = (DragEnd.z if DragEnd.z > DragStart.z else DragStart.z) + 1
				match(SelectedTool):
					0:
						#BuildThread = Thread.new()
						#BuildThread.start(BuildSelectedSection.bind(Vector3(StartX,0,StartZ),Vector3(EndX,0,EndZ)))
						BuildSelectedSection(Vector3(StartX,0,StartZ),Vector3(EndX,0,EndZ))
					1:
						for X in range(StartX+1,EndX-1):
							for Z in range(StartZ+1,EndZ-1):
								EraseSelection(Vector3(StartX,0,StartZ),Vector3(EndX,0,EndZ))
					2:
						var points:Array[Vector3]
						for X in range(StartX+1,EndX-1):
							for Z in range(StartZ+1,EndZ-1):
								points.append(Vector3(X,0,Z))
					_:
						return
				PreviewBuildMesh.visible = false
			#endregion
		#region PROP
		BUILDTOOLS.PROP:
			if Input.is_action_just_pressed("Lclick"):
				if OverlapTestingArea.has_overlapping_areas():
					return
				var _NewProp = SelectedProp._Scene.instantiate() as Node3D
				PropGrid.add_child(_NewProp)
				_NewProp.position = mouse_position(true)
				_NewProp.rotation_degrees = CellRotationToEuler(GetAverageWallRotationIndex(_NewProp.position,true))
				PlacedProps.append(_NewProp)
		#endregion

func BuildSelectedSection(StartCorner:Vector3,EndCorner:Vector3):
	push_warning(StartCorner)
	if (StartCorner.x < 0 or StartCorner.z < 0) or (EndCorner.x < 0 or EndCorner.z < 0):
		return
		
	for d in Labels.size():
		Labels[d].queue_free()
	Labels.clear()
	
	if DragEnd == DragStart:
		return
		
	var NewPoints:Array[Vector3]
	var Borders:Array[Vector3]
	var _border:int = 1
	
	for BX in range(StartCorner.x - _border,EndCorner.x + _border):
		for BZ in range(StartCorner.z - _border,EndCorner.z + _border):
			if BX in range(StartCorner.x,EndCorner.x) and BZ in range(StartCorner.z,EndCorner.z) and !BuildingPoints.has(Vector3(BX,0,BZ)):
				if !PERMANENTPLACEMENTS.has(Vector3(BX,0,BZ)):
					NewPoints.append(Vector3(BX,0,BZ))
			if !OverlappingBuildPoints.has(Vector3(BX,0,BZ)):
				OverlappingBuildPoints.append(Vector3(BX,0,BZ))

	for i in NewPoints.size():
		if OccupiedGridSquares.has(NewPoints[i]):
			continue
		OccupiedGridSquares.append(NewPoints[i])
		if !BuildingPoints.has(NewPoints[i]):
			BuildingPoints.append_array(NewPoints)

	if NewPoints.is_empty():
		return
	var ChunkCounter:int = 0
	for i in OverlappingBuildPoints.size():
		UpdateGridSquare(OverlappingBuildPoints[i])
		ChunkCounter +=1
		if ChunkCounter >= Chunksize:
			ChunkCounter = 0
			await get_tree().process_frame
		
	OverlappingBuildPoints.clear()
	
func EraseSelection(_start:Vector3,_end:Vector3):
	var removals:Array[Vector3]
	for X in range(_start.x,_end.x):
		for Z in range(_start.z,_end.z):
			BuildingPoints.erase(Vector3(X,0,Z))
			removals.append(Vector3(X,0,Z))
	for i in removals.size():
		BuildingGrid.set_cell_item(removals[i],GridMap.INVALID_CELL_ITEM)
		await get_tree().process_frame
	DEBUG_REFRESHBUILD()

func UpdateGridSquare(_gridsquare:Vector3,_erasing = false):#
	var LabelColor:Color = Color.WHITE
	var Dir
	var EdgeCount = 0
	var EdgeCheck:Array[Vector3]
	var CornerCheck:Array[Vector3]

	if PERMANENTPLACEMENTS.has(_gridsquare):
		return
	
	if !BuildingPoints.has(_gridsquare):
		return

	
	for x in CheckPositions.size():
		if (BuildingPoints.has(_gridsquare + (CheckPositions[x])) ) && (_gridsquare + CheckPositions[x]) != _gridsquare:
			#print("HAS: " + str(CheckPositions[x]))
			EdgeCount+=1


		if x == 1 or x == 3 or x == 5 or x == 7:
			EdgeCheck.append((CheckPositions[x]))
		elif x == 0 or x == 2 or x == 6 or x == 8:
			CornerCheck.append((CheckPositions[x]))
	
	var check = CheckBorderingGridCorners(_gridsquare)
	#print("CHECK VALUE:: " + str(check))
	#print("EDGECHECK " + str(EdgeCheck.size()))
	#print("CORNERCHECK " + str(CornerCheck.size()))
	match EdgeCount:
		#CORNER
		3:
			#print("CORNER")
			var ye = CheckBorderingGridAverage(_gridsquare,false)
			Dir = ye
			var noAVG = GetAverageWallRotationIndex(_gridsquare,true)
			BuildingGrid.set_cell_item(_gridsquare,0,noAVG)
		4:
			LabelColor = Color.GREEN
			var noAVG = GetAverageWallRotationIndex(_gridsquare,true)
			BuildingGrid.set_cell_item(_gridsquare,0,noAVG)

		5,6:
			var EdgesDirection = round(EdgeCheck.max())
			var CurrentEdgeCount:int = EdgeCheck.size()
			var no = GetAverageWallRotationIndex(_gridsquare)
			var noAVG = GetAverageWallRotationIndex(_gridsquare,true)
			Dir = EdgesDirection
			match CurrentEdgeCount:
				1:
					BuildingGrid.set_cell_item(_gridsquare,1,no)
				4:
					#print("::EDGECOUNT:: " + str(EdgeCount))
					match EdgeCount:
						5:
							#print("5's NORMAL CHECK:: at " + str(check) + " " + str(noAVG))
							match check:
								Vector3(Vector3.FORWARD*0.5),Vector3(Vector3.LEFT*0.5),Vector3(Vector3.RIGHT*0.5),Vector3(Vector3.BACK*0.5):
									BuildingGrid.set_cell_item(_gridsquare,1,noAVG)
								_:
									BuildingGrid.set_cell_item(_gridsquare,0,noAVG)

						6:
							BuildingGrid.set_cell_item(_gridsquare,1,noAVG)
						_:
							#print("SHOULD BE SOMETHING HERE AT")
							pass
				_:
					pass
		8:
			BuildingGrid.set_cell_item(_gridsquare,2)
		7:
			var check2 = CheckBorderingGridCorners(_gridsquare,false)
			var CurrentEdgeCount:int = EdgeCheck.size()
			#printerr(str(CurrentEdgeCount) + " 1VS1 " + str(check2))
		
			var no = GetAverageWallRotationIndex(_gridsquare,false,Vector3.ZERO,7)
			var noAVG = GetAverageWallRotationIndex(_gridsquare,true,Vector3.ZERO,7)

			match check:
				Vector3(Vector3.FORWARD),Vector3(Vector3.LEFT),Vector3(Vector3.RIGHT),Vector3(Vector3.BACK),Vector3(0,0,0.1):
					#print("attempting to determine :: " + str(CheckBorderingGridAverage(_gridsquare,true)))

					BuildingGrid.set_cell_item(_gridsquare,1,noAVG)
					#print("WOAH" + str(noAVG))
				_:
					#print("AVERAGE RETURN FOR 7 IS :: " + str(noAVG))
					BuildingGrid.set_cell_item(_gridsquare,3,noAVG)
					#print("NOAH" + str(noAVG))
	if ShowLabels:
		var lab = Label3D.new()
		BuildingGrid.add_child(lab)
		Labels.append(lab)
		lab.no_depth_test = true
		lab.modulate = LabelColor
		lab.global_position = _gridsquare + Vector3.UP
		lab.text = str(EdgeCount)+"\n"+str(CheckBorderingGridCorners(_gridsquare))+"\n"+str(CheckBorderingGridCorners(_gridsquare,true))
		lab.font_size = 32
		lab.billboard = true
			
#func OverlapChecks():
	#for i in OverlappingBuildPoints.size():
		#if BuildingPoints.has(OverlappingBuildPoints[i]):
			#

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
	
func MoveCursor(_movement:Vector3):
	BuildingCursorPosition = _movement
	Cursor.global_position = BuildingCursorPosition
	##print(Cursor.global_position)
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
			return snapped(result.position,BuildingGrid.cell_size)
		return result.position
	else:
		return Vector3.ZERO


func EdgeCheckPoint(_point:Vector3,_array:Array[Vector3]) -> int:
	var count:int
	for x in CheckPositions.size():
		if _array.has(_point + CheckPositions[x]) && _point + CheckPositions[x] != _point:
			count += 1
	return count


func DEBUG_REFRESHBUILD():
	for i in Labels.size():
		Labels[i].queue_free()
	Labels.clear()
	for i in BuildingPoints.size():
		UpdateGridSquare(BuildingPoints[i])


func DeleteRoom():
	pass
func DeselectRoom():
	pass

func CreateNewRoom():
	CurrentlyEditingRoom = RoomResource.new()
	pass

func FinalizeRoom():
	CurrentlyEditingRoom.RoomSquares = BuildingPoints
	CurrentlyEditingRoom.RoomArea = AABB(CurrentlyEditingRoom.RoomSquares[0],CurrentlyEditingRoom.RoomSquares[CurrentlyEditingRoom.RoomSquares.size()-1])
	CurrentlyEditingRoom.PlacedProps.append_array(PlacedProps)
	
	var average = Vector3.ZERO
	for i in CurrentlyEditingRoom.RoomSquares.size():
		average += CurrentlyEditingRoom.RoomSquares[i]
	average /= CurrentlyEditingRoom.RoomSquares.size()
	
	if ShowLabels:
		var RoomLabel = Label3D.new()
		add_child(RoomLabel)
		RoomLabel.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		RoomLabel.outline_size = 100
		RoomLabel.text = "ROOM"
		RoomLabel.position = average + (Vector3.UP*2)
		RoomLabel.font_size = 100
		RoomLabel.modulate = Color.ORANGE
	
	Rooms.append(CurrentlyEditingRoom)
	CurrentlyEditingRoom = null
	OccupiedGridSquares.clear()
	OccupiedGridSquares.append_array(BuildingPoints)
	PERMANENTPLACEMENTS.append_array(OccupiedGridSquares)
	BuildingPoints.clear()
	PlacedProps.clear()

func GetAverageWallRotationIndex(_position:Vector3,CornerFix:bool = false,_offset:Vector3 = Vector3.ZERO,intcheck:int = -1) -> int:
	var checking:Vector3 = CheckBorderingGridAverage(_position,CornerFix) + _offset
	var CornerChecking = CheckBorderingGridCorners(_position,true)
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

func BuildConnector(_doorpos:Vector3):
	if BuildingPoints.has(_doorpos):
		var ye:int = GetAverageWallRotationIndex(_doorpos,true)
		BuildingGrid.set_cell_item(_doorpos,4,ye)

func DrawBuildRect(StartPoint:Vector3=Vector3.ZERO,EndPoint:Vector3=Vector3.ZERO,StartPointMod:Vector3=Vector3.ZERO,EndPointMod:Vector3=Vector3.ZERO):
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	####R SIDE
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,StartPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,StartPoint.z))
	mesh.surface_set_color(Color.GREEN)
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,StartPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,StartPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_color(Color.WHITE)
	
	####L SIDE
	mesh.surface_set_color(Color.PURPLE)
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,EndPoint.z))
	mesh.surface_set_color(Color.ORANGE)
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_set_color(Color.WHITE)
	
	####B SIDE
	mesh.surface_set_color(Color.YELLOW)
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_set_color(Color.BLUE)
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,DragStart.z))
	
	####F SIDE
	mesh.surface_set_color(Color.AQUA)
	mesh.surface_add_vertex(Vector3(DragStart.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_set_color(Color.CRIMSON)
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,EndPoint.z))

	mesh.surface_set_color(Color.WHITE)
	
	####TOP
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,EndPoint.z))
	mesh.surface_set_uv(Vector2(0, 0))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,DragStart.z))
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,DragStart.z))

	
	mesh.surface_end()
	PreviewBuildMesh.mesh = mesh
	
