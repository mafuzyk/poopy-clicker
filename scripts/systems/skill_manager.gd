extends Node

const GameState = preload("res://scripts/core/game_state.gd")

signal skill_used(key: String)

const COOLDOWNS := {"cleanse": 60.0, "frenzy": 90.0, "shield": 75.0, "coinburst": 120.0}
const FRENZY_DURATION := 8.0
const SHIELD_DURATION := 10.0
const COINBURST_DURATION := 12.0

var game_state: GameState
var goober_manager: Node
var event_manager: Node

var _cooldown: Dictionary = {}
var _frenzy_remaining := 0.0
var _shield_remaining := 0.0
var _coinburst_remaining := 0.0


func setup(state: GameState) -> void:
	game_state = state
	for key in COOLDOWNS:
		_cooldown[key] = 0.0


func _process(delta: float) -> void:
	for key in _cooldown:
		_cooldown[key] = maxf(0.0, float(_cooldown[key]) - delta)
	_frenzy_remaining = maxf(0.0, _frenzy_remaining - delta)
	_coinburst_remaining = maxf(0.0, _coinburst_remaining - delta)
	if _shield_remaining > 0.0:
		_shield_remaining = maxf(0.0, _shield_remaining - delta)
		if _shield_remaining <= 0.0 and event_manager != null:
			event_manager.triggers_blocked = false
	game_state.frenzy_mult = 2.0 if _frenzy_remaining > 0.0 else 1.0
	game_state.coinburst_mult = 3.0 if _coinburst_remaining > 0.0 else 1.0


func is_bought(key: String) -> bool:
	return game_state.is_secret_upgrade_bought(key)


func is_on_cooldown(key: String) -> bool:
	return float(_cooldown.get(key, 0.0)) > 0.0


func get_cooldown_remaining(key: String) -> float:
	return float(_cooldown.get(key, 0.0))


func can_use(key: String) -> bool:
	return is_bought(key) and not is_on_cooldown(key)


func use_skill(key: String) -> bool:
	if not can_use(key):
		return false
	match key:
		"cleanse":
			if goober_manager != null and goober_manager.has_method("cleanse_goobers"):
				goober_manager.cleanse_goobers()
		"frenzy":
			_frenzy_remaining = FRENZY_DURATION
			game_state.frenzy_mult = 2.0
		"shield":
			if event_manager != null:
				event_manager.end_event()
				event_manager.triggers_blocked = true
			_shield_remaining = SHIELD_DURATION
		"coinburst":
			_coinburst_remaining = COINBURST_DURATION
			game_state.coinburst_mult = 3.0
	_cooldown[key] = COOLDOWNS[key]
	skill_used.emit(key)
	return true
