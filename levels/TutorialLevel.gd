extends Node2D

onready var camera = $EventCamera
onready var Globals = get_node("/root/Global")
onready var Music = get_node("/root/Music")

var Interview = preload("res://interviews/Interview.tscn")

var interview_running = false

var passed = {
	"Bodyguard": false,
	"CampaignManager": false,
	"Wife": false
}

func _ready():
	Music.change_song("Jazz")
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
	
	$BodyguardPortrait.connect("start_interrogation", self, "start_interview")
	$CampaignManagerPortrait.connect("start_interrogation", self, "start_interview")
	$WifePortrait.connect("start_interrogation", self, "start_interview")
	
	
	
	

func activate_platform(clue):
	print(clue)
	var platform = get_node_or_null(clue)
	platform.enable()
	camera.move_camera($Player.position, platform.position)
	Globals.evidence[clue] = true
	print(Globals.evidence)

func reset_camera():
	$Player.activate_camera()
	
func start_interview(person):
	print(person, " is trying to start")
	print(passed[person])
	if passed[person] == true:
		print("but it already happened")
		return  # don't restart finished interviews
	
	match person:
		"Bodyguard":
			run_interview_obj("res://interviews/bodyguardInterview.json")
		"CampaignManager":
			run_interview_obj("res://interviews/campaignManagerInterview.json")
		"Wife":
			print("TODO: Add link to Wife Interview")
	# TODO: Lock the player.

func run_interview_obj(path):
	if not interview_running:
		interview_running = true
		var interviewInst = Interview.instance()
		interviewInst.interviewPath = path
		$CanvasLayer.add_child(interviewInst)
		
		interviewInst.connect("finished", self, "onInterviewFinished")
		
		yield(interviewInst, "finished")  # don't do anything til interview says its done.
		Music.change_song("Jazz")
		yield(get_tree().create_timer(5), "timeout") # debounce of sorts?
		interview_running = false

func onInterviewFinished(status, person):
	if status == true:
		match person:
			"Bodyguard":
				passed["Bodyguard"] = true
				$SuitcaseDiscrepencyClue.enable()
			"Manager": 
				passed["CampaignManager"] = true
				$AssassinPlotClue.enable()
			"Wife": 
				passed["Wife"] = true
	check_completion()

func check_completion():
	if passed["Bodyguard"] == true and passed["CampaignManager"] == true and passed["Wife"] == true:
		finish_game()

func finish_game():
	pass
