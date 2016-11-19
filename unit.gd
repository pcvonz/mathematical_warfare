extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var Steering = load("res://scripts/Steering.gd")
var Vehicle = load("res://scripts/Vehicle.gd")

var detect_range
var nearby_enemies
var target

var SteeringForce = Vector2(0,0)
export var max_speed = 1.0
export var mass = 50.0 
export var max_force = 1.0
export var max_turn_rate = 1.0

var speed_multiplier = 1

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_fixed_process(true)
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	
	detect_range = get_node("detect")
	detect_range.connect("body_enter", self, "add_enemy")
	nearby_enemies = Array()
	target = null
	pass

func _process(delta):
	get_node("level_label").set_text(str(get_node("level_label/level").get_value()))
	
	#todo: incorporate player's commands
	if(target != null):
		SteeringForce += Steering.seek(target, self)
		Vehicle.update(delta, SteeringForce, speed_multiplier)
		set_linear_velocity(Vehicle.velocity)
		#var targetpos = target.get_pos()
		#var x_over_y  = targetpos.x / targetpos.y
		#global_translate(Vector2(x_over_y * 5, (1 - x_over_y) *5))
	elif(not nearby_enemies.empty()):
		target = nearby_enemies.pop_front()
	else:
		global_translate(Vector2(5,0))
	
func add_enemy(body):
	nearby_enemies.append(body)