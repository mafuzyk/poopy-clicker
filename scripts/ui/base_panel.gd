extends Control

const SafeMarginContainer = preload("res://scripts/ui/safe_margin_container.gd")
const Layout = preload("res://scripts/ui/layout.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal close_requested

const DIM_COLOR := Color(0, 0, 0, 0.75)

var title_label: Label
var content_slot: Control
var panel: PanelContainer
var close_button: Button
var _root_box: VBoxContainer
var _center: CenterContainer
var _scroll: ScrollContainer


func setup(panel_title: String, show_close_button := true) -> void:
	name = "BasePanel"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	z_index = 50
	_build(panel_title, show_close_button)


func _ready() -> void:
	_update_panel_size()
	resized.connect(_update_panel_size)


func _build(panel_title: String, show_close_button := true) -> void:
	var dim: ColorRect = ColorRect.new()
	dim.name = "Dim"
	dim.color = DIM_COLOR
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(dim)

	var safe_margin: SafeMarginContainer = SafeMarginContainer.new()
	safe_margin.name = "SafeMargin"
	safe_margin.set_base_margins(Layout.EDGE_MARGIN, Layout.EDGE_MARGIN, Layout.EDGE_MARGIN, Layout.EDGE_MARGIN)
	safe_margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(safe_margin)

	_center = CenterContainer.new()
	_center.name = "PanelCenter"
	_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	safe_margin.add_child(_center)

	panel = PanelContainer.new()
	panel.name = "Panel"
	panel.add_theme_stylebox_override("panel", UiStyles.panel_style())
	_center.add_child(panel)

	_root_box = VBoxContainer.new()
	_root_box.name = "PanelBox"
	_root_box.add_theme_constant_override("separation", 12)
	panel.add_child(_root_box)

	title_label = Label.new()
	title_label.name = "Title"
	title_label.text = panel_title
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", Layout.PANEL_TITLE_FONT)
	_root_box.add_child(title_label)

	_scroll = ScrollContainer.new()
	_scroll.name = "ContentScroll"
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_root_box.add_child(_scroll)

	var content_holder: VBoxContainer = VBoxContainer.new()
	content_holder.name = "ContentHolder"
	content_holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_holder.add_theme_constant_override("separation", 8)
	_scroll.add_child(content_holder)
	content_slot = content_holder

	close_button = UiStyles.make_button("Fechar", Layout.PANEL_ACTION_FONT, Layout.BAR_BUTTON_HEIGHT)
	close_button.name = "CloseButton"
	close_button.pressed.connect(close_requested.emit)
	close_button.visible = show_close_button
	_root_box.add_child(close_button)


func add_to_content(control: Control) -> void:
	content_slot.add_child(control)
	_update_panel_size.call_deferred()


func _update_panel_size() -> void:
	if panel == null or _root_box == null or _scroll == null or not is_inside_tree():
		return
	var viewport_size := get_viewport_rect().size
	var max_width := minf(Layout.PANEL_MAX_WIDTH, viewport_size.x - Layout.EDGE_MARGIN * 2.0)
	var max_height := viewport_size.y - Layout.TOP_BAR_HEIGHT - Layout.BOTTOM_BAR_HEIGHT - Layout.EDGE_MARGIN * 2.0

	var separation: float = float(_root_box.get_theme_constant("separation"))
	var visible_children := 0
	for child: Node in _root_box.get_children():
		if child is Control and (child as Control).visible:
			visible_children += 1
	var total_spacing := separation * maxf(0.0, float(visible_children - 1))

	var title_h := title_label.get_combined_minimum_size().y
	var close_h := close_button.get_combined_minimum_size().y if close_button.visible else 0.0
	var chrome_height := title_h + close_h + total_spacing

	var content_h := content_slot.get_combined_minimum_size().y
	var available_scroll_height := maxf(0.0, max_height - chrome_height)
	_scroll.custom_minimum_size.y = minf(content_h, available_scroll_height)

	panel.custom_minimum_size = Vector2(
		max_width,
		minf(chrome_height + content_h, max_height)
	)