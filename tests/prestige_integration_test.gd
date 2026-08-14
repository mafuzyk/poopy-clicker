extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")

var failures := 0
var checks := 0


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _ready() -> void:
	_run()


func _run() -> void:
	var main: Node = load("res://main.tscn").instantiate()
	add_child(main)
	await get_tree().process_frame

	var state = main.get("game_state")
	var save_manager = main.get("save_manager")
	var panel_manager = main.get("panel_manager")
	var event_manager = main.get("event_manager")
	var combo_manager = main.get("combo_manager")
	var goober_manager = main.get("goober_manager")
	var prestige_panel = main.get("prestige_panel")
	var click_button = main.get("click_button")

	save_manager.set_save_path_for_test("user://test_prestige_integration.json")

	check(prestige_panel != null, "prestige_panel existe")

	state.money = 1000
	panel_manager.open_surface("prestige")
	await get_tree().process_frame
	prestige_panel.refresh()
	check(prestige_panel.prestige_button.disabled, "money < cost: botao disabled")

	state.money = 900000
	state.lifetime_money = 640000
	state.click_level = 5
	state.auto_level = 3
	state.goober_coins = 12
	state.secret_shop_unlocked = true
	goober_manager.force_spawn("gold")
	goober_manager.force_spawn("gold")
	combo_manager.register_manual_click()
	event_manager.duration_override = 30.0
	event_manager.force_start_event("calm")

	prestige_panel.refresh()
	check(not prestige_panel.prestige_button.disabled, "money >= cost: botao enabled")

	prestige_panel.prestige_button.pressed.emit()
	await get_tree().process_frame
	check(prestige_panel.confirm_box.visible, "1o press mostra confirmacao")
	check(state.prestige_level == 0, "1o press NAO prestigia")

	prestige_panel.cancel_button.pressed.emit()
	await get_tree().process_frame
	check(not prestige_panel.confirm_box.visible, "cancelar esconde confirmacao")
	check(state.money == 900000, "cancelar nao muda estado")

	prestige_panel.prestige_button.pressed.emit()
	await get_tree().process_frame
	prestige_panel.confirm_button.pressed.emit()
	await get_tree().process_frame

	check(state.prestige_level == 1, "P1 apos confirmar")
	check(state.poopy_essence == 6, "+6 essence (sqrt(640000)/120)")
	check(state.money == 0 and state.lifetime_money == 0, "run resetada (money/lifetime)")
	check(state.click_level == 0 and state.auto_level == 0, "upgrades reset")
	check(state.goober_coins == 0 and not state.secret_shop_unlocked, "gc/shop reset")
	check(state.combo_count == 0 and is_equal_approx(state.combo_multiplier, 1.0), "combo reset")
	check(combo_manager.decay_timer.is_stopped(), "decay timer parado")
	check(goober_manager.goobers.is_empty(), "goobers imediatamente vazios")
	check(event_manager.get_active_event_id() == "calm", "evento calm sobrevive ao prestige")
	check(not panel_manager.is_open(), "painel fechado")
	check(not click_button.disabled, "gameplay restaurado (clique habilitado)")

	var loaded := GameState.new()
	var loader := SaveManager.new()
	loader.setup(loaded)
	loader.set_save_path_for_test("user://test_prestige_integration.json")
	check(loader.load(), "save roundtrip load")
	check(loaded.prestige_level == 1 and loaded.poopy_essence == 6, "save roundtrip P1 + 6 essence")

	await get_tree().create_timer(0.5).timeout
	check(goober_manager.goobers.size() >= 1, "spawns naturais repopulam apos prestige")

	_finish()


func _finish() -> void:
	if failures == 0:
		print("PRESTIGE INTEGRATION TEST PASS: %d checks" % checks)
	else:
		printerr("PRESTIGE INTEGRATION TEST FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
