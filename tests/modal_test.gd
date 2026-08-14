extends Node

const BasePanel = preload("res://scripts/ui/base_panel.gd")
const Layout = preload("res://scripts/ui/layout.gd")

var failures := 0
var checks := 0
var _frames := 0
var _test_base: BasePanel
var _test_small: BasePanel


func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("OK   ", label)
	else:
		failures += 1
		printerr("FAIL ", label)


func _ready() -> void:
	var root_ctl := Control.new()
	root_ctl.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root_ctl.size = Vector2(960, 540)
	add_child(root_ctl)

	_test_base = BasePanel.new()
	root_ctl.add_child(_test_base)
	_test_base.setup("TESTE")
	var content := PanelContainer.new()
	content.custom_minimum_size = Vector2(0.0, 300.0)
	_test_base.add_to_content(content)

	_test_small = BasePanel.new()
	root_ctl.add_child(_test_small)
	_test_small.setup("PEQUENO")


func _process(_delta: float) -> void:
	_frames += 1
	if _frames < 3:
		return
	set_process(false)

	var panel_size: Vector2 = _test_base.panel.size
	check(panel_size.y >= 300.0, "painel cresce com conteudo (altura %d)" % int(panel_size.y))
	check(panel_size.y <= 300.0 + Layout.BAR_BUTTON_HEIGHT + 120.0, "painel nao estoura (altura %d)" % int(panel_size.y))
	check(_test_base._scroll.custom_minimum_size.y >= 290.0, "scroll tem altura util (%.0f)" % _test_base._scroll.custom_minimum_size.y)
	check(_test_small.panel.size.y <= 150.0, "conteudo pequeno -> painel pequeno (altura %d)" % int(_test_small.panel.size.y))

	if failures == 0:
		print("MODAL TEST PASS: %d checks" % checks)
	else:
		printerr("MODAL TEST FAIL: %d/%d" % [failures, checks])
	get_tree().quit(failures)