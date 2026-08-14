extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const Layout = preload("res://scripts/ui/layout.gd")

var failures := 0
var checks := 0

var button: Button
var state: GameState
var controller: ClickController


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _ready() -> void:
	_test_movement_capabilities()


func _test_movement_capabilities() -> void:
	button = Button.new()
	button.size = Layout.CLICK_BUTTON_SIZE
	add_child(button)
	state = GameState.new()
	controller = ClickController.new()
	controller.setup(button, state)
	add_child(controller)
	controller.center_button()
	var area: Rect2 = controller.get_play_area_rect()

	# gravity: step 28 -> drift_y = randint(-14,14) + 16 = [2, 30], sempre positivo.
	controller.gravity_active = true
	var y0: float = button.position.y
	controller.move_click_button_randomly()
	check(button.position.y > y0, "gravity: drift_y sempre para baixo")
	check(button.position.y - y0 >= 2.0, "gravity: deslocamento >= +2 px")

	# invert_move (com gravity): drift vira negativo (int(-drift*0.85)).
	controller.invert_move_active = true
	var y1: float = button.position.y
	controller.move_click_button_randomly()
	check(button.position.y < y1, "invert_move: drift invertido para cima")

	# edge rebound: colado na borda esquerda, drift nunca deixa sair.
	controller.gravity_active = false
	controller.invert_move_active = false
	button.position.x = area.position.x + 2.0
	for i in range(10):
		controller.move_click_button_randomly()
		check(button.position.x >= area.position.x - 0.01, "rebound: nunca atravessa a borda (x)")

	# Determinístico: na zona de 8 px da borda, o drift e sempre redirecionado
	# para dentro (randint >= 9 para step 28), entao uma jogada afasta da borda.
	button.position.x = area.position.x + 2.0
	var x_before: float = button.position.x
	controller.move_click_button_randomly()
	check(button.position.x > x_before, "rebound: drift redirecionado para dentro a partir da borda")

	# center_pull: lerp de 8% do deslocamento restante por tick.
	controller.apply_effect_capabilities({"center_pull": true})
	button.position = Vector2(area.position.x + 10.0, area.position.y + 10.0)
	var effective: Vector2 = button.size * button.scale
	var center := Vector2(
		area.position.x + (area.size.x - effective.x) / 2.0,
		area.position.y + (area.size.y - effective.y) / 2.0
	)
	var expected_x: float = button.position.x + int((center.x - button.position.x) * 0.08)
	var expected_y: float = button.position.y + int((center.y - button.position.y) * 0.08)
	controller._effect_tick()
	check(is_equal_approx(button.position.x, expected_x), "center_pull: 8%% do deslocamento (x)")
	check(is_equal_approx(button.position.y, expected_y), "center_pull: 8%% do deslocamento (y)")

	# orbit: angulo 0.12, raio 42, dentro da area.
	controller.apply_effect_capabilities({"orbit": true})
	controller._effect_tick()
	var orbit_expected := center + Vector2(cos(0.12) * 42.0, sin(0.12) * 42.0)
	check(button.position.distance_to(orbit_expected) < 0.6, "orbit: centro + raio 42 em angulo 0.12")
	check(area.has_point(button.position), "orbit: dentro da area de jogo")

	# blink: ponteiro no centro do botao, roll determinístico.
	controller.apply_effect_capabilities({"blink": true})
	var pointer_on_button := button.position + effective / 2.0
	controller.set_pointer_position(pointer_on_button)
	controller.blink_roll_override = 0.0
	var before := button.position
	controller._effect_tick()
	check(button.position != before, "blink: roll < 0.14 teleporta")
	controller.blink_roll_override = 0.99
	before = button.position
	controller._effect_tick()
	check(button.position == before, "blink: roll >= 0.14 nao teleporta")

	# mouse_flee: foge do ponteiro com strength 28 (0 upgrades, 0 lifetime).
	controller.apply_effect_capabilities({"mouse_flee": true})
	var btn_center := button.position + effective / 2.0
	controller.set_pointer_position(btn_center + Vector2(50.0, 0.0))
	before = button.position
	controller._effect_tick()
	check(button.position.x < before.x, "flee: foge do ponteiro (x) para a esquerda")
	check(is_equal_approx(button.position.x, before.x - 28.0), "flee: strength base 28")
	check(is_equal_approx(button.position.y, before.y), "flee: dy=0 nao move y")

	# range: 220 + 28*1.5 = 262; ponteiro a 300px nao provoca fuga.
	before = button.position
	controller.set_pointer_position(btn_center + Vector2(300.0, 0.0))
	controller._effect_tick()
	check(button.position == before, "flee: ponteiro fora do range nao move")

	# frescor: ponteiro expirado nao reage.
	controller.set_pointer_position(btn_center + Vector2(50.0, 0.0))
	controller.pointer_fresh_until_ms = Time.get_ticks_msec() - 1
	before = button.position
	controller._effect_tick()
	check(button.position == before, "flee: ponteiro expirado nao reage")

	# Prestige: P3, lifetime 300000, click+auto 10 -> 28 + 5.4 + 1 + 6 = 40.4 -> 40.
	state.prestige_level = 3
	state.lifetime_money = 300000
	state.click_level = 5
	state.auto_level = 5
	controller.apply_effect_capabilities({"mouse_flee": true})
	btn_center = button.position + effective / 2.0
	controller.set_pointer_position(btn_center + Vector2(50.0, 0.0))
	before = button.position
	controller._effect_tick()
	check(is_equal_approx(button.position.x, before.x - 40.0), "flee: P3 strength 40")
	state.prestige_level = 0
	state.lifetime_money = 0
	state.click_level = 0
	state.auto_level = 0
	controller.apply_effect_capabilities({})

	# sticky: jitter ±5x/±3y por clique.
	controller.apply_effect_capabilities({"sticky_jitter": true})
	var all_in_bounds := true
	for i in range(8):
		var pos := button.position
		controller._apply_sticky_jitter()
		if absf(button.position.x - pos.x) > 5.01 or absf(button.position.y - pos.y) > 3.01:
			all_in_bounds = false
	check(all_in_bounds, "sticky: jitter dentro de ±5x/±3y")

	button.queue_free()
	_test_main_integration()


