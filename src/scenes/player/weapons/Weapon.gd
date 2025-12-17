# weapon.gd
class_name Weapon extends Node3D

@export var weapon_data: WeaponData
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_player: AudioStreamPlayer3D = $AudioStreamPlayer3D
@onready var muzzle: Marker3D = $Muzzle

var can_fire: bool = true
var current_ammo: int = 0

func _ready():
    if weapon_data:
        current_ammo = weapon_data.magazine_size

func fire():
    if not can_fire or current_ammo <= 0:
        return false
    
    current_ammo -= 1
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
    audio_player.play()
    
    if animation_player.has_animation("fire"):
        animation_player.play("fire")
    
    _create_simple_muzzle_flash()

func _create_simple_muzzle_flash():
    var particles = GPUParticles3D.new()
    particles.amount = 8
    particles.lifetime = 0.1
    particles.explosiveness = 1.0
    
    var material = ParticleProcessMaterial.new()
    material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
    material.emission_box_extents = Vector3(0.1, 0.1, 0.1)
    material.gravity = Vector3(0, 0, 0)
    particles.process_material = material
    
    muzzle.add_child(particles)
    particles.emitting = true
    get_tree().create_timer(0.2).timeout.connect(particles.queue_free)

func _spawn_hit_effect(position: Vector3):
    var particles = GPUParticles3D.new()
    particles.amount = 4
    particles.lifetime = 0.3
    
    get_tree().root.add_child(particles)
    particles.global_position = position
    particles.emitting = true
    
    get_tree().create_timer(0.5).timeout.connect(particles.queue_free)

func reload():
    current_ammo = weapon_data.magazine_size
    # TO DO recarga efectos sonidos