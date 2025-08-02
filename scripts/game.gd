extends Node2D

func _ready():

	# allow for the death signal to trigger a stopwatch reset
	var death = $death
	var stopwatch = $stopwatch
	death.player_died.connect(stopwatch.reset)
