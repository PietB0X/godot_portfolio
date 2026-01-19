@tool
extends StaticBody3D

## Skill Block - ? Block that unlocks skill information
## Based on brick.gd but for portfolio content

@export var content_id: String = "skill_frontend"  # Set in editor
@export var block_color: Color = Color.YELLOW  # Yellow for ? blocks
@export var popup_offset: Vector3 = Vector3(0, 1.6, 0)  # Local offset for in-world popup

@onready var bottom_detector = $BottomDetector
@onready var mesh = $Mesh
@onready var particles = $Particles
@onready var popup_anchor: Marker3D = $PopupAnchor

var opened = false
var content_data: Dictionary = {}
var _last_trigger_ms: int = 0

func _ready():
	if Engine.is_editor_hint():
		_sync_anchor_from_export()
		return
	
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
	if not body.is_in_group("player"):
		return
	
	# Mario-style: only trigger when the player hits from below while moving upward.
	# Player is a CharacterBody3D in this project.
	var player: CharacterBody3D = body as CharacterBody3D
	if player == null:
		return
	
	# Cooldown to avoid multi-triggers on the same bump
	var now: int = Time.get_ticks_msec()
	if now - _last_trigger_ms < 250:
		return
	
	# Moving upward (jumping). In this project, velocity.y is positive when moving up.
	var moving_up: bool = player.velocity.y > 0.25
	
	# Ensure player is below the block (head-bump)
	var from_below: bool = player.global_position.y < global_position.y - 0.1
	
	if moving_up and from_below:
		_last_trigger_ms = now
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
	# Create 3D popup and add to the world (no pausing, in-world UI)
	var popup_scene: PackedScene = preload("res://ui/skill_popup_3d.tscn")
	if not popup_scene:
		push_error("[SkillBlock] Failed to load skill_popup_3d.tscn!")
		return
	
	var popup: Node = popup_scene.instantiate()
	
	# Add as child of the block so it stays in the world space
	add_child(popup)
	if popup is Node3D:
		var p3d := popup as Node3D
		p3d.position = _get_popup_offset()
	
	# Set content
	if popup.has_method("set_content"):
		popup.set_content(content_data)
	else:
		push_error("[SkillBlock] Popup doesn't have set_content method!")

func _process(_delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	_sync_export_from_anchor()

func _get_popup_offset() -> Vector3:
	if popup_anchor:
		return popup_anchor.position
	return popup_offset

func _sync_export_from_anchor() -> void:
	if not popup_anchor:
		return
	# Keep the exported value in sync so it persists in scenes.
	if popup_offset != popup_anchor.position:
		popup_offset = popup_anchor.position

func _sync_anchor_from_export() -> void:
	if not popup_anchor:
		return
	popup_anchor.position = popup_offset
