extends Node2D

onready var camera = $EventCamera

func _ready():
	$CrumpledClue.connect("clue_obtained", self, "activate_platform")
	$CrumpledClue2.connect("clue_obtained", self, "activate_platform")
	$CrumpledClue3.connect("clue_obtained", self, "activate_platform")
	camera.connect("tween_finished", self, "reset_camera")

func activate_platform(clue):
	print(clue)
	var platform = get_node_or_null(clue)
	platform.enable()
	camera.move_camera($Player.position, platform.position)

func reset_camera():
	$Player.activate_camera()
