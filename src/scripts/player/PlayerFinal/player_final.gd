#player_final.gd
extends CharacterBody3D
class_name Player

@onready var state_machine: StateMachine = $StateMachine
@onready var head: Node3D = $Head
@onready var posture_controller: PostureController = $PostureController

@export_group("Movement variables")
@export var move_speed: float = 14.0
@export var move_acceleration: float = 60.0
@export var move_deceleration: float = 40.0
@export var input_direction: Vector2
@export var move_direction: Vector3
@export var max_desired_move_speed: float = 24
@export var desired_move_speed_curve: Curve #accumulated speed
@export var in_air_move_speed_curve: Curve
@export var hit_ground_cooldown: float = 0.1 #amount of time the character keep his accumulated speed before losing it (while being on ground)
var desired_move_speed: float

@export_group("Dash variables")
@export var dash_speed: float = 120.0
@export var dash_time: float = 0.11
@export var dashs_allowed: int = 3
@export var time_bef_can_dash_again: float = 0.8
@export var time_bef_reload_dash: float = 3.0
var velocity_pre_dash : Vector3
var has_dashed : bool = false
var dash_direction: Vector3 = Vector3.ZERO

@export_group("Jump variables")
@export var jump_height: float = 4.0
@export var jump_time_to_peak: float = 0.4
@export var jump_time_to_fall: float = 0.35
@export var jump_cooldown: float = 0.25
@export var jump_cooldown_ref: float
@export var jumps_in_air_allowed: int = 1
@export var jump_buff_on: bool = false
@export var buffered_jump: bool = false
@export var coyote_jump_cooldown: float = 0.3
@export var coyote_jump_on: bool = false
@export_range(0.1, 1.0, 0.05) var in_air_input_multiplier: float = 0.9
@onready var jump_velocity: float = (2.0 * jump_height) / jump_time_to_peak

@export_group("Slide variables")
var slide_direction: Vector3 = Vector3.ZERO
@export var use_desired_move_speed: bool = false
@export var slide_speed: float = 12.0
@export var slide_accel: float = 23.0
@export var slide_time: float = 1.2

@export var time_bef_can_slide_again: float = 1.5

@export_range(0.0, 90.0, 0.1) var max_slope_angle: float = 75.0 #max slope angle where the slide time operate
@export_range(0.0, 0.1, 0.001) var uphill_tolerance : float = 0.05 #vertical tolerance, to avoid fake uphills
@export var amount_velocity_lost_per_sec: float = 4.0
@export var slope_sliding_dms_incre: float = 2.0 #slope sliding desired move speed incrementer
@export var slope_sliding_ms_incre: float = 2.0 #slope sliding slide speed incrementer
@export var priority_over_crouch: bool = true #if enabled, give priority over crouch state (because crouch and slide actions are assigned at the same input action)
@export var continious_slide: bool = true
@export var slide_hitbox_height: float = 1.0
@export var slide_model_height: float = 0.5
var slide_buff_on: bool = false
var time_bef_can_slide_again_ref: float

@export_group("Gravity variables")
@onready var jump_gravity: float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak)
@onready var fall_gravity: float = (-2.0 * jump_height) / (jump_time_to_fall * jump_time_to_fall)

@export var bunny_hop_dms_incre: float = 3.0 #bunny hopping desired move speed incrementer
@export var auto_bunny_hop: bool = false
var last_frame_position: Vector3
var last_frame_velocity: Vector3
var was_on_floor: bool

@export var lose_vel_if_hit_wall_in_air : bool = false #vel = velocity
@export var lose_dms_if_hit_wall_in_air : bool = false #dms = desired move speed

#region refs
var hit_ground_cooldown_ref: float
var jumps_in_air_allowed_ref: int
var coyote_jump_cooldown_ref: float
var dash_time_ref: float
var dashs_allowed_ref: int
var time_bef_reload_dash_ref: float
var time_bef_can_dash_again_ref: float
var slide_time_ref: float
#endregion

@onready var ceiling_check: RayCast3D = %CeilingCheck
@onready var floor_check: RayCast3D = %FloorCheck
@onready var slide_floor_check: RayCast3D = %SlideFloorCheck

func _ready() -> void:
	posture_controller.setup(self)
	hit_ground_cooldown_ref = hit_ground_cooldown
	jump_cooldown_ref = jump_cooldown
	jump_cooldown = -1.0
	jumps_in_air_allowed_ref = jumps_in_air_allowed
	coyote_jump_cooldown_ref = coyote_jump_cooldown
	slide_time_ref = slide_time
	time_bef_can_slide_again_ref = time_bef_can_slide_again
	time_bef_can_slide_again = -1.0
	time_bef_can_dash_again_ref = time_bef_can_dash_again
	time_bef_can_dash_again = -1.0
	time_bef_reload_dash_ref = time_bef_reload_dash
	time_bef_reload_dash = -1.0
	dashs_allowed_ref = dashs_allowed
	pass

func _physics_process(delta: float) -> void:
	posture_controller.physics_update(delta)
	move_and_slide()

func apply_gravity(delta: float) -> void:
	#if play char goes up, apply jump gravity
	#otherwise, apply fall gravity
	if velocity.y >= 0.0: velocity.y += jump_gravity * delta
	elif velocity.y < 0.0: velocity.y += fall_gravity * delta
