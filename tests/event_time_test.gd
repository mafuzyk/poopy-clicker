extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventBanner = preload("res://scripts/ui/event_banner.gd")
const EventCatalog = preload("res://scripts/data/event_catalog.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const Layout = preload("res://scripts/ui/layout.gd")

var failures := 0
var checks := 0
var started_count := 0
var ended_count := 0
var last_started_id := ""
var last_ended_id := ""
var ratio_samples: Array = []

var state: GameState
var events: EventManager
var combo: ComboManager
var banner: EventBanner


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _ready() -> void:
	state = GameState.new()

	events = EventManager.new()
	events.triggers_blocked = true
	events.duration_override = 1.5
	events.setup(state)
	events.event_started.connect(func(id: String, _d: Dictionary) -> void:
		started_count += 1
		last_started_id = id
	)
	events.event_ended.connect(func(id: String) -> void:
		ended_count += 1
		last_ended_id = id
	)
	events.event_progress_changed.connect(func(ratio: float) -> void:
		ratio_samples.append(ratio)
	)
	add_child(events)

	combo = ComboManager.new()
	combo.setup(state)
	add_child(combo)

	banner = EventBanner.new()
	banner.setup(events)
	add_child(banner)

	_test_lifecycle()


func _test_lifecycle() -> void:
	check(not banner.visible, "sem evento: banner hidden")
	check(events.get_active_event_id() == "", "sem evento: active vazio")

	events.force_start_event("double_click")
	check(started_count == 1, "event_started emitido")
	check(last_started_id == "double_click", "active id = double_click")
	check(is_equal_approx(events.get_float_modifier("click_mult", 1.0), 2.0), "modifier click_mult 2.0 ativo")
	check(events.get_progress_ratio() > 0.99, "ratio inicia ~1.0")
	check(banner.visible, "evento iniciado: banner visible")
	check(banner.title_label.text == "2x click • Raro", "titulo = '2x click • Raro'")
	check(banner.desc_label.text == EventCatalog.EVENT_INFO["double_click"]["desc"], "descricao correta")
	check(banner.progress_bar.value > 0.0, "progress > 0")
	check(banner.mouse_filter == Control.MOUSE_FILTER_IGNORE, "banner nao captura touch")
	check(banner.panel.mouse_filter == Control.MOUSE_FILTER_IGNORE, "panel nao captura touch")

	await get_tree().create_timer(0.5).timeout
	var mid_ratio: float = events.get_progress_ratio()
	check(mid_ratio < 0.99, "ratio decresce (%.2f)" % mid_ratio)
	check(mid_ratio > 0.0, "ratio ainda > 0 (%.2f)" % mid_ratio)

	await get_tree().create_timer(1.3).timeout
	check(events.get_active_event_id() == "", "timeout encerra evento")
	check(ended_count == 1, "event_ended emitido")
	check(last_ended_id == "double_click", "event_ended com id antigo")
	check(is_equal_approx(events.get_float_modifier("click_mult", 1.0), 1.0), "modifier volta ao default")
	check(not banner.visible, "evento encerrado: banner hidden")

	_test_snack_break_combo()


func _test_snack_break_combo() -> void:
	events.force_start_event("snack_break")
	var grace: float = events.get_float_modifier("combo_grace", 0.0)
	check(is_equal_approx(grace, 900.0), "snack_break combo_grace = 900 ms")
	var grace_seconds: float = grace / 1000.0
	combo.register_manual_click(grace_seconds)
	check(state.combo_count == 1, "clique durante snack_break inicia combo")

	await get_tree().create_timer(2.0).timeout
	check(state.combo_count == 1, "2.0s < 2.7s: combo ainda ativo")

	await get_tree().create_timer(0.9).timeout
	check(state.combo_count == 0, "2.9s >= 2.7s: combo quebrou")

	events.end_event()
	check(events.get_float_modifier("combo_grace", 0.0) == 0.0, "evento encerrado: grace volta 0")
	combo.register_manual_click(events.get_float_modifier("combo_grace", 0.0) / 1000.0)
	check(state.combo_count == 1, "novo clique inicia combo")

	await get_tree().create_timer(1.9).timeout
	check(state.combo_count == 0, "sem grace: decay 1.8s quebra combo")

	_test_grace_no_retroactive_shorten()


func _test_grace_no_retroactive_shorten() -> void:
	events.force_start_event("snack_break")
	combo.register_manual_click(events.get_float_modifier("combo_grace", 0.0) / 1000.0)
	await get_tree().create_timer(1.0).timeout
	events.end_event()
	# Timer de 2.7s já iniciado não deve ser encurtado pelo fim do evento.
	await get_tree().create_timer(1.0).timeout
	check(state.combo_count == 1, "combo com grace NAO encurtado retroativamente (2.0s < 2.7s)")
	await get_tree().create_timer(0.9).timeout
	check(state.combo_count == 0, "combo quebra no prazo original de 2.7s")

	_test_scaled_clamp()


func _test_scaled_clamp() -> void:
	var button := Button.new()
	button.size = Layout.CLICK_BUTTON_SIZE
	add_child(button)

	var controller := ClickController.new()
	controller.setup(button, state)
	controller.set_event_scale_multiplier(1.22)

	var area: Rect2 = controller.get_play_area_rect()
	button.position = Vector2(area.end.x + 100.0, area.end.y + 100.0)
	controller.keep_button_inside()

	var effective: Vector2 = button.size * button.scale
	check(button.position.x + effective.x <= area.end.x + 0.01, "clamp usa tamanho escalado (borda direita)")
	check(button.position.y + effective.y <= area.end.y + 0.01, "clamp usa tamanho escalado (borda inferior)")
	check(button.position.x >= area.position.x - 0.01, "clamp respeita borda esquerda")
	check(button.position.y >= area.position.y - 0.01, "clamp respeita borda superior")

	controller.set_event_scale_multiplier(1.0)
	button.position = Vector2(area.end.x + 100.0, area.end.y + 100.0)
	controller.keep_button_inside()
	var unscaled: Vector2 = button.size * button.scale
	check(button.position.x + unscaled.x <= area.end.x + 0.01, "sem evento: clamp com tamanho normal (x)")
	check(button.position.y + unscaled.y <= area.end.y + 0.01, "sem evento: clamp com tamanho normal (y)")

	button.queue_free()
	_finish()


func _finish() -> void:
	if failures == 0:
		print("EVENT TIME TEST PASS: %d checks" % checks)
	else:
		printerr("EVENT TIME TEST FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
