
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var max_speed
var max_turn_rate
var mass
var max_force
var velocity


func seek(target, object):
	var desired_vec = target.get_global_pos() - object.get_global_pos()
	desired_vec = desired_vec.normalized() * max_speed
	return(desired_vec - object.get_linear_velocity())


func _init(mass, max_speed, max_force, max_turn_rate):
	self.mass = mass
	self.max_speed = max_speed
	self.max_force = max_force
	self.max_turn_rate = max_turn_rate
	self.velocity = velocity