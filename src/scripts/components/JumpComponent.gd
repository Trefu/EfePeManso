extends Node
class_name JumpComponent

var player: CharacterBody3D

func _ready() -> void:
	player = get_parent()

func handle_jump() -> void:
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.velocity.y = GameConfig.player_jump_velocity
