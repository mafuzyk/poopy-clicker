extends Control
class_name Playfield

var goober_layer: Control
var click_target_layer: Control
var reward_fx_layer: Control
var gameplay_overlay_layer: Control


func _ready() -> void:
	_build()


func _build() -> void:
	if goober_layer != null:
		return
	name = "Playfield"
	mouse_filter = Control.MOUSE_FILTER_PASS

	goober_layer = _make_layer("GooberLayer")
	click_target_layer = _make_layer("ClickTargetLayer")
	click_target_layer.mouse_filter = Control.MOUSE_FILTER_STOP
	reward_fx_layer = _make_layer("RewardFxLayer")
	gameplay_overlay_layer = _make_layer("GameplayOverlayLayer")


func ensure_built() -> void:
	if goober_layer == null:
		_build()


func _make_layer(layer_name: String) -> Control:
	var layer := Control.new()
	layer.name = layer_name
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(layer)
	return layer
