extends Control

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const EdgeBar = preload("res://scripts/ui/edge_bar.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal menu_requested
signal shop_requested
signal bestiary_requested
signal achievements_requested

var game_state: GameState
var economy: Economy

var money_label: Label
var auto_label: Label
var combo_label: Label
var goober_coins_label: Label
var menu_button: Button
var shop_button: Button
var bestiary_button: Button
var achievements_button: Button


func setup(state: GameState, econ: Economy) -> void:
	game_state = state
	economy = econ
	name = "HUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 10
	_build_top_bar()
	_build_bottom_bar()
	refresh()


func _build_top_bar() -> void:
	var bar: EdgeBar = EdgeBar.new()
	bar.name = "TopBar"
	bar.setup(EdgeBar.BarSide.TOP, Layout.TOP_BAR_HEIGHT)
	add_child(bar)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "TopRow"
	row.add_theme_constant_override("separation", Layout.GAP)
	bar.add_content(row)

	menu_button = UiStyles.make_button("Menu", Layout.BAR_BUTTON_FONT, Layout.BAR_BUTTON_HEIGHT)
	menu_button.custom_minimum_size.x = Layout.BAR_BUTTON_WIDTH
	menu_button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	menu_button.pressed.connect(menu_requested.emit)
	row.add_child(menu_button)

	var info: VBoxContainer = VBoxContainer.new()
	info.name = "InfoBox"
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	info.add_theme_constant_override("separation", 0)
	row.add_child(info)

	money_label = Label.new()
	money_label.name = "MoneyLabel"
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	money_label.add_theme_font_size_override("font_size", Layout.MONEY_FONT)
	info.add_child(money_label)

	auto_label = Label.new()
	auto_label.name = "AutoLabel"
	auto_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	auto_label.add_theme_font_size_override("font_size", Layout.SUB_INFO_FONT)
	auto_label.modulate = Color(1, 1, 1, 0.85)
	info.add_child(auto_label)

	combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	combo_label.add_theme_font_size_override("font_size", Layout.SUB_INFO_FONT)
	combo_label.visible = false
	info.add_child(combo_label)

	goober_coins_label = UiStyles.make_label("GC", Layout.GC_FONT, Color(1.0, 0.85, 0.3))
	goober_coins_label.name = "GooberCoinsLabel"
	goober_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	goober_coins_label.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	goober_coins_label.custom_minimum_size.x = Layout.BAR_BUTTON_WIDTH
	goober_coins_label.visible = false
	row.add_child(goober_coins_label)


func _build_bottom_bar() -> void:
	var bar: EdgeBar = EdgeBar.new()
	bar.name = "BottomBar"
	bar.setup(EdgeBar.BarSide.BOTTOM, Layout.BOTTOM_BAR_HEIGHT)
	add_child(bar)

	var row: HBoxContainer = HBoxContainer.new()
	row.name = "NavRow"
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", Layout.GAP)
	bar.add_content(row)

	shop_button = _make_nav_button("Loja", shop_requested)
	row.add_child(shop_button)

	bestiary_button = _make_nav_button("Gooberário", bestiary_requested)
	row.add_child(bestiary_button)

	achievements_button = _make_nav_button("Conquistas", achievements_requested)
	row.add_child(achievements_button)


func _make_nav_button(text: String, target: Signal) -> Button:
	var button := UiStyles.make_button(text, Layout.NAV_BUTTON_FONT, Layout.NAV_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.x = 96.0
	button.pressed.connect(target.emit)
	return button


func refresh() -> void:
	if game_state == null or economy == null:
		return
	money_label.text = "$" + NumberFormat.format(game_state.money)
	auto_label.text = NumberFormat.format(economy.get_auto_value()) + "/s"
	if game_state.combo_count > 0:
		combo_label.text = "🔥 Combo x%d (%.1fx)" % [game_state.combo_count, game_state.combo_multiplier]
		combo_label.visible = true
	else:
		combo_label.visible = false
	goober_coins_label.visible = game_state.secret_shop_unlocked
	if goober_coins_label.visible:
		goober_coins_label.text = "GC " + NumberFormat.format(game_state.goober_coins)