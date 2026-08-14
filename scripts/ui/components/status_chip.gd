extends PanelContainer
class_name StatusChip

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController
var color_role: StringName = UiTokens.COLOR_INFO

var _label: Label


func setup(theme_controller: ThemeController, text_value: String, role: StringName) -> void:
	theme_ref = theme_controller
	color_role = role
	_label = Label.new()
	_label.text = text_value
	_label.add_theme_font_size_override("font_size", UiTokens.FONT_SMALL)
	add_child(_label)
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func set_text(value: String) -> void:
	if _label != null:
		_label.text = value


func get_text() -> String:
	return _label.text if _label != null else ""


func _restyle() -> void:
	if theme_ref == null:
		return
	var accent := theme_ref.get_color(color_role)
	_label.add_theme_color_override("font_color", accent)
	var box := StyleBoxFlat.new()
	box.bg_color = accent.darkened(0.55)
	box.set_corner_radius_all(int(UiTokens.RADIUS_SMALL))
	box.content_margin_left = UiTokens.SPACE_2
	box.content_margin_right = UiTokens.SPACE_2
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	add_theme_stylebox_override("panel", box)
