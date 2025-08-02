# FreezeControl.gd
extends Node

var is_frozen: bool = false

func _input(event):
	if event.is_action_pressed("freeze"):
		toggle()

func freeze():
	is_frozen = true

func unfreeze():
	is_frozen = false

func toggle():
	is_frozen = !is_frozen
