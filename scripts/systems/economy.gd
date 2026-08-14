extends RefCounted

const GameState = preload("res://scripts/core/game_state.gd")

var game_state: GameState


func _init(state: GameState) -> void:
	game_state = state


func get_click_value() -> int:
	return 1 << game_state.click_level


func get_next_click_value() -> int:
	return 1 << (game_state.click_level + 1)


func get_auto_value() -> int:
	if game_state.auto_level == 0:
		return 0
	var base: int = 1 << (game_state.auto_level - 1)
	if game_state.sneaky_profit_bought:
		base = int(base * 1.25)
	return base


func get_next_auto_value() -> int:
	return 1 << game_state.auto_level


func get_click_upgrade_cost() -> int:
	return 200 * (1 << game_state.click_level)


func get_auto_upgrade_cost() -> int:
	return 500 * (1 << game_state.auto_level)