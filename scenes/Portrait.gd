extends Area2D

signal start_interrogation

export var character = ""

func _ready():
	connect("body_entered", self, "start_interrogation")

func start_interrogation(body):
	if body.get_name() == "Player":
		emit_signal("start_interrogation", character)
