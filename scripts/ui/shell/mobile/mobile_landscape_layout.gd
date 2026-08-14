extends Control
class_name MobileLandscapeLayout

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")

var header_slot: Control
var playfield_slot: Control
var nav_slot: Control
var event_slot: Control
var combo_slot: Control


func setup() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var vbox := VBoxContainer.new()
	vbox.name = "LandscapeRoot"
	vbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 0)
	add_child(vbox)

	header_slot = Control.new()
	header_slot.name = "HeaderSlot"
	header_slot.custom_minimum_size = Vector2(0, UiTokens.MOBILE_HEADER_HEIGHT_LANDSCAPE)
	vbox.add_child(header_slot)

	playfield_slot = Control.new()
	playfield_slot.name = "PlayfieldSlot"
	playfield_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	playfield_slot.mouse_filter = Control.MOUSE_FILTER_PASS
	vbox.add_child(playfield_slot)

	nav_slot = Control.new()
	nav_slot.name = "NavSlot"
	nav_slot.custom_minimum_size = Vector2(0, UiTokens.MOBILE_NAV_HEIGHT_LANDSCAPE)
	vbox.add_child(nav_slot)

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
