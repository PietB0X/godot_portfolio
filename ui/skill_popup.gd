extends Control

## Skill Popup UI - Shows skill information when ? block is hit

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var content_label = $Panel/VBoxContainer/ContentLabel
@onready var icon_label = $Panel/VBoxContainer/IconLabel
@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var panel = $Panel

var content_data: Dictionary = {}

func _ready():
	# Make popup fullscreen overlay
	anchor_left = 0.0
	anchor_top = 0.0
	anchor_right = 1.0
	anchor_bottom = 1.0
	offset_left = 0.0
	offset_top = 0.0
	offset_right = 0.0
	offset_bottom = 0.0
	
	# Make sure it's on top
	z_index = 100
	
	# IMPORTANT: Process input even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	
	# Close on ESC/Enter
	set_process_input(true)
	
	# Pause game when popup is open
	get_tree().paused = true

func _input(event):
	if not visible:
		return
	
	if event.is_action_pressed("ui_cancel"):  # ESC key
		_on_close_pressed()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_accept"):  # Enter key
		_on_close_pressed()
		get_viewport().set_input_as_handled()

func set_content(data: Dictionary):
	content_data = data
	
	if title_label:
		title_label.text = data.get("title", "")
	
	if content_label:
		content_label.text = data.get("content", "")
	
	if icon_label:
		icon_label.text = data.get("icon", "?")

func _on_close_pressed():
	# Unpause game
	get_tree().paused = false
	queue_free()
