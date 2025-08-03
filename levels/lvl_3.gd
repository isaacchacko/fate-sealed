extends Node

func _ready():
	# Find all death sources and pass them to DeathManager
	var death_sources = [
		$death,
		get_node("RedHulk/goonbadeath"),
		get_node("RedHulk2/goonbadeath"),
		get_node("RedHulk3/goonbadeath"),
		get_node("player")  # Not sure if this is right; check if correct
	]

	var player = $player
	var stopwatch = $stopwatch

	DeathManager.setup(player, stopwatch, death_sources)
