#player_final.gd
extends CharacterBody3D
class_name Player

@onready var state_machine: StateMachine = $StateMachine
@onready var head: Node3D = $Head
@onready var posture_controller: PostureController = $PostureController
@export var lerp_speed: float = 12.0
const DEFAULT_SPEED: float = 16.0
var current_speed := 0.0
var direction: Vector3 = Vector3.ZERO

const GRAVITY_MULTIPLIER := 3.0

func _ready() -> void:
	current_speed = DEFAULT_SPEED
	posture_controller.setup(self)
	pass

func _physics_process(delta: float) -> void:
	posture_controller.physics_update(delta)
	#esto va en un state
	if Input.is_action_just_pressed("jump"): 
		velocity.y = 11.0
	
	if !is_on_floor():
		velocity += get_gravity() * delta * GRAVITY_MULTIPLIER
	pass

func get_input_direction() -> Vector3:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if input_dir == Vector2.ZERO:
		return Vector3.ZERO

	return (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func apply_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	if input_dir.length() < 0.01:
		var decel := 50.0
		velocity = velocity.move_toward(Vector3(0, velocity.y, 0), decel * delta)
		return

	# Dirección en espacio global
	var move_dir := Vector3(input_dir.x, 0, input_dir.y).normalized()
	move_dir = transform.basis * move_dir
	move_dir.y = 0
	move_dir = move_dir.normalized()

	# Velocidad objetivo
	var target_velocity := move_dir * current_speed

	# Aceleración suave respetando la dirección
	var accel := 70.0
	# Conservamos velocity.y para gravedad / salto
	var current_velocity := Vector3(velocity.x, 0, velocity.z)
	current_velocity = current_velocity.move_toward(Vector3(target_velocity.x, 0, target_velocity.z), accel * delta)
	velocity.x = current_velocity.x
	velocity.z = current_velocity.z
