# TimeControl.gd
extends Node

var time_speed := 1.0   # 1.0 = forward, -1.0 = backward
var is_rewinding := false

func _process(_delta):
	is_rewinding = Input.is_action_pressed("rewind")
	time_speed = -1.0 if is_rewinding else 1.0
