
extends RigidBody

# member variables here, example:
# var a=2
# var b="textvar"

var max_speed
var max_turn_rate
var mass
var max_force
var velocity


#func seek(targetref, objectref):
#	if(targetref.get_ref() and objectref.get_ref()):
#		var dist_to = objectref.get_ref().get_global_pos().distance_to(targetref.get_ref().get_global_pos())
#	
#		if dist_to > 0:
#			var speed = dist_to / 2.0
#			if speed > objectref.get_ref().max_speed:
#				speed = objectref.get_ref().max_speed
#			var desired_vec = targetref.get_ref().get_pos() * speed / dist_to
#			return(desired_vec - objectref.get_ref().get_travel())
#	return Vector2(0,0)
func seek(targetref, objectref):
	if(targetref.get_ref() and objectref.get_ref()):
		var t_ref = targetref.get_ref()
		var o_ref = objectref.get_ref()
		var target_vec = t_ref.get_global_pos()
		var curr_vec = o_ref.get_global_pos()
		var vec_to = target_vec - curr_vec
		var distance_to = vec_to.length()
		
		if distance_to > 2:
			
			var decel_tweak = 0.3
			var speed = distance_to / 15 * decel_tweak
			#Make sure speed doesn't exceed the max speed
			min(speed, max_speed)
			var desired_vec = vec_to * speed / distance_to
			return(desired_vec - o_ref.get_travel())
		return(-o_ref.get_travel())

func _init(mass, max_speed, max_force, max_turn_rate):
	self.mass = mass
	self.max_speed = max_speed
	self.max_force = max_force
	self.max_turn_rate = max_turn_rate
	self.velocity = velocity