extends Node
class_name BuildingManager

@export var BuildingGrid:GridMap

static var instance:BuildingManager

@export var Cursor:Node3D
var BuildingCursorPosition:Vector3

var ClickPos:Vector3
@export var DragDeadzone:float = 1.0
var DragStart:Vector3
var DragEnd:Vector3

@export var PreviewBuildMesh:MeshInstance3D

func _enter_tree() -> void:
	instance = self

func _process(delta: float) -> void:
	MoveCursor(mouse_position(true))
	
	if Input.is_action_pressed("Lclick"):
		var MousePos = mouse_position(true)
		if Input.is_action_just_pressed("Lclick"):
			ClickPos = MousePos

		if MousePos.distance_to(ClickPos) > DragDeadzone:
			DragStart = ClickPos
			DragEnd = MousePos
			print("MAKING SQUARE BETWEEN " + str(DragStart) + " AND " + str(DragEnd))
			DrawBuildRect(DragStart,DragEnd)

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

func DrawBuildRect(StartPoint:Vector3,EndPoint:Vector3):
	var mesh = ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	####R SIDE
	mesh.surface_set_color(Color.RED)
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragStart.z))
	mesh.surface_set_color(Color.GREEN)
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_set_color(Color.WHITE)
	
	####L SIDE
	mesh.surface_set_color(Color.PURPLE)
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragEnd.z))
	mesh.surface_set_color(Color.ORANGE)
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragEnd.z))
	mesh.surface_set_color(Color.WHITE)
	
	####B SIDE
	mesh.surface_set_color(Color.YELLOW)
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragEnd.z))
	mesh.surface_set_color(Color.BLUE)
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragEnd.x,0,DragStart.z))
	
	####F SIDE
	mesh.surface_set_color(Color.AQUA)
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragEnd.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_set_color(Color.CRIMSON)
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragStart.z))
	mesh.surface_add_vertex(Vector3(DragStart.x,0,DragEnd.z))

	mesh.surface_set_color(Color.WHITE)
	
	####TOP
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,EndPoint.z))
	mesh.surface_set_uv(Vector2(0, 0))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(DragStart.x,1,DragStart.z))
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragEnd.z))
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(Vector3(DragEnd.x,1,DragStart.z))

	
	mesh.surface_end()
	PreviewBuildMesh.mesh = mesh
