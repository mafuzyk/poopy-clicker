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
	_test_primitives()
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


func _test_primitives() -> void:
	var GameState = preload("res://scripts/core/game_state.gd")
	var ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
	var PoopyButton = preload("res://scripts/ui/components/poopy_button.gd")
	var IconButton = preload("res://scripts/ui/components/icon_button.gd")
	var ResourceChip = preload("res://scripts/ui/components/resource_chip.gd")
	var StatusChip = preload("res://scripts/ui/components/status_chip.gd")
	var PoopyCard = preload("res://scripts/ui/components/poopy_card.gd")
	var SectionHeader = preload("res://scripts/ui/components/section_header.gd")
	var state = GameState.new()
	var theme = ThemeController.new()
	root.add_child(theme)
	theme.setup(state)

	var button := PoopyButton.new()
	root.add_child(button)
	button.setup(theme, PoopyButton.Variant.PRIMARY, PoopyButton.ControlSize.REGULAR)
	check(button.custom_minimum_size.y >= UiTokens.TOUCH_MIN, "regular button touch target")

	var icon := IconButton.new()
	root.add_child(icon)
	icon.setup(theme, "×")
	check(icon.custom_minimum_size.x >= UiTokens.TOUCH_MIN, "icon button width touch target")
	check(icon.custom_minimum_size.y >= UiTokens.TOUCH_MIN, "icon button height touch target")

	var chip := ResourceChip.new()
	root.add_child(chip)
	chip.setup(theme, "GC", UiTokens.COLOR_RESOURCE_GC)
	chip.set_amount("123")
	check(chip.get_amount_text() == "123", "resource chip amount")

	var status := StatusChip.new()
	root.add_child(status)
	status.setup(theme, "ATIVO", UiTokens.COLOR_SUCCESS)
	status.set_text("OK")
	check(status.get_text() == "OK", "status chip text")

	var card := PoopyCard.new()
	root.add_child(card)
	card.setup(theme, true)
	check(card.get_theme_stylebox("panel") != null, "card has panel style")

	var header := SectionHeader.new()
	root.add_child(header)
	header.setup(theme, "TITULO", "subtitulo")
	check(header.title_label.text == "TITULO", "section header title")
	check(header.subtitle_label.text == "subtitulo", "section header subtitle")