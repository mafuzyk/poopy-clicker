extends SceneTree

const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")

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
	var phone_p := LayoutClassifier.classify("Android", Vector2(360, 800), true)
	var phone_l := LayoutClassifier.classify("Android", Vector2(800, 360), true)
	var tablet := LayoutClassifier.classify("Android", Vector2(800, 600), true)
	var desktop := LayoutClassifier.classify("Windows", Vector2(1366, 768), false)
	var hybrid := LayoutClassifier.classify("Windows", Vector2(1366, 768), true)
	var forced := LayoutClassifier.classify("Windows", Vector2(1366, 768), false, "mobile")

	check(phone_p.family == LayoutClassifier.LayoutFamily.MOBILE, "Android phone portrait is Mobile")
	check(phone_l.family == LayoutClassifier.LayoutFamily.MOBILE, "Android phone landscape remains Mobile")
	check(phone_p.orientation == LayoutClassifier.Orientation.PORTRAIT, "portrait orientation")
	check(phone_l.orientation == LayoutClassifier.Orientation.LANDSCAPE, "landscape orientation")
	check(tablet.family == LayoutClassifier.LayoutFamily.LARGE_SCREEN, "600 short-edge tablet is Large-Screen")
	check(tablet.input == LayoutClassifier.InputProfile.TOUCH, "tablet is touch-first")
	check(desktop.family == LayoutClassifier.LayoutFamily.LARGE_SCREEN, "desktop is always Large-Screen")
	check(desktop.input == LayoutClassifier.InputProfile.POINTER, "desktop pointer profile")
	check(hybrid.input == LayoutClassifier.InputProfile.HYBRID, "touch desktop is Hybrid")
	check(forced.family == LayoutClassifier.LayoutFamily.MOBILE, "debug override can force Mobile")

	if failures == 0:
		print("LAYOUT CLASSIFIER PASS: %d checks" % checks)
	else:
		printerr("LAYOUT CLASSIFIER FAIL: %d/%d" % [failures, checks])
	quit(failures)
