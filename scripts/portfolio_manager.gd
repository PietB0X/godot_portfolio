extends Node

## Portfolio Content Manager
## Singleton that manages all portfolio content and tracks unlocked items

signal content_unlocked(content_id: String)
signal content_updated()

# All available portfolio content
var all_content: Dictionary = {}

# Unlocked content IDs
var unlocked_content: Array[String] = []

# Save file path
const SAVE_FILE_PATH = "user://portfolio_save.json"

func _ready():
	load_content_data()
	load_save_data()
	print("[PortfolioManager] Initialized with %d unlocked items" % unlocked_content.size())

## Load content definitions
func load_content_data():
	# Load content from separate data file for easy editing
	var content_script = load("res://data/portfolio_content.gd")
	if content_script:
		all_content = content_script.get_all_content()
		print("[PortfolioManager] Loaded %d content items" % all_content.size())
	else:
		push_error("[PortfolioManager] Failed to load portfolio_content.gd!")

## Check if content is unlocked
func is_content_unlocked(content_id: String) -> bool:
	return content_id in unlocked_content

## Unlock content
func unlock_content(content_id: String) -> bool:
	if content_id in unlocked_content:
		return false  # Already unlocked
	
	if not content_id in all_content:
		push_error("[PortfolioManager] Content ID '%s' not found!" % content_id)
		return false
	
	unlocked_content.append(content_id)
	save_data()
	content_unlocked.emit(content_id)
	content_updated.emit()
	
	print("[PortfolioManager] Unlocked: %s" % content_id)
	return true

## Get content data
func get_content(content_id: String) -> Dictionary:
	if not content_id in all_content:
		return {}
	return all_content[content_id]

## Get all unlocked content of a type
func get_unlocked_by_type(type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for id in unlocked_content:
		var content = get_content(id)
		if content.has("type") and content["type"] == type:
			result.append(content)
	return result

## Save progress to file
func save_data():
	var save_data = {
		"unlocked_content": unlocked_content,
		"version": 1
	}
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("[PortfolioManager] Saved progress")
	else:
		push_error("[PortfolioManager] Failed to save progress!")

## Load progress from file
func load_save_data():
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("[PortfolioManager] No save file found, starting fresh")
		return
	
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		
		if parse_result == OK:
			var data = json.get_data()
			if data.has("unlocked_content"):
				# Convert Array to Array[String]
				var loaded_array = data["unlocked_content"]
				unlocked_content.clear()
				for item in loaded_array:
					if item is String:
						unlocked_content.append(item)
				print("[PortfolioManager] Loaded %d unlocked items from save" % unlocked_content.size())
		else:
			push_error("[PortfolioManager] Failed to parse save file!")
	else:
		push_error("[PortfolioManager] Failed to open save file!")

## Get progress stats
func get_progress_stats() -> Dictionary:
	var total = all_content.size()
	var unlocked = unlocked_content.size()
	var skills_unlocked = get_unlocked_by_type("skill").size()
	var projects_unlocked = get_unlocked_by_type("project").size()
	var about_unlocked = get_unlocked_by_type("about").size()
	
	return {
		"total": total,
		"unlocked": unlocked,
		"skills": skills_unlocked,
		"projects": projects_unlocked,
		"about": about_unlocked
	}
