extends Node
class_name MovementComponent

var direction: Vector3 = Vector3.ZERO
var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()

func handle_movement(delta: float) -> void:
	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction, (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * GameConfig.player_lerp_speed)
	
	if direction:
		player.velocity.x = direction.x * GameConfig.player_movement_speed
		player.velocity.z = direction.z * GameConfig.player_movement_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, GameConfig.player_movement_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, GameConfig.player_movement_speed)
