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

var speed_multiplier = 1

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
	pass

func _process(delta):
	power_label.set_text(str(power_level.get_value()))
	
	#todo: incorporate player's commands
	if(target != null):
		#print("seek")
		SteeringForce += Steering.seek(target, self)
		Vehicle.update(delta, SteeringForce)
		#set_linear_velocity(Vehicle.velocity)
		look_at(get_global_pos() - get_travel().normalized())
		#print (Vehicle.velocity)
		move(Vehicle.velocity*0.5)
		
		#var targetpos = target.get_pos()
		#var x_over_y  = targetpos.x / targetpos.y
		#global_translate(Vector2(x_over_y * 5, (1 - x_over_y) *5))
	elif(not nearby_enemies.empty()):
		print("no target")
		target = nearby_enemies.pop_front()
	else:
		move(Vector2(movement_offset,0))
		#print("no enemies")
	
func fight(body):
	power_level.set_value(power_level.get_value()-1)
	
func add_enemy(body):
	for group in self.get_groups():
		if not group in body.get_groups():
			print("Enemy detected")
			nearby_enemies.append(body)