extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")

# Player info, associate ID to data
var player_info = {}
var players_done = []

var my_info = { name = "Nico", favorite_color = Color(255, 0, 255)}

func _player_connected(id):
	pass
	
func _player_disconnected(id):
	pass

func _connected_ok():
	rpc("register_player", get_tree().get_network_unique_id(), my_info)
	
func _server_disconnected():
	pass

func _connected_failed():
	pass

func _on_join_pressed():
	if (get_node("ip").get_text() == ""):
		return
	
	var ip = get_node("ip").get_text()
	
	get_node("host").set_disabled(true)
	get_node("join").set_disabled(true)
	
	var name = get_node("name").get_text()
	gamestate.join_game(ip, name)
		
func _on_host_pressed():
	get_node("host").set_disabled(true)
	get_node("join").set_disabled(true)
	
	var name = get_node("name").get_text()
	gamestate.host_game(name)

remote func register_player(id, info):
	player_info[id] = info
	if(get_tree().is_network_server()):
		rpc_id(id, "register_player", 1, my_info)
		for peer_id in player_info:
			rpc_id(id, "register_player", peer_id, player_info[peer_id])
			
remote func pre_configure_game():
	get_tree().set_pause(true) # pre-pause game before players are loaded
	#load world
	var world = load("res://unit_test.tscn").instance()
	get_node("/root").add_child(world)
	
	#load my player
	var my_player = preload("res://player.tscn").instance()
	my_player.set_name(str(get_tree().get_network_id()))
	get_node("/root/world/players").add_child(my_player)
	
	#load other players
	for p in player_info:
		var player = preload("res://player.tscn").instance()
		player.set_name(str(p))
		player.set_network_mode(NETWORK_MODE_SLAVE)
		get_node("/root/world/players").add_child(player)
		
	# Tell server (remember, server is always ID=1) that this peer is done pre-configuring
	rpc(1, "done_preconfiguring", get_tree().get_network_unique_id())

remote func done_preconfiguring(who):
	assert(get_tree().is_network_server())
	assert(who in player_info) #exists?
	assert(not who in players_done) # was not added yet
	
	players_done.append(who)
	if(players_done.size() == player_info.size()):
		rpc("post_configure_game")
	
remote func post_configure_game():
	get_tree().set_pause(false)
	#Game starts!