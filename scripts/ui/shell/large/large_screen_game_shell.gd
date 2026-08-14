extends "res://scripts/ui/shell/game_shell_base.gd"
class_name LargeScreenGameShell

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const Playfield = preload("res://scripts/ui/shell/playfield.gd")
const ClickTarget = preload("res://scripts/ui/gameplay/click_target.gd")
const LargeScreenLayout = preload("res://scripts/ui/shell/large/large_screen_layout.gd")
const LargeResourceHeader = preload("res://scripts/ui/shell/large/large_resource_header.gd")
const LargeNav = preload("res://scripts/ui/shell/large/large_nav.gd")
const ComboDisplay = preload("res://scripts/ui/gameplay/combo_display.gd")
const EventStatus = preload("res://scripts/ui/gameplay/event_status.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")

var state
var economy
var combo_manager
var event_manager
var theme_ref
var profile: Dictionary = {}

var header
var nav
var event_status
var combo_display

var _wide_layout
var _compact_layout
var _active_density := -1


func setup(state_ref, econ, combo, events, theme_controller, layout_profile: Dictionary) -> void:
	state = state_ref
	economy = econ
	combo_manager = combo
	event_manager = events
	theme_ref = theme_controller
	profile = layout_profile
	_build_shell()


func _build_shell() -> void:
	ensure_built()

	playfield = Playfield.new()
	playfield.name = "Playfield"
	header = LargeResourceHeader.new()
	nav = LargeNav.new()
	event_status = EventStatus.new()
	combo_display = ComboDisplay.new()

	click_target = ClickTarget.new()
	click_target.name = "ClickTarget"
	click_target.setup(theme_ref, Vector2(200, 84))

	header.setup(state, economy, theme_ref)
	nav.setup(theme_ref, profile)
	event_status.setup(event_manager, theme_ref)
	combo_display.setup(state, combo_manager, theme_ref)

	nav.shop_requested.connect(shop_requested.emit)
	nav.bestiary_requested.connect(bestiary_requested.emit)
	nav.menu_requested.connect(menu_requested.emit)

	_wide_layout = LargeScreenLayout.new()
	_wide_layout.setup(profile, LayoutClassifier.LargeDensity.WIDE)
	_compact_layout = LargeScreenLayout.new()
	_compact_layout.setup(profile, LayoutClassifier.LargeDensity.COMPACT)

	playfield.ensure_built()
	playfield.click_target_layer.add_child(click_target)

	_apply_density(get_density())
	resized.connect(_on_resized)


func get_density() -> int:
	return LayoutClassifier.LargeDensity.WIDE if size.x >= UiTokens.LARGE_COMPACT_BREAKPOINT else LayoutClassifier.LargeDensity.COMPACT


func _on_resized() -> void:
	var d := get_density()
	if d != _active_density:
		_apply_density(d)


func _apply_density(d: int) -> void:
	_active_density = d
	_detach()
	var layout = _wide_layout if d == LayoutClassifier.LargeDensity.WIDE else _compact_layout
	add_child(layout)
	layout.header_slot.add_child(header)
	layout.playfield_slot.add_child(playfield)
	layout.nav_slot.add_child(nav)
	layout.event_slot.add_child(event_status)
	layout.combo_slot.add_child(combo_display)
	header.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	playfield.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nav.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	event_status.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	combo_display.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	nav.set_density(d)


func _detach() -> void:
	for layout in [_wide_layout, _compact_layout]:
		if layout.get_parent() == self:
			remove_child(layout)
	for node in [header, playfield, nav, event_status, combo_display]:
		if node != null and node.get_parent() != null:
			node.get_parent().remove_child(node)
