extends Area2D

signal clue_obtained

export var clue_name = ""

func _ready():
	connect("body_entered", self, "obtain_clue")

func obtain_clue(body):
	if body.get_name() == "Player":
		emit_signal("clue_obtained", clue_name)
		queue_free()
