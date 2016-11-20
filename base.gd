extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var enemy_team
var health = 20

func setup(enemy_team):
	self.enemy_team = enemy_team

func _ready():
	get_node("Area2D").connect("body_enter", self, "damage_base")
	get_node("Label").set_text(str(health))
	
func damage_base(body):
	if(body.is_in_group(enemy_team)):
		if health > 0:
			body.rpc("kill_self")
			rpc("do_damage")
		else:
			print("game_over")
	
#Right now this does damage for each client connected (two clients = 1 damage)
sync func do_damage():
	health -= 1
	get_node("Label").set_text(str(health))
	
	
	