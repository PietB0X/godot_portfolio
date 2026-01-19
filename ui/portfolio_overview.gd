extends Control

## Portfolio Overview (HUD)
## Shows all chapters + entries, locked until unlocked via PortfolioManager.

@export var show_icons: bool = true

@onready var list_container: VBoxContainer = $Panel/Margin/VBox/List
@onready var stats_label: Label = $Panel/Margin/VBox/Stats

const CHAPTER_ORDER: Array[String] = ["about", "skill", "project"]
const CHAPTER_TITLES := {
	"about": "Über mich",
	"skill": "Skills",
	"project": "Projekte",
}

var _rows_by_id: Dictionary = {} # content_id -> {icon: Label, title: Label}

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_list()
	_refresh()
	PortfolioManager.content_updated.connect(_refresh)
	PortfolioManager.content_unlocked.connect(_on_content_unlocked)

func _on_content_unlocked(_content_id: String) -> void:
	# The detailed refresh is cheap here, keeps it robust.
	_refresh()

func _build_list() -> void:
	_rows_by_id.clear()
	for child in list_container.get_children():
		child.queue_free()

	var items_by_type: Dictionary = {}
	for t in CHAPTER_ORDER:
		items_by_type[t] = [] as Array[String]

	for content_id in PortfolioManager.all_content.keys():
		var id: String = str(content_id)
		var data: Dictionary = PortfolioManager.get_content(id)
		var t: String = str(data.get("type", ""))
		if not items_by_type.has(t):
			items_by_type[t] = [] as Array[String]
		var arr: Array[String] = items_by_type[t]
		arr.append(id)
		items_by_type[t] = arr

	for t in CHAPTER_ORDER:
		_add_chapter(str(t), items_by_type.get(t, [] as Array[String]))

func _add_chapter(t: String, ids: Array[String]) -> void:
	if ids.is_empty():
		return

	ids.sort_custom(func(a: String, b: String) -> bool:
		var ta: String = str(PortfolioManager.get_content(a).get("title", a))
		var tb: String = str(PortfolioManager.get_content(b).get("title", b))
		return ta.naturalnocasecmp_to(tb) < 0
	)

	var header := Label.new()
	header.text = str(CHAPTER_TITLES.get(t, t.capitalize()))
	header.add_theme_font_size_override("font_size", 18)
	header.modulate = Color(1, 1, 1, 0.95)
	list_container.add_child(header)

	for id in ids:
		var data: Dictionary = PortfolioManager.get_content(id)
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)

		var icon := Label.new()
		icon.text = str(data.get("icon", "•")) if show_icons else "•"
		icon.add_theme_font_size_override("font_size", 16)
		icon.custom_minimum_size = Vector2(22, 0)
		row.add_child(icon)

		var title := Label.new()
		title.text = str(data.get("title", id))
		title.add_theme_font_size_override("font_size", 14)
		title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		title.autowrap_mode = TextServer.AUTOWRAP_OFF
		row.add_child(title)

		list_container.add_child(row)
		_rows_by_id[id] = {"icon": icon, "title": title}

	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 10)
	list_container.add_child(spacer)

func _refresh() -> void:
	var stats: Dictionary = PortfolioManager.get_progress_stats()
	var unlocked: int = int(stats.get("unlocked", 0))
	var total: int = int(stats.get("total", 0))
	stats_label.text = "Fortschritt: %d / %d freigeschaltet" % [unlocked, total]

	for content_id in _rows_by_id.keys():
		var id: String = str(content_id)
		var row: Dictionary = _rows_by_id[id]
		var icon: Label = row["icon"]
		var title: Label = row["title"]

		var data: Dictionary = PortfolioManager.get_content(id)
		var is_unlocked: bool = PortfolioManager.is_content_unlocked(id)

		if is_unlocked:
			title.text = str(data.get("title", id))
			title.modulate = Color(1, 1, 1, 0.95)
			icon.modulate = Color(1, 1, 1, 0.95)
		else:
			title.text = "???"
			title.modulate = Color(1, 1, 1, 0.35)
			icon.modulate = Color(1, 1, 1, 0.35)
