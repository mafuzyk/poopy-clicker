extends Control

const Layout = preload("res://scripts/ui/layout.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

const TOAST_WIDTH := 300.0
const FADE_IN := 0.2
const HOLD_TIME := 2.2
const FADE_OUT := 0.4
const MAX_QUEUE := 5

var queue: Array = []
var showing := false
var panel: PanelContainer
var entry: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	z_index = 100


func show_toast(title: String, hint: String) -> void:
	if queue.size() >= MAX_QUEUE:
		queue.pop_front()
	queue.append({"title": title, "hint": hint})
	if not showing:
		show_next()


func show_next() -> void:
	showing = true
	entry = queue.pop_front()

	panel = PanelContainer.new()
	panel.name = "ToastPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", UiStyles.toast_style())

	var viewport_size := get_viewport_rect().size
	var width := minf(TOAST_WIDTH, viewport_size.x - Layout.EDGE_MARGIN * 2.0)

	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 1)
	panel.add_child(box)

	var title_label := UiStyles.make_label(entry["title"], 15, Color(1, 1, 1, 0.98))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title_label)

	if not String(entry["hint"]).is_empty():
		var hint_label := UiStyles.make_label(entry["hint"], 12, Color(1, 1, 1, 0.75))
		hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(hint_label)

	var size := panel.get_combined_minimum_size()
	panel.size = Vector2(width, size.y)
	panel.position = Vector2(
		(viewport_size.x - width) / 2.0,
		viewport_size.y - Layout.BOTTOM_BAR_HEIGHT - Layout.EDGE_MARGIN - size.y
	)
	add_child(panel)

	panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, FADE_IN)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT)
	tween.tween_callback(dismiss_current)


func dismiss_current() -> void:
	if panel != null and is_instance_valid(panel):
		panel.queue_free()
		panel = null
	showing = false
	if not queue.is_empty():
		show_next()