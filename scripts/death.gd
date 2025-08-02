extends StaticBody2D

func _on_body_entered(body):
	print("you suck balls")



#func _on_timer_timeout():
	#print("reload should occur")
	#get_tree().reload_current_scene()


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("you sssss balls")
	get_tree().reload_current_scene()
