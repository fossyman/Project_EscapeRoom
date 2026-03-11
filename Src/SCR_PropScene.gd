extends Node3D
class_name PropScene

@export var SuccessRequirements:Stats
var Name:String
var Icon:CompressedTexture2D

@export var MeshContainer:Node3D

func Create(_PropRef:RES_PropData):
	Name = _PropRef._Name
	Icon = _PropRef._Icon
	pass
