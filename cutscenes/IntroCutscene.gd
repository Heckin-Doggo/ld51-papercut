extends Control

# music singleton
onready var Music = get_node("/root/Music")

# preload the thing we want instances of
var dialogBox = preload("res://scenes/DialogBox.tscn")

# get child resources
onready var Slide = get_node("Slide")

# Called when the node enters the scene tree for the first time.
func _ready():
	Music.change_song("Slow")
	play_cutscene()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func play_cutscene():
#	# TODO: Make skipable instead of timer.
#	yield(get_tree().create_timer(1), "timeout")
#	$Detective.visible = true
#	yield(get_tree().create_timer(0.5), "timeout")
#
#	var dialog = dialogBox.instance()
#	dialog.dialogPath = "res://dialog/introCutscene1.json"
#	$CanvasLayer.add_child(dialog)
#
#	yield(dialog, "finished")
#
#	yield(get_tree().create_timer(0.5), "timeout")
#	$Paper.visible = true
#	yield(get_tree().create_timer(0.5), "timeout")
#
#	dialog = dialogBox.instance()
#	dialog.dialogPath = "res://dialog/introCutscene2.json"
#	$CanvasLayer.add_child(dialog)
#
#	yield(dialog, "finished")
#
#	$Detective.visible = false

func play_cutscene():
	var dialog
	
	Slide.texture = load("res://assets/art/cutscene/Start1.jpg")
	dialog = dialogBox.instance()
	dialog.dialogPath = "res://dialog/introCutscene1.json"
	$CanvasLayer.add_child(dialog)
	yield(dialog, "finished")
	
	Slide.texture = load("res://assets/art/cutscene/Start2.jpg")
	dialog = dialogBox.instance()
	dialog.dialogPath = "res://dialog/introCutscene2.json"
	$CanvasLayer.add_child(dialog)
	yield(dialog, "finished")
	
	Slide.texture = load("res://assets/art/cutscene/Start3.jpg")
	dialog = dialogBox.instance()
	dialog.dialogPath = "res://dialog/introCutscene3.json"
	$CanvasLayer.add_child(dialog)
	yield(dialog, "finished")
	
	Slide.texture = load("res://assets/art/cutscene/Start4.jpg")
	dialog = dialogBox.instance()
	dialog.dialogPath = "res://dialog/introCutscene4.json"
	$CanvasLayer.add_child(dialog)
	yield(dialog, "finished")
	
	Slide.texture = load("res://assets/art/cutscene/Start5.jpg")
	dialog = dialogBox.instance()
	dialog.dialogPath = "res://dialog/introCutscene5.json"
	$CanvasLayer.add_child(dialog)
	yield(dialog, "finished")
	
	get_tree().change_scene("res://levels/TutorialLevel.tscn")
	


