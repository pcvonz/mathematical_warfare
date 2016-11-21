extends Control

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var num_1
var num_2

func _ready():
	random_problem()
	set_process_input(true)
	get_node("LineEdit").connect("mouse_enter", self, "mouse_enter")
	get_node("LineEdit").connect("mouse_exit", self, "mouse_exit")
	
func mouse_enter():
	get_node("LineEdit").set_editable(true)
	get_node("LineEdit").grab_focus()
	print("hello")

func mouse_exit():
	print("hello")
	get_node("LineEdit").set_editable(false)

func random_problem():
	var symbol
	randomize()
	num_1 = round(rand_range(0, 50))
	randomize()
	num_2 = round(rand_range(-50, 50))
	if(num_2 < 0):
		symbol = ""
	else:
		symbol = " + "
	var string = str(num_1) + symbol + str(num_2) + "="
	get_node("Label").set_text(string)

func _input(event):
	if(event.is_action_pressed("ui_accept")):
		var answer = get_node("LineEdit").get_text()
		get_node("LineEdit").set_text("")
#		if (int(answer) == (num_1 + num_2)):
		random_problem()
		rpc("add_unit", get_parent().team)

sync func add_unit(team):
	var unit
	if(team == "team_1"):
		unit = load("team_1_unit.tscn").instance()
		unit.set_global_pos(get_node("../../../spawn_points/0").get_global_pos())
	else:
		unit = load("team_2_unit.tscn").instance()
		unit.set_global_pos(get_node("../../../spawn_points/1").get_global_pos())
	get_node("../../../").add_child(unit)
	unit.move_to(get_node("spawn_to").get_pos() + Vector2(20, 20))

func add_resource(body):
	body.add_child(self)
