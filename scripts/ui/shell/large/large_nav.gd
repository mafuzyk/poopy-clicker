extends Control
class_name LargeNav

signal shop_requested
signal bestiary_requested
signal menu_requested

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const PoopyButton = preload("res://scripts/ui/components/poopy_button.gd")
const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")

var theme_ref: ThemeController

var shop_button: PoopyButton
var bestiary_button: PoopyButton
var menu_button: PoopyButton

var _rail: VBoxContainer
var _cluster: HBoxContainer
var _density := LayoutClassifier.LargeDensity.WIDE


func setup(theme_controller: ThemeController, profile: Dictionary) -> void:
	theme_ref = theme_controller
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	shop_button = _make_button("Loja", shop_requested)
	bestiary_button = _make_button("Gooberário", bestiary_requested)
	menu_button = _make_button("Menu", menu_requested)

	_rail = VBoxContainer.new()
	_rail.name = "NavRail"
	_rail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_rail.alignment = BoxContainer.ALIGNMENT_CENTER
	_rail.add_theme_constant_override("separation", UiTokens.SPACE_2)
	add_child(_rail)

	_cluster = HBoxContainer.new()
	_cluster.name = "NavCluster"
	_cluster.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_cluster.alignment = BoxContainer.ALIGNMENT_CENTER
	_cluster.add_theme_constant_override("separation", UiTokens.SPACE_2)
	add_child(_cluster)

	set_density(LayoutClassifier.LargeDensity.WIDE if profile.get("density", LayoutClassifier.LargeDensity.WIDE) == LayoutClassifier.LargeDensity.WIDE else LayoutClassifier.LargeDensity.COMPACT)


func _make_button(label: String, target: Signal) -> PoopyButton:
	var b := PoopyButton.new()
	b.setup(theme_ref, PoopyButton.Variant.SECONDARY, PoopyButton.ControlSize.REGULAR)
	b.text = label
	b.pressed.connect(target.emit)
	return b


func set_density(density: int) -> void:
	_density = density
	for b in [shop_button, bestiary_button, menu_button]:
		var p: Node = b.get_parent()
		if p != null:
			p.remove_child(b)
	var active: Control = _rail if _density == LayoutClassifier.LargeDensity.WIDE else _cluster
	for b in [shop_button, bestiary_button, menu_button]:
		active.add_child(b)
	_rail.visible = _density == LayoutClassifier.LargeDensity.WIDE
	_cluster.visible = _density == LayoutClassifier.LargeDensity.COMPACT


func get_destination_count() -> int:
	return 3
