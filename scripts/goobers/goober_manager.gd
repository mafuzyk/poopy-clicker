extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Goober = preload("res://scripts/goobers/goober.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal goober_clicked

const MAX_GOOBERS := 10
const PASSIVE_SPAWN_INTERVAL := 12.0
const CLICK_SPAWN_THRESHOLD := 15
const SIZE_RATIO := 0.24
const GOOBER_SIZE_MIN := 88.0
const GOOBER_SIZE_MAX := 150.0
const ANIMATIONS := ["idle", "walk", "scare", "panic"]

# TEMP: ferramenta de teste determinístico no device até a UI final (remover na fase de polimento).
# Escondida por padrão; ative mudando DEV_TEST_SPAWN para true se precisar testar spawn manual.
var DEV_TEST_SPAWN := false
var _gameplay_input_blocked := false


func _ready() -> void:
	set_process_unhandled_input(true)

var click_button: Control
var game_state: GameState
var catalog: GooberCatalog
var shared_frames: SpriteFrames
var goobers: Array[Goober] = []
var click_spawn_counter := 0
var passive_spawn_timer := PASSIVE_SPAWN_INTERVAL

# Snapshot de modificadores de evento (fornecido pelo main; manager não conhece
# EventManager nem ramifica por ID). rare_bonus/boss_bonus/special_essence_bonus
# são plumbing exposto: chegam aqui e ficam consultáveis, mas o efeito de payout/
# spawn correspondente é deferido até o subsistema real existir (ver source map).
const DEFAULT_EVENT_SNAPSHOT := {
	"spawn_bonus": 0,
	"rare_bonus": 0.0,
	"boss_bonus": 0.0,
	"panic_reduce": 0,
	"special_money_mult": 1.0,
	"special_coin_bonus": 0,
	"special_essence_bonus": 0,
}

var event_snapshot: Dictionary = DEFAULT_EVENT_SNAPSHOT.duplicate(true)


# Chaves ausentes voltam ao default (snapshot vazio = reset completo, usado no end).
func apply_goober_snapshot(snapshot: Dictionary) -> void:
	for key in event_snapshot.keys():
		event_snapshot[key] = snapshot.get(key, DEFAULT_EVENT_SNAPSHOT[key])
	for goober in goobers:
		goober.event_panic_reduce = float(event_snapshot["panic_reduce"])


func get_goober_snapshot() -> Dictionary:
	return event_snapshot.duplicate()


func _effective_max_goobers() -> int:
	return MAX_GOOBERS + int(event_snapshot["spawn_bonus"])


func setup(button: Control, state_ref: GameState) -> void:
	click_button = button
	game_state = state_ref
	catalog = GooberCatalog.new()
	build_shared_frames()
	if DEV_TEST_SPAWN:
		build_dev_spawn_button()


func build_shared_frames() -> void:
	shared_frames = SpriteFrames.new()

	for animation in ANIMATIONS:
		shared_frames.add_animation(animation)
		var files: PackedStringArray = DirAccess.get_files_at("res://assets/goobers/" + animation)
		files.sort()
		for file in files:
			if not file.ends_with(".png"):
				continue
			var path := "res://assets/goobers/%s/%s" % [animation, file]
			shared_frames.add_frame(animation, load(path))


func _process(delta: float) -> void:
	if click_button == null:
		return

	passive_spawn_timer -= delta
	if passive_spawn_timer <= 0.0:
		passive_spawn_timer = PASSIVE_SPAWN_INTERVAL
		try_spawn_goober()

	var bounds := get_bounds()
	for i in range(goobers.size() - 1, -1, -1):
		var goober := goobers[i]
		goober.update(delta, click_button, bounds)
		if goober.wants_despawn():
			remove_child(goober)
			goober.queue_free()
			goobers.erase(goober)


func get_bounds() -> Rect2:
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var top := Layout.TOP_BAR_HEIGHT + Layout.EDGE_MARGIN
	var bottom := Layout.BOTTOM_BAR_HEIGHT + Layout.EDGE_MARGIN
	return Rect2(Layout.EDGE_MARGIN, top, viewport_size.x - Layout.EDGE_MARGIN * 2.0, viewport_size.y - top - bottom)


func try_spawn_goober() -> void:
	if goobers.size() >= _effective_max_goobers():
		return
	spawn_goober_of_type(catalog.roll_type())


func force_spawn(type_id: String) -> bool:
	if not catalog.is_enabled(type_id):
		push_warning("GooberManager: tipo bloqueado ou inexistente: " + type_id)
		return false
	if goobers.size() >= _effective_max_goobers():
		return false
	return spawn_goober_of_type(type_id)


func spawn_goober_of_type(type_id: String) -> bool:
	var data := catalog.get_type(type_id)
	if data.is_empty():
		return false

	var bounds := get_bounds()
	var base_size := clampf(bounds.size.y * SIZE_RATIO, GOOBER_SIZE_MIN, GOOBER_SIZE_MAX)

	var goober := Goober.new()
	goober.name = "Goober%d" % (goobers.size() + 1)
	goober.setup(shared_frames, base_size, type_id, data, game_state)
	goober.event_panic_reduce = float(event_snapshot["panic_reduce"])
	goober.defeated.connect(_on_goober_defeated.bind(goober))

	var goober_size := base_size * float(data["scale"])
	var margin := goober_size * 0.5
	goober.position = Vector2(
		bounds.position.x + margin + randf() * maxf(1.0, bounds.size.x - goober_size),
		bounds.position.y + margin + randf() * maxf(1.0, bounds.size.y - goober_size)
	)

	add_child(goober)
	goobers.append(goober)
	game_state.register_goober_seen(type_id)
	return true


func register_click() -> void:
	click_spawn_counter += 1
	if click_spawn_counter >= CLICK_SPAWN_THRESHOLD:
		click_spawn_counter = 0
		try_spawn_goober()


var dev_spawn_index := 0
var dev_button: Button


func build_dev_spawn_button() -> void:
	dev_button = Button.new()
	dev_button.name = "DevSpawnButton"
	dev_button.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	dev_button.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	dev_button.grow_vertical = Control.GROW_DIRECTION_BEGIN
	dev_button.offset_left = -(Layout.EDGE_MARGIN + 132.0)
	dev_button.offset_right = -Layout.EDGE_MARGIN
	dev_button.offset_top = -(Layout.BOTTOM_BAR_HEIGHT + Layout.EDGE_MARGIN + 34.0)
	dev_button.offset_bottom = -(Layout.BOTTOM_BAR_HEIGHT + Layout.EDGE_MARGIN)
	dev_button.modulate.a = 0.55
	dev_button.add_theme_font_size_override("font_size", 12)
	dev_button.pressed.connect(_on_dev_spawn_pressed)
	add_child(dev_button)
	update_dev_spawn_button_text()


func get_dev_spawn_pool() -> Array[String]:
	var pool: Array[String] = []
	for id in catalog.get_enabled_ids():
		if id != "normal":
			pool.append(id)
	return pool


func update_dev_spawn_button_text() -> void:
	var pool := get_dev_spawn_pool()
	if pool.is_empty():
		return
	dev_button.text = "DEV: " + String(pool[dev_spawn_index % pool.size()])


func _on_dev_spawn_pressed() -> void:
	var pool := get_dev_spawn_pool()
	if pool.is_empty():
		return
	var type_id: String = pool[dev_spawn_index % pool.size()]
	dev_spawn_index += 1
	spawn_goober_of_type(type_id)
	update_dev_spawn_button_text()


func set_gameplay_input_blocked(blocked: bool) -> void:
	_gameplay_input_blocked = blocked


func _unhandled_input(event: InputEvent) -> void:
	if _gameplay_input_blocked:
		return
	var pressed := false
	var tap_position := Vector2.ZERO

	if event is InputEventMouseButton:
		pressed = (event as InputEventMouseButton).pressed
		tap_position = (event as InputEventMouseButton).position
	elif event is InputEventScreenTouch:
		pressed = (event as InputEventScreenTouch).pressed
		tap_position = (event as InputEventScreenTouch).position

	if not pressed:
		return

	for i in range(goobers.size() - 1, -1, -1):
		if goobers[i].get_rect().has_point(tap_position):
			goobers[i].handle_click()
			get_viewport().set_input_as_handled()
			return


func _on_goober_defeated(goober: Goober) -> void:
	var data := catalog.get_type(goober.type_id)
	if data.is_empty():
		return
	game_state.register_goober_defeated(goober.type_id)
	var is_special: bool = goober.type_id != "normal"

	# Canônico (goober.py): payout = money * rarity_mult; depois special_money_mult
	# apenas para não-normal (quando > 1.0).
	var payout: int = int(float(data["money"]) * catalog.get_rarity_multiplier(String(data["rarity"])))
	var special_money_mult: float = float(event_snapshot["special_money_mult"])
	if is_special and special_money_mult > 1.0:
		payout = int(float(payout) * special_money_mult)

	# special_coin_bonus: apenas não-normal, apenas com secret shop desbloqueada.
	var extra_coins := 0
	if is_special and game_state.secret_shop_unlocked:
		extra_coins = int(event_snapshot["special_coin_bonus"])

	game_state.register_goober_click(goober.type_id, int(data["progress"]), int(data["gc"]), extra_coins)
	game_state.add_money(payout)
	goober_clicked.emit()