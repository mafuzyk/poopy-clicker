extends Button
class_name IconButton

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController


func setup(theme_controller: ThemeController, icon_text: String) -> void:
	theme_ref = theme_controller
	text = icon_text
	focus_mode = Control.FOCUS_ALL
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _restyle() -> void:
	if theme_ref == null:
		return
	custom_minimum_size = Vector2(UiTokens.TOUCH_MIN, UiTokens.TOUCH_MIN)
	var bg := Color.TRANSPARENT
	var border := Color.TRANSPARENT
	var text := theme_ref.get_color(UiTokens.COLOR_TEXT_SECONDARY)

	add_theme_stylebox_override("normal", _box(bg, border))
	add_theme_stylebox_override("hover", _box(theme_ref.get_color(UiTokens.COLOR_SURFACE_HIGH), border))
	add_theme_stylebox_override("pressed", _box(theme_ref.get_color(UiTokens.COLOR_SURFACE_LOW), border))
	add_theme_stylebox_override("focus", _box(Color.TRANSPARENT, theme_ref.get_color(UiTokens.COLOR_ACCENT)))
	add_theme_color_override("font_color", text)
	add_theme_color_override("font_hover_color", theme_ref.get_color(UiTokens.COLOR_TEXT_PRIMARY))
	add_theme_color_override("font_pressed_color", text)
	add_theme_font_size_override("font_size", UiTokens.FONT_BODY)


func _box(bg: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1 if border != Color.TRANSPARENT else 0)
	box.set_corner_radius_all(int(UiTokens.RADIUS_MEDIUM))
	return box
