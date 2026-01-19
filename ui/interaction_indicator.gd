extends Control

## Interaction Indicator - Shows "Press E to interact" when player is near interactable objects

@onready var label = $Label

var is_visible = false

func _ready():
	visible = false
	# Make sure it's on top
	z_index = 50
	# Don't override anchors - use scene settings

func show_indicator(text: String = "Press E to interact"):
	if label:
		label.text = text
	visible = true
	is_visible = true
	print("[InteractionIndicator] Showing: %s" % text)

func hide_indicator():
	visible = false
	is_visible = false
	print("[InteractionIndicator] Hiding")
