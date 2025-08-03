extends StaticBody2D

signal player_died

func _on_area_2d_body_entered(body: Node2D) -> void:
	DeathManager._on_death()
