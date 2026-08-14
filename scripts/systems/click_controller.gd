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

var click_button: Button
var game_state: GameState
# Multipliers de evento fornecidos pelo main (controller não conhece EventManager).
var event_move_multiplier := 1.0
var event_scale_multiplier := 1.0


func setup(button: Button, state: GameState) -> void:
	click_button = button
	game_state = state
	click_button.pressed.connect(_on_pressed)
	click_button.get_viewport().size_changed.connect(keep_button_inside)
	game_state.changed.connect(update_button_scale)
	update_button_scale()
	center_button()


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

	if randf() < EXTRA_X_DRIFT_CHANCE:
		drift_x += float((randi() % 2) * 2 - 1) * float(step / 2)

	click_button.position = Vector2(
		clampf(click_button.position.x + drift_x, area.position.x, maxf(area.position.x, area.end.x - effective_size.x)),
		clampf(click_button.position.y + drift_y, area.position.y, maxf(area.position.y, area.end.y - effective_size.y))
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
	move_click_button_randomly()
	clicked.emit()