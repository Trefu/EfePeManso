#player_final.gd
extends CharacterBody3D
class_name Player

@onready var state_machine: StateMachine = $StateMachine
@onready var head: Node3D = $Head
@onready var posture_controller: PostureController = $PostureController

@export_group("Movement variables")
var move_speed: float = 16.0
var move_acceleration: float = 70.0
var move_deceleration: float = 50.0
var input_direction: Vector2
var move_direction: Vector3
var desired_move_speed: float
var max_desired_move_speed: float = 24
var desired_move_speed_curve: Curve #accumulated speed
var hit_ground_cooldown: float = 0.1 #amount of time the character keep his accumulated speed before losing it (while being on ground)

var hit_ground_cooldown_ref: float

@export_group("Jump variables")
@export var jump_height: float = 2.0
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_fall: float = 0.35
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak
@export var jump_cooldown: float = 0.25

@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

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

	move_and_slide()

func apply_gravity(delta: float) -> void:
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jump_gravity * delta
	elif velocity.y < 0.0: velocity.y += fall_gravity * delta
