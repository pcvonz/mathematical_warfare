extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var name = ""

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)

func set_player_name(new_name):
	name = new_name
	get_node("name").set_text(name)

sync func add_thing(pos):
	var test = load("res://test.tscn").instance()
	get_node("../").add_child(test)
	test.set_global_pos(pos)
		
func _input(event):
	if event.is_action_pressed("go_to"):
		add_thing(get_global_mouse_pos())
		rpc("add_thing", get_global_mouse_pos())
		