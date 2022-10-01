extends KinematicBody2D

#movement stuffs
export var ACCELERATION = 20
export var FRICTION = 20
export var MOVE_SPEED = 200
export var GRAVITY = 500
export var GRAV_ACCELERATION = 20
export var JUMP_FORCE = 500
#the direction of movement from player input
var input_dir = 0
#the actual velocity of the player
var velocity = Vector2(0, GRAVITY)

func _physics_process(delta):
	#Gets the input direction for the players movement
	input_dir = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	
	move(delta)

#calculates each individual force applied to the player, then adds them together
#for a new velocity value, then calls the move function.
func move(delta):
	var jump_value = 0
	if Input.is_action_just_pressed("jump") and is_on_floor():
		jump_value = JUMP_FORCE * -1
	
	#the direction and speed of horizontal movement
	var movement_value = move_toward(velocity.x, input_dir * MOVE_SPEED, ACCELERATION)
	#The force of gravity
	var gravity_value = move_toward(velocity.y, GRAVITY, GRAV_ACCELERATION)
	#Force from grapple hook
	var grapple_value = Vector2.ZERO
	
	#make new velocity and add all forces together
	var new_velocity = grapple_value
	new_velocity.x = new_velocity.x + movement_value
	new_velocity.y = new_velocity.y + gravity_value
	new_velocity.y = new_velocity.y + jump_value
	#actually moves the player
	velocity = move_and_slide(new_velocity, Vector2.UP)
