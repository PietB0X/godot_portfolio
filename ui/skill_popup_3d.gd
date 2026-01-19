extends Node3D

## Skill Popup (3D) - In-world billboard card that does NOT pause the game.

@export var auto_hide_seconds: float = 2.5
@export var y_offset: float = 0.0

@onready var background: MeshInstance3D = $Background
@onready var title_label: Label3D = $TitleLabel
@onready var content_label: Label3D = $ContentLabel
@onready var icon_label: Label3D = $IconLabel

var _content_data: Dictionary = {}

func _ready() -> void:
	# Slight rise-in animation + auto-hide
	position.y += y_offset
	_scale_in()
	_auto_hide()

func _process(_delta: float) -> void:
	# Always face the active camera (billboard effect)
	var cam := get_viewport().get_camera_3d()
	if cam:
		# `look_at` makes the -Z axis face the target; depending on mesh/text facing,
		# this can result in mirrored content. Rotate 180° to show the front side.
		look_at(cam.global_transform.origin, Vector3.UP)
		rotate_y(PI)

func set_content(data: Dictionary) -> void:
	_content_data = data
	title_label.text = str(data.get("title", ""))
	content_label.text = str(data.get("content", ""))
	icon_label.text = str(data.get("icon", ""))
	
	# Adjust background size roughly based on content length (cheap + good enough)
	var lines: int = maxi(1, content_label.text.count("\n") + 1)
	var height: float = 1.0 + float(lines) * 0.25
	_set_background_size(Vector2(2.6, height))
	_reposition_labels(height)

func _auto_hide() -> void:
	if auto_hide_seconds <= 0:
		return
	await get_tree().create_timer(auto_hide_seconds).timeout
	_fade_out_and_free()

func _scale_in() -> void:
	scale = Vector3.ZERO
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _fade_out_and_free() -> void:
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	queue_free()

func _set_background_size(size: Vector2) -> void:
	var plane := background.mesh as PlaneMesh
	if plane:
		plane.size = size

func _reposition_labels(bg_height: float) -> void:
	# Labels are centered by default; nudge them to fit the background
	icon_label.position = Vector3(-1.05, bg_height * 0.35, 0.02)
	title_label.position = Vector3(-0.65, bg_height * 0.35, 0.02)
	content_label.position = Vector3(-1.15, bg_height * 0.05, 0.02)
