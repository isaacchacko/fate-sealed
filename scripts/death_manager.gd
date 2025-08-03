extends Node

var death_sources : Array = []
var player = null
var stopwatch = null

func _ready():
	pass # Will call setup from outside, once all refs are set

func setup(_player, _stopwatch, _death_sources : Array):
	player = _player
	stopwatch = _stopwatch
	death_sources = _death_sources
	_connect_all()

func _on_death():
	if player:
		player.die()
	if stopwatch:
		stopwatch.reset()

func _connect_all():
	for node in death_sources:
		if node.has_signal("player_died"):
			node.player_died.connect(_on_death)
