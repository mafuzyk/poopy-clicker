extends Control
class_name MobileNavDock

signal shop_requested
signal bestiary_requested
signal menu_requested

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const PoopyButton = preload("res://scripts/ui/components/poopy_button.gd")

var theme_ref: ThemeController

var shop_button: PoopyButton
var bestiary_button: PoopyButton
var menu_button: PoopyButton


func setup(theme_controller: ThemeController) -> void:
	theme_ref = theme_controller
	var row := HBoxContainer.new()
	row.name = "NavRow"
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", UiTokens.SPACE_3)
	add_child(row)

	shop_button = _nav_button("Loja")
	shop_button.pressed.connect(shop_requested.emit)
	row.add_child(shop_button)

	bestiary_button = _nav_button("Gooberário")
	bestiary_button.pressed.connect(bestiary_requested.emit)
	row.add_child(bestiary_button)

	menu_button = _nav_button("Menu")
	menu_button.pressed.connect(menu_requested.emit)
	row.add_child(menu_button)


func _nav_button(label: String) -> PoopyButton:
	var b := PoopyButton.new()
	b.setup(theme_ref, PoopyButton.Variant.SECONDARY, PoopyButton.ControlSize.REGULAR)
	b.text = label
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	return b


func get_destination_count() -> int:
	return 3
