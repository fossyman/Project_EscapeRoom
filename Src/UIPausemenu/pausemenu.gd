class_name PauseSystem extends Control

func resume():
	get_tree().paused = false
	$AnimationPlayer.play_backwards("blur")

func pause():
	get_tree().paused = true
	$AnimationPlayer.play("blur")

func testESC():
	if Input.is_action_just_pressed("esc") and get_tree().paused == false:
		pause()
	elif  Input.is_action_just_pressed("esc") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Roots/ROOT_MainMenu.tscn")
