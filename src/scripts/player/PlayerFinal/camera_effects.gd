# CameraEffects.gd
extends Node3D
class_name CameraEffects

@onready var head: Node3D = get_parent() 
@onready var player = head.get_parent() as Player
@onready var camera: Camera3D = $"../Camera3D"

# -------------------
# HEAD BOB
# -------------------
var bob_timer := 0.0
@export var bob_speed := 10.0
@export var bob_amount := 0.40

# -------------------
# CAMERA SHAKE
# -------------------
var shake_timer := 0.0
var shake_intensity := 0.0

func _ready():
	pass

func _physics_process(delta: float):
	_apply_head_bob(delta)
	_apply_camera_shake(delta)
	pass
# -------------------
# HEAD BOB
# -------------------
func _apply_head_bob(delta: float) -> void:
	var base_height: float = player.posture_controller.standing_head_height
	if player.posture_controller.is_crouching:
		base_height += player.posture_controller.crouch_depth

	if player.move_direction.length() > 0:
		var speed_factor: float = player.velocity.length() / player.move_speed
		bob_timer += delta * bob_speed * speed_factor
		var offset := sin(bob_timer) * bob_amount * speed_factor

		head.position.y = lerp(head.position.y, base_height + offset, delta * 10)
	else:
		bob_timer = 0
		head.position.y = lerp(head.position.y, base_height, delta * 10)

# -------------------
# CAMERA SHAKE
# -------------------
func start_shake(duration: float, intensity: float) -> void:
	shake_timer = duration
	shake_intensity = intensity

func _apply_camera_shake(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		head.position += Vector3(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity),
			0 # Z = 0 para no mover hacia adelante/atrás
		)
