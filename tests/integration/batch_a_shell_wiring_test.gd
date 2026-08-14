extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")
const MobileGameShell = preload("res://scripts/ui/shell/mobile/mobile_game_shell.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const GooberManager = preload("res://scripts/goobers/goober_manager.gd")

var failures := 0
var checks := 0
var fired: Array = []


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL ", label)
	else:
		print("OK   ", label)


func _ready() -> void:
	await _run()
	_finish()


func _run() -> void:
	var mobile := LayoutClassifier.classify("Android", Vector2(360, 800), true)
	var large := LayoutClassifier.classify("Windows", Vector2(1366, 768), false)
	check(mobile.family == LayoutClassifier.LayoutFamily.MOBILE, "mobile branch selection")
	check(large.family == LayoutClassifier.LayoutFamily.LARGE_SCREEN, "legacy large branch selection during M2")

	var host := Control.new()
	host.size = Vector2(360, 800)
	add_child(host)
	var state := GameState.new()
	var economy := Economy.new(state)
	var combo := ComboManager.new()
	combo.setup(state)
	add_child(combo)
	var events := EventManager.new()
	events.setup(state)
	add_child(events)
	var theme := ThemeController.new()
	theme.setup(state)
	add_child(theme)

	var shell := MobileGameShell.new()
	shell.setup(state, economy, combo, events, theme, mobile)
	host.add_child(shell)
	await get_tree().process_frame

	shell.shop_requested.connect(func() -> void: fired.append("shop"))
	shell.bestiary_requested.connect(func() -> void: fired.append("bestiary"))
	shell.menu_requested.connect(func() -> void: fired.append("menu"))
	shell.nav.shop_button.pressed.emit()
	shell.nav.bestiary_button.pressed.emit()
	shell.nav.menu_button.pressed.emit()
	check(fired.has("shop"), "shop nav re-emitted")
	check(fired.has("bestiary"), "bestiary nav re-emitted")
	check(fired.has("menu"), "menu nav re-emitted")

	var click := ClickController.new()
	add_child(click)
	click.setup(shell.click_target, state, shell.playfield.click_target_layer)
	check(click.get_play_area_rect() == Rect2(Vector2.ZERO, shell.playfield.click_target_layer.size), "click explicit bounds via shell")

	var gm := GooberManager.new()
	add_child(gm)
	gm.setup(shell.click_target, state, shell.playfield.goober_layer, shell.playfield.goober_layer)
	check(gm.goober_container == shell.playfield.goober_layer, "goober container via shell")
	check(gm.bounds_control == shell.playfield.goober_layer, "goober bounds via shell")


func _finish() -> void:
	if failures == 0:
		print("BATCH A WIRING PASS: %d checks" % checks)
	else:
		printerr("BATCH A WIRING FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
