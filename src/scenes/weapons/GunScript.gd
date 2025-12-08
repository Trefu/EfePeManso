extends Node3D

@export var damage = 1.0

@onready var animation: AnimationPlayer = $AnimationPlayer
@onready var shot_sound: AudioStreamPlayer = $ShotSound
@onready var raycast: RayCast3D = $RayCast3D

var can_shoot: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_pressed("shoot") and can_shoot and not animation.is_playing():
		animation.play("shoot")
		shot_sound.play()

func _on_animation_finished() -> void:
	can_shoot = true
