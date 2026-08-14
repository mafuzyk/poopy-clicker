extends RefCounted
class_name UiStyles

const CORNER_RADIUS := 10
const CORNER_RADIUS_SMALL := 8


static func panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.10, 0.11, 0.13, 0.97)
	style.border_color = Color(0.30, 0.32, 0.37, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(CORNER_RADIUS)
	style.content_margin_left = 16.0
	style.content_margin_right = 16.0
	style.content_margin_top = 14.0
	style.content_margin_bottom = 14.0
	return style


static func card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.16, 0.17, 0.20, 0.90)
	style.border_color = Color(0.28, 0.30, 0.34, 0.9)
	style.set_border_width_all(1)
	style.set_corner_radius_all(CORNER_RADIUS_SMALL)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 10.0
	style.content_margin_bottom = 10.0
	return style


static func button_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.22, 0.24, 0.28, 1.0)
	style.border_color = Color(0.34, 0.37, 0.42, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(CORNER_RADIUS_SMALL)
	return style


static func button_hover_style() -> StyleBoxFlat:
	var style := button_style()
	style.bg_color = Color(0.30, 0.33, 0.38, 1.0)
	return style


static func button_pressed_style() -> StyleBoxFlat:
	var style := button_style()
	style.bg_color = Color(0.14, 0.15, 0.18, 1.0)
	return style


static func button_disabled_style() -> StyleBoxFlat:
	var style := button_style()
	style.bg_color = Color(0.13, 0.14, 0.16, 0.8)
	style.border_color = Color(0.20, 0.22, 0.25, 0.8)
	return style


static func button_focus_style() -> StyleBoxFlat:
	var style := button_style()
	style.border_color = Color(0.6, 0.7, 1.0, 0.9)
	style.set_border_width_all(2)
	return style


static func style_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", button_style())
	button.add_theme_stylebox_override("hover", button_hover_style())
	button.add_theme_stylebox_override("pressed", button_pressed_style())
	button.add_theme_stylebox_override("disabled", button_disabled_style())
	button.add_theme_stylebox_override("focus", button_focus_style())
	button.add_theme_color_override("font_color", Color(0.95, 0.95, 0.97, 1.0))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_color_override("font_pressed_color", Color(0.85, 0.85, 0.9, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.55, 0.57, 0.62, 1.0))


static func make_button(text: String, font_size: int, min_height: float) -> Button:
	var button := Button.new()
	button.text = text
	button.add_theme_font_size_override("font_size", font_size)
	button.custom_minimum_size = Vector2(0.0, min_height)
	style_button(button)
	return button


static func make_label(text: String, font_size: int, color := Color(0.95, 0.95, 0.97, 1.0)) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.modulate = color
	return label


static func bar_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.08, 0.92)
	style.border_color = Color(0.22, 0.24, 0.28, 0.8)
	style.set_border_width_all(1)
	return style


static func toast_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.06, 0.08, 0.96)
	style.border_color = Color(0.38, 0.42, 0.48, 1.0)
	style.set_border_width_all(1)
	style.set_corner_radius_all(CORNER_RADIUS_SMALL)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	return style
