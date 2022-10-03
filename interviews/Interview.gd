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

# spawnable
var dialogBox = preload("res://scenes/DialogBox.tscn")

# currently shown view
var currentView = null

var ready = false



func _ready():
	interview = getInterview()
	assert(interview, "Interview not found.")
	initInterview()
	nextPhrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and ready:
		ready = false
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
			yield(get_tree().create_timer(5), "timeout")
			print("ready")
			ready = true
		"FailDialog":
			phraseNum += 1
			
			if failed:
				dialog(token)
		_:
			phraseNum += 1
	
func dialog(token):
	# setup scene
	if currentView:
		currentView.visible = false
	
	currentView = get_node(token["View"])
	currentView.visible = true
	
	# dialog box
	var dialogInst = dialogBox.instance()
	dialogInst.oneshotSpeaker = token["Name"]
	dialogInst.oneshotString = token["Text"]
	dialogInst.oneshotImage = token["Image"]
	
	$CanvasLayer.add_child(dialogInst)
	
	yield(dialogInst, "phraseFinished")
	print("ready")
	ready = true
