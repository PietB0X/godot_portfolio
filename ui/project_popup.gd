extends Control

## Project Popup UI - Shows detailed project information

@onready var title_label = $Panel/VBoxContainer/TitleLabel
@onready var subtitle_label = $Panel/VBoxContainer/SubtitleLabel
@onready var description_label = $Panel/VBoxContainer/DescriptionLabel
@onready var tech_stack_label = $Panel/VBoxContainer/TechStackLabel
@onready var github_button = $Panel/VBoxContainer/Buttons/GithubButton
@onready var live_button = $Panel/VBoxContainer/Buttons/LiveButton
@onready var close_button = $Panel/VBoxContainer/CloseButton
@onready var screenshot_texture = $Panel/VBoxContainer/ScreenshotTexture

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
	
	# Connect buttons
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
	if github_button:
		github_button.pressed.connect(_on_github_pressed)
	if live_button:
		live_button.pressed.connect(_on_live_pressed)
	
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
	
	if subtitle_label:
		subtitle_label.text = data.get("subtitle", "")
	
	if description_label:
		description_label.text = data.get("description", "")
	
	# Tech Stack
	if tech_stack_label:
		var tech_stack = data.get("tech_stack", [])
		if tech_stack.size() > 0:
			tech_stack_label.text = "Tech Stack: " + ", ".join(tech_stack)
		else:
			tech_stack_label.text = ""
	
	# GitHub Link
	if github_button:
		var github_link = data.get("github_link", "")
		if github_link != "":
			github_button.visible = true
			github_button.text = "GitHub"
		else:
			github_button.visible = false
	
	# Live Link
	if live_button:
		var live_link = data.get("live_link", "")
		if live_link != "":
			live_button.visible = true
			live_button.text = "Live Demo"
		else:
			live_button.visible = false
	
	# Screenshot
	if screenshot_texture:
		var screenshot_path = data.get("screenshot", "")
		if screenshot_path != "" and ResourceLoader.exists(screenshot_path):
			var texture = load(screenshot_path) as Texture2D
			if texture:
				screenshot_texture.texture = texture
				screenshot_texture.visible = true
			else:
				screenshot_texture.visible = false
		else:
			screenshot_texture.visible = false

func _on_close_pressed():
	# Unpause game
	get_tree().paused = false
	queue_free()

func _on_github_pressed():
	var github_link = content_data.get("github_link", "")
	if github_link != "":
		OS.shell_open(github_link)

func _on_live_pressed():
	var live_link = content_data.get("live_link", "")
	if live_link != "":
		OS.shell_open(live_link)
