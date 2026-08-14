extends VBoxContainer
class_name SectionHeader

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController
var title_label: Label
var subtitle_label: Label


func setup(theme_controller: ThemeController, title: String, subtitle: String = "") -> void:
	theme_ref = theme_controller
	add_theme_constant_override("separation", 0)
	title_label = Label.new()
	title_label.text = title
	title_label.add_theme_font_size_override("font_size", UiTokens.FONT_SECTION_TITLE)
	add_child(title_label)

	subtitle_label = Label.new()
	subtitle_label.text = subtitle
	subtitle_label.add_theme_font_size_override("font_size", UiTokens.FONT_SMALL)
	subtitle_label.visible = subtitle != ""
	add_child(subtitle_label)

	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _restyle() -> void:
	if theme_ref == null:
		return
	title_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_PRIMARY))
	subtitle_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_MUTED))
