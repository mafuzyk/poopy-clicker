extends Control

const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const BasePanel = preload("res://scripts/ui/base_panel.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal buy_click_upgrade
signal buy_auto_upgrade
signal close_requested

var game_state: GameState
var economy: Economy
var base: BasePanel

var money_label: Label
var click_card: PanelContainer
var auto_card: PanelContainer
var click_button: Button
var auto_button: Button
var click_name_label: Label
var auto_name_label: Label
var click_detail_label: Label
var auto_detail_label: Label
var click_price_label: Label
var auto_price_label: Label


func setup(state: GameState, econ: Economy) -> void:
	game_state = state
	economy = econ
	build_ui()
	game_state.changed.connect(refresh)
	refresh()
	visible = false


func build_ui() -> void:
	name = "ShopUI"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	base = BasePanel.new()
	base.setup("LOJA")
	base.close_requested.connect(close_requested.emit)
	add_child(base)

	money_label = UiStyles.make_label("", Layout.PANEL_ACTION_FONT, Color(1, 1, 1, 0.9))
	money_label.name = "MoneyLabel"
	money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(money_label)

	click_card = _make_upgrade_card(
		"click_card",
		"click_name_label",
		"click_detail_label",
		"click_price_label",
		"click_button",
		"Comprar",
		buy_click_upgrade
	)
	base.add_to_content(click_card)

	auto_card = _make_upgrade_card(
		"auto_card",
		"auto_name_label",
		"auto_detail_label",
		"auto_price_label",
		"auto_button",
		"Comprar",
		buy_auto_upgrade
	)
	base.add_to_content(auto_card)


func _make_upgrade_card(
	card_node_name: String,
	name_var: String,
	detail_var: String,
	price_var: String,
	button_var: String,
	button_text: String,
	action: Signal
) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = card_node_name
	card.add_theme_stylebox_override("panel", UiStyles.card_style())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)

	var name_label := UiStyles.make_label("", 18, Color(0.95, 0.95, 0.97, 1.0))
	name_label.name = name_var
	info.add_child(name_label)
	set(name_var, name_label)

	var detail_label := UiStyles.make_label("", 13, Color(1, 1, 1, 0.75))
	detail_label.name = detail_var
	detail_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(detail_label)
	set(detail_var, detail_label)

	var right := VBoxContainer.new()
	right.alignment = BoxContainer.ALIGNMENT_CENTER
	right.add_theme_constant_override("separation", 6)
	row.add_child(right)

	var price_label := UiStyles.make_label("", 16, Color(1.0, 0.85, 0.35))
	price_label.name = price_var
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	right.add_child(price_label)
	set(price_var, price_label)

	var buy_button := UiStyles.make_button(button_text, 14, 40.0)
	buy_button.name = button_var
	buy_button.custom_minimum_size.x = 92.0
	buy_button.pressed.connect(action.emit)
	right.add_child(buy_button)
	set(button_var, buy_button)

	return card


func refresh() -> void:
	var click_cost: int = economy.get_click_upgrade_cost()
	var auto_cost: int = economy.get_auto_upgrade_cost()

	money_label.text = "Você tem $" + NumberFormat.format(game_state.money)

	click_name_label.text = "Click upgrade — nível %d" % game_state.click_level
	click_detail_label.text = "A cada clique: $%s" % NumberFormat.format(economy.get_click_value())
	click_price_label.text = "$" + NumberFormat.format(click_cost)
	click_button.text = "Melhorar"
	click_button.disabled = game_state.money < click_cost

	auto_name_label.text = "Auto click — nível %d" % game_state.auto_level
	if game_state.auto_level == 0:
		auto_detail_label.text = "Clica sozinho a cada segundo"
	else:
		auto_detail_label.text = "Ganha $%s/s" % NumberFormat.format(economy.get_auto_value())
	auto_price_label.text = "$" + NumberFormat.format(auto_cost)
	auto_button.text = "Comprar" if game_state.auto_level == 0 else "Melhorar"
	auto_button.disabled = game_state.money < auto_cost