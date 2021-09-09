extends KinematicBody

onready var head = $Head
onready var ground_check = $GroundCheck

export(float) var gravity = 27.5
export(float) var jump_height = 3
export(float) var double_jump_height = 3

var horizontal_acceletation = 0
export(float) var normal_acceleration = 10
export(float) var air_acceleration = 1.5

var speed = 0
export(float) var walk_speed = 11
export(float) var sprint_speed = 15
export(float) var crouch_speed = 7

var resistance = 1
export(float) var air_resistance = 2.3

var gravity_vec = Vector3()
var direction = Vector3()
var horizontal_velocity = Vector3()
var movement = Vector3()

var is_moving = false
var is_walking = false
var is_sprinting = false
var is_crouching = false
var is_grounded = false
var full_contact = false

func _physics_process(delta):
	direction = Vector3()
	
	is_moving = false
	is_walking = false
	is_sprinting = false
	is_crouching = false
	is_grounded = false
	full_contact = false
	
	if ground_check.is_colliding():
		full_contact = true
	
	if !is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
		
		horizontal_acceletation = air_acceleration
		resistance = lerp(resistance, air_resistance, .075)
	
	elif is_on_floor() and full_contact:
		gravity_vec = -get_floor_normal() * gravity
		
		horizontal_acceletation = normal_acceleration
		resistance = lerp(resistance, 1, .075)
	
	else:
		gravity_vec = -get_floor_normal()
		
		horizontal_acceletation = normal_acceleration
		resistance = lerp(resistance, 1, .075)
	
	if is_on_floor() or full_contact:
		is_grounded = true
	
	if Input.is_action_just_pressed("jump") and is_grounded:
		jump(jump_height)
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z

	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	direction = direction.normalized()
	
	if direction != Vector3():
		is_moving = true
		
		if Input.is_action_pressed("sprint"):
			is_sprinting = true
			speed = lerp(speed, sprint_speed, .075)
		
		elif Input.is_action_pressed("crouch"):
			is_crouching = true
			speed = lerp(speed, crouch_speed, .075)
		
		else:
			is_walking = true
			speed = lerp(speed, walk_speed, .075)
	
	var calc_speed = speed / resistance
	horizontal_velocity = horizontal_velocity.linear_interpolate(direction * calc_speed, horizontal_acceletation * delta)
	
	movement.z = horizontal_velocity.z + gravity_vec.z
	movement.x = horizontal_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	# warning-ignore:return_value_discarded
	move_and_slide(movement, Vector3.UP)

func jump(height: float):
	var jump_force = sqrt(height * -2 * -gravity)
	gravity_vec = Vector3.UP * jump_force
