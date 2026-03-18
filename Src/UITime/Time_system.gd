class_name TimeSystem extends Node

signal Updated

@export var date_time : DateTime
@export var Ticks_per_sec: int = 6

func _process(delta: float) -> void:
	print(date_time)
	date_time.Increase_by_sec(delta * Ticks_per_sec)
	Updated.emit(date_time)
