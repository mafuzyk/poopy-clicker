extends Control

signal surface_opened(id: String)
signal surface_closed(id: String)

var surfaces: Dictionary = {}
var _active_surface := ""


func _ready() -> void:
	name = "PanelManager"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_open():
		close_surface()
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST and is_open():
		close_surface()


func register_surface(surface_id: String, control: Control) -> void:
	surfaces[surface_id] = control
	control.visible = false
	control.connect("close_requested", close_surface.bind(surface_id))
	add_child(control)


func open_surface(surface_id: String) -> void:
	if not surfaces.has(surface_id):
		push_warning("PanelManager: superficie inexistente: " + surface_id)
		return
	if _active_surface == surface_id:
		return
	if _active_surface != "":
		var previous: Control = surfaces[_active_surface]
		previous.visible = false
	var target: Control = surfaces[surface_id]
	target.visible = true
	target.move_to_front()
	_active_surface = surface_id
	surface_opened.emit(surface_id)


func close_surface(surface_id: String = "") -> void:
	if _active_surface == "":
		return
	if surface_id != "" and surface_id != _active_surface:
		return
	surfaces[_active_surface].visible = false
	var closed := _active_surface
	_active_surface = ""
	surface_closed.emit(closed)


func is_open() -> bool:
	return _active_surface != ""


func get_active_surface() -> String:
	return _active_surface