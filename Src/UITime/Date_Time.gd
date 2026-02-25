class_name DateTime extends Resource


@export_range(0,59) var seconds: int = 0
@export_range(0,59) var mintues: int = 0
@export_range(0,59) var hours: int = 0
@export var days: int = 0

var delta_time: float = 0

func Increase_by_sec(delta_seconds: float) -> void:
	delta_time += delta_seconds
	if delta_time < 1: return
	
	var delta_int_secs: int = delta_time
	delta_time -= delta_int_secs
	
	seconds += delta_int_secs
	mintues += seconds / 60
	hours += mintues / 60
	days += hours / 24
	
	seconds = seconds % 60
	mintues = mintues % 60
	hours = hours % 24
	
	print_debug(str(days) + ":" + str(hours) + ":" + str(seconds))
	pass
