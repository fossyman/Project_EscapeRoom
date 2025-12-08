extends Node
class_name BuildingManager

@export var EdgeColors:bool=false
@export var CornerColors:bool=false
@export var InnerCornerColors:bool=false

@export var BuildingGrid:GridMap

static var instance:BuildingManager

@export var Cursor:Node3D
var BuildingCursorPosition:Vector3

var ClickPos:Vector3
@export var DragDeadzone:float = 1.0
var DragStart:Vector3
var DragEnd:Vector3

@export var PreviewBuildMesh:MeshInstance3D

var SelectedSpaces:Array[Vector3]
var CurrentDragSpaces:Array[Vector3]

var Points:Array[Vector3] = []

var BuildEdges:Array[Vector3] = []

var Labels:Array[Label3D]

static var CheckPositions = [Vector3(1,0,1),Vector3(0,0,1),Vector3(-1,0,1),
							Vector3(1,0,0),Vector3(0,0,0),Vector3(-1,0,0),
							Vector3(1,0,-1),Vector3(0,0,-1),Vector3(-1,0,-1)]

func _enter_tree() -> void:
	instance = self

func _process(delta: float) -> void:
	if !GLOBALS.CanInteract:
		return
		
	MoveCursor(mouse_position(true))
	
	if Input.is_action_pressed("Lclick"):
		var MousePos = mouse_position(true)
		if Input.is_action_just_pressed("Lclick"):
			ClickPos = MousePos

		if MousePos.distance_to(ClickPos) > DragDeadzone:
			DragStart = ClickPos
			DragEnd = MousePos
			#print("MAKING SQUARE BETWEEN " + str(DragStart) + " AND " + str(DragEnd))
			DrawBuildRect(DragStart,DragEnd)
	if Input.is_action_just_released("Lclick"):
		var points = []
		if DragEnd == DragStart:
			return
		
		var StartX = (DragStart.x if DragStart.x < DragEnd.x else DragEnd.x) - 0
		var StartZ = (DragStart.z if DragStart.z < DragEnd.z else DragEnd.z) - 0
		
		var EndX = (DragEnd.x if DragEnd.x > DragStart.x else DragStart.x) + 1
		var EndZ = (DragEnd.z if DragEnd.z > DragStart.z else DragStart.z) + 1
		
		if EndX - StartX < 3.0 ||  EndZ - StartZ < 3.0 :
			return
		
		for X in range(StartX,EndX):
			print("width " + str(X))
			for Z in range(StartZ,EndZ):
				print("height " + str(Z))
				points.append(Vector3(X,0,Z))
		print(points.size())
		
		Points.append_array(points)
		for i in points.size():
			pass
		
		for i in Labels.size():
			Labels[i].queue_free()
		Labels.clear()
		BuildEdges.clear()
		BuildingGrid.clear()
		for i in Points.size():
			var ye = Label3D.new()
			add_child(ye)
			Labels.append(ye)
			ye.global_position = Points[i]
			
			var EdgeCount = 0
			var Edges = []
			
			var PrimaryEdge:int = 0 # 0=UP,1=RIGHT,2=DOWN,3=LEFT
			var EdgeCheck:Array[Vector3]
			var CornerCheck:Array[Vector3]
			
			for x in CheckPositions.size():
				if Points.has(Points[i] + CheckPositions[x]) && Points[i] + CheckPositions[x] != Points[i]:
					Edges.append(Points[i] + CheckPositions[x])

					EdgeCount += 1
				else:
					if x == 1 or x == 3 or x == 5 or x == 7:
						EdgeCheck.append(CheckPositions[x])
					elif x == 0 or x == 2 or x == 6 or x == 8:
						CornerCheck.append(CheckPositions[x])

			match EdgeCount:
				#CORNER
				3:
					match CheckBorderingGrid(Points[i]):
						Vector3(-1.0,0.0,-1.0):
							if CornerColors:
								ye.modulate = Color.YELLOW
							print("YELLOW IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,16)
							pass
						Vector3(1.0,0.0,-1.0):
							if CornerColors:
								ye.modulate = Color.MAGENTA
							print("MAGENTA IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,0)
							pass
						Vector3(1.0,0.0,1.0):
							if CornerColors:
								ye.modulate = Color.MAROON
							print("MAROON IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,22)
							pass
						Vector3(-1.0,0.0,1.0):
							if CornerColors:
								ye.modulate = Color.AQUA
							print("AQUA IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,10)
							pass
				4:
							match CheckBorderingGridCorners(Points[i]):
								Vector3(-0.6,0.0,0.2):
									if CornerColors:
										ye.modulate = Color.YELLOW
									print("YELLOW IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,10)
								pass
								Vector3(-0.6,0.0,-0.2):
									if CornerColors:
										ye.modulate = Color.DEEP_PINK
									print("YELLOW IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,16)
								pass
								Vector3(0.6,0.0,0.2):
									if CornerColors:
										ye.modulate = Color.AQUA
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,22)
								pass
								Vector3(0.6,0.0,-0.2):
									if CornerColors:
										ye.modulate = Color.CRIMSON
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,0)
								pass
								Vector3(0.2,0.0,0.6):
									if CornerColors:
										ye.modulate = Color.RED
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,22)
								pass
								Vector3(-0.2,0.0,0.6):
									if CornerColors:
										ye.modulate = Color.CORNFLOWER_BLUE
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,10)
								pass
								Vector3(-0.2,0.0,-0.6):
									if CornerColors:
										ye.modulate = Color.DARK_BLUE
										print("BLUE IS " + str(Vector3(0.0,0.0,-1.0)))
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,16)
								pass
								Vector3(0.2,0.0,-0.6):
									if CornerColors:
										ye.modulate = Color.ORANGE
										print("BLUE IS " + str(Vector3(0.0,0.0,-1.0)))
									print("AQUA IS " + str(EdgeCount))
									BuildingGrid.set_cell_item(Points[i],0,0)
								pass
				5,6:
					BuildEdges.append(Points[i])
					match GetPrimaryWallDirection(EdgeCheck):
						Vector3.LEFT:
							if EdgeColors:
								ye.modulate = Color.GREEN
							BuildingGrid.set_cell_item(Points[i],1,16)
							pass
						Vector3.RIGHT:
							if EdgeColors:
								ye.modulate = Color.PURPLE
							BuildingGrid.set_cell_item(Points[i],1,16)
							pass
						Vector3.FORWARD:
							if EdgeColors:
								ye.modulate = Color.PINK
							BuildingGrid.set_cell_item(Points[i],1,0)
							pass
						Vector3.BACK:
							if EdgeColors:
								ye.modulate = Color.ORANGE
							BuildingGrid.set_cell_item(Points[i],1,0)
							pass
				7:
					print(CheckBorderingGrid(Points[i]))
					match(CheckBorderingGrid(Points[i],true)):
						Vector3(-1.0,0.0,-1.0):
							if InnerCornerColors:
								ye.modulate = Color.YELLOW
							print("YELLOW IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,22)
							pass
						Vector3(1.0,0.0,-1.0):
							if InnerCornerColors:
								ye.modulate = Color.MAGENTA
							print("MAGENTA IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,10)
							pass
						Vector3(1.0,0.0,1.0):
							if InnerCornerColors:
								ye.modulate = Color.MAROON
							print("MAROON IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,16)
							pass
						Vector3(-1.0,0.0,1.0):
							if InnerCornerColors:
								ye.modulate = Color.AQUA
							print("AQUA IS " + str(EdgeCount))
							BuildingGrid.set_cell_item(Points[i],0,0)
							pass
						Vector3.LEFT:
							ye.modulate = Color.BLACK
							BuildingGrid.set_cell_item(Points[i],1,22)
						Vector3.RIGHT:
							ye.modulate = Color.BLACK
							BuildingGrid.set_cell_item(Points[i],1,22)
						Vector3.FORWARD:
							ye.modulate = Color.PURPLE
							BuildingGrid.set_cell_item(Points[i],1,0)
						Vector3.BACK:
							ye.modulate = Color.PURPLE
							BuildingGrid.set_cell_item(Points[i],1,0)
				8:
					#BuildingGrid.set_cell_item(Points[i],0)
					pass
			ye.text = str(EdgeCount)
			ye.font_size = 100
			ye.billboard = true
			
			
func GetPrimaryWallDirection(_EdgeTable:Array[Vector3]):
	print("Primary value is: " + str(_EdgeTable.max()))
	return _EdgeTable.max()

func CheckBorderingGrid(_position:Vector3,CornerFix:bool = false) -> Vector3:
	var EmptyPoints:Array[Vector3]
	var val:Vector3
	var avg:Vector3
	for i in CheckPositions.size():
		if Points.has(_position + CheckPositions[i]):
			EmptyPoints.append( (CheckPositions[i]) )
			
	for i in EmptyPoints.size():
		val += EmptyPoints[i]
		
	avg = val / EmptyPoints.size()
	print("BORDERS FOR " + str(_position) + " ARE THE FOLLOWING..." + str((avg*10).round()))
	if CornerFix:
		return (avg*10).round()
	return avg.round()

func CheckBorderingGridCorners(_position:Vector3) -> Vector3:
	var val:Vector3
	var avg:Vector3
	var FoundCorners:Array[Vector3]
	
	var dir:Vector3
	
	for i in CheckPositions.size():
		if Points.has(_position + CheckPositions[i]):
			FoundCorners.append(CheckPositions[i])

	
	var sum = FoundCorners.reduce(func(acc, num): return acc + num)
	var average = sum / FoundCorners.size()
	
	print("DIRECTION " + str(average))
	return average
	
func MoveCursor(_movement:Vector3):
	BuildingCursorPosition = _movement
	Cursor.global_position = BuildingCursorPosition
	#print(Cursor.global_position)
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
			return round(result.position)
		return result.position
	else:
		print("nonexistent")
		return Vector3.ZERO

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
	
