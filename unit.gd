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
var fight_range
var boredom

export var movement_offset = 1

var SteeringForce = Vector2(0,0)
var force #for calculating damage
export var max_speed = 5.0
export var mass = 10.0
export var max_force = 1.0
export var max_turn_rate = 100.0
var way_point = false
var speed_multiplier = 1
var wp

slave var slave_pos = Vector2()
slave var slave_motion = Vector2()
slave var slave_rot = 0
slave var slave_power_level = 30
var selfref   = weakref(self)
var spawn_target = null
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process(true)
	set_fixed_process(true)
	Vehicle = Vehicle.new(mass, max_speed, max_force, max_turn_rate)
	Steering = Steering.new(mass, max_speed, max_force, max_turn_rate)
	nearby_enemies = Array()
	target = null
	force = 0
	boredom = 0
	
	detect       = get_node("detect")
	fight_range  = get_node("fight")
	power_label  = get_node("level_label")
	power_level  = get_node("level_label/level")
	power_level.set_value(30.0) #default
	increase_level(0) #scale without modifying level
	
	#detect_range = get_node("detect/detect_range")
	#add_collision_exception_with(detect_range)
	detect.connect("body_enter", self, "add_enemy")
	fight_range.connect("body_enter", self, "fight")
	#get_node("collide").connect("area_exit", self, "fight")
	nearby_enemies = Array()
	target = null
#	for i in get_tree().get_nodes_in_group("team_1"):
#		add_collision_exception_with(i)
#	for i in get_tree().get_nodes_in_group("team_2"):
#		add_collision_exception_with(i)


func _process(delta):
	power_label.set_text(str(int(power_level.get_value())))
	#todo: incorporate player's commands
	if get_tree().is_network_server():
		if(target != null):
			var targetref = weakref(target)
			if(targetref.get_ref()):
				SteeringForce = Steering.seek(targetref, selfref)
	            #set_linear_velocity(Vehicle.velocity)
	            #print (Vehicle.velocity)
	#			move(Vehicle.velocity)
				force = abs(Vehicle.velocity.x)/10 * mass
	#			boredom += 1
	#			if(boredom == 300):
	#				print("tick")
	#				boredom = 0
	#				nearby_enemies.push_back(target)
	#				target = nearby_enemies.pop_front()
		elif(not nearby_enemies.empty()):
			target = nearby_enemies.pop_front()
		elif(wp != null and not wp.is_hidden()):
			var targetref = weakref(wp)
			SteeringForce = Steering.seek(targetref, selfref)
			if(get_global_pos().distance_to(wp.get_global_pos()) < 10):
				SteeringForce = Steering.seek(selfref, selfref)
				wp.hide()
		else:
			SteeringForce = Steering.seek(selfref, selfref)
		Vehicle.update(delta, SteeringForce)
		look_at(get_global_pos() - get_travel().normalized())
		move(Vehicle.velocity)
		rset("slave_motion", Vehicle.velocity)
		rset("slave_pos", get_pos())
		rset("slave_rot", get_rot())
		rset("slave_power_level", power_level.get_value())
	else:
		power_level.set_value(slave_power_level)
		set_pos(slave_pos)
		set_rot(slave_rot)


sync func increase_level(level_change):
	var current_level = power_level.get_value()
	var new_level = current_level + level_change
	
	if(new_level < 2):
		rpc("kill_self")
		
	
	power_level.set_value(new_level)
	self.scale(Vector2(1 + (level_change/50), 1 + (level_change/50)))
	mass = new_level
	max_speed = max_speed / new_level
	
sync func kill_self():
	queue_free()

func add_enemy(body):
	if(is_in_group("team_1")):
		if body.is_in_group("team_2"):
			nearby_enemies.append(body)
	else:
		if body.is_in_group("team_1"):
			nearby_enemies.append(body)
			

func fight(body):
	if(is_in_group("team_1")):
		if body.is_in_group("team_2"):
			if body.get_travel() < get_travel():
				body.rpc("increase_level", -(2+body.force))
	else:
		if body.is_in_group("team_1"):
			if body.get_travel() < get_travel():
				body.rpc("increase_level", -(2+body.force))