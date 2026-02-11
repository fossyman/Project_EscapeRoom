extends Node
class_name BuildVisualiser

static var compass = [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK]

static func DrawBuildLine(_PreviewMesh:MeshInstance3D,StartPoint:Vector3,EndPoint:Vector3):
	var mesh = ImmediateMesh.new()
	var dist1 = EndPoint.x - StartPoint.x
	var dist2 = EndPoint.z - StartPoint.z
	var furthest:int
	print( str(dist1) + " || " + str(dist2))
	if abs(dist1) > abs(dist2):
		furthest = StartPoint.x +1
	elif abs(dist2) > abs(dist1):
		furthest = StartPoint.z +1
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	#####TOP
	mesh.surface_add_vertex(Vector3(-0.5,1,0))
	mesh.surface_add_vertex(Vector3(-0.5,1,1 + StartPoint.distance_to(EndPoint)))
	mesh.surface_add_vertex(Vector3(0.5,1,1 + StartPoint.distance_to(EndPoint)))
	
	mesh.surface_add_vertex(Vector3(0.5,1,0))
	mesh.surface_add_vertex(Vector3(0.5,1,1 + StartPoint.distance_to(EndPoint)))
	mesh.surface_add_vertex(Vector3(-0.5,1,0))


	
	mesh.surface_end()
	_PreviewMesh.position = StartPoint
	_PreviewMesh.rotation.y = round( atan2(dist1,dist2) / 1.5708 ) * 1.5708
	_PreviewMesh.mesh = mesh

static func DrawBuildRect(_PreviewMesh:MeshInstance3D,StartPoint:Vector3,EndPoint:Vector3,StartPointMod:Vector3 = Vector3.ZERO,EndPointMod:Vector3 = Vector3.ZERO):
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
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,StartPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,StartPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_set_color(Color.BLUE)
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(EndPoint.x,0,StartPoint.z))
	
	####F SIDE
	mesh.surface_set_color(Color.AQUA)
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,EndPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,EndPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_color(Color.CRIMSON)
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,StartPoint.z))
	mesh.surface_add_vertex(Vector3(StartPoint.x,0,EndPoint.z))

	mesh.surface_set_color(Color.WHITE)
	
	####TOP
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,EndPoint.z))
	mesh.surface_set_uv(Vector2(0, 0))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	
	mesh.surface_set_uv(Vector2(1, 0))
	mesh.surface_add_vertex(Vector3(StartPoint.x,1,StartPoint.z))
	mesh.surface_set_uv(Vector2(0, 1))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,EndPoint.z))
	mesh.surface_set_uv(Vector2(1, 1))
	mesh.surface_add_vertex(Vector3(EndPoint.x,1,StartPoint.z))

	
	mesh.surface_end()
	_PreviewMesh.global_position = Vector3.ZERO
	_PreviewMesh.rotation_degrees.y = 0
	_PreviewMesh.mesh = mesh
