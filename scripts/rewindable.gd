extends Node


@export var record_duration : float = 3.0        # seconds to store
@export var snapshot_rate : int = 30             # how many saves per second
@export var properties : Array[StringName] = ["global_position"]

var history : Array = []
var accumulated_time : float = 0.0

func _ready():
	if not get_parent():
		push_warning("Rewindable must be a child of the node you want to rewind.")

func _physics_process(delta):
	var rewinding = TimeControl.is_rewinding

	accumulated_time += delta
	var interval = 1.0 / float(snapshot_rate)
	if accumulated_time >= interval:
		accumulated_time -= interval

		if not rewinding:
			# --- RECORD STATE ---
			var state = {}
			for prop in properties:
				state[prop] = get_parent().get(prop)
			history.push_front(state)
			var max_size = int(record_duration * snapshot_rate)
			if history.size() > max_size:
				history.pop_back()
		elif history.size() > 0:
			# --- REWIND TO PAST STATE ---
			var prev = history.pop_front()
			for prop in properties:
				get_parent().set(prop, prev[prop])
