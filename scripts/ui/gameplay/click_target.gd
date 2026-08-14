extends Button
class_name ClickTarget

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var theme_ref: ThemeController
var base_size := Vector2(200, 84)

var _visual_root: PanelContainer
var _label: Label
var _press_tween: Tween


func setup(theme_controller: ThemeController, size_value: Vector2) -> void:
	theme_ref = theme_controller
	base_size = size_value
	size = base_size
	focus_mode = Control.FOCUS_NONE
	flat = true
	_build_visual()
	button_down.connect(_on_down)
	button_up.connect(_on_up)
	theme_ref.tokens_changed.connect(_restyle)
	_restyle()


func _build_visual() -> void:
	_visual_root = PanelContainer.new()
	_visual_root.name = "VisualRoot"
	_visual_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visual_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_visual_root.pivot_offset = base_size / 2.0
	add_child(_visual_root)

	_label = Label.new()
	_label.name = "ClickLabel"
	_label.text = "CLICK"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_visual_root.add_child(_label)


func _restyle() -> void:
	if theme_ref == null or _visual_root == null:
		return
	_label.add_theme_font_size_override("font_size", UiTokens.FONT_DISPLAY)
	_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_PRIMARY))
	var box := StyleBoxFlat.new()
	box.bg_color = theme_ref.get_color(UiTokens.COLOR_ACCENT)
	box.border_color = theme_ref.get_color(UiTokens.COLOR_ACCENT_HOVER)
	box.set_border_width_all(2)
	box.set_corner_radius_all(int(UiTokens.RADIUS_LARGE))
	_visual_root.add_theme_stylebox_override("panel", box)


func _on_down() -> void:
	_apply_visual_scale(0.95, 0.0)


func _on_up() -> void:
	_apply_visual_scale(1.0, UiTokens.MOTION_MICRO)


func _apply_visual_scale(target_scale: float, duration: float) -> void:
	if _visual_root == null:
		return
	if _press_tween != null and _press_tween.is_valid():
		_press_tween.kill()
	_visual_root.pivot_offset = _visual_root.size / 2.0
	if duration <= 0.0:
		_visual_root.scale = Vector2.ONE * target_scale
		return
	_press_tween = create_tween()
	_press_tween.tween_property(_visual_root, "scale", Vector2.ONE * target_scale, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)


func get_visual_scale() -> Vector2:
	return _visual_root.scale if _visual_root != null else Vector2.ONE


func debug_set_pressed_visual(pressed: bool) -> void:
	if pressed:
		_on_down()
	else:
		_on_up()
