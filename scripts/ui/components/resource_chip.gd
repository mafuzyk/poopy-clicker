extends PanelContainer
class_name ResourceChip

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController
var color_role: StringName = UiTokens.COLOR_TEXT_PRIMARY
var label_text := ""
var amount_text := ""

var _label: Label
var _amount: Label


func setup(theme_controller: ThemeController, label: String, role: StringName) -> void:
	theme_ref = theme_controller
	label_text = label
	color_role = role
	_build()
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _build() -> void:
	var box := HBoxContainer.new()
	box.add_theme_constant_override("separation", UiTokens.SPACE_1)
	add_child(box)

	_label = Label.new()
	_label.text = label_text
	_label.add_theme_font_size_override("font_size", UiTokens.FONT_SMALL)
	box.add_child(_label)

	_amount = Label.new()
	_amount.text = amount_text
	_amount.add_theme_font_size_override("font_size", UiTokens.FONT_BODY)
	box.add_child(_amount)


func set_amount(text: String) -> void:
	amount_text = text
	if _amount != null:
		_amount.text = text


func get_amount_text() -> String:
	return amount_text


func _restyle() -> void:
	if theme_ref == null:
		return
	var accent := theme_ref.get_color(color_role)
	_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_MUTED))
	_amount.add_theme_color_override("font_color", accent)
	var box := StyleBoxFlat.new()
	box.bg_color = theme_ref.get_color(UiTokens.COLOR_SURFACE_LOW)
	box.border_color = accent
	box.set_border_width_all(1)
	box.set_corner_radius_all(int(UiTokens.RADIUS_SMALL))
	box.content_margin_left = UiTokens.SPACE_2
	box.content_margin_right = UiTokens.SPACE_2
	box.content_margin_top = 2.0
	box.content_margin_bottom = 2.0
	add_theme_stylebox_override("panel", box)
