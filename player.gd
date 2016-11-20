extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var name = ""
var test
var team
var enemy_team
var path
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)

func set_variables(team, enemy_team, path):
	self.team = team
	self.enemy_team = enemy_team
	self.path = path

func set_player_name(new_name):
	name = new_name
	get_node("name").set_text(name)

func call(pos):
	if(get_tree().is_network_server()):
		get_node(path).set_global_pos(pos)
		for i in get_tree().get_nodes_in_group(team):
			i.wp = get_node(path)
	else:
		rpc("set_wp", pos, team, path)

remote func set_wp(pos, team, path):
	get_node(path).set_global_pos(pos)
	print(get_tree().is_network_server())
	if(get_tree().is_network_server()):
		for i in get_tree().get_nodes_in_group(enemy_team):
			i.wp = get_node(path)
		

func _input(event):
	if event.is_action_released("go_to"):
		get_node(path).show()
		call(get_global_mouse_pos())
		