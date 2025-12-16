# weapon_data.gd
class_name WeaponData extends Resource

@export_category("Weapon Stats")
@export var weapon_name: String = "Weapon"
@export var damage: float = 10.0
@export var fire_rate: float = 0.5  
@export var magazine_size: int = 30
@export var reload_time: float = 2.0
@export_range(0.0, 1.0) var spread: float = 0.05

@export_category("Visuals & Audio")
@export var mesh: PackedScene
@export var muzzle_flash: GPUParticles3D
@export var shoot_sound: AudioStream
@export var reload_sound: AudioStream

@export_category("Ammo")
@export var ammo_type: String = "bullet"
@export var current_ammo: int = 30
@export var reserve_ammo: int = 90
