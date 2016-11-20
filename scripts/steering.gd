
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var max_speed
var max_turn_rate
var mass
var max_force
var velocity


func seek(targetref, objectref):
	if(targetref.get_ref() and objectref.get_ref()):
		var desired_vec = targetref.get_ref().get_global_pos() - objectref.get_ref().get_global_pos()
		desired_vec = desired_vec.normalized() * max_speed
		#return(desired_vec - object.get_linear_velocity())
		return(desired_vec - objectref.get_ref().get_travel())
	return Vector2(1,1)


func _init(mass, max_speed, max_force, max_turn_rate):
	self.mass = mass
	self.max_speed = max_speed
	self.max_force = max_force
	self.max_turn_rate = max_turn_rate
	self.velocity = velocity