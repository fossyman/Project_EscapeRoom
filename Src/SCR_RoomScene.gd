extends Node
class_name RoomScene

@export var PropContainer:Node3D
@export var FoundationGrid:GridMap

func _init() -> void:
	PropContainer = Node3D.new()
	FoundationGrid = GridMap.new()
	FoundationGrid.mesh_library = BuildManager.instance.FoundationTool.FoundationMeshArray
	add_child(PropContainer)
	add_child(FoundationGrid)
