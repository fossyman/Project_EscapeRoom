extends Node

var CanInteract:bool = true # Used for determining the players ability to interact with the game.

var MAIN:Node
var ROOT_CONTAINER:Node
var CURRENTROOT:RootManager
var CONSTANT:Node

func _ready() -> void:
	MAIN = get_tree().root.find_child("MAIN",true,false)
	ROOT_CONTAINER = MAIN.get_child(0)
	CURRENTROOT = ROOT_CONTAINER.get_child(0)
	CONSTANT = MAIN.get_child(1)

func ChangeRoot():
	pass
