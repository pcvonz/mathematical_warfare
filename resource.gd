extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	get_node("Area2D").connect("body_enter", self, "add_resource")

func add_resource(body):
	body.add_child(self)
