extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")
const Playfield = preload("res://scripts/ui/shell/playfield.gd")
const ResourcePresenter = preload("res://scripts/ui/gameplay/resource_presenter.gd")
const GameShellBase = preload("res://scripts/ui/shell/game_shell_base.gd")
const ClickTarget = preload("res://scripts/ui/gameplay/click_target.gd")
const MobileGameShell = preload("res://scripts/ui/shell/mobile/mobile_game_shell.gd")

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


func _run() -> void:
	_test_playfield_layers()
	_test_shell_base_contract()
	_test_resource_presenter()
	_test_click_target()
	await _test_mobile_shell()
	await _test_header_dock()
	await _test_combo_event()


func _test_playfield_layers() -> void:
	var playfield := Playfield.new()
	playfield.size = Vector2(360, 420)
	add_child(playfield)
	playfield.ensure_built()
	check(playfield.goober_layer != null, "goober layer exists")
	check(playfield.click_target_layer != null, "click target layer exists")
	check(playfield.reward_fx_layer != null, "reward fx layer exists")
	check(playfield.gameplay_overlay_layer != null, "gameplay overlay layer exists")
	for layer in [playfield.goober_layer, playfield.click_target_layer, playfield.reward_fx_layer, playfield.gameplay_overlay_layer]:
		check(layer.anchor_left == 0.0 and layer.anchor_top == 0.0 and layer.anchor_right == 1.0 and layer.anchor_bottom == 1.0, "%s fills playfield (full-rect)" % layer.name)


func _test_shell_base_contract() -> void:
	var shell := GameShellBase.new()
	add_child(shell)
	shell.ensure_built()
	check(shell.surface_layer != null, "surface layer exists")
	check(shell.overlay_layer != null, "overlay layer exists")
	check(shell.has_signal("shop_requested"), "shop_requested signal")
	check(shell.has_signal("bestiary_requested"), "bestiary_requested signal")
	check(shell.has_signal("menu_requested"), "menu_requested signal")


func _test_resource_presenter() -> void:
	var state := GameState.new()
	var economy := Economy.new(state)
	var snap := ResourcePresenter.snapshot(state, economy)
	check(snap["money"] == "$0", "fresh money snapshot")
	check(snap["income"] == "0/s", "fresh income snapshot")
	check(snap["gc_visible"] == false, "gc hidden before unlock")
	check(snap["essence_visible"] == false, "essence hidden")
	check(snap["prestige_visible"] == false, "prestige hidden")
	check(snap["prestige"] == "P0", "prestige P0")


func _test_click_target() -> void:
	var state := GameState.new()
	var theme := ThemeController.new()
	add_child(theme)
	theme.setup(state)
	var target := ClickTarget.new()
	add_child(target)
	target.setup(theme, Vector2(200, 84))
	target.scale = Vector2(0.9, 0.9)
	var mechanical_scale := target.scale
	target.debug_set_pressed_visual(true)
	check(target.scale == mechanical_scale, "cosmetic press never changes mechanical scale")
	check(target.get_visual_scale().x < 1.0, "press feedback affects visual child")
	target.debug_set_pressed_visual(false)


func _build_shell(host: Control) -> MobileGameShell:
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
	var profile := LayoutClassifier.classify("Android", host.size, true)
	shell.setup(state, economy, combo, events, theme, profile)
	host.add_child(shell)
	return shell


func _test_mobile_shell() -> void:
	var host := Control.new()
	host.size = Vector2(360, 800)
	add_child(host)
	var shell := _build_shell(host)
	await get_tree().process_frame
	await get_tree().process_frame

	check(shell.get_orientation() == LayoutClassifier.Orientation.PORTRAIT, "360x800 reports Portrait")
	check(shell.playfield != null and shell.playfield.size.x > 0.0 and shell.playfield.size.y > 0.0, "playfield has positive size")
	check(shell.header != null and shell.nav != null, "header and nav exist")
	var header_top: float = shell.header.get_global_rect().position.y
	var playfield_top: float = shell.playfield.get_global_rect().position.y
	var nav_top: float = shell.nav.get_global_rect().position.y
	check(header_top < playfield_top and playfield_top < nav_top, "header above playfield above nav")
	check(shell.click_target.get_parent() == shell.playfield.click_target_layer, "ClickTarget parented to click_target_layer")
	check(shell.nav.get_destination_count() == 3, "nav has exactly three primary destinations")

	var playfield_id := shell.playfield.get_instance_id()
	var click_id := shell.click_target.get_instance_id()

	host.size = Vector2(800, 360)
	await get_tree().process_frame
	await get_tree().process_frame

	check(shell.get_orientation() == LayoutClassifier.Orientation.LANDSCAPE, "800x360 reports Landscape")
	check(shell.playfield.get_instance_id() == playfield_id, "same Playfield instance survives resize")
	check(shell.click_target.get_instance_id() == click_id, "same ClickTarget instance survives resize")
	check(shell.header.custom_minimum_size.y < 100.0, "landscape header is compact")


func _test_header_dock() -> void:
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
	shell.setup(state, economy, combo, events, theme, LayoutClassifier.classify("Android", host.size, true))
	host.add_child(shell)
	await get_tree().process_frame

	check(shell.header.get_money_text() == "$0", "fresh money visible")
	check(shell.header.get_income_text() == "0/s", "fresh income visible")

	state.secret_shop_unlocked = true
	state.goober_coins = 42
	state.prestige_level = 3
	state.poopy_essence = 17
	state.changed.emit()
	await get_tree().process_frame

	check(shell.header.get_gc_text() == "42", "header exposes GC 42")
	check(shell.header.get_essence_text() == "17", "header exposes Essence 17")
	check(shell.header.get_prestige_text() == "P3", "header exposes P3")

	check(shell.nav.shop_button.custom_minimum_size.y >= 48.0, "dock shop button 48px touch target")
	check(shell.nav.menu_button.custom_minimum_size.y >= 48.0, "dock menu button 48px touch target")


func _test_combo_event() -> void:
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
	shell.setup(state, economy, combo, events, theme, LayoutClassifier.classify("Android", host.size, true))
	host.add_child(shell)
	await get_tree().process_frame

	check(not shell.combo_display.visible, "combo hidden at 0")
	combo.register_manual_click()
	await get_tree().process_frame
	check(shell.combo_display.visible, "combo visible after click")
	state.reset_combo()
	combo.combo_broken.emit()
	await get_tree().process_frame
	check(not shell.combo_display.visible, "combo hidden after break")

	check(not shell.event_status.visible, "event hidden initially")
	events.duration_override = 5.0
	events.force_start_event("overclock")
	await get_tree().process_frame
	check(shell.event_status.visible, "event status visible when active")
	check(shell.event_status._title_label.text == "Overclock", "event title shown")
	events.end_event()
	await get_tree().process_frame
	check(not shell.event_status.visible, "event status hidden after end")


func _finish() -> void:
	if failures == 0:
		print("MOBILE SHELL PASS: %d checks" % checks)
	else:
		printerr("MOBILE SHELL FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
