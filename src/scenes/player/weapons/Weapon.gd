# weapon.gd
class_name Weapon extends Node3D

@export var weapon_data: WeaponData
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var muzzle: Marker3D = $Muzzle
@onready var muzzle_flash_particles: GPUParticles3D = $MuzzleFlash/GPUParticles3D

var can_fire: bool = true
var current_ammo: int = 0

func _ready():
	if weapon_data:
		current_ammo = weapon_data.magazine_size

func fire():

	if not can_fire or current_ammo <= 0:
		return false
	
	#current_ammo -= 1
	can_fire = false
	
	get_tree().create_timer(weapon_data.fire_rate).timeout.connect(
		func(): can_fire = true
	)
	
	_shoot_raycast()
	
	_play_fire_effects()
	
	return true

func _shoot_raycast():
	var camera = get_viewport().get_camera_3d()

	if not camera:
		print('camara')
		return
	
	var from = camera.global_position
	var forward = -camera.global_transform.basis.z
	
	var spread_vec = Vector3(
		randf_range(-weapon_data.spread, weapon_data.spread),
		randf_range(-weapon_data.spread, weapon_data.spread),
		0
	)
	
	var to = from + (forward + spread_vec).normalized() * weapon_data.max_range
	
	var space = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	
	var result = space.intersect_ray(query)
	if result:
		_handle_hit(result)

func _handle_hit(result: Dictionary):
	var hit_obj = result.collider
	
	if hit_obj.has_method("take_damage"):
		hit_obj.take_damage(weapon_data.damage)
	
	_spawn_hit_effect(result.position)

func _play_fire_effects():
	
	if audio_player:
		audio_player.play()

	if animation_player.is_playing():
		animation_player.stop()
	if animation_player.has_animation("fire"):
		animation_player.play("fire")
	
	_show_muzzle_flash()

func _show_muzzle_flash():
	print("Activando flash")
	
	if muzzle_flash_particles:
		muzzle_flash_particles.restart()
		muzzle_flash_particles.emitting = true

func _spawn_hit_effect(_position: Vector3):
	print('efectos hit')

func reload():
	current_ammo = weapon_data.magazine_size
	# TO DO recarga efectos sonidos
