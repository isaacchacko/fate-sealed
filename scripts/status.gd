extends Node

@onready var status: Label = $status

var target_opacity := 0.0
var current_opacity := 0.0
var fade_speed := 5.0   # Adjust for faster/slower fade
var needs_clear_text := false

func set_status_text(new_text: String):
	if new_text.strip_edges() != "":
		# Fade in if text provided
		status.text = new_text
		target_opacity = 1.0
		needs_clear_text = false
	else:
		# Fade out if text is empty
		target_opacity = 0.0
		needs_clear_text = true

func _ready():
	# Optionally, set up background color and corner radius here
	self.color = Color(0, 0, 0, 1)  # Start fully opaque black (or pick your default)

func _process(delta):
	# Set label text and color based on the game state
	if TimeControl.is_rewinding:
		set_status_text("Rewinding...")
		status.add_theme_color_override("font_color", Color(1, 1, 0)) # Yellow
	elif FreezeControl.is_frozen:
		set_status_text("Sealing...")
		status.add_theme_color_override("font_color", Color(0, 0, 1)) # Blue
	else:
		set_status_text("")

	# Lerp opacity
	current_opacity = lerp(current_opacity, target_opacity, delta * fade_speed)
	status.modulate.a = current_opacity
	self.modulate.a = current_opacity

	# Clear text when hidden
	if needs_clear_text and current_opacity < 0.05:
		status.text = ""
		needs_clear_text = false
