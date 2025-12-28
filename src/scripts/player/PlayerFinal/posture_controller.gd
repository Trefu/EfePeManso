#posture_controller.gd
extends Node
class_name PostureController

@onready var standing_collision: CollisionShape3D = $"../StandingCollisionShape3D"
@onready var crouching_collision: CollisionShape3D = $"../CrouchingCollisionShape3D"
@onready var head: Node3D = $"../Head"
@onready var height_ray_cast_3d: RayCast3D = $"../HeightRayCast3D"

var player: Player
var standing_head_height := 1.5
var crouch_depth := -0.5
var lerp_speed := 12.0
var standing_speed := 7.0
var crouching_speed := 4.55
var is_crouching := false

func setup(p: Player) -> void:
	player = p
	_apply_standing()

func physics_update(delta: float) -> void:
	if is_crouching:
		_update_crouch(delta)
	else:
		_update_stand(delta)


# ========================
# PUBLIC API (usado por estados)
# ========================

func request_crouch() -> void:
	if is_crouching:
		return
	_apply_crouch()


func request_stand() -> void:
	if not is_crouching:
		return
	if not can_stand():
		return
	_apply_standing()


func can_stand() -> bool:
	return not height_ray_cast_3d.is_colliding()


# ========================
# INTERNAL
# ========================

func _apply_crouch() -> void:
	is_crouching = true

	standing_collision.disabled = true
	crouching_collision.disabled = false

	player.current_speed  = crouching_speed


func _apply_standing() -> void:
	is_crouching = false

	standing_collision.disabled = false
	crouching_collision.disabled = true

	player.current_speed  = standing_speed


func _update_crouch(delta: float) -> void:
	head.position.y = lerp(
		head.position.y,
		standing_head_height + crouch_depth,
		delta * lerp_speed
	)


func _update_stand(delta: float) -> void:
	head.position.y = lerp(
		head.position.y,
		standing_head_height,
		delta * lerp_speed
	)
