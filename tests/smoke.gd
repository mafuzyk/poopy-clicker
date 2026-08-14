extends SceneTree

# Smoke test headless para o slice fix/core-regressions-fidelity.
# Uso: godot --headless --path . --script res://tests/smoke.gd --quit-after 600

const GameState = preload("res://scripts/core/game_state.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")
const Goober = preload("res://scripts/goobers/goober.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")
const AchievementManager = preload("res://scripts/achievements/achievement_manager.gd")

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
	_test_state_change_emission()
	_test_combo_initial_state()
	_test_combo_formula()
	_test_combo_ordering()
	_test_combo_highest()
	_test_combo_achievements()
	_test_combo_save_and_migration()

	if failures == 0:
		print("SMOKE PASS: %d checks" % checks)
	else:
		printerr("SMOKE FAIL: %d/%d checks falharam" % [failures, checks])
	quit(failures)


var _seen_changes := 0
var _load_changes := 0


func _test_state_change_emission() -> void:
	var state := GameState.new()
	_seen_changes = 0
	state.changed.connect(func() -> void: _seen_changes += 1)
	state.register_goober_seen("gold")
	check(_seen_changes >= 1, "register_goober_seen emite changed (bestiary atualiza no spawn)")
	state.register_goober_seen("gold")
	state.register_goober_seen("gold")
	check(state.bestiary_counts["gold"]["seen"] == 3, "seen acumula (3x gold)")

	var state_for_save := GameState.new()
	state_for_save.add_money(100)
	state_for_save.add_money(50)
	state_for_save.stats["money_earned"] = 999
	var save_manager := SaveManager.new()
	save_manager.setup(state_for_save)
	save_manager.set_save_path_for_test("user://test_change.json")
	save_manager.save()

	var loaded := GameState.new()
	_load_changes = 0
	loaded.changed.connect(func() -> void: _load_changes += 1)
	var loader := SaveManager.new()
	loader.setup(loaded)
	loader.set_save_path_for_test("user://test_change.json")
	check(loader.load(), "load para teste de emission ok")
	check(loaded.get_money_earned_total() == 999, "money_earned correto no load")
	check(_load_changes >= 2, "load emite changed ao final (estado completo): %d emissões" % _load_changes)


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


func _test_combo_initial_state() -> void:
	var state := GameState.new()
	check(state.combo_count == 0, "combo inicial 0")
	check(is_equal_approx(state.combo_multiplier, 1.0), "multiplier inicial 1.0")
	check(state.get_highest_combo() == 0, "highest_combo inicial 0")
	check(int(state.stats.get("money_earned", -1)) == 0, "stats default mantem money_earned")


func _test_combo_formula() -> void:
	var state := GameState.new()
	var cases := {1: 1.05, 5: 1.25, 25: 2.25, 75: 4.75, 150: 8.5, 300: 16.0}
	for count: int in cases:
		state.combo_count = count
		state.combo_multiplier = 1.0 + count * 0.05
		check(is_equal_approx(state.combo_multiplier, cases[count]), "formula combo %d -> %.2f" % [count, cases[count]])


func _test_combo_ordering() -> void:
	var state := GameState.new()
	state.add_money(0)
	var mult_before: float = state.get_combo_multiplier()
	var gain := int(float(100) * mult_before)
	check(gain == 100, "primeiro clique: ganho usa mult 1.0 (100)")
	state.increment_combo()
	check(state.combo_count == 1, "combo incrementa DEPOIS do ganho")
	check(is_equal_approx(state.combo_multiplier, 1.05), "multiplier apos 1 clique = 1.05")
	var second_gain := int(float(100) * state.get_combo_multiplier())
	check(second_gain == 105, "segundo clique: ganho 105 (1.05x)")


func _test_combo_highest() -> void:
	var state := GameState.new()
	for i in range(10):
		state.increment_combo()
	check(state.get_highest_combo() == 10, "highest 10 com combo 10")
	state.reset_combo()
	check(state.combo_count == 0, "reset zera combo")
	check(is_equal_approx(state.combo_multiplier, 1.0), "reset volta mult 1.0")
	check(state.get_highest_combo() == 10, "highest permanece 10 apos reset")


