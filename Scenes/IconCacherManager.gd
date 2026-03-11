extends Node3D

@export var Camera:Camera3D
@export var CameraHolder:Node3D
@export var CameraViewport:Viewport
@export var SubjectArea:Node3D
@export var TestResource:RES_PropData
var CurrentAsset:RES_PropData
var CachingScene:PackedScene

var PropArray:Array[RES_PropData]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CollectAllPropReferences()

	pass # Replace with function body.

func CollectAllPropReferences():
	
	var PropPath = "res://Assets/Resources/PropData/"
	var PropDirectory = DirAccess.open(PropPath)
	
	if PropDirectory == null:
		return

	for x in PropDirectory.get_directories().size():
		print("ATTEMPTING " + str(PropDirectory.get_directories()[x]))
		for y in PropDirectory.get_files_at(PropDirectory.get_directories()[x]):
			print("ATTEMPTING " + str(y))
			var resource = load(PropPath+PropDirectory.get_directories()[x]+"/"+y) as RES_PropData
			print("RES?: "+resource)
			PropArray.append(resource)
			print("Y?: "+y)
		print("X?: "+PropDirectory.get_directories()[x])
	if PropArray.is_empty():
		return
	PrepareSceneForPicture(PropArray[0])
	SnapPicture()

func PrepareSceneForPicture(_prop:RES_PropData):
	CurrentAsset = _prop
	CachingScene = CurrentAsset._Scene
	var instance = CachingScene.instantiate() as PropScene
	SubjectArea.add_child(instance)
	CameraHolder.position = instance.MeshContainer.position

func SnapPicture():
	await RenderingServer.frame_post_draw
	var NewIcon = CameraViewport.get_texture().get_image()
	NewIcon.save_png("res://Cache/Icons/"+ CurrentAsset._Name + "ICON"+".png")
