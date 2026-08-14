extends RefCounted

const GameState = preload("res://scripts/core/game_state.gd")

var game_state: GameState


func _init(state: GameState) -> void:
	game_state = state


func get_click_value(event_mult: float = 1.0) -> int:
	# Canônico: base = int(2^level * prestige_click); event trunca dentro.
	var base: int = int(float(1 << game_state.click_level) * game_state.get_prestige_bonus_click())
	return int(float(base) * event_mult)


func get_next_click_value() -> int:
	return 1 << (game_state.click_level + 1)


func get_auto_value(event_mult: float = 1.0) -> int:
	if game_state.auto_level == 0:
		return 0
	var base: int = 1 << (game_state.auto_level - 1)
	if game_state.sneaky_profit_bought:
		base = int(float(base) * 1.25)
	base = int(float(base) * game_state.get_prestige_bonus_auto())
	return int(float(base) * event_mult)


func get_next_auto_value() -> int:
	return 1 << game_state.auto_level


func get_click_upgrade_cost() -> int:
	return 200 * (1 << game_state.click_level)


func get_auto_upgrade_cost() -> int:
	return 500 * (1 << game_state.auto_level)