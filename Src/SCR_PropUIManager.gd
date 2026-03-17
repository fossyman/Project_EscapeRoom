extends Panel

@export var ButtonTemplate:Button
@export var PropResourcePath:String
@export var PropButtonGrid:GridContainer

var CachedGenericProps:Array[RES_PropData]
var CachedPirateProps:Array[RES_PropData]
var CachedHorrorProps:Array[RES_PropData]
var CachedSciFiProps:Array[RES_PropData]
var CachedFantasyProps:Array[RES_PropData]

var GridID:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GeneratePropCache()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func GeneratePropCache():
	var Props = get_all_file_paths(PropResourcePath)
	
	for i in Props:
		var prop = ResourceLoader.load(i) as RES_PropData
		if prop._PropCategories[0]:
			match prop._PropCategories[0]:
				GLOBALS.PROP_CATEGORIES.GENERIC:
					CachedGenericProps.append(prop)
					pass
				GLOBALS.PROP_CATEGORIES.PIRATE:
					CachedPirateProps.append(prop)
					pass
				GLOBALS.PROP_CATEGORIES.FANTASY:
					CachedFantasyProps.append(prop)
					pass
				GLOBALS.PROP_CATEGORIES.HORROR:
					CachedHorrorProps.append(prop)
					pass
				GLOBALS.PROP_CATEGORIES.SCIFI:
					CachedSciFiProps.append(prop)
					pass
		else:
			printerr("PROP HAS NO CATEGORIES")
	GenerateGridContent(CachedPirateProps)
	
func GenerateGridContent(Propset:Array[RES_PropData]):
	for i in PropButtonGrid.get_child_count():
		PropButtonGrid.get_child(i).queue_free()
		
	for i in Propset:
		IconCacher.instance.ClearPlayspace()
		var Newbutton = PropButton.new()
		var NewIcon = TextureRect.new()
		NewIcon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		NewIcon.custom_minimum_size = Vector2(100,100)
		NewIcon.position = Vector2.ZERO
		Newbutton.custom_minimum_size = Vector2(100,100)
		Newbutton.Propdata = i
		PropButtonGrid.add_child(Newbutton)
		Newbutton.add_child(NewIcon)
		Newbutton.reparent(PropButtonGrid)
		NewIcon.texture = await IconCacher.instance.SnapPicture(i) as Texture2D
		Newbutton = null
		NewIcon = null
		
func get_all_file_paths(path: String) -> Array[String]:  
	var file_paths: Array[String] = []  
	var dir = DirAccess.open(path)  
	dir.list_dir_begin()  
	var file_name = dir.get_next()  
	while file_name != "":  
		var file_path = path + "/" + file_name  
		if dir.current_is_dir():  
			file_paths += get_all_file_paths(file_path)  
		else:  
			file_paths.append(file_path)  
		file_name = dir.get_next()  
	return file_paths
