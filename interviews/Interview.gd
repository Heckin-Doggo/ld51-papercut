extends Control

export var interviewPath = ""

onready var Music = get_node("/root/Music")
onready var Global = get_node("/root/Global")

var interview  # holds all the JSON

var phraseNum = 0
var failed = false
var restarted = false
var finished = false

# child resources
onready var DetectiveView = get_node("Detective")
onready var SuspectView = get_node("Suspect")
onready var BothView = get_node("Both")
onready var EvidenceSelect = get_node("CanvasLayer/EvidenceSelect")

# spawnable
var dialogBox = preload("res://scenes/DialogBox.tscn")

# currently shown view
var currentView = null

# for _ready function hijacking
var ready = false
var trigger = false

# correct button options
var correctOption = -1
var actual_options = []
var selectedOption = -1

# wackass temp jery rigging
var subdialog = []
var subdialogNum = 0

signal finished



func _ready():
	Music.change_song("Tense")
	interview = getInterview()
	assert(interview, "Interview not found.")
	initInterview()
	
	# init buttons
	for i in range(3):
		var optionButton = EvidenceSelect.get_node(str(i))
		optionButton.connect("pressed", self, "onOption"+str(i)+"Pressed")
	
	nextPhrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept") and ready) or trigger:
		ready = false
		trigger = false
		if !subdialog:
			nextPhrase()
		else:
			# run dialog
			dialog(subdialog[subdialogNum]);
			
			subdialogNum += 1
			# if last, remove
			if (subdialogNum >= len(subdialog)):
				subdialog = []  # remove subdialog
				interview[phraseNum]["Type"] = "Choice"
			
			


