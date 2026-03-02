extends Node
class_name FoundationManager
static var instance:FoundationManager

@export_category("FOUNDATION")
@export var BuildMat:Material
@export var DestroyMat:Material
@export var BuildSizeLabel:Label3D
@export var ShowLabels:bool=false
@export var EdgeColors:bool=false
@export var CornerColors:bool=false
@export var InnerCornerColors:bool=false

@export var PreviewBuildMesh:MeshInstance3D

var Labels:Array[Label3D]

@export var Chunksize = 64

@export var FoundationMeshArray:MeshLibrary

enum SELECTED_TOOL{FOUNDATION,ERASE,FLOOR}
var SelectedTool:SELECTED_TOOL = 0

signal FoundationPlaced
signal DoorwayPlaced

func _enter_tree() -> void:
	instance = self

func EraseArea(_layer:int,StartCorner:Vector3,EndCorner:Vector3):
	if (StartCorner.x < 0 or StartCorner.z < 0) or (EndCorner.x < 0 or EndCorner.z < 0):
		print("here")
		return
	
	if BuildManager.instance.DragEnd == BuildManager.instance.DragStart:
		print("or here")
		return
	
	
		
	var NewPoints:Array[Vector3]
	var Borders:Array[Vector3]
	var _border:int = 1
	
	for BX in range(StartCorner.x - _border,EndCorner.x + _border):
		for BZ in range(StartCorner.z - _border,EndCorner.z + _border):
			if BX in range(StartCorner.x,EndCorner.x) and BZ in range(StartCorner.z,EndCorner.z) and !BuildManager.instance.BuildingPoints.has(Vector3(BX,0,BZ)):
				if BuildManager.instance.PERMANENTPLACEMENTS.has(Vector3(BX,0,BZ)):
					BuildManager.instance.PERMANENTPLACEMENTS.erase(Vector3(BX,0,BZ))
			if BuildManager.instance.BuildingPoints.has(Vector3(BX,0,BZ)):
				BuildManager.instance.BuildingPoints.erase(Vector3(BX,0,BZ))
			if !BuildManager.instance.OverlappingBuildPoints.has(Vector3(BX,0,BZ)):
				BuildManager.instance.OverlappingBuildPoints.append(Vector3(BX,0,BZ))
	var ChunkCounter:int = 0
	print("1")
	if BuildManager.instance.OverlappingBuildPoints.is_empty():
		return
		
	for i in BuildManager.instance.OverlappingBuildPoints.size():
		print("2")
		BuildManager.instance.UpdateGridSquare(_layer,BuildManager.instance.OverlappingBuildPoints[i],true)
		ChunkCounter +=1
		if ChunkCounter >= Chunksize:
			ChunkCounter = 0
			await get_tree().process_frame
	BuildManager.instance.OverlappingBuildPoints.clear()
	BuildManager.instance.RebuildGridSquares(true)
	
func BuildConnector(_doorpos:Vector3):
	#if BuildManager.instance.BuildingPoints.has(_doorpos):
		#var ye:int = BuildManager.instance.GetAverageWallRotationIndex(_doorpos,true)
		#BuildManager.instance.BuildingGrid.set_cell_item(_doorpos,4,ye)
		#BuildManager.instance.CurrentRoom.HasDoor = true
		DoorwayPlaced.emit()

func SetTool(value:int = 0):
	SelectedTool = value
