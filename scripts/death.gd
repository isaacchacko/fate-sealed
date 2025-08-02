extends StaticBody2D

signal player_died

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("you sssss balls")
	player_died.emit()
	get_tree().reload_current_scene()