func getInterview() -> Array:
	var f = File.new()
	assert(f.file_exists(interviewPath), "Interview file path does not exist.")
	
	f.open(interviewPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY: # ?
		return output
	else:
		return [] # empty.


func initInterview():
	print("Begin")
	var token = interview[phraseNum];
	
	var suspect = token["Suspect"]
	
	var f = File.new()
	var img = "res://assets/art/portraits/" + suspect + token["Image"] + ".png"
	
	# load image
	if f.file_exists(img):
		SuspectView.get_node("PictureBorder/Portrait").texture = load(img)
		BothView.get_node("PictureBorder/Portrait").texture = load(img)
	else: 
		SuspectView.get_node("PictureBorder/Portrait").texture = load("res://assets/art/portraits/Invalid.png")
		BothView.get_node("PictureBorder/Portrait").texture = load("res://assets/art/portraits/Invalid.png")
	
	# update name
	SuspectView.get_node("PictureBorder/Label").text = token["Suspect"]
	BothView.get_node("PictureBorder/Label").text = token["Suspect"]
	
	phraseNum += 1
	
	token = interview[phraseNum]
	# if we seen this guy before
	if token["Type"] == "Restart" and Global.seenSuspects[suspect]:
		# put this dialog in the queue.
		token["Type"] = "Dialog"
	else:
		# skip this token, but note that we saw him
		Global.seenSuspects[suspect] = true
		phraseNum += 1


func finish():
	emit_signal("finished")
	queue_free()


func nextPhrase():
	if phraseNum >= len(interview): # len(dialog) is the num of JSOn dialog elements.
		finished = true
		print("DONE WITH DIALOG")
		finish()
		return false
	
	# get state
	var token = interview[phraseNum];
	
	var state = token["Type"]
	print(phraseNum, state)
	
	match state:
		"Restart":
			phraseNum += 1
			if restarted:
				dialog(token)
		"Dialog":
			phraseNum += 1
			dialog(token)
		"Log": 
			phraseNum += 1
			
			var log_token = {
				"Type": "Dialog",
				"View": "Detective",
				"Name": "Clue",
				"Image": "Default",
				"Text": token["Text"]
			}
			
			Global.evidence["Data"] = true
			
			dialog(log_token)
		"Choice": 
			# TODO: Do we want to advance yet? We need to re-reference.
#			phraseNum += 1
			
			var options = token["Options"]
			
			# clear class variables
			actual_options = []
			correctOption = -1
			selectedOption = -1
			
			for option in options:
				var require = option["Requires"]
				if Global.evidence[require]:  # if its in evidence list.
					actual_options.append(option)
			
			if len(actual_options) == 0:
				jumpToFail()
				return
			
			for i in range(len(actual_options)):
				var optionButton = EvidenceSelect.get_node(str(i))
				optionButton.get_node("Label").text = actual_options[i]["Text"]
				optionButton.visible = true
				
				if actual_options[i]["Correct"]:
					correctOption = i
				
				optionButton.connect("pressed", self, "onOptionPressed")
			
			# softlock prevention
			if correctOption == -1:
				print("Softlock prevented: no applicable evidence")
				jumpToFail()
				return
			
			token["Type"] = "SeenChoice" # repeat this for the next thing.
			
			# setup scene
			if currentView:
				currentView.visible = false
			currentView = get_node("Both")
			currentView.visible = true
			
			EvidenceSelect.visible = true
			
			
		"SeenChoice":
			if selectedOption == correctOption:
				selectedOption = -1
				correctOption = -1
				phraseNum += 1
				trigger = true
				return
			# else
			var choiceDialog = actual_options[selectedOption]["Dialog"]
			if typeof(choiceDialog) == TYPE_STRING and choiceDialog == "default":
				jumpToFail()
				return
			# else
			subdialog = actual_options[selectedOption]["Dialog"] 
			subdialogNum = 0
			trigger = true
			
			
			
		"FailDialog":
			phraseNum += 1
			
			if failed:
				dialog(token)
			else:
				print("DONE WITH DIALOG - GOOD ENDING!")
				finish() # SHOULD BE FINE IN GAME
		_:
			phraseNum += 1


func onOption0Pressed():
	print("0 clicked!")
	selectedOption = 0
	clearButtons()

func onOption1Pressed():
	print("1 clicked!")
	selectedOption = 1
	clearButtons()
	
func onOption2Pressed():
	print("2 clicked!")
	selectedOption = 2
	clearButtons()

func clearButtons():
	EvidenceSelect.get_node("0").visible = false
	EvidenceSelect.get_node("1").visible = false
	EvidenceSelect.get_node("2").visible = false
	EvidenceSelect.visible = false
	trigger = true


func jumpToFail():
	failed = true
	while (phraseNum < len(interview)):
		var token = interview[phraseNum]
		if token["Type"] == "FailDialog":
			print("Jumped to fail dialog.")
			trigger = true
			return
		phraseNum += 1
	print("No fail found.")


func dialog(token):
	# setup scene
	if currentView:
		currentView.visible = false
	
	currentView = get_node(token["View"])
	currentView.visible = true
	
	# give characters their sprite
	var characterName = token["Name"]
	if characterName == "Narrator":
		characterName = "Detective"
	
	if characterName == "Detective":
		var f = File.new()
		var img = "res://assets/art/interview/" + token["Name"] + token["Image"] + ".png"
		if f.file_exists(img):
			DetectiveView.get_node("Detective").texture = load(img)
			print("load success")
		else: 
			DetectiveView.get_node("Detective").texture = load("res://assets/art/portraits/Invalid.png")
			print("load fail")
	else:
		var f = File.new()
		var img = "res://assets/art/portraits/" + token["Name"] + token["Image"] + ".png"
		if f.file_exists(img):
			SuspectView.get_node("PictureBorder/Portrait").texture = load(img)
			BothView.get_node("PictureBorder/Portrait").texture = load(img)
		else: 
			SuspectView.get_node("PictureBorder/Portrait").texture = load("res://assets/art/portraits/Invalid.png")
			BothView.get_node("PictureBorder/Portrait").texture = load("res://assets/art/portraits/Invalid.png")
	

	# dialog box
	var dialogInst = dialogBox.instance()
	dialogInst.oneshotSpeaker = characterName
	dialogInst.oneshotString = token["Text"]
	dialogInst.oneshotImage = token["Image"]
	
	$CanvasLayer.add_child(dialogInst)
	
	yield(dialogInst, "phraseFinished")
	print("ready")
	ready = true
