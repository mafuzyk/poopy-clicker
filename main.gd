extends Control


const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")
const GooberManager = preload("res://scripts/goobers/goober_manager.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const ShopUI = preload("res://scripts/ui/shop_ui.gd")
const SecretShopUI = preload("res://scripts/ui/secret_shop_ui.gd")
const AchievementManager = preload("res://scripts/achievements/achievement_manager.gd")
const ToastUI = preload("res://scripts/ui/toast_ui.gd")
const Hud = preload("res://scripts/ui/hud.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const PanelManager = preload("res://scripts/ui/panel_manager.gd")
const MenuPanel = preload("res://scripts/ui/menu_panel.gd")
const AchievementsPanel = preload("res://scripts/ui/achievements_panel.gd")
const BestiaryPanel = preload("res://scripts/ui/bestiary_panel.gd")
const ShellPanel = preload("res://scripts/ui/shell_panel.gd")


var game_state: GameState
var economy: Economy
var click_controller: ClickController
var save_manager: SaveManager
var goober_manager: GooberManager
var combo_manager: ComboManager

var click_button: Button
var auto_clicker_timer: Timer
var shop_ui: ShopUI
var secret_shop_ui: SecretShopUI
var achievement_manager: AchievementManager
var toast_ui: ToastUI
var hud: Hud
var panel_manager: PanelManager
var menu_panel: MenuPanel
var achievements_panel: AchievementsPanel
var bestiary_panel: BestiaryPanel


func _ready() -> void:
	setup_game()
	setup_save()
	create_goober_manager()
	create_combo_manager()
	build_ui()
	setup_click_controller()
	setup_auto_clicker()
	setup_panels()
	achievement_manager.unlocked.connect(on_achievement_unlocked)
	setup_toast()
	setup_goobers()
	save_manager.load()
	if game_state.combo_count > 0:
		combo_manager.restart_decay()
	refresh_ui()


func setup_game() -> void:
	game_state = GameState.new()
	game_state.changed.connect(refresh_ui)
	economy = Economy.new(game_state)
	achievement_manager = AchievementManager.new()
	achievement_manager.setup(game_state)


func setup_save() -> void:
	save_manager = SaveManager.new()
	save_manager.name = "SaveManager"
	save_manager.setup(game_state)
	save_manager.add_save_handler(
		"unlocked_achievements",
		achievement_manager.get_unlocked_ids,
		achievement_manager.set_unlocked_ids
	)
	add_child(save_manager)


func setup_toast() -> void:
	toast_ui = ToastUI.new()
	toast_ui.name = "ToastUI"
	add_child(toast_ui)


func create_goober_manager() -> void:
	goober_manager = GooberManager.new()
	goober_manager.name = "GooberManager"
	add_child(goober_manager)


func create_combo_manager() -> void:
	combo_manager = ComboManager.new()
	combo_manager.name = "ComboManager"
	combo_manager.setup(game_state)
	add_child(combo_manager)


func setup_goobers() -> void:
	goober_manager.setup(click_button, game_state)


func build_ui() -> void:
	hud = Hud.new()
	hud.setup(game_state, economy)
	hud.menu_requested.connect(panel_manager_open_menu)
	hud.shop_requested.connect(panel_manager_open_shop)
	hud.bestiary_requested.connect(panel_manager_open_bestiary)
	hud.achievements_requested.connect(panel_manager_open_achievements)
	add_child(hud)

	click_button = Button.new()
	click_button.name = "ClickButton"
	click_button.text = "CLICK"
	click_button.size = Layout.CLICK_BUTTON_SIZE
	click_button.add_theme_font_size_override("font_size", 24)
	add_child(click_button)


func setup_panels() -> void:
	panel_manager = PanelManager.new()
	add_child(panel_manager)
	panel_manager.surface_opened.connect(_on_surface_opened)
	panel_manager.surface_closed.connect(_on_surface_closed)

	shop_ui = ShopUI.new()
	shop_ui.setup(game_state, economy)
	shop_ui.buy_click_upgrade.connect(on_buy_click_upgrade)
	shop_ui.buy_auto_upgrade.connect(on_buy_auto_upgrade)
	panel_manager.register_surface("shop", shop_ui)

	secret_shop_ui = SecretShopUI.new()
	secret_shop_ui.setup(game_state)
	secret_shop_ui.buy_requested.connect(on_secret_buy_requested)
	panel_manager.register_surface("gshop", secret_shop_ui)

	achievements_panel = AchievementsPanel.new()
	achievements_panel.setup(game_state, achievement_manager)
	panel_manager.register_surface("achievements", achievements_panel)

	bestiary_panel = BestiaryPanel.new()
	bestiary_panel.setup(game_state)
	panel_manager.register_surface("bestiary", bestiary_panel)

	menu_panel = MenuPanel.new()
	menu_panel.setup(game_state)
	menu_panel.surface_requested.connect(panel_manager.open_surface)
	menu_panel.save_requested.connect(save_now)
	panel_manager.register_surface("menu", menu_panel)

	_register_shell("missions", "MISSÕES", "Objetivos gerados com progresso de clique, dinheiro e goobers.", "chega com o sistema de missões (spec §18).")
	_register_shell("prestige", "PRESTIGE", "Recomeçar a partida acumulando Poopy Essence para bônus permanentes.", "chega com Prestige + Essence (spec §19).")
	_register_shell("perks", "PERKS", "Melhorias passivas compradas com Poopy Essence.", "chega com o sistema de perks (spec §20).")
	_register_shell("stats", "ESTATÍSTICAS", "Histórico completo da partida: cliques, goobers, ganhos totais.", "chega com o sistema de stats (spec §25).")
	_register_shell("themes", "TEMAS", "Aparência do jogo: fundo, cores e estilo.", "chega com os temas (spec §21).")
	_register_shell("settings", "CONFIGURAÇÕES", "Som, texto, desempenho e acessibilidade.", "chega com as configurações (spec §22).")


func _register_shell(surface_id: String, title: String, description: String, note: String) -> void:
	var shell := ShellPanel.new()
	shell.setup(title, description, note)
	panel_manager.register_surface(surface_id, shell)


func panel_manager_open_menu() -> void:
	panel_manager.open_surface("menu")


func panel_manager_open_shop() -> void:
	panel_manager.open_surface("shop")


func panel_manager_open_bestiary() -> void:
	panel_manager.open_surface("bestiary")


func panel_manager_open_achievements() -> void:
	panel_manager.open_surface("achievements")


func _on_surface_opened(_id: String) -> void:
	_set_gameplay_blocked(true)


func _on_surface_closed(_id: String) -> void:
	_set_gameplay_blocked(false)


func _set_gameplay_blocked(blocked: bool) -> void:
	click_button.disabled = blocked
	click_button.modulate = Color(0.55, 0.55, 0.6, 0.35) if blocked else Color.WHITE
	goober_manager.set_gameplay_input_blocked(blocked)


func save_now() -> void:
	save_manager.save()
	toast_ui.show_toast("Jogo salvo", "Progresso gravado")


func on_secret_buy_requested(upgrade: String) -> void:
	game_state.try_buy_secret_upgrade(upgrade)


func on_buy_click_upgrade() -> void:
	game_state.try_buy_click_upgrade(economy.get_click_upgrade_cost())


func on_buy_auto_upgrade() -> void:
	game_state.try_buy_auto_upgrade(economy.get_auto_upgrade_cost())


func setup_click_controller() -> void:
	click_controller = ClickController.new()
	click_controller.name = "ClickController"
	click_controller.setup(click_button, game_state)
	click_controller.clicked.connect(on_click)
	add_child(click_controller)


func setup_auto_clicker() -> void:
	auto_clicker_timer = Timer.new()
	auto_clicker_timer.name = "AutoClickerTimer"
	auto_clicker_timer.wait_time = 1.0
	auto_clicker_timer.one_shot = false
	auto_clicker_timer.autostart = true
	auto_clicker_timer.timeout.connect(on_auto_click)
	add_child(auto_clicker_timer)


func on_click() -> void:
	# Canônico: ganho usa o multiplicador ATUAL; só depois o combo incrementa.
	var base_gain: int = economy.get_click_value()
	var click_gain: int = int(float(base_gain) * game_state.get_combo_multiplier())
	game_state.register_button_click()
	game_state.add_money(click_gain)
	combo_manager.register_manual_click()
	goober_manager.register_click()


func on_auto_click() -> void:
	game_state.add_money(economy.get_auto_value())


func on_achievement_unlocked(id: String) -> void:
	var definition := achievement_manager.get_definition(id)
	if definition.is_empty():
		return
	toast_ui.show_toast(definition["name"], definition["hint"])


func refresh_ui() -> void:
	hud.refresh()
	if menu_panel != null and menu_panel.visible:
		menu_panel.refresh()
	if achievements_panel != null and achievements_panel.visible:
		achievements_panel.refresh()
	if bestiary_panel != null and bestiary_panel.visible:
		bestiary_panel.refresh()