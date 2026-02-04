class_name RT_MainMenu extends Node


@export var level: PackedScene

func _ready() -> void:
	$"CONTENT/Interactables/Setting menu/Full screen".button_pressed = true if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN else false
	$"CONTENT/Interactables/Setting menu/MainVolSlider".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Main volume")))
	$"CONTENT/Interactables/Setting menu/MusicSlider".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music ")))
	$"CONTENT/Interactables/Setting menu/SFXSlider".value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))




func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(level)
	pass # Replace with function body.


func _on_settings_pressed() -> void:
	$CONTENT/Interactables/PLAYSET.visible = false
	$CONTENT/Interactables/CREDQUIT.visible = false
	
	$"CONTENT/Interactables/Setting menu".visible = true
func _on_credits_pressed() -> void:
	$CONTENT/Interactables/PLAYSET.visible = false
	$CONTENT/Interactables/CREDQUIT.visible = false
	
	$"CONTENT/Interactables/Credits menu".visible = true 
func _on_quit_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_back_pressed() -> void:
	$CONTENT/Interactables/PLAYSET.visible = true
	$CONTENT/Interactables/CREDQUIT.visible = true
	$"CONTENT/Interactables/Setting menu".visible = false
	$"CONTENT/Interactables/Credits menu".visible = false
	pass # Replace with function body.


func _on_full_screen_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)


func _on_main_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Main volume"),value)


func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"),value)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"),value)
