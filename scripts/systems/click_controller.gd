extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal clicked

const BASE_DIFFICULTY: int = 28
const DIFFICULTY_PER_UPGRADE: int = 3
const MAX_DIFFICULTY: int = 120
const EXTRA_X_DRIFT_CHANCE: float = 0.18
const MIN_BUTTON_SCALE: float = 0.82
const SCALE_PER_UPGRADE: float = 0.004

# Constantes canônicas de efeitos de evento (game_window.py).
const GRAVITY_DRIFT := 16.0
const INVERT_DRIFT_FACTOR := 0.85
const EDGE_REBOUND_ZONE := 8.0
const CENTER_PULL_FACTOR := 0.08
const ORBIT_ANGLE_STEP := 0.12
const ORBIT_RADIUS := 42.0
const BLINK_DISTANCE := 180.0
const BLINK_CHANCE := 0.14
const BLINK_JUMP := 55.0
const FLEE_RANGE_BASE := 220.0
const FLEE_RANGE_PER_DIFFICULTY := 1.5
const FLEE_STRENGTH_BASE := 28.0
const FLEE_PRESTIGE_FACTOR := 1.8
const FLEE_WEALTH_DIVISOR := 300000.0
const FLEE_WEALTH_CAP := 2.5
const FLEE_UPGRADE_FACTOR := 0.6
const STICKY_JITTER_X := 5.0
const STICKY_JITTER_Y := 3.0
const EFFECT_TICK_INTERVAL := 0.26
const POINTER_FRESHNESS_MS := 800

var click_button: Button
var game_state: GameState

# Multipliers/capabilities de evento fornecidos pelo main (controller não conhece EventManager).
var event_move_multiplier := 1.0
var event_scale_multiplier := 1.0
var gravity_active := false
var invert_move_active := false
var center_pull_active := false
var orbit_active := false
var mouse_flee_active := false
var blink_active := false
var sticky_active := false

var _orbit_angle := 0.0
var _effect_tick_timer := 0.0

# Ponteiro virtual compartilhado (mouse desktop + touch Android) com janela de frescor:
# flee/blink só reagem a ponteiro recente e dentro da área de jogo.
var pointer_position := Vector2.ZERO
var pointer_fresh_until_ms := 0

# Testes: roll determinístico para blink (< 0 usa randf()).
var blink_roll_override := -1.0


func setup(button: Button, state: GameState) -> void:
	click_button = button
	game_state = state
	click_button.pressed.connect(_on_pressed)
	click_button.get_viewport().size_changed.connect(keep_button_inside)
	game_state.changed.connect(update_button_scale)
	update_button_scale()
	center_button()


func apply_effect_capabilities(caps: Dictionary) -> void:
	event_move_multiplier = maxf(0.0, float(caps.get("move_mult", 1.0)))
	event_scale_multiplier = maxf(0.0, float(caps.get("scale_mult", 1.0)))
	gravity_active = bool(caps.get("gravity", false))
	invert_move_active = bool(caps.get("invert_move", false))
	center_pull_active = bool(caps.get("center_pull", false))
	orbit_active = bool(caps.get("orbit", false))
	mouse_flee_active = bool(caps.get("mouse_flee", false))
	blink_active = bool(caps.get("blink", false))
	sticky_active = bool(caps.get("sticky_jitter", false))
	if not orbit_active:
		_orbit_angle = 0.0
	update_button_scale()


func set_pointer_position(pos: Vector2) -> void:
	pointer_position = pos
	pointer_fresh_until_ms = Time.get_ticks_msec() + POINTER_FRESHNESS_MS


func _process(delta: float) -> void:
	_effect_tick_timer += delta
	if _effect_tick_timer >= EFFECT_TICK_INTERVAL:
		_effect_tick_timer = 0.0
		_effect_tick()


func _effect_tick() -> void:
	if center_pull_active:
		_apply_center_pull()
	if orbit_active:
		_apply_orbit()
	if mouse_flee_active or blink_active:
		_apply_pointer_effects()


