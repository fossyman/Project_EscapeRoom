extends Node
class_name GridmapPlus

@export var GridMeshLibrary:MeshLibrary
@export var StartingLayers:int
var Gridmaps:Array[GridMap]
@export var NavRegion:NavigationRegion3D

func _ready() -> void:
	for i in StartingLayers:
		CreateGrid()

func CreateGrid():
	var NewGrid = GridMap.new()
	add_child(NewGrid)
	NewGrid.cell_size = Vector3.ONE
	NewGrid.cell_center_x = false
	NewGrid.cell_center_y = false
	NewGrid.cell_center_z = false
	NewGrid.mesh_library = GridMeshLibrary
	Gridmaps.append(NewGrid)

func clear_cell_item(_layer:int,_position:Vector3i):
	Gridmaps[_layer].set_cell_item(_position,GridMap.INVALID_CELL_ITEM)

func set_cell_item(_layer:int,_position:Vector3i,_item:int,_direction:int):
	Gridmaps[_layer].set_cell_item(_position,_item,_direction)

func UpdateNavigationRegion():
	NavRegion.bake_navigation_mesh()
