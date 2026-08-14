extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const NumberFormat = preload("res://scripts/ui/number_format.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")
const Layout = preload("res://scripts/ui/layout.gd")

signal close_requested

var game_state: GameState
var base: BasePanel
var total_label: Label
var _list: VBoxContainer


func setup(state: GameState) -> void:
	game_state = state
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("MISSÕES")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build()
	game_state.changed.connect(refresh)
	refresh()


func _build() -> void:
	total_label = UiStyles.make_label("", Layout.PANEL_ACTION_FONT, Color(0.85, 0.9, 1.0))
	total_label.name = "TotalLabel"
	total_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	base.add_to_content(total_label)

	_list = VBoxContainer.new()
	_list.name = "MissionList"
	_list.add_theme_constant_override("separation", 8)
	base.add_to_content(_list)


func refresh() -> void:
	if game_state == null or base == null:
		return
	total_label.text = "Missões completas: %d" % int(game_state.mission_state.get("completed_total", 0))

	for child in _list.get_children():
		child.queue_free()

	var raw: Variant = game_state.mission_state.get("slots", [])
	var slots: Array = raw if typeof(raw) == TYPE_ARRAY else []
	if slots.is_empty():
		_list.add_child(UiStyles.make_label("Nenhuma missão ativa.", 13, Color(1, 1, 1, 0.6)))
		return

	for mission in slots:
		var card := PanelContainer.new()
		card.add_theme_stylebox_override("panel", UiStyles.card_style())
		var box := VBoxContainer.new()
		box.add_theme_constant_override("separation", 2)
		card.add_child(box)

		box.add_child(UiStyles.make_label(str(mission.get("title", "")), 15, Color(0.95, 0.95, 0.97, 1.0)))
		var desc := UiStyles.make_label(str(mission.get("description", "")), 12, Color(1, 1, 1, 0.7))
		desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		box.add_child(desc)
		var prog := int(mission.get("progress", 0))
		var target := int(mission.get("target", 0))
		var reward := "$%s + %d GC" % [NumberFormat.format(int(mission.get("reward_money", 0))), int(mission.get("reward_coins", 0))]
		box.add_child(UiStyles.make_label("%d / %d   •   %s" % [prog, target, reward], 12, Color(1.0, 0.85, 0.35)))

		_list.add_child(card)
