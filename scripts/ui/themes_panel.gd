extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested
signal theme_clicked(id: String)

var game_state: GameState
var base: BasePanel
var _buttons: Dictionary = {}


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("TEMAS")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build()
	game_state.changed.connect(refresh)
	refresh()


func _build() -> void:
	var coins_label := UiStyles.make_label("", Layout.PANEL_ACTION_FONT, Color(1, 1, 1, 0.9))
	coins_label.name = "CoinsLabel"
	coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(coins_label)
	coins_label.text = ""

	for id in GameState.UI_THEMES:
		var button := UiStyles.make_button("", 14, 44.0)
		button.name = "Theme" + String(id).capitalize()
		button.pressed.connect(theme_clicked.emit.bind(id))
		_buttons[id] = button
		base.add_to_content(button)
	refresh()


func refresh() -> void:
	if game_state == null or base == null:
		return
	for id in GameState.UI_THEMES:
		var button: Button = _buttons[id]
		var name := str(GameState.UI_THEMES[id]["name"])
		if id == game_state.selected_ui_theme:
			button.text = "%s — equipado" % name
			button.disabled = true
		elif game_state.is_theme_owned(id):
			button.text = "%s — equipar" % name
			button.disabled = false
		else:
			button.text = "%s — %d GC" % [name, game_state.get_theme_cost(id)]
			button.disabled = game_state.goober_coins < game_state.get_theme_cost(id)
