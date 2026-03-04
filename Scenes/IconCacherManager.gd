extends Node3D

@export var Camera:Camera3D
@export var CameraViewport:Viewport
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await RenderingServer.frame_post_draw
	var NewIcon = CameraViewport.get_texture().get_image()
	NewIcon.save_png("res://Cache/Icons/"+ "ICON"+".png")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
