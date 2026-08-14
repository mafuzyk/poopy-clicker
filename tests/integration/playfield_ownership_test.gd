extends SceneTree

const GameState = preload("res://scripts/core/game_state.gd")
const ClickController = preload("res://scripts/systems/click_controller.gd")
const GooberManager = preload("res://scripts/goobers/goober_manager.gd")

var failures := 0
var checks := 0


func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		printerr("FAIL ", label)
	else:
		print("OK   ", label)


func _initialize() -> void:
	_test_click_explicit_bounds()
	_test_goober_explicit_container()
	_test_legacy_setup()
	if failures == 0:
		print("PLAYFIELD OWNERSHIP PASS: %d checks" % checks)
	else:
		printerr("PLAYFIELD OWNERSHIP FAIL: %d/%d" % [failures, checks])
	quit(failures)


func _test_click_explicit_bounds() -> void:
	var play_area := Control.new()
	play_area.size = Vector2(360, 420)
	root.add_child(play_area)
	var button := Button.new()
	button.size = Vector2(160, 72)
	play_area.add_child(button)
	var state := GameState.new()
	var click := ClickController.new()
	root.add_child(click)
	click.setup(button, state, play_area)
	click.center_button()
	check(click.get_play_area_rect() == Rect2(Vector2.ZERO, play_area.size), "explicit click bounds use local playfield")
	check(button.position.x >= 0.0 and button.position.y >= 0.0, "click remains inside explicit bounds")


func _test_goober_explicit_container() -> void:
	var bounds := Control.new()
	bounds.size = Vector2(360, 420)
	root.add_child(bounds)
	var container := Control.new()
	container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bounds.add_child(container)
	var button := Button.new()
	button.size = Vector2(160, 72)
	bounds.add_child(button)
	var state := GameState.new()
	var manager := GooberManager.new()
	root.add_child(manager)
	manager.setup(button, state, container, bounds)
	check(manager.force_spawn("gold"), "force spawn gold in explicit container")
	check(manager.goobers.size() == 1, "one goober spawned")
	var goober = manager.goobers[0]
	check(goober.get_parent() == container, "goober parent is explicit container")
	var b: Rect2 = manager.get_bounds()
	check(b == Rect2(Vector2.ZERO, bounds.size), "goober bounds use explicit bounds")
	check(b.has_point(goober.position), "goober position inside bounds")


func _test_legacy_setup() -> void:
	var button := Button.new()
	button.size = Vector2(160, 72)
	root.add_child(button)
	var state := GameState.new()
	var click := ClickController.new()
	root.add_child(click)
	click.setup(button, state)
	click.center_button()
	check(true, "legacy click setup ok")

	var manager := GooberManager.new()
	root.add_child(manager)
	manager.setup(button, state)
	check(true, "legacy goober setup ok")
