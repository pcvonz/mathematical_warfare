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
export var follows_waypoints = 0

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
	nearby_enemies = {}
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
	detect.connect("body_exit", self, "remove_enemy")
	fight_range.connect("body_enter", self, "fight")
	target = null


func _process(delta):
	if((follows_waypoints % 4) == 0):
		get_node("Sprite").set_modulate(Color(1, 1, 1))
	else:
		get_node("Sprite").set_modulate(Color(.7, .7, .7))
		
	power_label.set_text(str(int(power_level.get_value())))
	force = abs((get_travel().x + get_travel().y) * power_level.get_value())/20
	
	#damage tick
	if target != null:
		var ref = weakref(target)
		if ref.get_ref() and get_global_pos().distance_to(ref.get_ref().get_global_pos()) < 10:
			print("Engaging")
			fight(target)
			
	#todo: incorporate player's commands
	if get_tree().is_network_server():
		if not nearby_enemies.empty():
			#print("ENEMY")
			target = nearby_enemies[nearby_enemies.keys()[0]]
			var targetref = weakref(target)
			for i in nearby_enemies.keys():
				var i_ref = weakref(nearby_enemies[i])
				if (i != null and target != null) and (i_ref.get_ref() and targetref.get_ref()):
					if get_global_pos().distance_to(nearby_enemies[i].get_global_pos()) < get_global_pos().distance_to(nearby_enemies[target.get_name()].get_global_pos()):
						target = nearby_enemies[i]
						targetref = weakref(target)
				
			
			if(target != null and targetref.get_ref() and targetref.get_ref().get_type() == "KinematicBody2D"):
				SteeringForce = Steering.seek(targetref, selfref)
		elif(wp != null and not wp.is_hidden() and (follows_waypoints % 4) == 0):
			var targetref = weakref(wp)
			SteeringForce = Steering.seek_slow(targetref, selfref)
			if(get_global_pos().distance_to(wp.get_global_pos()) < 10):
				SteeringForce = Steering.seek_slow(selfref, selfref)
				wp.hide()
		else:
			SteeringForce = Steering.seek_slow(selfref, selfref)
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
	#print("Scaling: ", 1 + (level_change/50.0), ", ", 1 + (level_change/50.0))
	self.scale(Vector2(1 + (level_change/50.0), 1 + (level_change/50.0)))
	mass = new_level
	max_speed = max_speed / new_level

func remove_from_dict(name):
	if nearby_enemies.has(name):
		nearby_enemies.erase(name)

sync func kill_self():
	if(is_in_group("team_1")):
		for i in get_tree().get_nodes_in_group("team_2"):
			var i_ref = weakref(i)
			if(i != null and i_ref.get_ref()):
				if i.has_method("remove_from_dict"):
					i.remove_from_dict(get_name())
	else:
		for i in get_tree().get_nodes_in_group("team_1"):
			var i_ref = weakref(i)
			if(i != null and i_ref.get_ref() ):
				if i.has_method("remove_from_dict"):
					i.remove_from_dict(get_name())
	queue_free()


func add_enemy(body):
	if(is_in_group("team_1")):
		if body.is_in_group("team_2"):
			nearby_enemies[body.get_name()] = body
	else:
		if body.is_in_group("team_1"):
			nearby_enemies[body.get_name()] = body

func remove_enemy(body):
	if(is_in_group("team_1")):
		if body.is_in_group("team_2"):
			nearby_enemies.erase(body.get_name())
	else:
		if body.is_in_group("team_1"):
			nearby_enemies.erase(body.get_name())

func fight(body):
	if(is_in_group("team_1")):
		if body.is_in_group("team_2"):
			if body.get_travel() < get_travel():
				target = null
				print("Damage: ", (2+body.force))
				body.rpc("increase_level", -(2+body.force))
				get_node("Particles2D").set_emitting(true)
	else:
		if body.is_in_group("team_1"):
			if body.get_travel() < get_travel():
				target = null
				print("Damage: ", (2+body.force))
				body.rpc("increase_level", -(2+body.force))
				get_node("Particles2D").set_emitting(true)
				
				
remote func on_click():
	follows_waypoints += 1
	