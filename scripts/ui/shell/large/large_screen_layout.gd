extends Control
class_name LargeScreenLayout

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")

var header_slot: Control
var playfield_slot: Control
var nav_slot: Control
var event_slot: Control
var combo_slot: Control


func setup(profile: Dictionary, density: int) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var touch: bool = profile.get("input", LayoutClassifier.InputProfile.POINTER) != LayoutClassifier.InputProfile.POINTER
	if density == LayoutClassifier.LargeDensity.WIDE:
		_build_wide(touch)
	else:
		_build_compact()


func _build_wide(touch: bool) -> void:
	var hbox := HBoxContainer.new()
	hbox.name = "WideRoot"
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.add_theme_constant_override("separation", 0)
	add_child(hbox)

	nav_slot = Control.new()
	nav_slot.name = "NavSlot"
	var rail := UiTokens.LARGE_NAV_RAIL_TOUCH if touch else UiTokens.LARGE_NAV_RAIL_POINTER
	nav_slot.custom_minimum_size = Vector2(rail, 0)
	hbox.add_child(nav_slot)

	var vbox := VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 0)
	hbox.add_child(vbox)

	header_slot = Control.new()
	header_slot.name = "HeaderSlot"
	header_slot.custom_minimum_size = Vector2(0, 100.0)
	vbox.add_child(header_slot)

	playfield_slot = Control.new()
	playfield_slot.name = "PlayfieldSlot"
	playfield_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(playfield_slot)

	event_slot = _overlay_top(playfield_slot)
	combo_slot = _overlay_bottom(playfield_slot)


func _build_compact() -> void:
	var vbox := VBoxContainer.new()
	vbox.name = "CompactRoot"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 0)
	add_child(vbox)

	var top := HBoxContainer.new()
	top.name = "CompactTop"
	top.custom_minimum_size = Vector2(0, 72.0)
	top.add_theme_constant_override("separation", 0)
	vbox.add_child(top)

	header_slot = Control.new()
	header_slot.name = "HeaderSlot"
	header_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(header_slot)

	nav_slot = Control.new()
	nav_slot.name = "NavSlot"
	top.add_child(nav_slot)

	playfield_slot = Control.new()
	playfield_slot.name = "PlayfieldSlot"
	playfield_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(playfield_slot)

	event_slot = _overlay_top(playfield_slot)
	combo_slot = _overlay_bottom(playfield_slot)


func _overlay_top(parent: Control) -> Control:
	var c := Control.new()
	c.name = "EventSlot"
	c.anchor_top = 0.0
	c.anchor_left = 0.0
	c.anchor_right = 1.0
	c.anchor_bottom = 0.0
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c


func _overlay_bottom(parent: Control) -> Control:
	var c := Control.new()
	c.name = "ComboSlot"
	c.anchor_top = 1.0
	c.anchor_left = 0.0
	c.anchor_right = 1.0
	c.anchor_bottom = 1.0
	c.grow_vertical = Control.GROW_DIRECTION_BEGIN
	c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(c)
	return c
