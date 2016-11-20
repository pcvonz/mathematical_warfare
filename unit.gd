extends KinematicBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var Steering = load("res://scripts/steering.gd")
var Vehicle = load("res://scripts/Vehicle.gd")

var detect
var detect_range
var nearby_enemies
var target
var power_level
var power_label

export var movement_offset = 1

var SteeringForce = Vector2(0,0)
export var max_speed = 1.0
export var mass = 50.0 
export var max_force = 1.0
export var max_turn_rate = 100.0
var way_point = false
var speed_multiplier = 1
var wp

slave var slave_pos = Vector2()
slave var slave_motion = Vector2()
slave var slave_rot = 0

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_fixed_process(true)
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	
	detect_range = get_node("detect")
	power_label  = get_node("level_label")
	power_level  = get_node("level_label/level")
	power_level.set_value(10.0)
	
	#detect_range = get_node("detect/detect_range")
	#add_collision_exception_with(detect_range)
	detect_range.connect("body_enter", self, "add_enemy")
	#get_node("collide").connect("area_exit", self, "fight")
	nearby_enemies = Array()
	target = null

func _process(delta):
	power_label.set_text(str(power_level.get_value()))
	#todo: incorporate player's commands
	if get_tree().is_network_server():
		if(wp != null):
			SteeringForce += Steering.seek(wp, self)
		if(target != null):
			SteeringForce += Steering.seek(target, self)

		elif(not nearby_enemies.empty()):
			print("no target")
			target = nearby_enemies.pop_front()
		else:
			pass
		Vehicle.update(delta, SteeringForce)
		#set_linear_velocity(Vehicle.velocity)
		look_at(get_global_pos() - get_travel().normalized())

		move(Vehicle.velocity*0.5)
		rset("slave_motion", Vehicle.velocity*.5)
		rset("slave_pos", get_pos())
		rset("slave_rot", get_rot())
	else:
		set_pos(slave_pos)
		set_rot(slave_rot)
		
	
func fight(body):
	power_level.set_value(power_level.get_value()-1)
	
func add_enemy(body):
	print("Hmm")
	for group in self.get_groups():
		if not group in body.get_groups():
			print("Enemy detected")
			nearby_enemies.append(body)