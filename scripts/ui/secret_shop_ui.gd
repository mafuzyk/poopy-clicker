extends Control

const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const BasePanel = preload("res://scripts/ui/base_panel.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal buy_requested(upgrade: String)
signal close_requested

const UPGRADE_ORDER := [
	GameState.GOOBER_CHARM,
	GameState.HEAVY_BUTTON,
	GameState.LUCKY_PAWS,
	GameState.SNEAKY_PROFIT,
	GameState.PANIC_SHIELD,
]

const UPGRADE_NAMES := {
	GameState.GOOBER_CHARM: "Goober Charm",
	GameState.HEAVY_BUTTON: "Heavy Button",
	GameState.LUCKY_PAWS: "Lucky Paws",
	GameState.SNEAKY_PROFIT: "Sneaky Profit",
	GameState.PANIC_SHIELD: "Panic Shield",
}

const DESCRIPTIONS := {
	GameState.GOOBER_CHARM: "Goobers param menos",
	GameState.HEAVY_BUTTON: "Empurrão normal reduzido",
	GameState.LUCKY_PAWS: "+1 moeda extra por goober",
	GameState.SNEAKY_PROFIT: "+25% no auto click",
	GameState.PANIC_SHIELD: "Empurrão de pânico reduzido",
}

var UPGRADE_BUTTONS: Dictionary = {}
var UPGRADE_CARDS: Dictionary = {}

var game_state: GameState
var base: BasePanel
var coins_label: Label


func setup(state: GameState) -> void:
	game_state = state
	build_ui()
	game_state.changed.connect(refresh)
	refresh()
	visible = false


func build_ui() -> void:
	name = "SecretShopUI"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	base = BasePanel.new()
	base.setup("LOJA SECRETA")
	base.close_requested.connect(close_requested.emit)
	add_child(base)

	coins_label = UiStyles.make_label("", Layout.PANEL_ACTION_FONT, Color(1, 1, 1, 0.9))
	coins_label.name = "CoinsLabel"
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(coins_label)

	for upgrade in UPGRADE_ORDER:
		var card := _make_upgrade_card(upgrade)
		UPGRADE_CARDS[upgrade] = card
		base.add_to_content(card)


func _make_upgrade_card(upgrade: String) -> PanelContainer:
	var card := PanelContainer.new()
	card.name = "Upgrade" + upgrade.capitalize()
	card.add_theme_stylebox_override("panel", UiStyles.card_style())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 12)
	card.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 4)
	row.add_child(info)

	var name_label := UiStyles.make_label(UPGRADE_NAMES[upgrade], 17, Color(0.95, 0.95, 0.97, 1.0))
	info.add_child(name_label)

	var desc_label := UiStyles.make_label(DESCRIPTIONS[upgrade], 13, Color(1, 1, 1, 0.75))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc_label)

	var button := UiStyles.make_button("", 14, 40.0)
	button.name = "Button"
	button.custom_minimum_size.x = 96.0
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	button.pressed.connect(buy_requested.emit.bind(upgrade))
	UPGRADE_BUTTONS[upgrade] = button
	row.add_child(button)

	return card


func refresh() -> void:
	coins_label.text = "Goober coins: " + NumberFormat.format(game_state.goober_coins)

	for upgrade in UPGRADE_ORDER:
		var button: Button = UPGRADE_BUTTONS[upgrade]
		var card: PanelContainer = UPGRADE_CARDS[upgrade]
		if game_state.is_secret_upgrade_bought(upgrade):
			button.text = "Comprado"
			button.disabled = true
		else:
			var cost: int = game_state.get_secret_upgrade_cost(upgrade)
			button.text = "%d GC" % cost
			button.disabled = game_state.goober_coins < cost