func _test_main_integration() -> void:
	var main_scene: Node = load("res://main.tscn").instantiate()
	add_child(main_scene)
	await get_tree().process_frame

	var main: Node = main_scene
	main.get("event_manager").duration_override = 3.0

	main.get("event_manager").force_start_event("invert_colors")
	var overlay: Control = main.get("invert_overlay")
	check(overlay.visible, "main: invert_colors liga o overlay")
	check(overlay.mouse_filter == Control.MOUSE_FILTER_IGNORE, "main: overlay nao captura touch")

	main.get("event_manager").force_start_event("storm_mode")
	check(not overlay.visible, "main: substituicao desliga overlay antigo")
	var controller_ref: Node = main.get("click_controller")
	check(controller_ref.gravity_active, "main: storm_mode ativa gravity no controller")
	check(is_equal_approx(controller_ref.event_move_multiplier, 1.25), "main: storm_mode move_mult 1.25")

	main.get("event_manager").force_start_event("heatwave")
	check(controller_ref.mouse_flee_active, "main: heatwave ativa mouse_flee")
	check(not controller_ref.gravity_active, "main: heatwave reseta gravity (replace)")

	main.get("event_manager").force_start_event("calm")
	check(not controller_ref.mouse_flee_active, "main: calm reseta mouse_flee")
	check(is_equal_approx(controller_ref.event_move_multiplier, 0.65), "main: calm move_mult 0.65")

	main.get("event_manager").end_event()
	check(is_equal_approx(controller_ref.event_move_multiplier, 1.0), "main: fim do evento move_mult 1.0")
	check(not controller_ref.center_pull_active, "main: fim do evento limpa capabilities")

	# Regressões de cleanup do derived capability (sticky jitter).
	main.get("event_manager").force_start_event("sticky")
	check(controller_ref.sticky_active, "main: sticky ativa sticky_jitter")
	check(is_equal_approx(controller_ref.event_move_multiplier, 0.35), "main: sticky move_mult 0.35")
	main.get("event_manager").end_event()
	check(not controller_ref.sticky_active, "regressao: end_event limpa sticky_jitter")
	check(is_equal_approx(controller_ref.event_move_multiplier, 1.0), "regressao: end_event move_mult 1.0")

	main.get("event_manager").force_start_event("sticky")
	check(controller_ref.sticky_active, "main: sticky reativado")
	main.get("event_manager").force_start_event("calm")
	check(not controller_ref.sticky_active, "regressao: replace sticky->calm limpa sticky_jitter")
	check(is_equal_approx(controller_ref.event_move_multiplier, 0.65), "main: replace sticky->calm move_mult 0.65")
	main.get("event_manager").end_event()

	var goober_manager: Node = main.get("goober_manager")
	goober_manager.apply_goober_snapshot({"spawn_bonus": 1})
	var spawned := 0
	while goober_manager.force_spawn("gold"):
		spawned += 1
	check(spawned == 11, "main: spawn cap = 10 + 1 (frenzy +1), spawnados %d" % spawned)

	var game_state_ref = main.get("game_state")
	game_state_ref.secret_shop_unlocked = true
	game_state_ref.mission_state["slots"] = []
	var money_before: int = game_state_ref.get_money_earned_total()
	var coins_before: int = game_state_ref.goober_coins
	goober_manager.apply_goober_snapshot({"spawn_bonus": 0, "special_money_mult": 1.5, "special_coin_bonus": 2})
	goober_manager._on_goober_defeated(goober_manager.goobers[0])
	check(game_state_ref.get_money_earned_total() == money_before + 9375, "main: gold payout 5000*1.25*1.5 = 9375")
	check(game_state_ref.goober_coins == coins_before + 7, "main: gold gc 5 + special 2 = 7")

	_finish()


func _finish() -> void:
	if failures == 0:
		print("EVENT EFFECTS TEST PASS: %d checks" % checks)
	else:
		printerr("EVENT EFFECTS TEST FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
