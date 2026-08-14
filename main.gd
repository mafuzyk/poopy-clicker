extends Control


const GameState = preload("res://scripts/core/game_state.gd")
const Economy = preload("res://scripts/systems/economy.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const SaveManager = preload("res://scripts/systems/save_manager.gd")
const GooberManager = preload("res://scripts/goobers/goober_manager.gd")
const ComboManager = preload("res://scripts/systems/combo_manager.gd")
const EventManager = preload("res://scripts/systems/event_manager.gd")
const EventCatalog = preload("res://scripts/data/event_catalog.gd")
const EventBanner = preload("res://scripts/ui/event_banner.gd")
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
var event_manager: EventManager
var event_banner: EventBanner
var invert_overlay: ColorRect

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
	create_event_manager()
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


func create_event_manager() -> void:
	event_manager = EventManager.new()
	event_manager.name = "EventManager"
	event_manager.setup(game_state)
	event_manager.event_started.connect(_on_event_started)
	event_manager.event_ended.connect(_on_event_ended)
	add_child(event_manager)


# start: aplica definition + derived capabilities do evento INICIADO.
func _on_event_started(id: String, definition: Dictionary) -> void:
	if click_controller == null:
		return
	var caps: Dictionary = definition.duplicate()
	for key in EventCatalog.derived_capabilities(id).keys():
		caps[key] = EventCatalog.derived_capabilities(id)[key]
	click_controller.apply_effect_capabilities(caps)
	_apply_goober_snapshot_from_event()
	if invert_overlay != null:
		invert_overlay.visible = event_manager.get_bool_modifier("invert_colors", false)


# end: aplica capabilities/snapshot VAZIOS (defaults) — nunca reaplica
# derived do evento que terminou (id do event_ended é o antigo).
func _on_event_ended(_id: String) -> void:
	if click_controller == null:
		return
	click_controller.apply_effect_capabilities({})
	if goober_manager != null:
		goober_manager.apply_goober_snapshot({})
	if invert_overlay != null:
		invert_overlay.visible = false


func _apply_goober_snapshot_from_event() -> void:
	if goober_manager == null:
		return
	goober_manager.apply_goober_snapshot({
		"spawn_bonus": event_manager.get_float_modifier("spawn_bonus", 0.0),
		"rare_bonus": event_manager.get_float_modifier("rare_bonus", 0.0),
		"boss_bonus": event_manager.get_float_modifier("boss_bonus", 0.0),
		"panic_reduce": event_manager.get_float_modifier("panic_reduce", 0.0),
		"special_money_mult": event_manager.get_float_modifier("special_money_mult", 1.0),
		"special_coin_bonus": event_manager.get_float_modifier("special_coin_bonus", 0.0),
		"special_essence_bonus": event_manager.get_float_modifier("special_essence_bonus", 0.0),
	})


func _input(event: InputEvent) -> void:
	# Ponteiro virtual compartilhado: mouse (desktop) + touch (Android) alimentam
	# o mesmo pointer do ClickController (flee/blink usam com janela de frescor).
	if click_controller == null:
		return
	var pointer_position := Vector2.INF
	if event is InputEventMouseMotion:
		pointer_position = (event as InputEventMouseMotion).position
	elif event is InputEventScreenTouch:
		pointer_position = (event as InputEventScreenTouch).position
	elif event is InputEventScreenDrag:
		pointer_position = (event as InputEventScreenDrag).position
	if pointer_position != Vector2.INF:
		click_controller.set_pointer_position(pointer_position)


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

	event_banner = EventBanner.new()
	event_banner.setup(event_manager)
	add_child(event_banner)

	create_invert_overlay()


func create_invert_overlay() -> void:
	# Overlay temporário full-screen, transparente a input, que inverte a cena
	# renderizada enquanto o capability invert_colors está ativo (sem tocar na
	# UI provisória; será substituído no redesign final).
	invert_overlay = ColorRect.new()
	invert_overlay.name = "InvertOverlay"
	invert_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	invert_overlay.z_index = 100
	invert_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	invert_overlay.color = Color.WHITE
	invert_overlay.visible = false
	var shader := Shader.new()
	shader.code = "shader_type canvas_item;\n\
		uniform sampler2D screen_tex : hint_screen_texture, filter_linear;\n\
		void fragment() {\n\
			vec4 c = texture(screen_tex, SCREEN_UV);\n\
			COLOR = vec4(vec3(1.0) - c.rgb, c.a);\n\
		}"
	var material := ShaderMaterial.new()
	material.shader = shader
	invert_overlay.material = material
	add_child(invert_overlay)


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
	# Canônico: base click × event click_mult × combo ATUAL; só depois incrementa combo.
	var base_gain: int = economy.get_click_value()
	var click_gain: int = compute_click_gain(
		base_gain,
		event_manager.get_float_modifier("click_mult", 1.0),
		game_state.get_combo_multiplier()
	)
	game_state.register_button_click()
	game_state.add_money(click_gain)
	game_state.goober_coins += compute_click_coin_grant(
		game_state.secret_shop_unlocked,
		event_manager.get_float_modifier("click_coin_bonus", 0.0)
	)
	combo_manager.register_manual_click(combo_grace_ms_to_seconds(
		event_manager.get_float_modifier("combo_grace", 0.0)
	))
	goober_manager.register_click()


func on_auto_click() -> void:
	var gain: int = compute_auto_gain(
		economy.get_auto_value(),
		event_manager.get_float_modifier("auto_mult", 1.0)
	)
	game_state.add_money(gain)


static func compute_click_gain(base_gain: int, event_click_mult: float, combo_mult: float) -> int:
	return int(float(base_gain) * event_click_mult * combo_mult)


static func compute_auto_gain(base_gain: int, event_auto_mult: float) -> int:
	return int(float(base_gain) * event_auto_mult)


# combo_grace no canônico é ms (EVENT_INFO); ComboManager usa segundos.
static func combo_grace_ms_to_seconds(grace_ms: float) -> float:
	return grace_ms / 1000.0


# Canônico: coin_rain concede GC por clique apenas com a secret shop desbloqueada.
static func compute_click_coin_grant(secret_shop_unlocked: bool, bonus: float) -> int:
	if not secret_shop_unlocked or bonus <= 0.0:
		return 0
	return int(bonus)


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