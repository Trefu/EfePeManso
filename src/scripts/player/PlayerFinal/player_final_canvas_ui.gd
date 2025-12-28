# player_final_canvas_ui.gd
extends CanvasLayer


@export var player: Player
@onready var state_label: Label = $Control/StateLabel
@onready var speed_label: Label = $Control/SpeedLabel

func _ready():
	$Control.mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(delta):
	
	if player and player.state_machine:
		state_label.text = "State: " + player.state_machine.get_current_state_name()
		speed_label.text = "Speed: %.2f" % player.velocity.length()
