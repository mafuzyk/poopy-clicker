extends Control
class_name GameShellBase

signal shop_requested
signal bestiary_requested
signal menu_requested

var playfield: Control
var surface_layer: Control
var overlay_layer: Control
var click_target: Button


func _ready() -> void:
	_build()


func _build() -> void:
	if surface_layer != null:
		return
	name = "GameShellBase"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_PASS

	surface_layer = Control.new()
	surface_layer.name = "SurfaceLayer"
	surface_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	surface_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	surface_layer.z_index = 50
	add_child(surface_layer)

	overlay_layer = Control.new()
	overlay_layer.name = "OverlayLayer"
	overlay_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay_layer.z_index = 100
	add_child(overlay_layer)


func ensure_built() -> void:
	if surface_layer == null:
		_build()


func set_gameplay_blocked(blocked: bool) -> void:
	if click_target != null:
		click_target.disabled = blocked
