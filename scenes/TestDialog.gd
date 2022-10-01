extends Node2D


# Declare member variables here. Examples:
var enabled = false

# preload the thing we want instances of
var dialogBox = preload("res://scenes/DialogBox.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_left") and not enabled:
		enabled = true
		var dialogInst = dialogBox.instance()
		dialogInst.dialogPath = "res://dialog/dialogTest.json"
		$CanvasLayer.add_child(dialogInst)
