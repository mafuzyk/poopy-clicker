extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested
signal prestige_confirmed

var base: BasePanel
var game_state: GameState

var prestige_button: Button
var confirm_box: Control
var confirm_button: Button
var cancel_button: Button

var _info_label: Label


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("PRESTIGE", false)
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build()
	game_state.changed.connect(refresh)
	visibility_changed.connect(_on_visibility_changed)
	refresh()


func _build() -> void:
	_info_label = UiStyles.make_label("", 14, Color(1, 1, 1, 0.9))
	_info_label.name = "InfoLabel"
	_info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(_info_label)

	prestige_button = UiStyles.make_button("Prestigiar", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	prestige_button.name = "PrestigeButton"
	prestige_button.pressed.connect(_on_prestige_pressed)
	base.add_to_content(prestige_button)

	confirm_box = VBoxContainer.new()
	confirm_box.name = "ConfirmBox"
	confirm_box.visible = false
	confirm_box.add_theme_constant_override("separation", 8)

	var confirm_label := UiStyles.make_label("Confirmar Prestige?\nEsta ação reinicia o progresso da run.", 14, Color(1, 0.9, 0.6, 1.0))
	confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	confirm_box.add_child(confirm_label)

	confirm_button = UiStyles.make_button("Confirmar Prestige", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	confirm_button.name = "ConfirmButton"
	confirm_button.pressed.connect(prestige_confirmed.emit)
	confirm_box.add_child(confirm_button)

	cancel_button = UiStyles.make_button("Cancelar", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	cancel_button.name = "CancelButton"
	cancel_button.pressed.connect(_on_cancel_pressed)
	confirm_box.add_child(cancel_button)

	base.add_to_content(confirm_box)


func _on_prestige_pressed() -> void:
	confirm_box.visible = true
	prestige_button.visible = false


func _on_cancel_pressed() -> void:
	reset_confirm()


# Sempre que o painel é exibido, volta ao estado inicial (botão, sem confirm).
func _on_visibility_changed() -> void:
	if visible:
		reset_confirm()


func reset_confirm() -> void:
	if confirm_box == null:
		return
	confirm_box.visible = false
	prestige_button.visible = true


func refresh() -> void:
	if game_state == null or base == null:
		return
	var level := game_state.prestige_level
	var cost := game_state.get_prestige_cost()
	var gain := game_state.calculate_prestige_gain()
	var next := level + 1
	_info_label.text = (
		"Prestige atual: P%d\n"
		+ "Poopy Essence: %d\n\n"
		+ "Próximo custo: $%s\n"
		+ "Essência estimada: +%d\n\n"
		+ "Bônus atual:\nClique +%d%%\nAuto +%d%%\n\n"
		+ "Próximo nível:\nClique +%d%%\nAuto +%d%%\n\n"
		+ "Será resetado:\ndinheiro da run, upgrades, Goober Coins,\n"
		+ "progresso/itens da loja Goober e combo.\n\n"
		+ "Será mantido:\nPrestige, Poopy Essence, conquistas,\n"
		+ "Gooberário e estatísticas históricas."
	) % [level, game_state.poopy_essence, NumberFormat.format(cost), gain, level * 12, level * 10, next * 12, next * 10]
	prestige_button.disabled = not game_state.can_prestige()
