extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested
signal surface_requested(id: String)
signal save_requested

const SURFACE_ORDER := [
	"shop",
	"gshop",
	"bestiary",
	"achievements",
	"missions",
	"prestige",
	"perks",
	"stats",
	"themes",
	"settings",
]

const SURFACE_LABELS := {
	"shop": "Loja",
	"gshop": "Loja Goobers",
	"bestiary": "Gooberário",
	"achievements": "Conquistas",
	"missions": "Missões",
	"prestige": "Prestige",
	"perks": "Perks",
	"stats": "Estatísticas",
	"themes": "Temas",
	"settings": "Configurações",
}

const SURFACE_ICONS := {
	"shop": "▲",
	"gshop": "◉",
	"bestiary": "◈",
	"achievements": "★",
	"missions": "☑",
	"prestige": "✦",
	"perks": "●",
	"stats": "≡",
	"themes": "◐",
	"settings": "⚙",
}

var base: BasePanel
var game_state: GameState
var _grid: GridContainer
var _gshop_button: Button


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("MENU")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build_grid()
	_build_actions()
	game_state.changed.connect(refresh)
	refresh()


func _build_grid() -> void:
	var grid_wrap := PanelContainer.new()
	grid_wrap.name = "MenuGridCard"
	grid_wrap.add_theme_stylebox_override("panel", UiStyles.card_style())
	base.add_to_content(grid_wrap)

	_grid = GridContainer.new()
	_grid.name = "MenuGrid"
	_grid.columns = 2
	_grid.add_theme_constant_override("h_separation", 8)
	_grid.add_theme_constant_override("v_separation", 8)
	_grid.resized.connect(_update_columns)
	grid_wrap.add_child(_grid)

	for surface_id: String in SURFACE_ORDER:
		var button: Button = _make_entry_button(surface_id)
		_grid.add_child(button)
		if surface_id == "gshop":
			_gshop_button = button


func _make_entry_button(surface_id: String) -> Button:
	var button := Button.new()
	button.name = "Entry" + surface_id.capitalize()
	button.text = "%s %s" % [SURFACE_ICONS.get(surface_id, ""), SURFACE_LABELS[surface_id]]
	button.custom_minimum_size = Vector2(0.0, Layout.NAV_BUTTON_HEIGHT)
	button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	button.add_theme_font_size_override("font_size", Layout.PANEL_ACTION_FONT)
	UiStyles.style_button(button)
	button.pressed.connect(surface_requested.emit.bind(surface_id))
	return button


func _build_actions() -> void:
	var actions := VBoxContainer.new()
	actions.name = "MenuActions"
	actions.add_theme_constant_override("separation", 8)

	var separator := HSeparator.new()
	separator.name = "MenuSeparator"
	actions.add_child(separator)

	var save_button := UiStyles.make_button("Salvar agora", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	save_button.name = "SaveNowButton"
	save_button.pressed.connect(save_requested.emit)
	actions.add_child(save_button)

	var close_button := UiStyles.make_button("Voltar ao jogo", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	close_button.name = "CloseMenuButton"
	close_button.pressed.connect(close_requested.emit)
	actions.add_child(close_button)

	base.add_to_content(actions)


func _update_columns() -> void:
	if _grid == null or not _grid.is_inside_tree():
		return
	if _grid.size.x >= 720.0:
		_grid.columns = 3
	elif _grid.size.x >= 360.0:
		_grid.columns = 2
	else:
		_grid.columns = 1


func refresh() -> void:
	if _gshop_button == null:
		return
	_gshop_button.visible = game_state.secret_shop_unlocked