extends Node

const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 12

# Name for my player
var player_name = "The Warrior"

# Names for remote players in id:name format
var players = {}
var players_ready = []
# Signals to let lobby GUI know what's going on
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func _connected_ok():
	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	emit_signal("connection_succeeded")

remote func register_player(id, name):
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, name) # Send new dude to player
	players[id] = name
	emit_signal("player_list_changed")
	
func join_game(ip, name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
func host_game(name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)
	
func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing
	var spawn_points = {}
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points)

	pre_start_game(spawn_points)
		
	
remote func pre_start_game(spawn_points):
#	assert(get_tree().is_network_server())
	
	var world = load("res://map.tscn").instance()
	get_tree().get_root().add_child(world)
	
	get_tree().get_root().get_node("lobby").hide()
	
	var player_scene = load("res://player.tscn")
	
	for p_id in spawn_points:
		var spawn_pos = world.get_node("spawn_points/" + str(spawn_points[p_id])).get_pos()
		var player = player_scene.instance()
		player.set_name(str(p_id))
		player.set_pos(spawn_pos)
		
		if (p_id == get_tree().get_network_unique_id()):
			#if node for this peer id, set master
			player.set_network_mode(NETWORK_MODE_MASTER)
			player.set_player_name(player_name)
		else:
			#otherwise, slave
			player.set_network_mode(NETWORK_MODE_SLAVE)
			player.set_player_name(players[p_id])
	
		world.get_node("players").add_child(player)
		
	#Tell server you're ready to start
	if not get_tree().is_network_server():
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

remote func post_start_game():
	get_tree().set_pause(false) #unpause the game!
	
remote func ready_to_start(id):
	assert(get_tree().is_network_server())
	
	if not id in players_ready:
		players_ready.append(id)
	
	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()
	
		