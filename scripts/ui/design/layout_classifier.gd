extends RefCounted
class_name LayoutClassifier

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")

enum LayoutFamily { MOBILE, LARGE_SCREEN }
enum Orientation { PORTRAIT, LANDSCAPE }
enum InputProfile { TOUCH, POINTER, HYBRID }
enum LargeDensity { COMPACT, WIDE }

const TABLET_SHORT_EDGE := 600.0


static func classify(platform_name: String, viewport_size: Vector2, touchscreen_available: bool, override_name: String = "") -> Dictionary:
	var orientation := Orientation.PORTRAIT if viewport_size.y >= viewport_size.x else Orientation.LANDSCAPE
	var short_edge := minf(viewport_size.x, viewport_size.y)
	var family := LayoutFamily.LARGE_SCREEN
	var normalized_override := override_name.strip_edges().to_lower()

	if normalized_override == "mobile":
		family = LayoutFamily.MOBILE
	elif normalized_override == "large":
		family = LayoutFamily.LARGE_SCREEN
	elif platform_name in ["Android", "iOS"]:
		family = LayoutFamily.LARGE_SCREEN if short_edge >= TABLET_SHORT_EDGE else LayoutFamily.MOBILE
	elif platform_name == "Web" and touchscreen_available and short_edge < TABLET_SHORT_EDGE:
		family = LayoutFamily.MOBILE

	var input := InputProfile.TOUCH
	if platform_name in ["Windows", "Linux", "macOS"]:
		input = InputProfile.HYBRID if touchscreen_available else InputProfile.POINTER
	elif platform_name == "Web" and family == LayoutFamily.LARGE_SCREEN:
		input = InputProfile.HYBRID if touchscreen_available else InputProfile.POINTER

	var density := LargeDensity.COMPACT if viewport_size.x < UiTokens.LARGE_COMPACT_BREAKPOINT else LargeDensity.WIDE
	return {"family": family, "orientation": orientation, "input": input, "density": density}


static func runtime_profile(viewport_size: Vector2) -> Dictionary:
	return classify(OS.get_name(), viewport_size, DisplayServer.is_touchscreen_available(), OS.get_environment("POOPY_LAYOUT_OVERRIDE"))
