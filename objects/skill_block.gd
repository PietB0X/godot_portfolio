extends StaticBody3D

## Skill Block - ? Block that unlocks skill information
## Based on brick.gd but for portfolio content

@export var content_id: String = "skill_frontend"  # Set in editor
@export var block_color: Color = Color.YELLOW  # Yellow for ? blocks

@onready var bottom_detector = $BottomDetector
@onready var mesh = $Mesh
@onready var particles = $Particles

var opened = false
var content_data: Dictionary = {}

func _ready():
	# Connect bottom detector
	bottom_detector.body_entered.connect(_on_bottom_hit)
	
	# Load content data
	content_data = PortfolioManager.get_content(content_id)
	
	if content_data.is_empty():
		push_error("[SkillBlock] Content ID '%s' not found!" % content_id)
		return
	
	# Check if already opened
	if PortfolioManager.is_content_unlocked(content_id):
		_set_opened_state()

func _on_bottom_hit(body: Node3D) -> void:
	if body.is_in_group("player"):
		open_block()

func open_block():
	# Unlock content in PortfolioManager (idempotent - safe to call multiple times)
	PortfolioManager.unlock_content(content_id)
	
	# Visual feedback
	particles.restart()
	Audio.play("res://sounds/break.ogg")  # Use break sound or create new one
	
	# Change appearance to opened state (only once)
	if not opened:
		opened = true
		_set_opened_state()
	
	# Show UI popup with skill info (can be shown multiple times)
	_show_skill_popup()
	
	print("[SkillBlock] Opened: %s" % content_id)

func _set_opened_state():
	# Change mesh to gray/opened appearance
	# Use set_deferred to avoid signal issues
	call_deferred("_apply_opened_material")

func _apply_opened_material():
	if not mesh:
		return
	
	# The mesh is an instanced scene (brick.glb)
	# We set material_override in the scene, so we can modify it directly
	# Find all MeshInstance3D nodes in the instanced scene
	_find_and_modify_mesh_instances(mesh)

func _find_and_modify_mesh_instances(node: Node):
	# Check if this node is a MeshInstance3D
	
	# Recursively check children
	for child in node.get_children():
		_find_and_modify_mesh_instances(child)

func _show_skill_popup():
	# Create popup and add to scene tree
	var popup_scene = preload("res://ui/skill_popup.tscn")
	if not popup_scene:
		push_error("[SkillBlock] Failed to load skill_popup.tscn!")
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
	else:
		push_error("[SkillBlock] Popup doesn't have set_content method!")
