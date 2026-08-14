extends SceneTree

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const Playfield = preload("res://scripts/ui/shell/playfield.gd")
const ResourcePresenter = preload("res://scripts/ui/gameplay/resource_presenter.gd")
const GameShellBase = preload("res://scripts/ui/shell/game_shell_base.gd")
const ClickTarget = preload("res://scripts/ui/gameplay/click_target.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")

var failures := 0
var checks := 0


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL ", label)
	else:
		print("OK   ", label)


func _initialize() -> void:
	_test_playfield_layers()
	_test_shell_base_contract()
	_test_resource_presenter()
	_test_click_target()
	if failures == 0:
		print("MOBILE SHELL PASS: %d checks" % checks)
	else:
		printerr("MOBILE SHELL FAIL: %d/%d" % [failures, checks])
	quit(failures)


func _test_playfield_layers() -> void:
	var playfield := Playfield.new()
	playfield.size = Vector2(360, 420)
	root.add_child(playfield)
	playfield.ensure_built()
	check(playfield.goober_layer != null, "goober layer exists")
	check(playfield.click_target_layer != null, "click target layer exists")
	check(playfield.reward_fx_layer != null, "reward fx layer exists")
	check(playfield.gameplay_overlay_layer != null, "gameplay overlay layer exists")
	for layer in [playfield.goober_layer, playfield.click_target_layer, playfield.reward_fx_layer, playfield.gameplay_overlay_layer]:
		check(layer.anchor_left == 0.0 and layer.anchor_top == 0.0 and layer.anchor_right == 1.0 and layer.anchor_bottom == 1.0, "%s fills playfield (full-rect)" % layer.name)


func _test_shell_base_contract() -> void:
	var shell := GameShellBase.new()
	root.add_child(shell)
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
	check(snap["gc"] == "0", "gc value")
	check(snap["essence_visible"] == false, "essence hidden")
	check(snap["essence"] == "0", "essence value")
	check(snap["prestige_visible"] == false, "prestige hidden")
	check(snap["prestige"] == "P0", "prestige P0")


func _test_click_target() -> void:
	var state := GameState.new()
	var theme := ThemeController.new()
	root.add_child(theme)
	theme.setup(state)

	var target := ClickTarget.new()
	root.add_child(target)
	target.setup(theme, Vector2(200, 84))
	target.scale = Vector2(0.9, 0.9)
	var mechanical_scale := target.scale
	target.debug_set_pressed_visual(true)
	check(target.scale == mechanical_scale, "cosmetic press never changes mechanical scale")
	check(target.get_visual_scale().x < 1.0, "press feedback affects visual child")
	target.debug_set_pressed_visual(false)
