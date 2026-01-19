extends StaticBody3D

## Project Board - Platform that displays project information
## Player can interact by getting close or jumping on it

@export var content_id: String = "project_lessingyard"  # Set in editor

@onready var interaction_area = $InteractionArea
@onready var mesh = $platform
@onready var title_label = $Display/TitleLabel
@onready var icon_sprite = $Display/IconSprite

var content_data: Dictionary = {}
var player_nearby = false
var interaction_indicator = null

func _ready():
	# Connect interaction area
	if interaction_area:
		interaction_area.body_entered.connect(_on_body_entered)
		interaction_area.body_exited.connect(_on_body_exited)
	
	# Load content data
	content_data = PortfolioManager.get_content(content_id)
	
	if content_data.is_empty():
		push_error("[ProjectBoard] Content ID '%s' not found!" % content_id)
		return
	
	# Set display text and icon
	_update_display()
	
	# Get or create interaction indicator
	_get_interaction_indicator()
	
	print("[ProjectBoard] Loaded project: %s" % content_data.get("title", "Unknown"))

func _get_interaction_indicator():
	# Find existing indicator - check HUD first, then CanvasLayer
	var main_scene = get_tree().current_scene
	
	# First, check if indicator is in HUD (user might have added it manually)
	var hud = main_scene.get_node_or_null("HUD")
	if hud:
		interaction_indicator = hud.get_node_or_null("InteractionIndicator")
		if interaction_indicator:
			print("[ProjectBoard] Found interaction indicator in HUD")
			return
	
	# If not in HUD, check CanvasLayer
	var canvas_layer = main_scene.get_node_or_null("CanvasLayer")
	if not canvas_layer:
		# Create CanvasLayer if it doesn't exist
		canvas_layer = CanvasLayer.new()
		canvas_layer.name = "CanvasLayer"
		main_scene.add_child(canvas_layer)
	
	# Check if indicator already exists in CanvasLayer
	interaction_indicator = canvas_layer.get_node_or_null("InteractionIndicator")
	if not interaction_indicator:
		# Create indicator if it doesn't exist
		var indicator_scene = preload("res://ui/interaction_indicator.tscn")
		interaction_indicator = indicator_scene.instantiate()
		interaction_indicator.name = "InteractionIndicator"
		canvas_layer.add_child(interaction_indicator)
		print("[ProjectBoard] Created interaction indicator in CanvasLayer")
	else:
		print("[ProjectBoard] Found existing interaction indicator in CanvasLayer")

func _update_display():
	# Set title text
	if title_label:
		title_label.text = content_data.get("title", "Project")
	
	# Set icon (PNG texture)
	if icon_sprite:
		var icon_path = content_data.get("icon_path", "")
		if icon_path != "" and ResourceLoader.exists(icon_path):
			var texture = load(icon_path) as Texture2D
			if texture:
				icon_sprite.texture = texture
				icon_sprite.visible = true
				print("[ProjectBoard] Loaded icon from: %s" % icon_path)
			else:
				icon_sprite.visible = false
				push_warning("[ProjectBoard] Failed to load icon texture from: %s" % icon_path)
		else:
			icon_sprite.visible = false
			if icon_path != "":
				push_warning("[ProjectBoard] Icon path not found: %s" % icon_path)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = true
		print("[ProjectBoard] Player entered interaction area for: %s" % content_id)
		# Show interaction indicator
		if interaction_indicator:
			interaction_indicator.show_indicator("Press E to interact")

func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_nearby = false
		print("[ProjectBoard] Player left interaction area for: %s" % content_id)
		# Hide interaction indicator
		if interaction_indicator:
			interaction_indicator.hide_indicator()

func _input(event):
	# Allow interaction with E key when nearby
	if player_nearby and event.is_action_pressed("interact"):
		_show_project_popup()
		# Hide indicator after interaction
		if interaction_indicator:
			interaction_indicator.hide_indicator()

func _show_project_popup():
	# Create popup and add to scene tree
	var popup_scene = preload("res://ui/project_popup.tscn")
	if not popup_scene:
		push_error("[ProjectBoard] Failed to load project_popup.tscn!")
		return
	
	var popup = popup_scene.instantiate()
	
	# Add to CanvasLayer or main scene
	var main_scene = get_tree().current_scene
	var canvas_layer = main_scene.get_node_or_null("CanvasLayer")
	
	if canvas_layer:
		canvas_layer.add_child(popup)
	else:
		# Create CanvasLayer if it doesn't exist
		canvas_layer = CanvasLayer.new()
		canvas_layer.name = "CanvasLayer"
		main_scene.add_child(canvas_layer)
		canvas_layer.add_child(popup)
	
	# Set content
	if popup.has_method("set_content"):
		popup.set_content(content_data)
		print("[ProjectBoard] Showing popup for: %s" % content_data.get("title", "Unknown"))
	else:
		push_error("[ProjectBoard] Popup doesn't have set_content method!")
