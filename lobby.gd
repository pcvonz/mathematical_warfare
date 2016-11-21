extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
#	gamestate.connect("connection_failed", self, "_on_connection_failed")
#	gamestate.connect("game_ended", self, "_on_game_ended")
#	gamestate.connect("game_error", self, "_on_game_error")
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")

# Player info, associate ID to data
var player_info = {}
var players_done = []

var my_info = { name = "Nico", favorite_color = Color(255, 0, 255)}

func _player_disconnected(id):
	get_node("status").set_text("Player Disconnected :(")
	
func _player_connected(id):
	get_node("status").show()
	
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
	get_node("start").set_disabled(false)
	
	
	var name = get_node("name").get_text()
	gamestate.host_game(name)

func _on_start_pressed():
	gamestate.begin_game()
