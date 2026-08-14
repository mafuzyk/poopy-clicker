extends PanelContainer
class_name PoopyCard

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController
var elevated := false


func setup(theme_controller: ThemeController, is_elevated: bool = false) -> void:
	theme_ref = theme_controller
	elevated = is_elevated
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _restyle() -> void:
	if theme_ref == null:
		return
	var box := StyleBoxFlat.new()
	box.bg_color = theme_ref.get_color(UiTokens.COLOR_SURFACE_HIGH if elevated else UiTokens.COLOR_SURFACE)
	box.border_color = theme_ref.get_color(UiTokens.COLOR_BORDER_SUBTLE)
	box.set_border_width_all(1)
	box.set_corner_radius_all(int(UiTokens.RADIUS_MEDIUM))
	box.content_margin_left = UiTokens.SPACE_3
	box.content_margin_right = UiTokens.SPACE_3
	box.content_margin_top = UiTokens.SPACE_3
	box.content_margin_bottom = UiTokens.SPACE_3
	add_theme_stylebox_override("panel", box)
