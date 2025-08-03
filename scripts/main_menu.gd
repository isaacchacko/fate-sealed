extends Node2D


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/lvl_0.tscn")


func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_how_to_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/how_to.tscn")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
