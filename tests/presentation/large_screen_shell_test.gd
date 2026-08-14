extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")
const LargeScreenGameShell = preload("res://scripts/ui/shell/large/large_screen_game_shell.gd")

var failures := 0
var checks := 0


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


func _make_shell(host: Control, profile: Dictionary) -> LargeScreenGameShell:
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
	var shell := LargeScreenGameShell.new()
	shell.setup(state, economy, combo, events, theme, profile)
	host.add_child(shell)
	return shell


func _run() -> void:
	var host := Control.new()
	host.size = Vector2(1366, 768)
	add_child(host)
	var shell := _make_shell(host, LayoutClassifier.classify("Windows", Vector2(1366, 768), false))
	await get_tree().process_frame
	await get_tree().process_frame

	check(shell.get_density() == LayoutClassifier.LargeDensity.WIDE, "1366x768 uses Wide density")
	var nav_x: float = shell.nav.get_global_rect().position.x
	var playfield_x: float = shell.playfield.get_global_rect().position.x
	check(nav_x < playfield_x, "wide nav rail is left of playfield")
	check(shell.header.get_global_rect().position.y < shell.playfield.get_global_rect().position.y, "header above playfield")
	check(shell.playfield.size.x > shell.nav.size.x, "playfield has more area than nav")
	check(shell.nav.get_destination_count() == 3, "three primary nav destinations")
	check(shell.nav.shop_button.focus_mode == Control.FOCUS_ALL, "pointer profile enables focus")

	var playfield_id := shell.playfield.get_instance_id()
	var click_id := shell.click_target.get_instance_id()

	host.size = Vector2(800, 600)
	await get_tree().process_frame
	await get_tree().process_frame

	check(shell.get_density() == LayoutClassifier.LargeDensity.COMPACT, "800x600 uses Compact density")
	check(shell.playfield.get_instance_id() == playfield_id, "same Playfield survives density swap")
	check(shell.click_target.get_instance_id() == click_id, "same ClickTarget survives density swap")
	check(shell.nav.get_global_rect().position.y < shell.playfield.get_global_rect().position.y, "compact nav relocates to top cluster (not bottom dock)")

	var touch_host := Control.new()
	touch_host.size = Vector2(800, 600)
	add_child(touch_host)
	var touch_shell := _make_shell(touch_host, LayoutClassifier.classify("Android", Vector2(800, 600), true))
	await get_tree().process_frame
	await get_tree().process_frame
	check(touch_shell.get_density() == LayoutClassifier.LargeDensity.COMPACT, "800x600 touch stays LargeCompact (never Mobile)")
	for b in [touch_shell.nav.shop_button, touch_shell.nav.bestiary_button, touch_shell.nav.menu_button]:
		check(b.custom_minimum_size.y >= 48.0, "touch nav action >= 48px")


func _finish() -> void:
	if failures == 0:
		print("LARGE SCREEN SHELL PASS: %d checks" % checks)
	else:
		printerr("LARGE SCREEN SHELL FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
