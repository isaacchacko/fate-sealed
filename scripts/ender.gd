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
		game_won.emit()
		# Optionally, wait for the animation to finish
		await ender.animation_finished
		var current_scene_file = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene_file.to_int() + 1
		var next_level_path = "res://levels/lvl_" + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
		HistoryManager.reset_all()
