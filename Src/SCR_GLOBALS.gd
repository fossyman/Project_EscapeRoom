extends Node

var CanInteract:bool = true # Used for determining the players ability to interact with the game.

var MAIN:Node
var ROOT_CONTAINER:Node
var CURRENTROOT:RootManager
var CONSTANT:Node
var DELTA:float

var MAINMENU_ROOT = "res://Scenes/Roots/ROOT_MainMenu.tscn"
var GAMEPLAYROOT_ROOT = "res://Scenes/Roots/ROOT_Gameplay.tscn"


enum PROP_CATEGORIES{GENERIC,PIRATE,FANTASY,HORROR,SCIFI}

var money:float = 0

func _ready() -> void:
	MAIN = get_tree().root.find_child("MAIN",true,false)
	if !MAIN:
		return
	ROOT_CONTAINER = MAIN.get_child(0)
	CURRENTROOT = ROOT_CONTAINER.get_child(0)
	CONSTANT = MAIN.get_child(1)

func _process(delta: float) -> void:
	DELTA = delta

func ChangeRoot(_newRootPath:String):
	CURRENTROOT.queue_free()
	var instancedRoot = (ResourceLoader.load(_newRootPath) as PackedScene).instantiate()
	add_child(instancedRoot)
	CURRENTROOT = instancedRoot
	pass
