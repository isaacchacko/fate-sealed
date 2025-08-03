extends CanvasLayer

var running := false
var elapsed_time := 0.0
var rewinding := false

func _ready():
	reset()
	start()

func _process(delta):
	if Input.is_action_pressed("rewind"):
		rewinding = true
	else:
		rewinding = false

	if running:
		if rewinding:
			elapsed_time = max(0.0, elapsed_time - delta)
		else:
			elapsed_time += delta
		$label.text = format_time(elapsed_time)

func start():
	running = true

func stop():
	running = false

func reset():
	elapsed_time = 0.0
	$label.text = format_time(elapsed_time)
	

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millis = int((seconds - int(seconds)) * 100)
	return "%02d:%02d.%02d" % [minutes, secs, millis]
