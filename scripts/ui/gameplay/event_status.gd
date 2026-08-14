extends Control
class_name EventStatus

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

var event_manager
var theme_ref: ThemeController

var _panel: PanelContainer
var _title_label: Label
var _desc_label: Label
var _progress: ProgressBar


func setup(event_manager_ref, theme_controller: ThemeController) -> void:
	event_manager = event_manager_ref
	theme_ref = theme_controller
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	visible = false

	_panel = PanelContainer.new()
	_panel.name = "EventPanel"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_panel.custom_minimum_size.x = 220.0
	add_child(_panel)

	var box := VBoxContainer.new()
	box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	box.add_theme_constant_override("separation", 2)
	_panel.add_child(box)

	_title_label = Label.new()
	_title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title_label.add_theme_font_size_override("font_size", UiTokens.FONT_BUTTON)
	box.add_child(_title_label)

	_desc_label = Label.new()
	_desc_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_desc_label.add_theme_font_size_override("font_size", UiTokens.FONT_CAPTION)
	box.add_child(_desc_label)

	_progress = ProgressBar.new()
	_progress.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_progress.show_percentage = false
	_progress.min_value = 0.0
	_progress.max_value = 1.0
	_progress.custom_minimum_size.y = 6.0
	box.add_child(_progress)

	event_manager.event_started.connect(_on_started)
	event_manager.event_ended.connect(_on_ended)
	event_manager.event_progress_changed.connect(_on_progress)
	_apply_theme()


func _apply_theme() -> void:
	if theme_ref == null or _panel == null:
		return
	_title_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_PRIMARY))
	_desc_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_SECONDARY))
	var box := StyleBoxFlat.new()
	box.bg_color = theme_ref.get_color(UiTokens.COLOR_SURFACE_HIGH)
	box.border_color = theme_ref.get_color(UiTokens.COLOR_BORDER_SUBTLE)
	box.set_border_width_all(1)
	box.set_corner_radius_all(int(UiTokens.RADIUS_MEDIUM))
	box.content_margin_left = UiTokens.SPACE_3
	box.content_margin_right = UiTokens.SPACE_3
	box.content_margin_top = UiTokens.SPACE_2
	box.content_margin_bottom = UiTokens.SPACE_2
	_panel.add_theme_stylebox_override("panel", box)


func _on_started(_id: String, definition: Dictionary) -> void:
	var rarity := str(definition.get("rarity", "common"))
	_title_label.text = str(definition.get("name", ""))
	_desc_label.text = str(definition.get("desc", ""))
	_progress.value = 1.0
	visible = true


func _on_ended(_id: String) -> void:
	visible = false


func _on_progress(ratio: float) -> void:
	if visible:
		_progress.value = ratio
