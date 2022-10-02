extends Control

export var interviewPath = ""

var interview  # holds all the JSON

var phraseNum = 0
var failed = false

# child resources
onready var DetectiveView = get_node("Detective")
onready var SuspectView = get_node("Suspect")
onready var BothView = get_node("Both")

# currently shown view
var currentView = null



func _ready():
	interview = getInterview()
	assert(interview, "Interview not found.")
	nextPhrase()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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

func nextPhrase() -> void:
	if phraseNum >= len(interview): # len(dialog) is the num of JSOn dialog elements.
		pass
		# TODO: what happens if we even get to this state???
	
	# get state
	var token = interview[phraseNum];
	
	var state = token["Type"]
	
	match state:
		"Begin":
			pass
		"Restart":
			pass
		"Dialog":
			pass
		"Log": 
			pass
		"Choice": 
			pass
		"FailDialog":
			pass
	
	
