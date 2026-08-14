extends Button
class_name PoopyButton

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

enum Variant { PRIMARY, SECONDARY, GHOST, DANGER }
enum ControlSize { COMPACT, REGULAR, LARGE }

var theme_ref: ThemeController
var variant := Variant.PRIMARY
var size_mode := ControlSize.REGULAR


func setup(theme_controller: ThemeController, v: int = Variant.PRIMARY, s: int = ControlSize.REGULAR) -> void:
	theme_ref = theme_controller
	variant = v
	size_mode = s
	focus_mode = Control.FOCUS_ALL
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _restyle() -> void:
	if theme_ref == null:
		return
	match size_mode:
		ControlSize.COMPACT:
			custom_minimum_size.y = 40.0
		ControlSize.REGULAR:
			custom_minimum_size.y = UiTokens.TOUCH_MIN
		ControlSize.LARGE:
			custom_minimum_size.y = 56.0

	var bg := theme_ref.get_color(UiTokens.COLOR_SURFACE)
	var border := theme_ref.get_color(UiTokens.COLOR_BORDER_SUBTLE)
	var text := theme_ref.get_color(UiTokens.COLOR_TEXT_PRIMARY)
	var hover_bg := theme_ref.get_color(UiTokens.COLOR_SURFACE_HIGH)
	var pressed_bg := theme_ref.get_color(UiTokens.COLOR_SURFACE_LOW)
	match variant:
		Variant.PRIMARY:
			bg = theme_ref.get_color(UiTokens.COLOR_ACCENT)
			border = theme_ref.get_color(UiTokens.COLOR_ACCENT)
			text = theme_ref.get_color(UiTokens.COLOR_BACKGROUND_DEEP)
			hover_bg = theme_ref.get_color(UiTokens.COLOR_ACCENT_HOVER)
			pressed_bg = theme_ref.get_color(UiTokens.COLOR_ACCENT_PRESSED)
		Variant.SECONDARY:
			bg = theme_ref.get_color(UiTokens.COLOR_SURFACE_HIGH)
			border = theme_ref.get_color(UiTokens.COLOR_BORDER_STRONG)
		Variant.GHOST:
			bg = Color.TRANSPARENT
			border = Color.TRANSPARENT
		Variant.DANGER:
			bg = theme_ref.get_color(UiTokens.COLOR_DANGER)
			border = theme_ref.get_color(UiTokens.COLOR_DANGER)
			text = theme_ref.get_color(UiTokens.COLOR_BACKGROUND_DEEP)
			hover_bg = bg
			pressed_bg = bg.darkened(0.15)

	add_theme_stylebox_override("normal", _box(bg, border))
	add_theme_stylebox_override("hover", _box(hover_bg, border))
	add_theme_stylebox_override("pressed", _box(pressed_bg, border))
	add_theme_stylebox_override("disabled", _box(theme_ref.get_color(UiTokens.COLOR_SURFACE_LOW), theme_ref.get_color(UiTokens.COLOR_BORDER_SUBTLE)))
	add_theme_stylebox_override("focus", _focus_box(theme_ref.get_color(UiTokens.COLOR_ACCENT)))
	add_theme_color_override("font_color", text)
	add_theme_color_override("font_hover_color", text)
	add_theme_color_override("font_pressed_color", text)
	add_theme_color_override("font_disabled_color", theme_ref.get_color(UiTokens.COLOR_DISABLED))
	add_theme_font_size_override("font_size", UiTokens.FONT_BUTTON)


func _box(bg: Color, border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = bg
	box.border_color = border
	box.set_border_width_all(1)
	box.set_corner_radius_all(int(UiTokens.RADIUS_MEDIUM))
	box.content_margin_left = UiTokens.SPACE_4
	box.content_margin_right = UiTokens.SPACE_4
	box.content_margin_top = UiTokens.SPACE_2
	box.content_margin_bottom = UiTokens.SPACE_2
	return box


func _focus_box(accent: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color.TRANSPARENT
	box.border_color = accent
	box.set_border_width_all(2)
	box.set_corner_radius_all(int(UiTokens.RADIUS_MEDIUM))
	box.content_margin_left = UiTokens.SPACE_4
	box.content_margin_right = UiTokens.SPACE_4
	box.content_margin_top = UiTokens.SPACE_2
	box.content_margin_bottom = UiTokens.SPACE_2
	return box
