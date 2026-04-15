class_name PauseSystem extends Control
@onready var settings = $"Panel/VBoxContainer/settings/Setting menu"

var IsPaused:bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if !IsPaused:
			pause()
		else:
			resume()
			
func resume():
	IsPaused = false
	get_tree().paused = IsPaused
	visible = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	IsPaused = true
	get_tree().paused = IsPaused
	visible = true
	$AnimationPlayer.play("blur")

func _on_resume_pressed() -> void:
	resume()
	visible = false

func _on_settings_pressed() -> void:
	settings.visible = true
	pass

func _on_quit_pressed() -> void:
	GLOBALS.ChangeRoot(GLOBALS.MAINMENU_ROOT)
