extends Node2D

func _ready():

	# allow for the death signal to trigger a stopwatch reset
	var death = $death
	var stopwatch = $stopwatch
	var player = $player
	var goonbadeath = get_node("goonba/goonbadeath")
	var goonbadeath2 = get_node("goonba2/goonbadeath")
	var goonbadeath3 = get_node("goonba3/goonbadeath")
	var goonbadeath4 = get_node("goonba4/goonbadeath")
	var goonbadeath5 = get_node("goonba5/goonbadeath")
	var goonbadeath6 = get_node("goonba6/goonbadeath")
	var goonbadeath7 = get_node("goonba7/goonbadeath")
	var goonbadeath8 = get_node("goonba8/goonbadeath")
	var goonbadeath9 = get_node("goonba9/goonbadeath")
	var eagle = get_node("eagle/goonbadeath")
	death.player_died.connect(player.die)
	death.player_died.connect(stopwatch.reset)
	player.player_died.connect(player.die)
	player.player_died.connect(stopwatch.reset)
	goonbadeath.player_died.connect(player.die)
	goonbadeath.player_died.connect(stopwatch.reset)
	goonbadeath2.player_died.connect(player.die)
	goonbadeath2.player_died.connect(stopwatch.reset)
	goonbadeath3.player_died.connect(player.die)
	goonbadeath3.player_died.connect(stopwatch.reset)
	goonbadeath4.player_died.connect(player.die)
	goonbadeath4.player_died.connect(stopwatch.reset)
	goonbadeath5.player_died.connect(player.die)
	goonbadeath5.player_died.connect(stopwatch.reset)
	goonbadeath6.player_died.connect(player.die)
	goonbadeath6.player_died.connect(stopwatch.reset)
	goonbadeath7.player_died.connect(player.die)
	goonbadeath7.player_died.connect(stopwatch.reset)
	goonbadeath8.player_died.connect(player.die)
	goonbadeath8.player_died.connect(stopwatch.reset)
	goonbadeath9.player_died.connect(player.die)
	goonbadeath9.player_died.connect(stopwatch.reset)
	eagle.player_died.connect(player.die)
	eagle.player_died.connect(stopwatch.reset)
