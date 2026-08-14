extends Control
class_name EdgeBar

const SafeMarginContainer = preload("res://scripts/ui/safe_margin_container.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

enum BarSide { TOP, BOTTOM }

var side := BarSide.TOP
var base_height := Layout.TOP_BAR_HEIGHT
var content_margin: SafeMarginContainer


func setup(bar_side: BarSide, height: float) -> void:
	name = "EdgeBar"
	side = bar_side
	base_height = height
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	if side == BarSide.TOP:
		set_anchors_preset(Control.PRESET_TOP_WIDE)
		grow_horizontal = Control.GROW_DIRECTION_BOTH
		offset_bottom = base_height
	else:
		set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
		grow_horizontal = Control.GROW_DIRECTION_BOTH
		offset_top = -base_height
	_build_background()
	_build_content_margin()
	if is_inside_tree():
		_set_safe_insets()


func _build_background() -> void:
	var background: Panel = Panel.new()
	background.name = "BarBackground"
	background.add_theme_stylebox_override("panel", UiStyles.bar_style())
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)


func _build_content_margin() -> void:
	content_margin = SafeMarginContainer.new()
	content_margin.name = "BarContent"
	content_margin.set_base_margins(Layout.EDGE_MARGIN, Layout.BAR_PADDING, Layout.EDGE_MARGIN, Layout.BAR_PADDING)
	content_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(content_margin)


func add_content(control: Control) -> void:
	content_margin.add_child(control)


func _ready() -> void:
	resized.connect(_set_safe_insets)
	_set_safe_insets()


func _set_safe_insets() -> void:
	if content_margin == null or not is_inside_tree():
		return
	var window_size := Vector2(DisplayServer.window_get_size())
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		return
	var safe_area := DisplayServer.get_display_safe_area()
	var viewport_size := get_viewport_rect().size
	var scale_factor := viewport_size / window_size
	var inset_left := int(safe_area.position.x * scale_factor.x)
	var inset_right := int((window_size.x - safe_area.end.x) * scale_factor.x)
	var inset_top := int(safe_area.position.y * scale_factor.y)
	var inset_bottom := int((window_size.y - safe_area.end.y) * scale_factor.y)

	if side == BarSide.TOP:
		content_margin.set_base_margins(
			Layout.EDGE_MARGIN + inset_left,
			Layout.BAR_PADDING + inset_top,
			Layout.EDGE_MARGIN + inset_right,
			Layout.BAR_PADDING
		)
	else:
		content_margin.set_base_margins(
			Layout.EDGE_MARGIN + inset_left,
			Layout.BAR_PADDING,
			Layout.EDGE_MARGIN + inset_right,
			Layout.BAR_PADDING + inset_bottom
		)