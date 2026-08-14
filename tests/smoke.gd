extends SceneTree

# Smoke test headless para o slice fix/core-regressions-fidelity.
# Uso: godot --headless --path . --script res://tests/smoke.gd --quit-after 600

const GameState = preload("res://scripts/core/game_state.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")
const Goober = preload("res://scripts/goobers/goober.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")

var failures := 0
var checks := 0


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _initialize() -> void:
	_test_stats_money()
	_test_heavy_panic_formulas()
	_test_catalog_push_coverage()
	_test_save_load_v2()

	if failures == 0:
		print("SMOKE PASS: %d checks" % checks)
	else:
		printerr("SMOKE FAIL: %d/%d checks falharam" % [failures, checks])
	quit(failures)


func _test_stats_money() -> void:
	var state := GameState.new()
	state.add_money(100)
	state.add_money(250)
	state.set_money(0)
	check(state.money == 0, "set_money zera money")
	check(state.lifetime_money == 350, "lifetime_money acumula 350")
	check(state.get_money_earned_total() == 350, "money_earned acumula 350 (persistente, nao zera no reset)")


func _test_heavy_panic_formulas() -> void:
	var state := GameState.new()
	var data := {
		"hp": 1, "push_normal": 6.0, "push_panic": 28.0,
		"speed_min": 1.0, "speed_max": 2.0, "scale": 1.0, "color": "ffffff",
	}
	var goober := Goober.new()
	goober.setup(null, 86.0, "normal", data, state)

	check(is_equal_approx(goober.get_effective_normal_push(), 6.0), "normal push base 6")
	check(is_equal_approx(goober.get_effective_panic_push(), 28.0), "panic push base 28")

	state.heavy_button_bought = true
	check(is_equal_approx(goober.get_effective_normal_push(), 3.0), "Heavy Button: 6 -> 3")
	state.heavy_button_bought = false

	state.panic_shield_bought = true
	check(is_equal_approx(goober.get_effective_panic_push(), 18.0), "Panic Shield: 28 -> 18")

	var tiny_data := data.duplicate()
	tiny_data["push_normal"] = 4.0
	tiny_data["push_panic"] = 22.0
	var tiny := Goober.new()
	tiny.setup(null, 86.0, "tiny", tiny_data, state)
	check(tiny.get_effective_normal_push() < goober.get_effective_normal_push(), "tiny push < normal push")
	check(is_equal_approx(tiny.get_effective_panic_push(), 12.0), "Panic Shield min: tiny 22 -> 12")


func _test_catalog_push_coverage() -> void:
	var catalog := GooberCatalog.new()
	var state := GameState.new()
	for id: String in catalog.get_enabled_ids():
		var data := catalog.get_type(id)
		var goober := Goober.new()
		goober.setup(null, 86.0, id, data, state)
		check(goober.get_current_push_force() >= 1.0, "push valido para %s (%.1f)" % [id, goober.get_current_push_force()])


func _test_save_load_v2() -> void:
	var state := GameState.new()
	state.add_money(500)
	state.click_level = 3
	state.stats["money_earned"] = 1234

	var save_manager := SaveManager.new()
	save_manager.setup(state)
	save_manager.set_save_path_for_test("user://test_save.json")
	save_manager.save()

	var loaded := GameState.new()
	var loader := SaveManager.new()
	loader.setup(loaded)
	loader.set_save_path_for_test("user://test_save.json")
	check(loader.load(), "load v2 ok")
	check(loaded.get_money_earned_total() == 1234, "money_earned roundtrip")
	check(loaded.click_level == 3, "click_level roundtrip")

	var legacy := {
		"save_version": 1,
		"money": 99,
		"lifetime_money": 777,
		"click_level": 1,
		"auto_level": 0,
	}
	var legacy_save: String = JSON.stringify(legacy)
	var legacy_file := FileAccess.open("user://test_legacy.json", FileAccess.WRITE)
	legacy_file.store_string(legacy_save)
	legacy_file.close()
	var legacy_state := GameState.new()
	var legacy_loader := SaveManager.new()
	legacy_loader.setup(legacy_state)
	legacy_loader.set_save_path_for_test("user://test_legacy.json")
	check(legacy_loader.load(), "load v1 ok")
	check(legacy_state.get_money_earned_total() == 777, "migration v1: money_earned <- lifetime_money")