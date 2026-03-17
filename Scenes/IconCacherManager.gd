extends Node3D
class_name IconCacher
static var instance:IconCacher
@export var Camera:Camera3D
@export var CameraHolder:Node3D
@export var CameraViewport:SubViewport
@export var SubjectArea:Node3D
@export var TestResource:RES_PropData
@export_flags_3d_render var PropRenderLayer
var CurrentAsset:RES_PropData
var CachingScene:PackedScene

var PropArray:Array[RES_PropData]

func _enter_tree() -> void:
	instance = self

func PrepareSceneForPicture(_prop:RES_PropData):
		
	CurrentAsset = _prop
	CachingScene = CurrentAsset._Scene
	var instance = CachingScene.instantiate() as PropScene
	SubjectArea.add_child(instance)
	
	for i in instance.MeshContainer.get_children(true):
		print(i.name + i.get_class())
		if i is MeshInstance3D:
			i.layers = PropRenderLayer
	
	print(CameraHolder.position)
	CameraHolder.position = instance.MeshContainer.position
	print(CameraHolder.position)

func SnapPicture(_prop:RES_PropData) -> Texture2D:
	PrepareSceneForPicture(_prop)
	await get_tree().process_frame
	CameraViewport.render_target_update_mode = SubViewport.UPDATE_ONCE
	await RenderingServer.frame_post_draw
	var ico = CameraViewport.get_texture().get_image()
	var NewIcon = ImageTexture.create_from_image(ico)
	ClearPlayspace()
	return NewIcon
	#NewIcon.save_png("res://Cache/Icons/"+ CurrentAsset._Name + "ICON"+".png")

func ClearPlayspace():
	for i in SubjectArea.get_child_count():
		SubjectArea.get_child(i).queue_free()
