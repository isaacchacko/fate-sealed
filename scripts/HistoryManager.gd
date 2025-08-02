extends Node

@export var record_duration : float = 1000.0
@export var snapshot_rate : int = 60

# registered[node_id] = { "node": node, "properties": [...], "created_at": int }
var registered = {}
# node_id -> [state_dict, ...]
var histories = {}
var historyTime = 0;  # helps to distinguish when ephemeral nodes were created

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
			var createdAt = reg_info['createdAt']

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
				if historyTime < createdAt:  # if true, obj is ephemeral and
											 # should not be alive rn
					if node.is_inside_tree():
						node.queue_free()

					registered.erase(node_id)
					histories.erase(node_id)
					continue

				var entry = histories.get(node_id, [])
				if entry.size() > 0:
					var state = entry.pop_front()
					apply_state_to_node(node, state)

	# update the history time
	if not TimeControl.is_rewinding:
		historyTime += 1
	elif TimeControl.is_rewinding:
		historyTime = max(0, historyTime - 1)

# called when player dies
func reset_all():
	registered.clear()
	histories.clear()
	historyTime = 0

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
		if prop == "alive":  # immediately triggers set_alive helper function
							   # i miss useEffect
			node.set_alive(state[prop])
			continue

		node.set(prop, state[prop])  # default set

# Nodes should call this in _ready()
func register_node(node: Node, properties: Array, isEphemeral: bool):
	var node_id = node.get_instance_id()
	registered[node_id] = { "node": node,
							"properties": properties,
							"createdAt": historyTime if isEphemeral else -1}
	if !histories.has(node_id):
		histories[node_id] = []
