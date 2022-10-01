extends Control

# The intention of this dialog box is for it to be created as needed; it should
# not be preloaded, and instead be ready for loading at any given time.
# TODO: Maybe create a function to preload a dialog box.

# settings
export var dialogPath = ""
export(float) var textSpeed = 0.05

var dialog

var phraseNum = 0
var finished = false

# child resources
onready var Name = get_node("Border/Name")
onready var Dialog = get_node("TextBackground/Dialog")

func _ready():
	$Timer.wait_time = textSpeed
	dialog = getDialog()
	assert(dialog, "Dialog not found.")
	nextPhrase()

#func start(dialog_path):
#	dialogPath = dialog_path
#	dialog = getDialog()
#	assert(dialog, "Dialog not found.")
#	nextPhrase()

# input
func _process(_delta):
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			nextPhrase()
		else:
			Dialog.visible_characters = len(Dialog.text)  # skip to the end of dialog.

func getDialog() -> Array:
	var f = File.new()
	assert(f.file_exists(dialogPath), "Dialog file path does not exist.")
	
	f.open(dialogPath, File.READ)
	var json = f.get_as_text()
	
	var output = parse_json(json)
	
	if typeof(output) == TYPE_ARRAY: # ?
		return output
	else:
		return [] # empty.

func nextPhrase() -> void:
	if phraseNum >= len(dialog): # len(dialog) is the num of JSOn dialog elements.
		queue_free() # delete this dialog box
		return
	
	finished = false  # phrase now running.
	
	Name.text = dialog[phraseNum]["Name"]
	Dialog.bbcode_text = dialog[phraseNum]["Text"]
	
	Dialog.visible_characters = 0
	
	# Update Portrait
	var f = File.new()
	var img = "res://assets/art/portraits/" + dialog[phraseNum]["Name"] + dialog[phraseNum]["Image"] + ".png"
	if f.file_exists(img):
		$Picture.texture = load(img)
	else: 
		$Picture.texture = load("res://assets/art/portraits/Invalid.png")
		
	# TODO: update tick sound.
	var tick = "res://assets/sfx/dialog/" + dialog[phraseNum]["Name"] + ".wav"
	if f.file_exists(img):
		$DialogTick.stream = load(tick)
	else: 
		$DialogTick.stream = null
	
	
	while Dialog.visible_characters < len(Dialog.text):
		Dialog.visible_characters += 1
		$DialogTick.play()
		
		$Timer.start()
		yield($Timer, "timeout")
	
	finished = true
	phraseNum += 1
	return
	
	
