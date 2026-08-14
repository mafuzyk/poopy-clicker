extends Control

const BasePanel = preload("res://scripts/ui/base_panel.gd")

signal close_requested

var base: BasePanel


func setup(surface_title: String, description: String, availability_note: String) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	base = BasePanel.new()
	base.setup(surface_title)
	base.close_requested.connect(close_requested.emit)
	add_child(base)

	var description_label := Label.new()
	description_label.text = description
	description_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	description_label.add_theme_font_size_override("font_size", 18)
	base.add_to_content(description_label)

	var note_label := Label.new()
	note_label.text = "Indisponível — %s" % availability_note
	note_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	note_label.add_theme_font_size_override("font_size", 15)
	note_label.modulate = Color(1.0, 0.8, 0.4)
	base.add_to_content(note_label)