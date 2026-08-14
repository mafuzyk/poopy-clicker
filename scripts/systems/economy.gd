extends RefCounted

const GameState = preload("res://scripts/core/game_state.gd")

var game_state: GameState


func _init(state: GameState) -> void:
	game_state = state


func get_click_value(event_mult: float = 1.0) -> int:
	# Canônico: base = int(2^level * prestige_click * collection_money);
	# perk e event e synergy truncam juntos.
	var base: int = int(float(1 << game_state.click_level) * game_state.get_prestige_bonus_click() * game_state.get_collection_money_bonus())
	var perk_mult: float = 1.0 + float(game_state.get_perk_level("economy_click")) * 0.05
	return int(float(base) * perk_mult * event_mult * game_state.get_synergy_click_mult())


func get_next_click_value() -> int:
	return 1 << (game_state.click_level + 1)


func get_auto_value(event_mult: float = 1.0) -> int:
	if game_state.auto_level == 0:
		return 0
	var base: int = 1 << (game_state.auto_level - 1)
	if game_state.sneaky_profit_bought:
		base = int(float(base) * 1.25)
	base = int(float(base) * game_state.get_prestige_bonus_auto() * game_state.get_collection_money_bonus())
	var perk_mult: float = 1.0 + float(game_state.get_perk_level("economy_auto")) * 0.05
	return int(float(base) * perk_mult * event_mult * game_state.get_synergy_auto_mult())


func get_next_auto_value() -> int:
	return 1 << game_state.auto_level


func get_click_upgrade_cost() -> int:
	return 200 * (1 << game_state.click_level)


func get_auto_upgrade_cost() -> int:
	return 500 * (1 << game_state.auto_level)