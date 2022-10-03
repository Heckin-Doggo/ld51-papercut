extends Node2D

onready var camera = $EventCamera
onready var Globals = get_node("/root/Global")

func _ready():
	$ReporterTestimonyClue.connect("clue_obtained", self, "activate_platform")
	$ProtesterTestimonyClue.connect("clue_obtained", self, "activate_platform")
	$MayorTimeLineClue.connect("clue_obtained", self, "activate_platform")
	$EventPhotoClue.connect("clue_obtained", self, "activate_platform")
	$CarCompartmentClue.connect("clue_obtained", self, "activate_platform")
	$BulletClue.connect("clue_obtained", self, "activate_platform")
	$PodiumChangeClue.connect("clue_obtained", self, "activate_platform")
	$ReporterPhotoClue.connect("clue_obtained", self, "activate_platform")
	$CallLogClue.connect("clue_obtained", self, "activate_platform")
	$RefreshmentTableClue.connect("clue_obtained", self, "activate_platform")
	$SniperTestimonyClue.connect("clue_obtained", self, "activate_platform")
	$SuitcaseDiscrepencyClue.connect("clue_obtained", self, "activate_platform")
	$AssassinPlotClue.connect("clue_obtained", self, "activate_platform")
	camera.connect("tween_finished", self, "reset_camera")

func activate_platform(clue):
	print(clue)
	var platform = get_node_or_null(clue)
	platform.enable()
	camera.move_camera($Player.position, platform.position)
	Globals.evidence[clue] = true
	print(Globals.evidence)

func reset_camera():
	$Player.activate_camera()
