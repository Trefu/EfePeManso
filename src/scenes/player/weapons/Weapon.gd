# weapon.gd
class_name Weapon extends Node3D

@export var weapon_data: WeaponData
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var muzzle_flash_particles: GPUParticles3D = $MuzzleFlash/GPUParticles3D
@onready var muzzle: Marker3D = $MuzzlePosition

var can_fire: bool = true
var current_ammo: int = 0

func _ready():
	if weapon_data:
		current_ammo = weapon_data.magazine_size
		_configure_muzzle_flash()

func fire():
	if not can_fire or current_ammo <= 0:
		return false
	
	#TO DO RESTAR MUNICIÓN XD
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
		return
	
	var from = camera.global_position
	var forward = - camera.global_transform.basis.z
	
	var spread_x = randf_range(-weapon_data.spread, weapon_data.spread)
	var spread_y = randf_range(-weapon_data.spread, weapon_data.spread)
	
	var direction = forward
	direction.x += spread_x
	direction.y += spread_y
	direction = direction.normalized()
	
	var to = from + direction * weapon_data.max_range
	
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
	if muzzle_flash_particles:
		muzzle_flash_particles.global_transform = muzzle.global_transform
		muzzle_flash_particles.restart()
		muzzle_flash_particles.emitting = true
	else:
		print("ERROR: No hay muzzle_flash_particles")

#TO DO por ahora esto es provisional y para todas las armas
func _spawn_hit_effect(hit_position: Vector3):
	print("Hit en:", hit_position)
	
	var debug_sphere = MeshInstance3D.new()
	debug_sphere.mesh = SphereMesh.new()
	debug_sphere.mesh.radius = 0.08
	debug_sphere.mesh.height = 0.16
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color.RED
	debug_sphere.material_override = material
	
	get_tree().current_scene.add_child(debug_sphere)
	debug_sphere.global_position = hit_position
	
	var tween = create_tween()
	tween.tween_property(debug_sphere, "scale", Vector3(0.1, 0.1, 0.1), 0.4)
	tween.parallel().tween_property(material, "albedo_color:a", 0.0, 0.4)
	
	await get_tree().create_timer(0.5).timeout
	debug_sphere.queue_free()

func _configure_muzzle_flash():
	if not weapon_data or not muzzle_flash_particles:
		return

	var quad_mesh = muzzle_flash_particles.draw_pass_1
	var current_material = quad_mesh.material
	
	if not current_material:
		current_material = StandardMaterial3D.new()
	
	var new_material = current_material.duplicate()
	
	new_material.albedo_texture = weapon_data.muzzle_flash_texture
	new_material.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	new_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	quad_mesh.material = new_material
	
	
func reload():
	current_ammo = weapon_data.magazine_size
	# TO DO recarga efectos sonidos
