extends Control
class_name ComboDisplay

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var state
var combo_manager
var theme_ref: ThemeController

var _label: Label


func setup(state_ref, combo_manager_ref, theme_controller: ThemeController) -> void:
	state = state_ref
	combo_manager = combo_manager_ref
	theme_ref = theme_controller
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_label = Label.new()
	_label.name = "ComboLabel"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_font_size_override("font_size", UiTokens.FONT_CARD_TITLE)
	add_child(_label)

	combo_manager.combo_increased.connect(_on_combo_increased)
	combo_manager.combo_broken.connect(_on_combo_broken)
	_apply_theme()
	_refresh()


func _apply_theme() -> void:
	if theme_ref == null or _label == null:
		return
	_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_ACCENT))


func _on_combo_increased(_count: int, _multiplier: float) -> void:
	_refresh()


func _on_combo_broken() -> void:
	_refresh()


func _refresh() -> void:
	if state == null:
		return
	var count: int = state.combo_count
	if count <= 0:
		visible = false
		return
	visible = true
	_label.text = "x%d  •  %.1fx" % [count, state.combo_multiplier]
