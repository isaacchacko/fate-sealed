extends CanvasLayer

var running := false
var elapsed_time := 0.0
var rewinding := false

var target_color := Color(1, 1, 1)
var current_color := Color(1, 1, 1)
var transition_speed := 5.0

func _ready():
	reset()
	start()

func _process(delta):
	# Set target color based on current app state
	if FreezeControl.is_frozen:
		target_color = Color(0, 0, 1)   # Blue when frozen
	elif TimeControl.is_rewinding:
		target_color = Color(1, 1, 0)   # Yellow when rewinding
	else:
		target_color = Color(1, 1, 1)   # White otherwise

	# Lerp towards target color
	current_color = current_color.lerp(target_color, delta * transition_speed)
	$label.add_theme_color_override("font_color", current_color)

	# Track rewind input
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

	if FreezeControl.is_frozen:
		running = false
	else:
		running = true

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
