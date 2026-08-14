extends Node

const GameState = preload("res://scripts/core/game_state.gd")

const SFX_NAMES := [
	"achievement", "auto_tick", "boss_death", "boss_hit", "buy", "click", "click_combo",
	"coin", "collection", "combo_break", "combo_up", "essence", "event_end", "event_start",
	"gold_hit", "goober_pop", "goober_spawn", "menu_open", "mission_done", "offline_earnings",
	"panic", "prestige", "prestige_essence", "rgb_death", "rgb_hit", "upgrade",
]

var game_state: GameState
var _sounds: Dictionary = {}


func setup(state: GameState) -> void:
	game_state = state
	for name in SFX_NAMES:
		var path := "res://assets/audio/sfx/%s.wav" % name
		if ResourceLoader.exists(path):
			_sounds[name] = load(path)


func play(name: String) -> void:
	if game_state == null or not bool(game_state.settings.get("sound_enabled", true)):
		return
	var stream: AudioStream = _sounds.get(name)
	if stream == null:
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
