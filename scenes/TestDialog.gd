extends Node2D

# global music controller
onready var Music = get_node("/root/Music")

# Declare member variables here. Examples:
var enabled = false

# preload the thing we want instances of
var dialogBox = preload("res://scenes/DialogBox.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	Music.change_song("Jazz")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("ui_left") and not enabled:
		enabled = true
		var dialogInst = dialogBox.instance()
		dialogInst.dialogPath = "res://dialog/dialogTest.json"
		$CanvasLayer.add_child(dialogInst)
		enabled = false
	if Input.is_action_just_pressed("ui_right") and not enabled:
		enabled = true
		var dialogInst = dialogBox.instance()
		dialogInst.dialogPath = "res://dialog/dialogTest2.json"
		$CanvasLayer.add_child(dialogInst)
		enabled = false
	if Input.is_action_just_pressed("ui_up") and not enabled:
		enabled = true
		var dialogInst = dialogBox.instance()
		dialogInst.dialogPath = "res://dialog/dialogTest3.json"
		$CanvasLayer.add_child(dialogInst)
		enabled = false
