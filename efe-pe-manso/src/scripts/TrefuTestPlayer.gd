extends CharacterBody3D

@export var currentSpeed = 5.0
const crouchingSpeed = 3.0

const jumpVelocity = 4.5

const aim_sensitivity = 0.4

func _ready():
	#para que el mouse empiece 'oculto'
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * aim_sensitivity))
		%head.rotate_x(deg_to_rad(-event.relative.y * aim_sensitivity))
		%head.rotation.x = clamp(%head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "foward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * currentSpeed
		velocity.z = direction.z * currentSpeed
	else:
		velocity.x = move_toward(velocity.x, 0, currentSpeed)
		velocity.z = move_toward(velocity.z, 0, currentSpeed)

	move_and_slide()
