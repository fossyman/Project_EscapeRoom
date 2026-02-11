class_name AudioMangerSystem extends Node

var active_music_stream: AudioStreamPlayer


@export_group("main")
@export var Clips: Node


func play(audio_name, from_position: float = 0.0) -> void:
	active_music_stream = Clips.get_node(audio_name)
	active_music_stream.play(from_position)
