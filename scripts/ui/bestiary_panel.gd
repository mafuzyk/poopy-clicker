extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")
const GameState = preload("res://scripts/core/game_state.gd")
const UiStyles = preload("res://scripts/ui/ui_styles.gd")

signal close_requested

const RARITY_COLORS := {
	"common": Color(0.75, 0.75, 0.75),
	"rare": Color(0.45, 0.65, 1.0),
	"epic": Color(0.7, 0.45, 1.0),
	"legendary": Color(1.0, 0.7, 0.25),
	"mythic": Color(1.0, 0.35, 0.45),
}

var base: BasePanel
var game_state: GameState
var catalog: GooberCatalog
var _seen_labels: Dictionary = {}
var _clicked_labels: Dictionary = {}
var _summary_label: Label


func setup(state: GameState) -> void:
	game_state = state
	catalog = GooberCatalog.new()
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup("GOOBERÁRIO")
	base.close_requested.connect(close_requested.emit)
	add_child(base)
	_build_header()
	_build_rows()
	game_state.changed.connect(_on_state_changed)
	refresh()


func _build_header() -> void:
	_summary_label = Label.new()
	_summary_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_summary_label.add_theme_font_size_override("font_size", 16)
	base.add_to_content(_summary_label)

	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 8)
	var type_header := Label.new()
	type_header.text = "TIPO"
	type_header.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	type_header.add_theme_font_size_override("font_size", 14)
	type_header.modulate = Color(1, 1, 1, 0.6)
	columns.add_child(type_header)
	for title: String in ["RARIDADE", "VISTO", "CLICADO"]:
		var header := Label.new()
		header.text = title
		header.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		header.custom_minimum_size = Vector2(110.0, 0.0)
		header.add_theme_font_size_override("font_size", 14)
		header.modulate = Color(1, 1, 1, 0.6)
		columns.add_child(header)
	base.add_to_content(columns)


func _build_rows() -> void:
	for id: String in catalog.TYPES:
		var data: Dictionary = catalog.TYPES[id]
		var card := PanelContainer.new()
		card.name = "Row" + id.capitalize()
		card.add_theme_stylebox_override("panel", UiStyles.card_style())

		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 8)
		card.add_child(row)

		var name_label := Label.new()
		name_label.text = String(data.get("name", id))
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.add_theme_font_size_override("font_size", 15)
		var blocked_reason := catalog.get_blocked_reason(id)
		if blocked_reason != "":
			name_label.text += "  [%s]" % blocked_reason
		row.add_child(name_label)

		var rarity := String(data.get("rarity", "common"))
		var rarity_label := Label.new()
		rarity_label.text = rarity.capitalize()
		rarity_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		rarity_label.custom_minimum_size = Vector2(110.0, 0.0)
		rarity_label.modulate = RARITY_COLORS.get(rarity, Color.WHITE)
		rarity_label.add_theme_font_size_override("font_size", 15)
		row.add_child(rarity_label)

		var seen_label := Label.new()
		seen_label.name = "Seen"
		seen_label.text = "0"
		seen_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		seen_label.custom_minimum_size = Vector2(110.0, 0.0)
		seen_label.add_theme_font_size_override("font_size", 15)
		row.add_child(seen_label)

		var clicked_label := Label.new()
		clicked_label.name = "Clicked"
		clicked_label.text = "0"
		clicked_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		clicked_label.custom_minimum_size = Vector2(110.0, 0.0)
		clicked_label.add_theme_font_size_override("font_size", 15)
		row.add_child(clicked_label)

		_seen_labels[id] = seen_label
		_clicked_labels[id] = clicked_label
		base.add_to_content(card)


func _on_state_changed() -> void:
	if visible:
		refresh()


func refresh() -> void:
	if game_state == null:
		return
	var seen_count := 0
	for id: String in catalog.TYPES:
		var entry: Dictionary = game_state.bestiary_counts.get(id, {})
		var seen := int(entry.get("seen", 0))
		var clicked := int(entry.get("clicked", 0))
		if _seen_labels.has(id):
			_seen_labels[id].text = str(seen)
		if _clicked_labels.has(id):
			_clicked_labels[id].text = str(clicked)
		if seen > 0:
			seen_count += 1
	_summary_label.text = "%d / %d tipos vistos" % [seen_count, catalog.TYPES.size()]