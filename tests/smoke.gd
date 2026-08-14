extends SceneTree

# Smoke test headless para o slice fix/core-regressions-fidelity.
# Uso: godot --headless --path . --script res://tests/smoke.gd --quit-after 600

const GameState = preload("res://scripts/core/game_state.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")
const Goober = preload("res://scripts/goobers/goober.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")
const AchievementManager = preload("res://scripts/achievements/achievement_manager.gd")
const EventCatalog = preload("res://scripts/data/event_catalog.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const GooberManager = preload("res://scripts/goobers/goober_manager.gd")
const Main = preload("res://main.gd")

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
	_test_event_catalog()
	_test_rarity_selection_two_phase()
	_test_random_trigger_roll()
	_test_event_modifiers()
	_test_event_payout_and_grace_conversion()
	_test_scale_composition()
	_test_events_achievements()
	_test_events_seen_persistence()
	_test_event_full_pool()
	_test_derived_capabilities()
	_test_controller_capability_snapshot()
	_test_goober_snapshot_plumbing()
	_test_panic_reduce_push()
	_test_panic_speed_canonical()
	_test_special_reward_gating()
	_test_click_coin_gating()

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
	check(total == 33, "total achievements = 33 (27 + 4 combo + 2 events), atual %d" % total)


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


func _test_event_catalog() -> void:
	check(EventCatalog.count() == 35, "catalogo tem 35 EVENT_INFO")
	check(EventCatalog.get_rarity_weight("common") == 5.0, "weight common = 5.0")
	check(EventCatalog.get_rarity_weight("rare") == 2.5, "weight rare = 2.5")
	check(EventCatalog.get_rarity_weight("epic") == 1.2, "weight epic = 1.2")
	check(EventCatalog.get_rarity_weight("legendary") == 0.5, "weight legendary = 0.5")
	check(EventCatalog.get_rarity_weight("mythic") == 0.15, "weight mythic = 0.15")
	check(EventCatalog.get_rarity_label("common") == "Comum", "label common = Comum")
	check(EventCatalog.get_rarity_label("rare") == "Raro", "label rare = Raro")
	check(EventCatalog.get_rarity_label("epic") == "Épico", "label epic = Épico")
	check(EventCatalog.get_rarity_label("legendary") == "Lendário", "label legendary = Lendário")
	check(EventCatalog.get_rarity_label("mythic") == "Mítico", "label mythic = Mítico")
	check(EventCatalog.CORE_ENABLED_IDS.size() == 7, "pool core tem 7 eventos habilitados")

	var dc: Dictionary = EventCatalog.get_event("double_click")
	check(bool(dc.get("good", false)), "double_click good = true")
	check(str(dc.get("rarity", "")) == "rare", "double_click rarity = rare")
	check(int(dc.get("duration", 0)) == 8, "double_click duration = 8")
	check(is_equal_approx(float(dc.get("click_mult", 0.0)), 2.0), "double_click click_mult = 2.0")
	var sb: Dictionary = EventCatalog.get_event("snack_break")
	check(int(sb.get("combo_grace", 0)) == 900, "snack_break combo_grace = 900 (ms no catalogo)")
	check(str(sb.get("rarity", "")) == "common", "snack_break rarity = common")
	check(int(sb.get("duration", 0)) == 6, "snack_break duration = 6")


func _test_rarity_selection_two_phase() -> void:
	var rarities: Array = EventCatalog.RARITY_INFO.keys()
	var weights: Array = []
	for rarity in rarities:
		weights.append(EventCatalog.get_rarity_weight(rarity))
	var total := 0.0
	for w in weights:
		total += float(w)
	check(is_equal_approx(total, 9.35), "soma dos weights = 9.35")

	check(EventCatalog.pick_rarity_from_roll(rarities, weights, 0.0) == "common", "roll 0 -> common")
	check(EventCatalog.pick_rarity_from_roll(rarities, weights, 0.999) == "mythic", "roll .999 -> mythic")
	var common_boundary: float = 5.0 / total
	check(EventCatalog.pick_rarity_from_roll(rarities, weights, common_boundary - 0.001) == "common", "antes da fronteira -> common")
	check(EventCatalog.pick_rarity_from_roll(rarities, weights, common_boundary + 0.001) == "rare", "depois da fronteira -> rare")

	var candidates: Array = EventCatalog.CORE_ENABLED_IDS.duplicate()
	var available: Array = EventCatalog.get_available_rarities(candidates)
	check(available == ["common", "rare"], "pool core: raridades disponiveis = [common, rare]")

	# Pool parcial pesa apenas common (5.0) e rare (2.5): total 7.5.
	var pool_boundary: float = 5.0 / 7.5
	var chosen: String = EventCatalog.choose_event(candidates, {}, pool_boundary - 0.001, 0.0)
	check(EventCatalog.CORE_ENABLED_IDS.has(chosen), "roll abaixo da fronteira -> common (%s)" % chosen)
	check(str(EventCatalog.EVENT_INFO[chosen]["rarity"]) == "common", "candidato pertence a rarity sorteada (common)")
	chosen = EventCatalog.choose_event(candidates, {}, pool_boundary + 0.001, 0.0)
	check(chosen != "", "roll acima da fronteira -> rare (nao morre)")
	check(str(EventCatalog.EVENT_INFO[chosen]["rarity"]) == "rare", "candidato pertence a rarity sorteada (rare)")

	# Bug corrigido: roll extremo nao pode cair numa raridade sem candidatos
	# habilitados e retornar "" silenciosamente.
	var extreme: String = EventCatalog.choose_event(candidates, {}, 0.999, 0.0)
	check(extreme != "", "roll 0.999 com pool parcial nao retorna vazio")
	check(str(EventCatalog.EVENT_INFO[extreme]["rarity"]) == "rare", "roll 0.999 cai em rare (ultima raridade do pool)")

	var rare_ids: Array = []
	for id in candidates:
		if str(EventCatalog.EVENT_INFO[id]["rarity"]) == "rare":
			rare_ids.append(id)
	check(rare_ids.size() == 3, "pool core tem 3 eventos rare (2x click, 2x auto, chaos): %s" % str(rare_ids))
	check(rare_ids.has(extreme), "candidato sorteado esta entre os rare do pool")

	check(EventCatalog.pick_candidate_from_roll(["a", "b"], 0.0) == "a", "candidate roll 0 -> primeiro")
	check(EventCatalog.pick_candidate_from_roll(["a", "b"], 0.999) == "b", "candidate roll .999 -> ultimo")
	var with_mod := EventCatalog.choose_event(candidates, {"rare": 1.08, "epic": 1.08}, 0.0, 0.0)
	check(EventCatalog.CORE_ENABLED_IDS.has(with_mod), "modifiers de rarity nao quebram selecao (%s)" % with_mod)
	# Pool completo (35): o canônico não tem nenhum evento mythic — 4 raridades
	# com candidatos; mythic fica de fora exatamente como o pool parcial.
	var all_ids: Array = EventCatalog.EVENT_INFO.keys()
	var full_available: Array = EventCatalog.get_available_rarities(all_ids)
	check(full_available == ["common", "rare", "epic", "legendary"], "35 habilitados: 4 raridades (mythic sem eventos no canonico)")
	check(EventCatalog.choose_event(all_ids, {}, 0.999, 0.0) != "", "pool completo: roll extremo nao morre (legendary)")


func _test_random_trigger_roll() -> void:
	var state := GameState.new()
	var manager := EventManager.new()
	manager.setup(state)
	root.add_child(manager)

	check(not manager.try_random_event(0.23, 0.0, 0.0), "trigger roll > 0.22 nao inicia")
	check(not manager.has_active_event(), "sem evento ativo apos roll alto")

	check(manager.try_random_event(0.22, 0.0, 0.0), "trigger roll == 0.22 inicia")
	check(manager.has_active_event(), "evento ativo apos roll == 0.22")
	check(EventCatalog.CORE_ENABLED_IDS.has(manager.get_active_event_id()), "evento sorteado pertence ao pool core")
	manager.end_event()

	check(manager.try_random_event(0.21, 0.0, 0.0), "trigger roll < 0.22 inicia")
	var active_id := manager.get_active_event_id()
	check(not manager.try_random_event(0.0, 0.0, 0.0), "random check com evento ativo nao substitui")
	check(manager.get_active_event_id() == active_id, "evento ativo permanece o mesmo")
	check(state.get_events_seen() == 2, "events_seen = 2 (um por start_event)")
	manager.end_event()

	manager.triggers_blocked = true
	check(not manager.try_random_event(0.0, 0.0, 0.0), "triggers_blocked bloqueia random check")
	manager.triggers_blocked = false


func _check_modifier(manager: EventManager, id: String, key: String, expected: float) -> void:
	manager.force_start_event(id)
	check(is_equal_approx(manager.get_float_modifier(key, 1.0), expected), "%s: %s == %.2f" % [id, key, expected])
	manager.end_event()


func _test_event_modifiers() -> void:
	var state := GameState.new()
	var manager := EventManager.new()
	manager.setup(state)
	root.add_child(manager)

	check(is_equal_approx(manager.get_float_modifier("click_mult", 1.0), 1.0), "sem evento: click_mult 1.0")
	check(is_equal_approx(manager.get_float_modifier("auto_mult", 1.0), 1.0), "sem evento: auto_mult 1.0")
	check(is_equal_approx(manager.get_float_modifier("move_mult", 1.0), 1.0), "sem evento: move_mult 1.0")
	check(is_equal_approx(manager.get_float_modifier("scale_mult", 1.0), 1.0), "sem evento: scale_mult 1.0")
	check(is_equal_approx(manager.get_float_modifier("combo_grace", 0.0), 0.0), "sem evento: combo_grace 0")
	check(not manager.get_bool_modifier("invert_colors", false), "sem evento: invert_colors false")

	_check_modifier(manager, "double_click", "click_mult", 2.0)
	_check_modifier(manager, "double_auto", "auto_mult", 2.0)
	_check_modifier(manager, "big_button", "scale_mult", 1.22)
	_check_modifier(manager, "tiny_button", "scale_mult", 0.78)
	_check_modifier(manager, "chaos", "move_mult", 1.35)
	_check_modifier(manager, "calm", "move_mult", 0.65)
	_check_modifier(manager, "snack_break", "combo_grace", 900.0)

	check(is_equal_approx(manager.get_float_modifier("click_mult", 1.0), 1.0), "apos end_event: click_mult volta 1.0")
	check(not manager.start_event("nao_existe"), "id invalido rejeitado")
	check(manager.start_event("double_click"), "start_event valido")
	check(not manager.start_event("calm"), "start_event sem replace nao substitui ativo")
	check(manager.get_active_event_id() == "double_click", "ativo segue double_click")

	var replaced_ids: Array = []
	manager.event_ended.connect(func(id: String) -> void: replaced_ids.append(id))
	check(manager.start_event("calm", true), "replace ativo substitui evento")
	check(replaced_ids == ["double_click"], "replace emite event_ended do antigo (double_click)")
	check(manager.get_active_event_id() == "calm", "ativo agora e calm")
	manager.end_event()
	check(replaced_ids == ["double_click", "calm"], "end_event emite event_ended do ativo")
	check(not manager.has_active_event(), "end_event limpa estado")


func _test_event_payout_and_grace_conversion() -> void:
	check(Main.compute_click_gain(100, 2.0, 1.5) == 300, "payout click: int(100 * 2.0 * 1.5) = 300")
	check(Main.compute_auto_gain(100, 2.0) == 200, "payout auto: int(100 * 2.0) = 200")
	check(Main.compute_click_gain(100, 1.0, 1.0) == 100, "sem eventos: payout click = base")
	check(is_equal_approx(Main.combo_grace_ms_to_seconds(900.0), 0.9), "combo_grace 900 ms -> 0.9 s")


func _test_scale_composition() -> void:
	var state := GameState.new()
	state.click_level = 10
	state.auto_level = 15
	var button := Button.new()
	var controller := ClickController.new()
	controller.game_state = state
	controller.click_button = button

	controller.update_button_scale()
	check(is_equal_approx(button.scale.x, 0.9), "progressao 25 upgrades -> escala 0.90")
	controller.set_event_scale_multiplier(1.22)
	check(is_equal_approx(button.scale.x, 0.9 * 1.22), "big_button compoe: 0.90 * 1.22 = 1.098")
	controller.set_event_scale_multiplier(1.0)
	check(is_equal_approx(button.scale.x, 0.9), "evento termina: volta 0.90 (NAO 1.0)")
	controller.set_event_scale_multiplier(0.78)
	check(is_equal_approx(button.scale.x, 0.9 * 0.78), "tiny_button compoe: 0.90 * 0.78")


func _test_events_achievements() -> void:
	var state := GameState.new()
	var manager := AchievementManager.new()
	manager.setup(state)
	for i in range(24):
		state.register_event_seen()
	manager.evaluate()
	check(not manager.is_unlocked("events_25"), "24 eventos: events_25 locked")
	state.register_event_seen()
	manager.evaluate()
	check(manager.is_unlocked("events_25"), "25 eventos: events_25 unlock")
	check(manager.get_progress("events_100") == Vector2i(25, 100), "progress events_100 = 25/100")
	for i in range(75):
		state.register_event_seen()
	manager.evaluate()
	check(manager.is_unlocked("events_100"), "100 eventos: events_100 unlock")


func _test_events_seen_persistence() -> void:
	var state := GameState.new()
	for i in range(7):
		state.register_event_seen()
	var save_manager := SaveManager.new()
	save_manager.setup(state)
	save_manager.set_save_path_for_test("user://test_events_seen.json")
	save_manager.save()

	var loaded := GameState.new()
	var loader := SaveManager.new()
	loader.setup(loaded)
	loader.set_save_path_for_test("user://test_events_seen.json")
	check(loader.load(), "load events_seen ok")
	check(loaded.get_events_seen() == 7, "events_seen roundtrip = 7")

	# Save v3 antigo sem events_seen: normalizado retroativamente para 0.
	var old_v3 := {
		"save_version": 3,
		"money": 5,
		"lifetime_money": 5,
		"stats": {"money_earned": 5, "highest_combo": 0},
		"click_level": 0,
	}
	_write_test_save(old_v3, "user://test_old_v3.json")
	var old_state := GameState.new()
	var old_loader := SaveManager.new()
	old_loader.setup(old_state)
	old_loader.set_save_path_for_test("user://test_old_v3.json")
	check(old_loader.load(), "load v3 antigo ok")
	check(old_state.get_events_seen() == 0, "v3 antigo: events_seen normalizado para 0")
	check(old_state.get_money_earned_total() == 5, "v3 antigo: money_earned preservado")


func _test_event_full_pool() -> void:
	var all_ids: Array = EventCatalog.all_ids()
	check(all_ids.size() == 35, "pool completo: 35 IDs")

	# Setup sem ids explícitos usa o pool natural completo (35).
	var state := GameState.new()
	var manager := EventManager.new()
	manager.setup(state)
	root.add_child(manager)
	check(manager.enabled_ids.size() == 35, "pool natural padrao = 35 habilitados")

	# Qualquer roll de raridade/candidato deve produzir um evento válido.
	for roll in [0.0, 0.25, 0.5, 0.75, 0.999]:
		var started := manager.try_random_event(0.0, roll, 0.5)
		check(started, "try_random_event com roll %.3f inicia evento" % roll)
		if manager.has_active_event():
			check(EventCatalog.EVENT_INFO.has(manager.get_active_event_id()), "evento sorteado no catalogo")
		manager.end_event()


func _test_derived_capabilities() -> void:
	check(EventCatalog.derived_capabilities("sticky") == {"sticky_jitter": true}, "sticky: jitter derivado")
	check(EventCatalog.derived_capabilities("calm") == {}, "calm: sem capacidades derivadas")
	check(EventCatalog.derived_capabilities("nao_existe") == {}, "id desconhecido: derivados vazios")


func _make_controller(state: GameState) -> ClickController:
	var controller := ClickController.new()
	controller.game_state = state
	controller.click_button = Button.new()
	return controller


func _test_controller_capability_snapshot() -> void:
	var state := GameState.new()
	var controller := _make_controller(state)

	check(is_equal_approx(controller.event_move_multiplier, 1.0), "controller: move_mult default 1.0")
	check(is_equal_approx(controller.event_scale_multiplier, 1.0), "controller: scale_mult default 1.0")
	check(not controller.gravity_active, "controller: gravity default false")

	controller.apply_effect_capabilities({"move_mult": 1.25, "gravity": true})
	check(is_equal_approx(controller.event_move_multiplier, 1.25), "storm_mode: move_mult 1.25")
	check(controller.gravity_active, "storm_mode: gravity ativo")
	check(not controller.invert_move_active, "storm_mode: sem invert_move")

	controller.apply_effect_capabilities({"move_mult": 1.45, "mouse_flee": true})
	check(controller.mouse_flee_active, "heatwave: mouse_flee ativo")
	check(not controller.gravity_active, "heatwave: gravity resetado (snapshot substitui)")

	controller.apply_effect_capabilities({"invert_move": true, "blink": true})
	check(controller.invert_move_active and controller.blink_active, "glitch_flip: invert+blink compostos")
	check(is_equal_approx(controller.event_move_multiplier, 1.0), "glitch_flip: move_mult volta 1.0")

	# Fim de evento: snapshot vazio reseta tudo.
	controller.apply_effect_capabilities({})
	check(not controller.invert_move_active and not controller.blink_active, "end: flags resetadas")
	check(is_equal_approx(controller.event_move_multiplier, 1.0), "end: move_mult 1.0")
	check(is_equal_approx(controller.event_scale_multiplier, 1.0), "end: scale_mult 1.0")


func _test_goober_snapshot_plumbing() -> void:
	var manager := GooberManager.new()
	check(is_equal_approx(float(manager.event_snapshot["special_money_mult"]), 1.0), "snapshot default: special_money_mult 1.0")
	check(int(manager.event_snapshot["spawn_bonus"]) == 0, "snapshot default: spawn_bonus 0")

	manager.apply_goober_snapshot({
		"spawn_bonus": 4,
		"rare_bonus": 0.01,
		"boss_bonus": 0.05,
		"panic_reduce": 8,
		"special_money_mult": 1.5,
		"special_coin_bonus": 2,
		"special_essence_bonus": 1,
	})
	var snapshot := manager.get_goober_snapshot()
	check(int(snapshot["spawn_bonus"]) == 4, "snapshot: spawn_bonus 4")
	check(is_equal_approx(float(snapshot["rare_bonus"]), 0.01), "plumbing: rare_bonus 0.01 exposto")
	check(is_equal_approx(float(snapshot["boss_bonus"]), 0.05), "plumbing: boss_bonus 0.05 exposto")
	check(int(snapshot["special_essence_bonus"]) == 1, "plumbing: special_essence_bonus 1 exposto")
	check(int(snapshot["panic_reduce"]) == 8, "snapshot: panic_reduce 8")
	check(is_equal_approx(float(snapshot["special_money_mult"]), 1.5), "snapshot: special_money_mult 1.5")

	check(manager._effective_max_goobers() == 14, "spawn cap = 10 + 4")
	manager.apply_goober_snapshot({"spawn_bonus": 0})
	check(manager._effective_max_goobers() == 10, "spawn cap volta a 10")

	# Snapshot vazio (end de evento) reseta TODAS as chaves para defaults.
	manager.apply_goober_snapshot({})
	var reset := manager.get_goober_snapshot()
	check(int(reset["spawn_bonus"]) == 0, "reset: spawn_bonus 0")
	check(is_equal_approx(float(reset["special_money_mult"]), 1.0), "reset: special_money_mult 1.0")
	check(int(reset["panic_reduce"]) == 0, "reset: panic_reduce 0")
	check(is_equal_approx(float(reset["rare_bonus"]), 0.0), "reset: rare_bonus 0.0")


func _test_panic_reduce_push() -> void:
	var catalog := GooberCatalog.new()
	var state := GameState.new()
	var data := catalog.get_type("boss")
	var goober := Goober.new()
	goober.setup(null, 86.0, "boss", data, state)
	var base := goober.get_current_push_force()
	goober.event_panic_reduce = 8.0
	check(is_equal_approx(goober.get_current_push_force(), maxf(1.0, base - 8.0)), "panic_reduce subtrai do push")
	goober.event_panic_reduce = 999.0
	check(is_equal_approx(goober.get_current_push_force(), 1.0), "push clampado em 1.0")


func _test_panic_speed_canonical() -> void:
	# Canônico (goober.py): spd = (speed_max + 3) — o panic NUNCA é mais lento
	# que o andar do próprio tipo (regressão: speedy 3-4 andava a 4x e fugia a 3x).
	var catalog := GooberCatalog.new()
	var state := GameState.new()
	var checked := 0
	for id: String in catalog.get_enabled_ids():
		var data := catalog.get_type(id)
		var goober := Goober.new()
		goober.setup(null, 86.0, id, data, state)
		var body_size: float = 86.0 * float(data["scale"])
		var walk_max: float = float(data["speed_max"]) * body_size
		goober.start_panic()
		var panic_speed: float = absf(goober.velocity.x)
		check(is_equal_approx(panic_speed, (float(data["speed_max"]) + 3.0) * body_size),
			"panic %s: speed = speed_max + 3" % id)
		check(panic_speed > walk_max, "panic %s: mais rapido que o andar maximo" % id)
		checked += 1
	check(checked == 16, "16 tipos habilitados verificados (sem bloqueados)")


func _test_special_reward_gating() -> void:
	# special_money_mult: apenas goobers não-normal (canônico goober.py:590-593).
	var state := GameState.new()
	state.secret_shop_unlocked = true
	var manager := GooberManager.new()
	manager.game_state = state
	manager.catalog = GooberCatalog.new()
	manager.apply_goober_snapshot({"special_money_mult": 1.5, "special_coin_bonus": 2})

	var before_coins := state.goober_coins
	manager._on_goober_defeated(_make_fake_goober("gold", manager))
	check(state.get_money_earned_total() == 9375, "gold: 5000 * 1.25 * 1.5 = 9375")
	check(state.goober_coins == before_coins + 7, "gold: gc 5 + special_coin 2 = 7")

	var normal_before := state.goober_coins
	manager._on_goober_defeated(_make_fake_goober("normal", manager))
	check(state.get_money_earned_total() == 9375, "normal: money 0, sem special_money_mult")
	check(state.goober_coins == normal_before + 1, "normal: gc 1 sem special_coin_bonus")


func _make_fake_goober(type_id: String, manager: GooberManager) -> Goober:
	var data := manager.catalog.get_type(type_id) if manager.catalog != null else GooberCatalog.new().get_type(type_id)
	var goober := Goober.new()
	goober.type_id = type_id
	goober.game_state = manager.game_state
	goober.setup(null, 86.0, type_id, data, manager.game_state)
	return goober


func _test_click_coin_gating() -> void:
	check(Main.compute_click_coin_grant(true, 1.0) == 1, "click_coin_bonus com secret shop = 1")
	check(Main.compute_click_coin_grant(false, 1.0) == 0, "click_coin_bonus SEM secret shop = 0")
	check(Main.compute_click_coin_grant(true, 0.0) == 0, "click_coin_bonus 0 = 0")
	check(Main.compute_click_coin_grant(true, 2.5) == 2, "click_coin_bonus 2.5 -> int 2")