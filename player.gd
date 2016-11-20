extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var name = ""
var test
var team
var enemy_team
var path
var cam
var cam_speed = 20
var move
func _ready():
	set_process_input(true)
	set_process(true)
	cam = get_node("Camera2D")
	move = get_global_pos()
	if(int(get_name()) == get_tree().get_network_unique_id()):
		cam.make_current()
	
func _process(delta):
	
	if(Input.is_action_pressed("camera_right")):
		move += Vector2(cam_speed, 0)
	if(Input.is_action_pressed("camera_left")):
		move += Vector2(-cam_speed, 0)
	if(Input.is_action_pressed("camera_up")):
		move += Vector2(0, -cam_speed)
	if(Input.is_action_pressed("camera_down")):
		move += Vector2(0, cam_speed)
	cam.set_global_pos(move)
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
	get_node(path).show()
	print(get_tree().is_network_server())
	get_node(path).show()
	if(get_tree().is_network_server()):
		for i in get_tree().get_nodes_in_group(enemy_team):
			i.wp = get_node(path)
		

func _input(event):
	if event.is_action_released("go_to"):
#		if(get_global_mouse_pos().y < 750):
		get_node(path).set_global_pos(get_global_mouse_pos())
		get_node(path).show()
		call(get_global_mouse_pos())
		