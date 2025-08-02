extends Node

@export var record_duration : float = 1000.0
@export var snapshot_rate : int = 60

# Structure: node_id -> { "node": node, "properties": [prop1, ...] }
var registered = {}
# node_id -> [state_dict, ...]
var histories = {}

var accumulated_time : float = 0.0

func _physics_process(delta):
	var rewinding = TimeControl.is_rewinding
	accumulated_time += delta
	var interval = 1.0 / float(snapshot_rate)
	if accumulated_time >= interval:
		accumulated_time -= interval

		for node_id in registered.keys():
			var reg_info = registered[node_id]
			var node = reg_info["node"]
			var properties = reg_info["properties"]
			if not rewinding:
				# --- RECORD ---
				record_node_state(node, properties)
				# Clamp history size
				var max_size = int(record_duration * snapshot_rate)
				var entry = histories.get(node_id, [])
				while entry.size() > max_size:
					entry.pop_back()
			else:
				# --- REWIND ---
				var entry = histories.get(node_id, [])
				if entry.size() > 0:
					var state = entry.pop_front()
					apply_state_to_node(node, state)

# Called automatically for all nodes during recording!
func record_node_state(node: Node, properties: Array):
	var node_id = node.get_instance_id()
	if !histories.has(node_id):
		histories[node_id] = []
	var state = {}
	for prop in properties:
		state[prop] = node.get(prop)
	histories[node_id].push_front(state)

func apply_state_to_node(node: Node, state: Dictionary):
	for prop in state.keys():
		node.set(prop, state[prop])

# Nodes should call this in _ready()
func register_node(node: Node, properties: Array):
	var node_id = node.get_instance_id()
	registered[node_id] = { "node": node, "properties": properties }
	if !histories.has(node_id):
		histories[node_id] = []
