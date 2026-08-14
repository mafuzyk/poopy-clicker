extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested
signal buy_perk_requested(key: String)

var game_state: GameState
var base: BasePanel
var essence_label: Label
var _buttons: Dictionary = {}
var _level_labels: Dictionary = {}


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("PERKS")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build()
	game_state.changed.connect(refresh)
	refresh()


func _build() -> void:
	essence_label = UiStyles.make_label("", Layout.PANEL_ACTION_FONT, Color(0.85, 0.7, 1.0))
	essence_label.name = "EssenceLabel"
	essence_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(essence_label)

	for def in GameState.PERK_DEFS:
		var key := str(def["key"])
		var card := PanelContainer.new()
		card.name = "Perk" + key.capitalize()
		card.add_theme_stylebox_override("panel", UiStyles.card_style())

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 12)
		card.add_child(row)

		var info := VBoxContainer.new()
		info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		info.add_theme_constant_override("separation", 2)
		row.add_child(info)

		var name_label := UiStyles.make_label(str(def["name"]), 16, Color(0.95, 0.95, 0.97, 1.0))
		info.add_child(name_label)

		var desc_label := UiStyles.make_label(str(def["desc"]), 12, Color(1, 1, 1, 0.7))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		info.add_child(desc_label)

		var level_label := UiStyles.make_label("", 13, Color(0.9, 0.9, 1.0, 0.9))
		info.add_child(level_label)

		var button := UiStyles.make_button("", 14, 40.0)
		button.custom_minimum_size.x = 92.0
		button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		button.pressed.connect(buy_perk_requested.emit.bind(key))
		row.add_child(button)

		_buttons[key] = button
		_level_labels[key] = level_label
		base.add_to_content(card)


func refresh() -> void:
	if game_state == null or base == null:
		return
	essence_label.text = "Poopy Essence: " + NumberFormat.format(game_state.poopy_essence)
	for def in GameState.PERK_DEFS:
		var key := str(def["key"])
		var level := game_state.get_perk_level(key)
		var max_level := int(def["max_level"])
		var label: Label = _level_labels[key]
		label.text = "Nível %d/%d" % [level, max_level]
		var button: Button = _buttons[key]
		if level >= max_level:
			button.text = "MAX"
			button.disabled = true
		else:
			button.text = "%d" % game_state.get_perk_cost(key)
			button.disabled = game_state.poopy_essence < game_state.get_perk_cost(key)
