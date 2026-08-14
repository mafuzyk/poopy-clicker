extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested

var game_state: GameState
var base: BasePanel
var _label: Label


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("ESTATÍSTICAS")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_label = UiStyles.make_label("", 15, Color(1, 1, 1, 0.92))
	_label.name = "StatsLabel"
	base.add_to_content(_label)
	game_state.changed.connect(refresh)
	refresh()


func refresh() -> void:
	if game_state == null or base == null:
		return
	var goobers_clicked := 0
	for type_id in game_state.bestiary_counts:
		goobers_clicked += int(game_state.bestiary_counts[type_id].get("clicked", 0))
	_label.text = (
		"Cliques no botão: %s\n"
		+ "Goobers clicados: %s\n"
		+ "Tipos vistos: %d\n"
		+ "Dinheiro total ganho: $%s\n"
		+ "Prestígio atual: P%d\n"
		+ "Prestígios feitos: %d\n"
		+ "Poopy Essence: %d\n"
		+ "Goober Coins: %d\n"
		+ "Maior combo: %d\n"
		+ "Eventos vistos: %d\n"
		+ "Ganho offline: $%s\n"
		+ "Tempo offline (s): %s"
	) % [
		NumberFormat.format(game_state.button_clicks_total),
		NumberFormat.format(goobers_clicked),
		game_state.get_collection_unique_seen(),
		NumberFormat.format(game_state.get_money_earned_total()),
		game_state.prestige_level,
		int(game_state.stats.get("prestiges_done", 0)),
		game_state.poopy_essence,
		NumberFormat.format(game_state.goober_coins),
		game_state.get_highest_combo(),
		game_state.get_events_seen(),
		NumberFormat.format(int(game_state.stats.get("offline_earned_total", 0))),
		NumberFormat.format(int(game_state.stats.get("offline_seconds", 0))),
	]