func _apply_center_pull() -> void:
	var area: Rect2 = get_play_area_rect()
	var effective_size := _get_effective_size()
	var center := Vector2(
		area.position.x + (area.size.x - effective_size.x) / 2.0,
		area.position.y + (area.size.y - effective_size.y) / 2.0
	)
	# Canônico: lerp de 8% do deslocamento restante por tick (int por eixo).
	click_button.position = Vector2(
		click_button.position.x + int((center.x - click_button.position.x) * CENTER_PULL_FACTOR),
		click_button.position.y + int((center.y - click_button.position.y) * CENTER_PULL_FACTOR)
	)


func _apply_orbit() -> void:
	_orbit_angle += ORBIT_ANGLE_STEP
	var area: Rect2 = get_play_area_rect()
	var effective_size := _get_effective_size()
	var center := Vector2(
		area.position.x + (area.size.x - effective_size.x) / 2.0,
		area.position.y + (area.size.y - effective_size.y) / 2.0
	)
	click_button.position = center + Vector2(
		cos(_orbit_angle) * ORBIT_RADIUS,
		sin(_orbit_angle) * ORBIT_RADIUS
	)
	keep_button_inside()


func _apply_pointer_effects() -> void:
	if not _pointer_is_fresh():
		return
	var area: Rect2 = get_play_area_rect()
	if not area.has_point(pointer_position):
		return

	var btn_center := click_button.position + _get_effective_size() / 2.0
	var dx: float = btn_center.x - pointer_position.x
	var dy: float = btn_center.y - pointer_position.y
	var distance_sq: float = dx * dx + dy * dy

	if blink_active:
		var roll: float = randf() if blink_roll_override < 0.0 else blink_roll_override
		if distance_sq < BLINK_DISTANCE * BLINK_DISTANCE and roll < BLINK_CHANCE:
			click_button.position = Vector2(
				click_button.position.x + randf_range(-BLINK_JUMP, BLINK_JUMP),
				click_button.position.y + randf_range(-BLINK_JUMP, BLINK_JUMP)
			)
			keep_button_inside()
		if not mouse_flee_active:
			return

	var flee_range: float = FLEE_RANGE_BASE + float(get_difficulty_step()) * FLEE_RANGE_PER_DIFFICULTY
	if not (mouse_flee_active and distance_sq < flee_range * flee_range):
		return

	var flee_strength := int(
		FLEE_STRENGTH_BASE
		+ float(game_state.prestige_level) * FLEE_PRESTIGE_FACTOR
		+ minf(float(game_state.lifetime_money) / FLEE_WEALTH_DIVISOR, FLEE_WEALTH_CAP)
		+ float(game_state.click_level + game_state.auto_level) * FLEE_UPGRADE_FACTOR
	)
	if dx != 0.0:
		click_button.position.x += flee_strength * (1.0 if dx > 0.0 else -1.0)
	if dy != 0.0:
		click_button.position.y += flee_strength * (1.0 if dy > 0.0 else -1.0)
	keep_button_inside()


func _pointer_is_fresh() -> bool:
	return Time.get_ticks_msec() < pointer_fresh_until_ms


func set_event_move_multiplier(value: float) -> void:
	event_move_multiplier = maxf(0.0, value)


func set_event_scale_multiplier(value: float) -> void:
	event_scale_multiplier = maxf(0.0, value)
	update_button_scale()


func update_button_scale() -> void:
	var total_upgrades: int = game_state.click_level + game_state.auto_level
	var base_scale: float = maxf(MIN_BUTTON_SCALE, 1.0 - total_upgrades * SCALE_PER_UPGRADE)
	# Composição: escala de progressão × escala de evento (nunca substitui).
	click_button.scale = Vector2.ONE * (base_scale * event_scale_multiplier)


func get_difficulty_step() -> int:
	var total_upgrades: int = game_state.click_level + game_state.auto_level
	return mini(BASE_DIFFICULTY + total_upgrades * DIFFICULTY_PER_UPGRADE, MAX_DIFFICULTY)


