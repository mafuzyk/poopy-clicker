extends Node
class_name ThemeController

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const GameState = preload("res://scripts/core/game_state.gd")

signal tokens_changed

var game_state: GameState
var _palette: Dictionary = {}
var _applied_theme := ""

const THEME_OVERRIDES := {
	"default": {},
	"gold": {UiTokens.COLOR_ACCENT: Color("#F6C85F"), UiTokens.COLOR_BACKGROUND: Color("#16130C"), UiTokens.COLOR_SURFACE: Color("#272216")},
	"ice": {UiTokens.COLOR_ACCENT: Color("#69D5FF"), UiTokens.COLOR_BACKGROUND: Color("#0D141A"), UiTokens.COLOR_SURFACE: Color("#18252D")},
	"void": {UiTokens.COLOR_ACCENT: Color("#D16BFF"), UiTokens.COLOR_BACKGROUND: Color("#0D0912"), UiTokens.COLOR_SURFACE: Color("#211727")},
	"candy": {UiTokens.COLOR_ACCENT: Color("#FF79B0"), UiTokens.COLOR_BACKGROUND: Color("#180F16"), UiTokens.COLOR_SURFACE: Color("#2B1B26")},
	"matrix": {UiTokens.COLOR_ACCENT: Color("#65E68A"), UiTokens.COLOR_BACKGROUND: Color("#0C140E"), UiTokens.COLOR_SURFACE: Color("#17251A")},
	"sunset": {UiTokens.COLOR_ACCENT: Color("#FF8B66"), UiTokens.COLOR_BACKGROUND: Color("#18100F"), UiTokens.COLOR_SURFACE: Color("#2B1D1A")},
}


func setup(state: GameState) -> void:
	game_state = state
	game_state.changed.connect(_sync_from_state)
	_sync_from_state()


func _sync_from_state() -> void:
	var id := game_state.selected_ui_theme if game_state != null else "default"
	if id == _applied_theme and not _palette.is_empty():
		return
	_applied_theme = id if THEME_OVERRIDES.has(id) else "default"
	_palette = UiTokens.default_palette()
	for role in THEME_OVERRIDES[_applied_theme]:
		_palette[role] = THEME_OVERRIDES[_applied_theme][role]
	tokens_changed.emit()


func get_color(role: StringName) -> Color:
	if _palette.has(role):
		return _palette[role]
	push_warning("ThemeController: missing semantic color role: %s" % role)
	return Color.MAGENTA


func get_palette() -> Dictionary:
	return _palette.duplicate()
