extends StaticBody2D

@onready var ender: AnimatedSprite2D = $AnimatedSprite2D
signal game_won
var activated := false

func _ready():
	ender.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not activated and not body.is_in_group("player"):  # Optionally check it's the player
		activated = true
		ender.play("donzo")
		print("you the goat")
		game_won.emit()
		# Optionally, wait for the animation to finish:
		await ender.animation_finished
		HistoryManager.reset_all()
		get_tree().reload_current_scene()
