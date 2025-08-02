extends Node

@export var record_duration : float = 1000.0
@export var snapshot_rate : int = 60

# registered[node_id] = { "node": node, "properties": [...], "created_at": int }
var registered = {}
var frozen_states = {}
# node_id -> [state_dict, ...]
var histories = {}
var historyTime = 0;  # helps to distinguish when ephemeral nodes were created


var accumulated_time : float = 0.0

func _unhandled_input(event):
	if event.is_action_pressed("freeze"):  # toggle on key press
		FreezeControl.is_frozen = !FreezeControl.is_frozen
		if FreezeControl.is_frozen:
			frozen_states.clear()
			for node_id in registered.keys():
				var reg_info = registered[node_id]
				var node = reg_info["node"]
				var properties = reg_info["properties"]
				var state = {}
				for prop in properties:
					state[prop] = node.get(prop)
				frozen_states[node_id] = state

		
func _physics_process(delta):
	# freeze code
	if FreezeControl.is_frozen:
		for node_id in frozen_states.keys():
			var node = registered[node_id]["node"]
			var state = frozen_states[node_id]
			for prop in state.keys():
				node.set(prop, state[prop])
		
		
	var rewinding = TimeControl.is_rewinding
	accumulated_time += delta
	var interval = 1.0 / float(snapshot_rate)
	
	if FreezeControl.is_frozen:
		return
		
	if accumulated_time >= interval:
		accumulated_time -= interval

		for node_id in registered.keys():

			# the following is used for ALL objects
			var reg_info = registered[node_id]
			var node = reg_info["node"]
			var properties = reg_info["properties"]
			var createdAt = reg_info['createdAt']

			# the following is only relevant to sealable objects.
			# if the object is not sealable, these variable values are generic
			var seal_info = reg_info['seal']
			var isSealed = seal_info['isSealed']
			var sealExpiresAt = seal_info['expiresAt']

			if not rewinding:
				if isSealed and historyTime < sealExpiresAt:  # obj sealed
					var entry = histories.get(node_id, [])
					if entry.size() > 0:
						var state = entry[historyTime]
						apply_state_to_node(node, state)

				else:  # record
					record_node_state(node, properties)
					# Clamp history size
					var max_size = int(record_duration * snapshot_rate)
					var entry = histories.get(node_id, [])
					while entry.size() > max_size:
						entry.pop_back()

			else:

				# this only triggers for ephemeral obj
				if historyTime < createdAt:  # obj does not exist (historyTime)
					if node.is_inside_tree():
						node.queue_free()

					registered.erase(node_id)
					histories.erase(node_id)
					continue

				var entry = histories.get(node_id, [])
				if entry.size() > 0:
					var state

					# either
					if isSealed and historyTime < sealExpiresAt:  # obj sealed
						state = entry[historyTime]
					else:
						state = entry.pop_front()

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

func seal(node: Node):
	var node_id = node.get_instance_id()

	# sanity check that node is sealable
	if (!registered[node_id]['sealable']):
		return

	var entry = histories.get(node_id, [])
	if entry.size() > 0:  # if there is history to seal
		registered[node_id]['seal']['isSealed'] = true
		registered[node_id]['seal']['expiresAt'] = historyTime

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
func register_node(node: Node, properties: Array, ephemeral: bool, sealable: bool):

	# ephemeral objects cannot be choosen to be sealed. they CAN be used by
	# sealable enemies. say an enemy shoots a bomb. the bomb will still
	# create history, and because the enemy is sealed the bomb will always be
	# shot, but the bomb itself cannot be sealed.
	assert(!(ephemeral and sealable),
	"ephemeral objects cannot be choosen to be sealed.")

	var node_id = node.get_instance_id()
	registered[node_id] = {
		"node": node,
		"properties": properties,
		"createdAt": historyTime if ephemeral else -1,
		"sealable": sealable,
		"seal": {
			"isSealed": false,
			"expiresAt": null
			}
		}
	if !histories.has(node_id):
		histories[node_id] = []
