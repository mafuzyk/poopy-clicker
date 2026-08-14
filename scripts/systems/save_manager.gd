extends Node

const GameState = preload("res://scripts/core/game_state.gd")

const SAVE_VERSION: int = 3
const SAVE_PATH: String = "user://save.json"
const SAVE_TMP_PATH: String = "user://save.json.tmp"
const AUTOSAVE_INTERVAL: float = 60.0

var game_state: GameState
var save_handlers: Array[Dictionary] = []
var save_path_override: String = ""


func set_save_path_for_test(path: String) -> void:
	save_path_override = path


func _save_path() -> String:
	return save_path_override if save_path_override != "" else SAVE_PATH


func add_save_handler(key: String, getter: Callable, setter: Callable) -> void:
	save_handlers.append({"key": key, "getter": getter, "setter": setter})


func setup(state: GameState) -> void:
	game_state = state


func _ready() -> void:
	var autosave_timer: Timer = Timer.new()
	autosave_timer.name = "AutosaveTimer"
	autosave_timer.wait_time = AUTOSAVE_INTERVAL
	autosave_timer.one_shot = false
	autosave_timer.autostart = true
	autosave_timer.timeout.connect(save)
	add_child(autosave_timer)


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save()


func save() -> void:
	var path := _save_path()
	var file: FileAccess = FileAccess.open(path + ".tmp", FileAccess.WRITE)
	if file == null:
		push_error("SaveManager: falha ao abrir " + path + " para escrita")
		return

	var data := {
		"save_version": SAVE_VERSION,
		"money": game_state.money,
		"lifetime_money": game_state.lifetime_money,
		"stats": game_state.stats,
		"combo_count": game_state.combo_count,
		"combo_multiplier": game_state.combo_multiplier,
		"click_level": game_state.click_level,
		"auto_level": game_state.auto_level,
		"goober_clicks_total": game_state.goober_clicks_total,
		"goober_click_progress": game_state.goober_click_progress,
		"bestiary_counts": game_state.bestiary_counts,
		"goober_coins": game_state.goober_coins,
		"secret_shop_unlocked": game_state.secret_shop_unlocked,
		"goober_charm_bought": game_state.goober_charm_bought,
		"heavy_button_bought": game_state.heavy_button_bought,
		"lucky_paws_bought": game_state.lucky_paws_bought,
		"sneaky_profit_bought": game_state.sneaky_profit_bought,
		"panic_shield_bought": game_state.panic_shield_bought,
		"button_clicks_total": game_state.button_clicks_total,
	}

	for handler in save_handlers:
		data[handler["key"]] = handler["getter"].call()

	file.store_string(JSON.stringify(data, "\t"))
	file.close()

	var error := DirAccess.rename_absolute(ProjectSettings.globalize_path(path + ".tmp"), ProjectSettings.globalize_path(path))
	if error != OK:
		push_error("SaveManager: falha ao substituir " + path + " (erro %d)" % error)


func load() -> bool:
	var path := _save_path()
	if not FileAccess.file_exists(path):
		return false

	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return false

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()

	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("SaveManager: save inválido ou corrompido")
		return false

	var data: Dictionary = parsed
	var version: int = int(data.get("save_version", 0))

	if version > SAVE_VERSION:
		push_warning("SaveManager: save de versão futura ignorado")
		return false

	if version < SAVE_VERSION:
		data = _migrate(data, version)

	game_state.set_money(int(data.get("money", 0)))
	game_state.lifetime_money = int(data.get("lifetime_money", 0))
	var raw_stats: Variant = data.get("stats", {})
	game_state.stats = raw_stats if typeof(raw_stats) == TYPE_DICTIONARY else {}
	game_state.combo_count = int(data.get("combo_count", 0))
	game_state.combo_multiplier = float(data.get("combo_multiplier", 1.0))
	game_state.click_level = int(data.get("click_level", 0))
	game_state.auto_level = int(data.get("auto_level", 0))
	game_state.goober_clicks_total = int(data.get("goober_clicks_total", 0))
	game_state.goober_click_progress = int(data.get("goober_click_progress", 0))
	if typeof(data.get("bestiary_counts")) == TYPE_DICTIONARY:
		game_state.bestiary_counts = data.get("bestiary_counts", {})
	else:
		game_state.bestiary_counts = {}
	game_state.goober_coins = int(data.get("goober_coins", 0))
	game_state.secret_shop_unlocked = bool(data.get("secret_shop_unlocked", false))
	game_state.goober_charm_bought = bool(data.get("goober_charm_bought", false))
	game_state.heavy_button_bought = bool(data.get("heavy_button_bought", false))
	game_state.lucky_paws_bought = bool(data.get("lucky_paws_bought", false))
	game_state.sneaky_profit_bought = bool(data.get("sneaky_profit_bought", false))
	game_state.panic_shield_bought = bool(data.get("panic_shield_bought", false))
	game_state.button_clicks_total = int(data.get("button_clicks_total", 0))

	for handler in save_handlers:
		handler["setter"].call(data.get(handler["key"], []))
	# Estados intermediários emitiram changed com dados parciais; reavaliar
	# consumidores (achievements, painéis) apenas com o estado completo.
	game_state.changed.emit()
	return true


func _migrate(data: Dictionary, from_version: int) -> Dictionary:
	var migrated := data.duplicate(true)
	var current := from_version
	while current < SAVE_VERSION:
		match current:
			1:
				migrated = _migrate_v1_to_v2(migrated)
			2:
				migrated = _migrate_v2_to_v3(migrated)
		current += 1
	migrated["save_version"] = SAVE_VERSION
	return migrated


func _migrate_v1_to_v2(data: Dictionary) -> Dictionary:
	if not data.has("stats") or typeof(data.get("stats")) != TYPE_DICTIONARY:
		data["stats"] = {"money_earned": int(data.get("lifetime_money", 0))}
	return data


func _migrate_v2_to_v3(data: Dictionary) -> Dictionary:
	var stats: Dictionary = data.get("stats", {}) if typeof(data.get("stats")) == TYPE_DICTIONARY else {}
	stats["highest_combo"] = int(stats.get("highest_combo", 0))
	data["stats"] = stats
	data["combo_count"] = 0
	data["combo_multiplier"] = 1.0
	return data