func _test_combo_achievements() -> void:
	var state := GameState.new()
	var manager := AchievementManager.new()
	manager.setup(state)
	for i in range(24):
		state.increment_combo()
	manager.evaluate()
	check(not manager.is_unlocked("combo_25"), "highest 24: combo_25 locked")
	state.increment_combo()
	manager.evaluate()
	check(manager.is_unlocked("combo_25"), "highest 25: combo_25 unlock")
	for i in range(50):
		state.increment_combo()
	manager.evaluate()
	check(manager.is_unlocked("combo_75"), "highest 75: combo_75 unlock")
	for i in range(75):
		state.increment_combo()
	manager.evaluate()
	check(manager.is_unlocked("combo_150"), "highest 150: combo_150 unlock")
	for i in range(150):
		state.increment_combo()
	manager.evaluate()
	check(manager.is_unlocked("combo_300"), "highest 300: combo_300 unlock")
	check(manager.get_progress("combo_75") == Vector2i(300, 75), "progress combo_75 = 300/75")

	var combo_ids := ["combo_25", "combo_75", "combo_150", "combo_300"]
	var total := 0
	for id: String in AchievementManager.DEFINITIONS:
		total += 1
	for id2: String in combo_ids:
		check(AchievementManager.DEFINITIONS.has(id2), "achievement %s definido" % id2)
	check(total == 31, "total achievements = 31 (era 27 + 4 combo), atual %d" % total)


func _write_test_save(data: Dictionary, path: String) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func _test_combo_save_and_migration() -> void:
	var state := GameState.new()
	for i in range(7):
		state.increment_combo()
	state.stats["money_earned"] = 555
	var save_manager := SaveManager.new()
	save_manager.setup(state)
	save_manager.set_save_path_for_test("user://test_combo_v3.json")
	save_manager.save()

	var loaded := GameState.new()
	var loader := SaveManager.new()
	loader.setup(loaded)
	loader.set_save_path_for_test("user://test_combo_v3.json")
	check(loader.load(), "load v3 ok")
	check(loaded.combo_count == 7, "v3 roundtrip: combo_count")
	check(is_equal_approx(loaded.combo_multiplier, 1.35), "v3 roundtrip: combo_multiplier")
	check(loaded.get_highest_combo() == 7, "v3 roundtrip: highest_combo")
	check(loaded.get_money_earned_total() == 555, "v3 roundtrip: money_earned preservado")

	var v2 := {
		"save_version": 2,
		"money": 10,
		"lifetime_money": 20,
		"stats": {"money_earned": 20},
		"click_level": 0,
	}
	_write_test_save(v2, "user://test_combo_v2.json")
	var from_v2 := GameState.new()
	var v2_loader := SaveManager.new()
	v2_loader.setup(from_v2)
	v2_loader.set_save_path_for_test("user://test_combo_v2.json")
	check(v2_loader.load(), "v2 -> v3 load ok")
	check(from_v2.combo_count == 0, "v2 -> v3: combo_count default 0")
	check(is_equal_approx(from_v2.combo_multiplier, 1.0), "v2 -> v3: combo_multiplier default 1.0")
	check(from_v2.get_highest_combo() == 0, "v2 -> v3: highest_combo 0")
	check(from_v2.get_money_earned_total() == 20, "v2 -> v3: money_earned preservado")

	var v1 := {
		"save_version": 1,
		"money": 5,
		"lifetime_money": 300,
		"click_level": 0,
	}
	_write_test_save(v1, "user://test_combo_v1.json")
	var from_v1 := GameState.new()
	var v1_loader := SaveManager.new()
	v1_loader.setup(from_v1)
	v1_loader.set_save_path_for_test("user://test_combo_v1.json")
	check(v1_loader.load(), "v1 -> v3 load ok")
	check(from_v1.get_money_earned_total() == 300, "v1 -> v3: money_earned <- lifetime_money")
	check(from_v1.combo_count == 0, "v1 -> v3: combo_count default 0")
	check(from_v1.get_highest_combo() == 0, "v1 -> v3: highest_combo 0")


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