extends Control

export var interviewPath = ""

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

var ready = false
var trigger = false



func _ready():
	interview = getInterview()
	assert(interview, "Interview not found.")
	initInterview()
	
	# init buttons
	for i in range(3):
		var optionButton = EvidenceSelect.get_node(str(i))
		optionButton.connect("pressed", self, "onOptionPressed")
	
	nextPhrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Input.is_action_just_pressed("ui_accept") and ready) or trigger:
		ready = false
		trigger = false
		nextPhrase()


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
	
	var f = File.new()
	var img = "res://assets/art/portraits/" + token["Suspect"] + token["Image"] + ".png"
	
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
	if token["Type"] == "Restart" and restarted:
		# put this dialog in the queue.
		token["Type"] = "Dialog"
	else:
		# skip this token
		phraseNum += 1


func nextPhrase():
	if phraseNum >= len(interview): # len(dialog) is the num of JSOn dialog elements.
		finished = true
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
			yield(get_tree().create_timer(2), "timeout")
			print("ready")
			ready = true
		"Choice": 
			phraseNum += 1
			# setup scene
			if currentView:
				currentView.visible = false
			currentView = get_node("Both")
			currentView.visible = true
			
			EvidenceSelect.visible = true
			
			var options = token["Options"]
			print(options[0]["Text"])
			
			for i in range(3):
				var optionButton = EvidenceSelect.get_node(str(i))
				optionButton.get_node("Label").text = options[i]["Text"]
				optionButton.visible = true
				
				optionButton.connect("pressed", self, "onOptionPressed")
			
			
			
		"FailDialog":
			phraseNum += 1
			
			if failed:
				dialog(token)
		_:
			phraseNum += 1


func onOptionPressed():
	print("clicked!")
	EvidenceSelect.get_node("0").visible = false
	EvidenceSelect.get_node("1").visible = false
	EvidenceSelect.get_node("2").visible = false
	EvidenceSelect.visible = false
	trigger = true




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
