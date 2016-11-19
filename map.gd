extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var resource

func _ready():
	set_process(true)
	resource = preload("res://resource.tscn").instance()
	for i in range(30):
		