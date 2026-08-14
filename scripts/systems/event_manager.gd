extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const EventCatalog = preload("res://scripts/data/event_catalog.gd")

signal event_started(id: String, definition: Dictionary)
signal event_ended(id: String)
signal event_progress_changed(ratio: float)

const EVENT_CHECK_INTERVAL := 9.0
const EVENT_TRIGGER_CHANCE := 0.22
const PROGRESS_POLL_INTERVAL := 0.15

var game_state: GameState
var enabled_ids: Array = []

var active_event_id := ""
var active_definition: Dictionary = {}
var active_duration := 0.0

# Shield futuro (Skill Shield): cancela evento ativo e bloqueia novos por 10s.
var triggers_blocked := false
# Hook futuro (prestige_level >= 3): multiplica pesos de rare/epic por 1.08.
var rarity_weight_modifiers: Dictionary = {}
# Apenas testes: duração fixa para eventos forçados (>= 0 ativa o override).
var duration_override := -1.0

var check_timer: Timer
var duration_timer: Timer
var progress_timer: Timer


func setup(state: GameState, ids: Array = []) -> void:
	game_state = state
	# Pool padrão: todos os 35; slices/testes podem passar um subset explícito.
	enabled_ids = ids.duplicate() if not ids.is_empty() else EventCatalog.all_ids()

	check_timer = Timer.new()
	check_timer.name = "RandomEventCheckTimer"
	check_timer.wait_time = EVENT_CHECK_INTERVAL
	check_timer.one_shot = false
	check_timer.autostart = true
	check_timer.timeout.connect(try_random_event)
	add_child(check_timer)

	duration_timer = Timer.new()
	duration_timer.name = "EventDurationTimer"
	duration_timer.one_shot = true
	duration_timer.timeout.connect(_on_duration_timeout)
	add_child(duration_timer)

	progress_timer = Timer.new()
	progress_timer.name = "EventProgressTimer"
	progress_timer.wait_time = PROGRESS_POLL_INTERVAL
	progress_timer.one_shot = false
	progress_timer.autostart = true
	progress_timer.timeout.connect(_emit_progress)
	add_child(progress_timer)


# ---------- random check ----------


# Roll <= EVENT_TRIGGER_CHANCE ativa a seleção (random.random() > chance -> return).
# Parâmetros de roll < 0 usam randf() real; testes passam valores determinísticos.
func try_random_event(trigger_roll: float = -1.0, rarity_roll: float = -1.0, candidate_roll: float = -1.0) -> bool:
	if has_active_event():
		return false
	if triggers_blocked:
		return false

	var roll: float = randf() if trigger_roll < 0.0 else trigger_roll
	if roll > EVENT_TRIGGER_CHANCE:
		return false

	var event_id := EventCatalog.choose_event(enabled_ids, rarity_weight_modifiers, rarity_roll, candidate_roll)
	if event_id == "":
		return false
	return start_event(event_id)


# ---------- lifecycle ----------


func start_event(event_id: String, replace_active: bool = false) -> bool:
	var definition: Dictionary = EventCatalog.get_event(event_id)
	if definition.is_empty():
		return false
	if has_active_event():
		if not replace_active:
			return false
		# Substituição encerra o antigo explicitamente: listeners que limpam
		# side effects (invert_colors, orbital, gravity...) recebem event_ended.
		var old_id := active_event_id
		_clear_runtime()
		event_ended.emit(old_id)

	active_event_id = event_id
	active_definition = definition
	active_duration = get_effective_duration(definition)
	game_state.register_event_seen()
	duration_timer.start(active_duration)
	event_started.emit(active_event_id, active_definition)
	event_progress_changed.emit(get_progress_ratio())
	return true


func force_start_event(event_id: String) -> bool:
	return start_event(event_id, true)


func end_event() -> void:
	if not has_active_event():
		return
	var old_id := active_event_id
	_clear_runtime()
	event_ended.emit(old_id)


func _on_duration_timeout() -> void:
	end_event()


func _clear_runtime() -> void:
	active_event_id = ""
	active_definition = {}
	active_duration = 0.0
	duration_timer.stop()


func _emit_progress() -> void:
	if has_active_event():
		event_progress_changed.emit(get_progress_ratio())


# ---------- queries ----------


func has_active_event() -> bool:
	return active_event_id != ""


func get_active_event_id() -> String:
	return active_event_id


func get_active_definition() -> Dictionary:
	return active_definition


func get_effective_duration(definition: Dictionary) -> float:
	if duration_override >= 0.0:
		return duration_override
	return float(definition.get("duration", 0))


func get_remaining_seconds() -> float:
	if not has_active_event():
		return 0.0
	return maxf(0.0, duration_timer.time_left)


func get_progress_ratio() -> float:
	if not has_active_event() or active_duration <= 0.0:
		return 0.0
	return clampf(get_remaining_seconds() / active_duration, 0.0, 1.0)


func get_float_modifier(key: String, default_value: float) -> float:
	if not has_active_event() or not active_definition.has(key):
		return default_value
	return float(active_definition.get(key, default_value))


func get_bool_modifier(key: String, default_value: bool = false) -> bool:
	if not has_active_event() or not active_definition.has(key):
		return default_value
	return bool(active_definition.get(key, default_value))
