extends Node

const GameState = preload("res://scripts/core/game_state.gd")

signal combo_increased(count: int, multiplier: float)
signal combo_broken

const BASE_DECAY_SECONDS := 1.8

var game_state: GameState
var decay_timer: Timer


func setup(state: GameState) -> void:
	game_state = state
	decay_timer = Timer.new()
	decay_timer.name = "ComboDecayTimer"
	decay_timer.one_shot = true
	decay_timer.timeout.connect(_on_decay_timeout)
	add_child(decay_timer)


func register_manual_click(extra_grace_seconds: float = 0.0) -> void:
	if game_state == null:
		return
	game_state.increment_combo()
	restart_decay(extra_grace_seconds)
	combo_increased.emit(game_state.combo_count, game_state.combo_multiplier)


# Reinicia o decay sem incrementar o combo (usado ao carregar combo ativo).
func restart_decay(extra_grace_seconds: float = 0.0) -> void:
	if game_state == null:
		return
	decay_timer.start(BASE_DECAY_SECONDS + maxf(0.0, extra_grace_seconds))


func _on_decay_timeout() -> void:
	game_state.reset_combo()
	combo_broken.emit()