extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")
const MobileGameShell = preload("res://scripts/ui/shell/mobile/mobile_game_shell.gd")
const LargeScreenGameShell = preload("res://scripts/ui/shell/large/large_screen_game_shell.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")

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
	var cases := [
		["Mobile Portrait 320x568", Vector2(320, 568), true, LayoutClassifier.LayoutFamily.MOBILE],
		["Mobile Portrait 360x800", Vector2(360, 800), true, LayoutClassifier.LayoutFamily.MOBILE],
		["Mobile Landscape 568x320", Vector2(568, 320), true, LayoutClassifier.LayoutFamily.MOBILE],
		["Mobile Landscape 800x360", Vector2(800, 360), true, LayoutClassifier.LayoutFamily.MOBILE],
		["Large touch 800x600", Vector2(800, 600), true, LayoutClassifier.LayoutFamily.LARGE_SCREEN],
		["Large touch 1024x768", Vector2(1024, 768), true, LayoutClassifier.LayoutFamily.LARGE_SCREEN],
		["Large pointer 1366x768", Vector2(1366, 768), false, LayoutClassifier.LayoutFamily.LARGE_SCREEN],
		["Large pointer 1920x1080", Vector2(1920, 1080), false, LayoutClassifier.LayoutFamily.LARGE_SCREEN],
	]
	for entry in cases:
		await _check_case(entry[0], entry[1], entry[2], entry[3])


func _check_case(label: String, size: Vector2, touch: bool, family: int) -> void:
	var platform := "Android" if touch else "Windows"
	var profile := LayoutClassifier.classify(platform, size, touch)
	check(profile.family == family, "%s family correct" % label)

	var host := Control.new()
	host.size = size
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

	var shell
	if family == LayoutClassifier.LayoutFamily.MOBILE:
		shell = MobileGameShell.new()
	else:
		shell = LargeScreenGameShell.new()
	shell.setup(state, economy, combo, events, theme, profile)
	host.add_child(shell)
	await get_tree().process_frame
	await get_tree().process_frame

	check(shell.playfield.size.x > 0.0 and shell.playfield.size.y > 0.0, "%s playfield non-zero" % label)
	var shell_rect: Rect2 = shell.get_global_rect()
	var nav_rect: Rect2 = shell.nav.get_global_rect()
	check(shell_rect.encloses(nav_rect) or shell_rect.intersects(nav_rect), "%s nav in shell bounds" % label)

	var click := ClickController.new()
	add_child(click)
	click.setup(shell.click_target, state, shell.playfield.click_target_layer)
	click.center_button()
	click.keep_button_inside()
	var playfield_rect: Rect2 = shell.playfield.get_global_rect()
	var target_rect: Rect2 = shell.click_target.get_global_rect()
	check(playfield_rect.encloses(target_rect), "%s ClickTarget inside Playfield" % label)

	shell.queue_free()


func _finish() -> void:
	if failures == 0:
		print("LAYOUT MATRIX PASS: %d checks" % checks)
	else:
		printerr("LAYOUT MATRIX FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)
