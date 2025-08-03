extends Node2D

func _ready():

	# allow for the death signal to trigger a stopwatch reset
	var death = $death
	var stopwatch = $stopwatch
	var player = $player
	var goonbadeath = get_node("goonba/goonbadeath")
	var goonbadeath2 = get_node("goonba2/goonbadeath")
	var eagle = get_node("eagle/goonbadeath")
	death.player_died.connect(player.die)
	death.player_died.connect(stopwatch.reset)
	player.player_died.connect(player.die)
	player.player_died.connect(stopwatch.reset)
	goonbadeath.player_died.connect(player.die)
	goonbadeath.player_died.connect(stopwatch.reset)
	goonbadeath2.player_died.connect(player.die)
	goonbadeath2.player_died.connect(stopwatch.reset)
	eagle.player_died.connect(player.die)
	eagle.player_died.connect(stopwatch.reset)
