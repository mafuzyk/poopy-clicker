extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const AchievementManager = preload("res://scripts/achievements/achievement_manager.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal close_requested

var base: BasePanel
var game_state: GameState
var achievement_manager: AchievementManager
var _status_labels: Dictionary = {}
var _summary_label: Label


func setup(state: GameState, manager: AchievementManager) -> void:
	game_state = state
	achievement_manager = manager
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("CONQUISTAS")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build_rows()
	game_state.changed.connect(_on_state_changed)
	refresh()
	resized.connect(_on_state_changed)


func _build_rows() -> void:
	for id: String in AchievementManager.DEFINITIONS:
		var definition: Dictionary = AchievementManager.DEFINITIONS[id]
		base.add_to_content(_make_row(id, definition))

	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.add_theme_font_size_override("font_size", 16)
	base.add_to_content(_summary_label)


func _make_row(id: String, definition: Dictionary) -> Control:
	var card := PanelContainer.new()
	card.name = "Row" + id.capitalize()
	card.add_theme_stylebox_override("panel", UiStyles.card_style())

	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	card.add_child(row)

	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	row.add_child(info)

	var name_label := Label.new()
	name_label.text = String(definition.get("name", id))
	name_label.add_theme_font_size_override("font_size", 16)
	info.add_child(name_label)

	var hint_label := Label.new()
	hint_label.text = String(definition.get("hint", ""))
	hint_label.add_theme_font_size_override("font_size", 13)
	hint_label.modulate = Color(1, 1, 1, 0.8)
	hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(hint_label)

	var status_label := Label.new()
	status_label.name = "Status"
	status_label.text = ""
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	status_label.custom_minimum_size.x = 110.0
	row.add_child(status_label)
	_status_labels[id] = status_label
	return card


func _on_state_changed() -> void:
	if visible:
		refresh()


func refresh() -> void:
	if game_state == null:
		return
	var unlocked_count := 0
	for id: String in AchievementManager.DEFINITIONS:
		if not _status_labels.has(id):
			continue
		var status_label: Label = _status_labels[id]
		var unlocked := achievement_manager.is_unlocked(id)
		if unlocked:
			unlocked_count += 1
			status_label.text = "DESBLOQUEADO"
			status_label.modulate = Color(0.6, 1.0, 0.6)
		else:
			status_label.modulate = Color(1, 1, 1, 0.8)
			var progress := achievement_manager.get_progress(id)
			if progress.y > 0:
				status_label.text = "%s / %s" % [
					progress_formatter(progress.x),
					progress_formatter(progress.y)
				]
			else:
				status_label.text = "bloqueado"
	if _summary_label != null:
		_summary_label.text = "%d / %d desbloqueadas" % [
			unlocked_count,
			AchievementManager.DEFINITIONS.size()
		]


func progress_formatter(value: int) -> String:
	if value >= 1000000:
		return "%0.1fM" % (value / 1000000.0)
	if value >= 1000:
		return "%0.1fK" % (value / 1000.0)
	return str(value)