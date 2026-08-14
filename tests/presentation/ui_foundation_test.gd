extends SceneTree

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
	check(UiTokens.SPACE_1 == 4.0, "spacing foundation starts at 4")
	check(UiTokens.SPACE_7 == 48.0, "spacing scale reaches 48")
	check(UiTokens.TOUCH_MIN == 48.0, "touch minimum is 48")
	check(UiTokens.FONT_RESOURCE_PRIMARY == 28, "resource primary typography role")
	check(UiTokens.RADIUS_PILL > 100.0, "pill radius is semantic")
	var palette := UiTokens.default_palette()
	check(palette.has(UiTokens.COLOR_BACKGROUND), "default background token exists")
	check(palette.has(UiTokens.COLOR_ACCENT), "default accent token exists")
	check(palette.has(UiTokens.COLOR_RESOURCE_GC), "GC semantic color exists")
	check(palette.has(UiTokens.COLOR_RARITY_MYTHIC), "rarity semantic color exists")
	_test_theme_controller()
	if failures == 0:
		print("UI FOUNDATION PASS: %d checks" % checks)
	else:
		printerr("UI FOUNDATION FAIL: %d/%d" % [failures, checks])
	quit(failures)


func _test_theme_controller() -> void:
	var GameState = preload("res://scripts/core/game_state.gd")
	var ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
	var state = GameState.new()
	state.owned_ui_themes = ["default", "gold"]
	state.selected_ui_theme = "default"
	var theme = ThemeController.new()
	root.add_child(theme)
	theme.setup(state)
	var default_accent := theme.get_color(UiTokens.COLOR_ACCENT)
	state.selected_ui_theme = "gold"
	state.changed.emit()
	var gold_accent := theme.get_color(UiTokens.COLOR_ACCENT)
	check(default_accent != gold_accent, "selected theme changes semantic accent")
	check(theme.get_color(UiTokens.COLOR_RESOURCE_GC) == UiTokens.default_palette()[UiTokens.COLOR_RESOURCE_GC], "theme keeps GC semantics")
	theme.queue_free()