func get_play_area_rect() -> Rect2:
	var viewport_size := click_button.get_viewport_rect().size
	var top_inset := Layout.TOP_BAR_HEIGHT
	var bottom_inset := Layout.BOTTOM_BAR_HEIGHT
	var width := maxf(Layout.EDGE_MARGIN * 2.0, viewport_size.x - Layout.EDGE_MARGIN * 2.0)
	var height := maxf(1.0, viewport_size.y - top_inset - bottom_inset)
	return Rect2(Layout.EDGE_MARGIN, top_inset, width, height)


# Tamanho visual real: `size` é pré-transform; `scale` (progressão × evento)
# muda o retângulo efetivo — o clamp precisa enxergar isso.
func _get_effective_size() -> Vector2:
	return click_button.size * click_button.scale


func move_click_button_randomly() -> void:
	var step: int = maxi(1, int(round(float(get_difficulty_step()) * event_move_multiplier)))
	var area: Rect2 = get_play_area_rect()
	var effective_size := _get_effective_size()

	var drift_x: float = float(randi_range(-step, step))
	var drift_y: float = float(randi_range(-step / 2, step / 2))

	# Canônico: gravity soma +16 em drift_y ANTES do invert_move.
	if gravity_active:
		drift_y += GRAVITY_DRIFT

	if randf() < EXTRA_X_DRIFT_CHANCE:
		drift_x += float((randi() % 2) * 2 - 1) * float(step / 2)

	# Canônico: invert_move aplica depois do gravity, por eixo, com int().
	if invert_move_active:
		drift_x = int(-drift_x * INVERT_DRIFT_FACTOR)
		drift_y = int(-drift_y * INVERT_DRIFT_FACTOR)

	# Canônico: rebote de borda — drift apontando para fora é redirecionado
	# para dentro quando o botão está a 8 px da borda.
	var min_x := area.position.x
	var min_y := area.position.y
	var max_x := maxf(min_x, area.end.x - effective_size.x)
	var max_y := maxf(min_y, area.end.y - effective_size.y)
	var current_x: float = click_button.position.x
	var current_y: float = click_button.position.y
	if current_x < min_x + EDGE_REBOUND_ZONE and drift_x <= 0.0:
		drift_x = float(randi_range(maxi(1, step / 3), maxi(2, step)))
	if current_x > max_x - EDGE_REBOUND_ZONE and drift_x >= 0.0:
		drift_x = -float(randi_range(maxi(1, step / 3), maxi(2, step)))
	if current_y < min_y + EDGE_REBOUND_ZONE and drift_y <= 0.0:
		drift_y = float(randi_range(1, maxi(1, step / 3)))
	if current_y > max_y - EDGE_REBOUND_ZONE and drift_y >= 0.0:
		drift_y = -float(randi_range(1, maxi(1, step / 3)))

	click_button.position = Vector2(
		clampf(current_x + drift_x, min_x, max_x),
		clampf(current_y + drift_y, min_y, max_y)
	)


func keep_button_inside() -> void:
	var area: Rect2 = get_play_area_rect()
	var effective_size := _get_effective_size()

	click_button.position = Vector2(
		clampf(click_button.position.x, area.position.x, maxf(area.position.x, area.end.x - effective_size.x)),
		clampf(click_button.position.y, area.position.y, maxf(area.position.y, area.end.y - effective_size.y))
	)


func center_button() -> void:
	var area: Rect2 = get_play_area_rect()
	var effective_size := _get_effective_size()

	click_button.position = Vector2(
		(area.size.x - effective_size.x) / 2.0 + area.position.x,
		(area.size.y - effective_size.y) / 2.0 + area.position.y
	)


func _on_pressed() -> void:
	# Canônico: sticky adiciona jitter ±5x/±3y por clique (além de move_mult 0.35).
	_apply_sticky_jitter()
	move_click_button_randomly()
	clicked.emit()


func _apply_sticky_jitter() -> void:
	if not sticky_active:
		return
	click_button.position = Vector2(
		click_button.position.x + randf_range(-STICKY_JITTER_X, STICKY_JITTER_X),
		click_button.position.y + randf_range(-STICKY_JITTER_Y, STICKY_JITTER_Y)
	)
	keep_button_inside()
