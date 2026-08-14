extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")

var failures := 0
var checks := 0
var state: GameState
var combo: ComboManager


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _ready() -> void:
	state = GameState.new()
	combo = ComboManager.new()
	combo.setup(state)
	add_child(combo)
	_test_decay_and_restart()


func _test_decay_and_restart() -> void:
	combo.register_manual_click()
	combo.register_manual_click()
	combo.register_manual_click()
	check(state.combo_count == 3, "3 cliques -> combo 3")

	await get_tree().create_timer(1.0).timeout
	combo.register_manual_click()
	check(state.combo_count == 4, "click apos 1.0s mantem combo (4)")

	await get_tree().create_timer(0.8).timeout
	check(state.combo_count == 4, "0.8s apos 2o click: combo NAO resetou (4)")
	check(is_equal_approx(state.combo_multiplier, 1.20), "multiplier segue 1.20 (combo 4)")

	await get_tree().create_timer(1.1).timeout
	check(state.combo_count == 0, "decay apos ~1.9s do ultimo click: combo 0")
	check(is_equal_approx(state.combo_multiplier, 1.0), "multiplier volta 1.0 apos decay")
	check(state.get_highest_combo() == 4, "highest_combo preservado apos decay")

	combo.register_manual_click(0.9)
	check(state.combo_count == 1, "register_manual_click com grace extra incrementa")
	await get_tree().create_timer(2.0).timeout
	check(state.combo_count == 1, "decay 1.8+0.9=2.7s: combo ainda ativo em 2.0s")
	await get_tree().create_timer(0.9).timeout
	check(state.combo_count == 0, "decay completo apos ~2.9s com grace")

	if failures == 0:
		print("COMBO TIME TEST PASS: %d checks" % checks)
	else:
		printerr("COMBO TIME TEST FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)