extends MarginContainer

const BASE_MARGIN := 10.0

var _base_left := BASE_MARGIN
var _base_top := BASE_MARGIN
var _base_right := BASE_MARGIN
var _base_bottom := BASE_MARGIN


func _ready() -> void:
	_update_margins()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_update_margins()


func set_base_margins(left: float, top: float, right: float, bottom: float) -> void:
	_base_left = left
	_base_top = top
	_base_right = right
	_base_bottom = bottom
	_update_margins()


func _update_margins() -> void:
	if not is_inside_tree():
		return
	var window_size := Vector2(DisplayServer.window_get_size())
	if window_size.x <= 0.0 or window_size.y <= 0.0:
		return
	var viewport_size := get_viewport_rect().size
	var scale_factor := viewport_size / window_size
	var safe_area := DisplayServer.get_display_safe_area()
	add_theme_constant_override("margin_left", int(_base_left + safe_area.position.x * scale_factor.x))
	add_theme_constant_override("margin_top", int(_base_top + safe_area.position.y * scale_factor.y))
	add_theme_constant_override("margin_right", int(_base_right + (window_size.x - safe_area.end.x) * scale_factor.x))
	add_theme_constant_override("margin_bottom", int(_base_bottom + (window_size.y - safe_area.end.y) * scale_factor.y))