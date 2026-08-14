extends Control

const EventManager = preload("res://scripts/systems/event_manager.gd")
const EventCatalog = preload("res://scripts/data/event_catalog.gd")
const Layout = preload("res://scripts/ui/layout.gd")

const BANNER_WIDTH := 240.0
const PROGRESS_HEIGHT := 8.0

var event_manager: EventManager

var panel: PanelContainer
var title_label: Label
var desc_label: Label
var progress_bar: ProgressBar
var fallback_color := Color("#8bd3ff")


func setup(manager: EventManager) -> void:
	event_manager = manager
	name = "EventBanner"
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 20
	set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	position.y = Layout.TOP_BAR_HEIGHT + Layout.EDGE_MARGIN
	visible = false

	panel = PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.custom_minimum_size.x = BANNER_WIDTH
	panel.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(panel)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 4)
	panel.add_child(box)

	title_label = Label.new()
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 16)
	box.add_child(title_label)

	desc_label = Label.new()
	desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	desc_label.custom_minimum_size.x = BANNER_WIDTH - 24.0
	desc_label.add_theme_font_size_override("font_size", 13)
	desc_label.modulate = Color(1, 1, 1, 0.85)
	box.add_child(desc_label)

	progress_bar = ProgressBar.new()
	progress_bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	progress_bar.custom_minimum_size.y = PROGRESS_HEIGHT
	progress_bar.show_percentage = false
	progress_bar.min_value = 0.0
	progress_bar.max_value = 1.0
	box.add_child(progress_bar)

	event_manager.event_started.connect(_on_event_started)
	event_manager.event_ended.connect(_on_event_ended)
	event_manager.event_progress_changed.connect(_on_progress_changed)


func _on_event_started(_id: String, definition: Dictionary) -> void:
	var rarity := str(definition.get("rarity", ""))
	var title := str(definition.get("name", ""))
	var rarity_label: String = EventCatalog.get_rarity_label(rarity)
	title_label.text = "%s • %s" % [title, rarity_label] if rarity_label != "" else title
	desc_label.text = str(definition.get("desc", ""))
	progress_bar.value = 1.0
	var event_color := _parse_color(str(definition.get("color", "")))
	progress_bar.modulate = event_color
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.1, 0.13, 0.92)
	style.border_color = event_color
	style.set_border_width_all(1)
	style.set_corner_radius_all(10)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	panel.add_theme_stylebox_override("panel", style)
	visible = true


func _on_event_ended(_id: String) -> void:
	visible = false


func _on_progress_changed(ratio: float) -> void:
	if visible:
		progress_bar.value = ratio


func _parse_color(hex: String) -> Color:
	var value: Color = Color.from_string(hex, fallback_color)
	return value
