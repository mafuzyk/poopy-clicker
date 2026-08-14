# Poopy Clicker 2.0 — Batch A (M1–M3) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the shared Poopy Clicker 2.0 presentation foundation, then ship deliberate Mobile Portrait/Landscape and Large-Screen Tablet/Desktop gameplay shells without changing canonical gameplay rules or save data.

**Architecture:** Batch A is a vertical migration. M1 introduces semantic tokens, a theme runtime, reusable primitives and deterministic layout classification while leaving the legacy UI functional. M2 adds a dedicated Mobile shell and explicit playfield ownership while Large-Screen temporarily remains on the legacy HUD. M3 adds a separate Large-Screen shell and removes the active dependency on the legacy HUD/EventBanner from `main.gd`; Mobile and Large-Screen share domain/runtime state and semantic components, not geometry.

**Tech Stack:** Godot 4.7+, GDScript, code-first `Control` UI, GL Compatibility renderer, existing custom headless test style (`SceneTree`/test scenes), no new third-party dependencies.

## Global Constraints

- Authoritative design: `docs/superpowers/specs/2026-08-14-poopy-clicker-2-master-design.md`.
- Plan authored against `main` commit `bdea213e1c2aa828e77157701b4bc27779936873`. Start from that commit or a descendant. If newer commits changed files listed in this plan, inspect/reconcile them before editing; never overwrite newer behavior blindly.
- Godot floor is **4.7+**.
- Preserve the current save schema. **Batch A must not bump save version or change persisted field meaning.**
- Preserve canonical gameplay math and runtime behavior. No economy, spawn, combo, event, Prestige, perk, mission or achievement balance changes belong in Batch A.
- Mobile and Large-Screen are **different layout families**. Do not implement one universal geometry with `if mobile` branches.
- Phone Portrait and Phone Landscape are distinct Mobile compositions. Rotation must not switch to Large-Screen.
- Tablet uses the Large-Screen family with a Touch/Hybrid profile. Desktop uses Large-Screen with Pointer/Keyboard or Hybrid profile.
- Layout family is chosen at shell creation and stays stable for the session. Resizing/rotation only changes composition inside that family.
- Shared semantics are allowed: tokens, theme controller, primitive components, gameplay presentation components and domain state. Shared shell geometry is not.
- Default theme uses a dark structural layer and violet-family primary accent. Theme IDs are interpreted only by `ThemeController`; feature controls never branch on `selected_ui_theme`.
- Normal touch targets are at least **48×48 logical px**. CLICK is larger but its invisible hit region must remain spatially honest.
- New UI uses semantic tokens. Existing legacy panels may keep `UiStyles` until their later migration; do not rewrite them in Batch A.
- `UiStyles`, `Layout`, `Hud`, `EdgeBar`, `EventBanner`, `BasePanel` and `PanelManager` are compatibility code during this batch. Do not delete them merely because the new shells stop using some of them.
- Code-first GDScript remains the default. Do not convert Batch A into a `.tscn`-heavy rewrite.
- Do not introduce ECS, a global EventBus, DI framework, service locator, singleton manager migration or unrelated directory cleanup.
- Cosmetic motion must never own the same transform property as gameplay movement. CLICK mechanical movement/scale remains controlled by `ClickController`; cosmetic press feedback is applied to a visual child.
- `main.gd` is the Composition Root. It may know both shell classes and choose one; shell classes must not know `main.gd`.
- Run targeted tests before smoke. CI is not the first test run.
- For commands below, use `GODOT_BIN="${GODOT_BIN:-godot}"`. If the environment exposes Godot as `godot4`, set `GODOT_BIN=godot4` once before running commands.
- Standard smoke command: `"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600`.
- Every milestone ends with its gate before proceeding to the next milestone.
- Agent completion report must contain exactly these sections: `Changed`, `Tests run`, `Results`, `Not tested`, `Known risks`.

---

## File Structure Locked by This Plan

### New shared design files

- `scripts/ui/design/ui_tokens.gd` — raw scales plus semantic role names/default values; no runtime state.
- `scripts/ui/design/theme_controller.gd` — selected theme ID → semantic palette; emits palette changes.
- `scripts/ui/design/layout_classifier.gd` — pure layout family/orientation/input/density classification plus debug override parsing.

### New shared primitive files

- `scripts/ui/components/poopy_button.gd` — semantic button variants/sizes and focus/touch behavior.
- `scripts/ui/components/icon_button.gd` — compact visual icon action with 48×48 minimum hit target.
- `scripts/ui/components/resource_chip.gd` — semantic resource chip.
- `scripts/ui/components/status_chip.gd` — compact semantic status chip.
- `scripts/ui/components/poopy_card.gd` — structural card primitive.
- `scripts/ui/components/section_header.gd` — title/subtitle/action header primitive.

### New gameplay presentation files

- `scripts/ui/gameplay/resource_presenter.gd` — shared formatting/visibility snapshot for Money, Income, GC, Essence and Prestige.
- `scripts/ui/gameplay/click_target.gd` — gameplay Button compatible with `ClickController`, with separate cosmetic visual root.
- `scripts/ui/gameplay/combo_display.gd` — combo presentation driven by GameState/ComboManager.
- `scripts/ui/gameplay/event_status.gd` — compact active-event presentation driven by EventManager.

### New shell files

- `scripts/ui/shell/playfield.gd` — explicit Goober/Click/Reward/GameplayOverlay layers.
- `scripts/ui/shell/game_shell_base.gd` — common shell contract/signals/layer references only; **no platform geometry**.
- `scripts/ui/shell/mobile/mobile_game_shell.gd` — Mobile family coordinator and orientation swap.
- `scripts/ui/shell/mobile/mobile_portrait_layout.gd` — Portrait geometry.
- `scripts/ui/shell/mobile/mobile_landscape_layout.gd` — Landscape geometry.
- `scripts/ui/shell/mobile/mobile_resource_header.gd` — Mobile resource composition.
- `scripts/ui/shell/mobile/mobile_nav_dock.gd` — permanent `Shop / Gooberário / Menu` Mobile dock.
- `scripts/ui/shell/large/large_screen_game_shell.gd` — Large-Screen family coordinator and compact/wide swap.
- `scripts/ui/shell/large/large_screen_layout.gd` — LargeCompact and LargeWide geometry.
- `scripts/ui/shell/large/large_resource_header.gd` — Large-Screen resource composition.
- `scripts/ui/shell/large/large_nav.gd` — Large-Screen nav; vertical rail in Wide, horizontal cluster in Compact.

### Existing production files modified

- `main.gd` — composition/wiring only: create theme controller, classify family, build shell, route layers to gameplay managers, preserve legacy Large-Screen during M2, then replace it in M3.
- `scripts/systems/click_controller.gd` — optional explicit local play-area control; legacy fallback preserved.
- `scripts/goobers/goober_manager.gd` — optional explicit Goober container/bounds control; legacy fallback preserved.
- `scripts/ui/safe_margin_container.gd` — only if required to make shell-level safe area deterministic/testable; do not duplicate safe insets in children.

### New tests

- `tests/presentation/ui_foundation_test.gd`
- `tests/presentation/layout_classifier_test.gd`
- `tests/integration/playfield_ownership_test.gd`
- `tests/presentation/mobile_shell_test.gd`
- `tests/presentation/large_screen_shell_test.gd`
- `tests/integration/batch_a_shell_wiring_test.gd`

Do not move existing tests merely to satisfy the future taxonomy.

---

# PRE-FLIGHT — M0 Gate Verification (No Batch-A Feature Code Yet)

### Task 0: Verify the baseline before changing presentation architecture

**Files:**
- Read: `docs/superpowers/specs/2026-08-14-poopy-clicker-2-master-design.md`
- Read: `main.gd`
- Read: `scripts/ui/ui_styles.gd`
- Read: `scripts/ui/layout.gd`
- Read: `scripts/ui/hud.gd`
- Read: `scripts/systems/click_controller.gd`
- Read: `scripts/goobers/goober_manager.gd`
- Read: `tests/smoke.gd`

**Interfaces:**
- Consumes: current `main` behavior.
- Produces: verified clean baseline; no production API.

- [ ] **Step 1: Start from clean current main**

```bash
git fetch origin
git switch main
git pull --ff-only origin main
git status --short
git rev-parse HEAD
```

Expected: clean status. Head must be `bdea213e1c2aa828e77157701b4bc27779936873` or a descendant whose newer changes have been reviewed against this plan.

- [ ] **Step 2: Parse the whole project headlessly**

```bash
GODOT_BIN="${GODOT_BIN:-godot}"
"$GODOT_BIN" --headless --path . --editor --quit
```

Expected: exit 0; no parser errors.

- [ ] **Step 3: Run the canonical smoke suite**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

Expected: exit 0 and smoke PASS summary.

- [ ] **Step 4: Run UI/runtime characterization already present**

```bash
"$GODOT_BIN" --headless --path . tests/modal_test.tscn
"$GODOT_BIN" --headless --path . tests/combo_time_test.tscn
"$GODOT_BIN" --headless --path . tests/event_time_test.tscn
"$GODOT_BIN" --headless --path . tests/event_effects_test.tscn
"$GODOT_BIN" --headless --path . tests/prestige_integration_test.tscn
```

Expected: every command exits 0.

- [ ] **Step 5: If any baseline test fails, stop**

Do not “fix while redesigning.” Record the failing command/output in `Known risks` and resolve baseline separately before Task 1.

---

# M1 — Shared Design Foundation

## Task 1: Add semantic token foundation

**Files:**
- Create: `scripts/ui/design/ui_tokens.gd`
- Create: `tests/presentation/ui_foundation_test.gd`

**Interfaces:**
- Consumes: none.
- Produces: `UiTokens` constants and helpers used by ThemeController/components/shells.

- [ ] **Step 1: Write the failing foundation test**

Create `tests/presentation/ui_foundation_test.gd` initially with token checks:

```gdscript
extends SceneTree

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")

var failures := 0

func check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL ", label)
    else:
        print("OK   ", label)

func _initialize() -> void:
    check(UiTokens.SPACE_1 == 4.0, "spacing foundation starts at 4")
    check(UiTokens.SPACE_7 == 48.0, "spacing scale reaches 48")
    check(UiTokens.TOUCH_MIN == 48.0, "touch minimum is 48")
    check(UiTokens.FONT_RESOURCE_PRIMARY == 28, "resource primary typography role")
    check(UiTokens.RADIUS_PILL > 100.0, "pill radius is semantic")
    var palette := UiTokens.default_palette()
    check(palette.has(UiTokens.COLOR_BACKGROUND), "default background token exists")
    check(palette.has(UiTokens.COLOR_ACCENT), "default accent token exists")
    check(palette.has(UiTokens.COLOR_RESOURCE_GC), "GC semantic color exists")
    check(palette.has(UiTokens.COLOR_RARITY_MYTHIC), "rarity semantic color exists")
    quit(failures)
```

- [ ] **Step 2: Run the test and verify it fails because UiTokens does not exist**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
```

Expected: parser/load failure for `ui_tokens.gd`.

- [ ] **Step 3: Implement the token file with the exact minimum contract**

Create `scripts/ui/design/ui_tokens.gd`:

```gdscript
extends RefCounted
class_name UiTokens

const COLOR_BACKGROUND_DEEP: StringName = &"background_deep"
const COLOR_BACKGROUND: StringName = &"background"
const COLOR_SURFACE_LOW: StringName = &"surface_low"
const COLOR_SURFACE: StringName = &"surface"
const COLOR_SURFACE_HIGH: StringName = &"surface_high"
const COLOR_BORDER_SUBTLE: StringName = &"border_subtle"
const COLOR_BORDER_STRONG: StringName = &"border_strong"
const COLOR_TEXT_PRIMARY: StringName = &"text_primary"
const COLOR_TEXT_SECONDARY: StringName = &"text_secondary"
const COLOR_TEXT_MUTED: StringName = &"text_muted"
const COLOR_ACCENT: StringName = &"accent"
const COLOR_ACCENT_HOVER: StringName = &"accent_hover"
const COLOR_ACCENT_PRESSED: StringName = &"accent_pressed"
const COLOR_SUCCESS: StringName = &"success"
const COLOR_WARNING: StringName = &"warning"
const COLOR_DANGER: StringName = &"danger"
const COLOR_INFO: StringName = &"info"
const COLOR_DISABLED: StringName = &"disabled"
const COLOR_RESOURCE_MONEY: StringName = &"resource_money"
const COLOR_RESOURCE_GC: StringName = &"resource_gc"
const COLOR_RESOURCE_ESSENCE: StringName = &"resource_essence"
const COLOR_PRESTIGE: StringName = &"prestige"
const COLOR_RARITY_COMMON: StringName = &"rarity_common"
const COLOR_RARITY_RARE: StringName = &"rarity_rare"
const COLOR_RARITY_EPIC: StringName = &"rarity_epic"
const COLOR_RARITY_LEGENDARY: StringName = &"rarity_legendary"
const COLOR_RARITY_MYTHIC: StringName = &"rarity_mythic"

const SPACE_1 := 4.0
const SPACE_2 := 8.0
const SPACE_3 := 12.0
const SPACE_4 := 16.0
const SPACE_5 := 24.0
const SPACE_6 := 32.0
const SPACE_7 := 48.0

const RADIUS_SMALL := 6.0
const RADIUS_MEDIUM := 10.0
const RADIUS_LARGE := 16.0
const RADIUS_XL := 22.0
const RADIUS_PILL := 999.0

const FONT_CAPTION := 12
const FONT_SMALL := 14
const FONT_BODY := 16
const FONT_BUTTON := 16
const FONT_CARD_TITLE := 18
const FONT_SECTION_TITLE := 22
const FONT_RESOURCE_PRIMARY := 28
const FONT_DISPLAY := 36
const FONT_HERO := 44

const MOTION_MICRO := 0.10
const MOTION_STANDARD := 0.20
const MOTION_EXPRESSIVE := 0.40

const TOUCH_MIN := 48.0
const MOBILE_NAV_HEIGHT := 64.0
const MOBILE_NAV_HEIGHT_LANDSCAPE := 54.0
const MOBILE_HEADER_HEIGHT := 100.0
const MOBILE_HEADER_HEIGHT_LANDSCAPE := 60.0
const LARGE_NAV_RAIL_POINTER := 104.0
const LARGE_NAV_RAIL_TOUCH := 120.0
const LARGE_COMPACT_BREAKPOINT := 1100.0

static func default_palette() -> Dictionary:
    return {
        COLOR_BACKGROUND_DEEP: Color("#0D0E13"),
        COLOR_BACKGROUND: Color("#12141B"),
        COLOR_SURFACE_LOW: Color("#181B24"),
        COLOR_SURFACE: Color("#20232E"),
        COLOR_SURFACE_HIGH: Color("#292D3A"),
        COLOR_BORDER_SUBTLE: Color("#343948"),
        COLOR_BORDER_STRONG: Color("#4A5062"),
        COLOR_TEXT_PRIMARY: Color("#F5F3FA"),
        COLOR_TEXT_SECONDARY: Color("#B8B6C3"),
        COLOR_TEXT_MUTED: Color("#7F7D8B"),
        COLOR_ACCENT: Color("#A970FF"),
        COLOR_ACCENT_HOVER: Color("#BC8CFF"),
        COLOR_ACCENT_PRESSED: Color("#8C53E8"),
        COLOR_SUCCESS: Color("#6ED99A"),
        COLOR_WARNING: Color("#F1C75B"),
        COLOR_DANGER: Color("#FF6B7A"),
        COLOR_INFO: Color("#69C4FF"),
        COLOR_DISABLED: Color("#666A78"),
        COLOR_RESOURCE_MONEY: Color("#D7F08A"),
        COLOR_RESOURCE_GC: Color("#F6C85F"),
        COLOR_RESOURCE_ESSENCE: Color("#A88BFF"),
        COLOR_PRESTIGE: Color("#E5D9FF"),
        COLOR_RARITY_COMMON: Color("#B5B7C2"),
        COLOR_RARITY_RARE: Color("#62A7FF"),
        COLOR_RARITY_EPIC: Color("#A970FF"),
        COLOR_RARITY_LEGENDARY: Color("#FFB84D"),
        COLOR_RARITY_MYTHIC: Color("#FF5CAA"),
    }
```

- [ ] **Step 4: Run foundation test**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
```

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/design/ui_tokens.gd tests/presentation/ui_foundation_test.gd
git commit -m "feat(ui): add Poopy 2 semantic token foundation"
```

---

## Task 2: Add ThemeController with semantic palette ownership

**Files:**
- Create: `scripts/ui/design/theme_controller.gd`
- Modify: `tests/presentation/ui_foundation_test.gd`

**Interfaces:**
- Consumes: `UiTokens.default_palette()`, `GameState.selected_ui_theme`, `GameState.changed`.
- Produces: `ThemeController.setup(state)`, `get_color(role)`, `get_palette()`, signal `tokens_changed`.

- [ ] **Step 1: Extend the test with theme-runtime assertions**

Add:

```gdscript
const GameState = preload("res://scripts/core/game_state.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")

func _test_theme_controller() -> void:
    var state := GameState.new()
    state.owned_ui_themes = ["default", "gold"]
    state.selected_ui_theme = "default"
    var theme := ThemeController.new()
    root.add_child(theme)
    theme.setup(state)
    var default_accent := theme.get_color(UiTokens.COLOR_ACCENT)
    state.selected_ui_theme = "gold"
    state.changed.emit()
    var gold_accent := theme.get_color(UiTokens.COLOR_ACCENT)
    check(default_accent != gold_accent, "selected theme changes semantic accent")
    check(theme.get_color(UiTokens.COLOR_RESOURCE_GC) == UiTokens.default_palette()[UiTokens.COLOR_RESOURCE_GC], "theme keeps GC semantics")
    theme.queue_free()
```

Call `_test_theme_controller()` before `quit(failures)`.

- [ ] **Step 2: Run and verify failure**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
```

Expected: missing `theme_controller.gd`.

- [ ] **Step 3: Implement ThemeController**

Required behavior:

```gdscript
extends Node
class_name ThemeController

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const GameState = preload("res://scripts/core/game_state.gd")

signal tokens_changed

var game_state: GameState
var _palette: Dictionary = {}
var _applied_theme := ""

const THEME_OVERRIDES := {
    "default": {},
    "gold": {UiTokens.COLOR_ACCENT: Color("#F6C85F"), UiTokens.COLOR_BACKGROUND: Color("#16130C"), UiTokens.COLOR_SURFACE: Color("#272216")},
    "ice": {UiTokens.COLOR_ACCENT: Color("#69D5FF"), UiTokens.COLOR_BACKGROUND: Color("#0D141A"), UiTokens.COLOR_SURFACE: Color("#18252D")},
    "void": {UiTokens.COLOR_ACCENT: Color("#D16BFF"), UiTokens.COLOR_BACKGROUND: Color("#0D0912"), UiTokens.COLOR_SURFACE: Color("#211727")},
    "candy": {UiTokens.COLOR_ACCENT: Color("#FF79B0"), UiTokens.COLOR_BACKGROUND: Color("#180F16"), UiTokens.COLOR_SURFACE: Color("#2B1B26")},
    "matrix": {UiTokens.COLOR_ACCENT: Color("#65E68A"), UiTokens.COLOR_BACKGROUND: Color("#0C140E"), UiTokens.COLOR_SURFACE: Color("#17251A")},
    "sunset": {UiTokens.COLOR_ACCENT: Color("#FF8B66"), UiTokens.COLOR_BACKGROUND: Color("#18100F"), UiTokens.COLOR_SURFACE: Color("#2B1D1A")},
}

func setup(state: GameState) -> void:
    game_state = state
    game_state.changed.connect(_sync_from_state)
    _sync_from_state()

func _sync_from_state() -> void:
    var id := game_state.selected_ui_theme if game_state != null else "default"
    if id == _applied_theme and not _palette.is_empty():
        return
    _applied_theme = id if THEME_OVERRIDES.has(id) else "default"
    _palette = UiTokens.default_palette()
    for role in THEME_OVERRIDES[_applied_theme]:
        _palette[role] = THEME_OVERRIDES[_applied_theme][role]
    tokens_changed.emit()

func get_color(role: StringName) -> Color:
    if _palette.has(role):
        return _palette[role]
    push_warning("ThemeController: missing semantic color role: %s" % role)
    return Color.MAGENTA

func get_palette() -> Dictionary:
    return _palette.duplicate()
```

No screen may read `THEME_OVERRIDES` or switch on theme ID.

- [ ] **Step 4: Run test and smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

Expected: both exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/design/theme_controller.gd tests/presentation/ui_foundation_test.gd
git commit -m "feat(ui): add semantic theme controller"
```

---

## Task 3: Add deterministic layout classification and debug override

**Files:**
- Create: `scripts/ui/design/layout_classifier.gd`
- Create: `tests/presentation/layout_classifier_test.gd`

**Interfaces:**
- Produces: `LayoutClassifier.classify(platform_name, viewport_size, touchscreen_available, override_name="") -> Dictionary` with keys `family`, `orientation`, `input`, `density`.
- Runtime override source: environment variable `POOPY_LAYOUT_OVERRIDE=mobile|large`.

- [ ] **Step 1: Write the failing classifier test**

```gdscript
extends SceneTree

const LayoutClassifier = preload("res://scripts/ui/design/layout_classifier.gd")
var failures := 0

func check(condition: bool, label: String) -> void:
    if not condition:
        failures += 1
        printerr("FAIL ", label)

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
    quit(failures)
```

- [ ] **Step 2: Verify test fails**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/layout_classifier_test.gd
```

Expected: missing classifier.

- [ ] **Step 3: Implement the classifier with stable family semantics**

Use this contract:

```gdscript
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
```

Important: Main calls `runtime_profile()` once to choose family. Mobile/Large shells may recalculate orientation/density internally, but must not ask Main to replace families on resize.

- [ ] **Step 4: Run classifier and smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/layout_classifier_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

Expected: exit 0.

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/design/layout_classifier.gd tests/presentation/layout_classifier_test.gd
git commit -m "feat(ui): add platform layout classifier"
```

---

## Task 4: Add core semantic primitives

**Files:**
- Create: `scripts/ui/components/poopy_button.gd`
- Create: `scripts/ui/components/icon_button.gd`
- Create: `scripts/ui/components/resource_chip.gd`
- Create: `scripts/ui/components/status_chip.gd`
- Create: `scripts/ui/components/poopy_card.gd`
- Create: `scripts/ui/components/section_header.gd`
- Modify: `tests/presentation/ui_foundation_test.gd`

**Interfaces:**
- All primitives consume `ThemeController` and semantic roles.
- `PoopyButton.setup(theme, variant, size)` is the common action primitive.
- No primitive reads GameState.

- [ ] **Step 1: Add failing primitive contract tests**

Instantiate each primitive, add to `root`, call setup, then assert:

```gdscript
var button := PoopyButton.new()
root.add_child(button)
button.setup(theme, PoopyButton.Variant.PRIMARY, PoopyButton.ControlSize.REGULAR)
check(button.custom_minimum_size.y >= UiTokens.TOUCH_MIN, "regular button touch target")

var icon := IconButton.new()
root.add_child(icon)
icon.setup(theme, "×")
check(icon.custom_minimum_size.x >= UiTokens.TOUCH_MIN, "icon button width touch target")
check(icon.custom_minimum_size.y >= UiTokens.TOUCH_MIN, "icon button height touch target")

var chip := ResourceChip.new()
root.add_child(chip)
chip.setup(theme, "GC", UiTokens.COLOR_RESOURCE_GC)
chip.set_amount("123")
check(chip.get_amount_text() == "123", "resource chip amount")
```

Also instantiate `StatusChip`, `PoopyCard`, `SectionHeader` and assert they create their required labels/style without error.

- [ ] **Step 2: Run and verify missing component failures**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
```

- [ ] **Step 3: Implement primitives using semantic styles**

Requirements:

`PoopyButton`:
- variants: `PRIMARY`, `SECONDARY`, `GHOST`, `DANGER`;
- sizes: `COMPACT` min 40 high for pointer-only use, `REGULAR` min 48, `LARGE` min 56;
- Mobile/Touch callers use REGULAR or LARGE, never COMPACT;
- visible focus StyleBox with 2 px semantic accent border;
- no feature-specific strings or colors.

Core style helper inside the component may create `StyleBoxFlat` from ThemeController. Example:

```gdscript
func _box(bg: Color, border: Color, radius: float) -> StyleBoxFlat:
    var box := StyleBoxFlat.new()
    box.bg_color = bg
    box.border_color = border
    box.set_border_width_all(1)
    box.set_corner_radius_all(int(radius))
    box.content_margin_left = UiTokens.SPACE_4
    box.content_margin_right = UiTokens.SPACE_4
    box.content_margin_top = UiTokens.SPACE_2
    box.content_margin_bottom = UiTokens.SPACE_2
    return box
```

`ResourceChip` exposes `setup(theme, label_text, color_role)` and `set_amount(text)`; `get_amount_text()` is provided for tests.

`StatusChip` exposes `setup(theme, text, color_role)` and `set_text(value)`.

`PoopyCard` exposes `setup(theme, elevated := false)`; no feature booleans.

`SectionHeader` exposes `setup(theme, title, subtitle := "")` and creates title/subtitle labels only.

Every component connects to `theme.tokens_changed` and reapplies its semantic style.

- [ ] **Step 4: Run foundation test and parser**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
"$GODOT_BIN" --headless --path . --editor --quit
```

Expected: exit 0.

- [ ] **Step 5: Run smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

- [ ] **Step 6: Commit and run M1 Gate**

```bash
git add scripts/ui/components scripts/ui/design tests/presentation
git commit -m "feat(ui): add Poopy 2 core UI primitives"
```

**M1 Gate:** `ui_foundation_test.gd`, `layout_classifier_test.gd`, project parse and smoke all pass. Confirm no legacy feature panel was restyled and no screen contains branches for individual theme IDs.

---

# M2 — Mobile Game Shell

## Task 5: Make gameplay bounds/layer ownership explicit without breaking legacy behavior

**Files:**
- Modify: `scripts/systems/click_controller.gd`
- Modify: `scripts/goobers/goober_manager.gd`
- Create: `tests/integration/playfield_ownership_test.gd`

**Interfaces:**
- `ClickController.setup(button, state, play_area := null)`; `play_area` must be the same local coordinate space as the button parent.
- `GooberManager.setup(button, state, goober_container := null, bounds_control := null)`.
- Null arguments preserve current viewport/Layout fallback for legacy tests/UI.

- [ ] **Step 1: Write characterization tests for explicit and fallback bounds**

Test exact invariants:

```gdscript
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
```

For GooberManager, pass a `Control` container/bounds of known size, force-spawn an enabled Goober, then assert the Goober parent is the supplied container and its position lies in the supplied bounds.

Also instantiate each manager with the old shorter `setup(...)` call and assert it does not error, preserving compatibility.

- [ ] **Step 2: Run and verify failure on old signatures/ownership**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/integration/playfield_ownership_test.gd
```

Expected: failure because explicit playfield/container APIs do not exist yet.

- [ ] **Step 3: Update ClickController minimally**

Add `var play_area: Control` and optional third setup parameter. `get_play_area_rect()` becomes:

```gdscript
func get_play_area_rect() -> Rect2:
    if play_area != null and is_instance_valid(play_area):
        return Rect2(Vector2.ZERO, play_area.size)
    var viewport_size := click_button.get_viewport_rect().size
    var top_inset := Layout.TOP_BAR_HEIGHT
    var bottom_inset := Layout.BOTTOM_BAR_HEIGHT
    var width := maxf(Layout.EDGE_MARGIN * 2.0, viewport_size.x - Layout.EDGE_MARGIN * 2.0)
    var height := maxf(1.0, viewport_size.y - top_inset - bottom_inset)
    return Rect2(Layout.EDGE_MARGIN, top_inset, width, height)
```

Do not change difficulty, movement, scale, event capability or pointer formulas.

- [ ] **Step 4: Update GooberManager minimally**

Add optional container/bounds references. Required behavior:

```gdscript
var goober_container: Node
var bounds_control: Control

func setup(button: Control, state_ref: GameState, container: Node = null, bounds: Control = null) -> void:
    click_button = button
    game_state = state_ref
    goober_container = container if container != null else self
    bounds_control = bounds
    # existing catalog/frame setup follows

func get_bounds() -> Rect2:
    if bounds_control != null and is_instance_valid(bounds_control):
        return Rect2(Vector2.ZERO, bounds_control.size)
    # preserve current Layout-based fallback
```

Spawn with `goober_container.add_child(goober)`. Despawn/cleanup must use `queue_free()`/the Goober's actual parent rather than assuming the manager is the visual parent.

Do not change spawn selection, rewards, size formulas or MAX_GOOBERS.

- [ ] **Step 5: Run targeted integration + smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/integration/playfield_ownership_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

Expected: both exit 0.

- [ ] **Step 6: Commit**

```bash
git add scripts/systems/click_controller.gd scripts/goobers/goober_manager.gd tests/integration/playfield_ownership_test.gd
git commit -m "refactor(ui): make gameplay playfield ownership explicit"
```

---

## Task 6: Create shared Playfield and shell contract

**Files:**
- Create: `scripts/ui/shell/playfield.gd`
- Create: `scripts/ui/shell/game_shell_base.gd`
- Create: `scripts/ui/gameplay/resource_presenter.gd`
- Create: `tests/presentation/mobile_shell_test.gd` (initial structural subset)

**Interfaces:**
- `Playfield` exposes `goober_layer`, `click_target_layer`, `reward_fx_layer`, `gameplay_overlay_layer`.
- `GameShellBase` exposes signals `shop_requested`, `bestiary_requested`, `menu_requested`; references `playfield`, `surface_layer`, `overlay_layer`, `click_target`; method `set_gameplay_blocked(blocked)`.
- `ResourcePresenter.snapshot(state, economy) -> Dictionary`.

- [ ] **Step 1: Write structural shell test first**

The initial test creates a `Playfield`, sizes it to 360×420 and checks all four named layers fill it. It also verifies `ResourcePresenter.snapshot()` returns:

```gdscript
{
    "money": "$0",
    "income": "0/s",
    "gc_visible": false,
    "gc": "0",
    "essence_visible": false,
    "essence": "0",
    "prestige_visible": false,
    "prestige": "P0",
}
```

For `essence_visible`, use `state.prestige_level > 0 or state.poopy_essence > 0`. For GC, use `state.secret_shop_unlocked`. Prestige indicator is visible after `prestige_level > 0`.

- [ ] **Step 2: Run and verify missing files fail**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
```

- [ ] **Step 3: Implement Playfield**

`Playfield` is a full-rect `Control`. Each sublayer is a full-rect `Control`; set `mouse_filter = IGNORE` except `click_target_layer`, which must allow the Button it contains to receive input. Do not position HUD/nav here.

- [ ] **Step 4: Implement GameShellBase contract only**

The base class may create/own shared `surface_layer` and `overlay_layer`, but must not choose Portrait/Landscape/Wide geometry. Subclasses decide where `playfield` is mounted.

- [ ] **Step 5: Implement ResourcePresenter**

Use `NumberFormat.format` and read-only queries. It must not mutate state and must not connect signals.

- [ ] **Step 6: Run test, parser and commit**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . --editor --quit
git add scripts/ui/shell scripts/ui/gameplay/resource_presenter.gd tests/presentation/mobile_shell_test.gd
git commit -m "feat(ui): add shared game shell contract and playfield"
```

---

## Task 7: Build semantic ClickTarget with independent cosmetic transform

**Files:**
- Create: `scripts/ui/gameplay/click_target.gd`
- Modify: `tests/presentation/mobile_shell_test.gd`

**Interfaces:**
- `ClickTarget extends Button`, so existing `ClickController` remains compatible.
- `setup(theme, base_size)` configures visual child and hit size.
- Outer Button owns mechanical `position/scale`; child `_visual_root` owns cosmetic press scale.

- [ ] **Step 1: Add failing transform-ownership test**

Test:

```gdscript
var target := ClickTarget.new()
root.add_child(target)
target.setup(theme, Vector2(200, 84))
target.scale = Vector2(0.9, 0.9)
var mechanical_scale := target.scale
target.debug_set_pressed_visual(true)
check(target.scale == mechanical_scale, "cosmetic press never changes mechanical scale")
check(target.get_visual_scale().x < 1.0, "press feedback affects visual child")
target.debug_set_pressed_visual(false)
```

A small debug/test method is acceptable if it simply drives the same internal visual-state path as `button_down/button_up`; do not expose gameplay cheats.

- [ ] **Step 2: Run and verify missing ClickTarget**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
```

- [ ] **Step 3: Implement ClickTarget**

Requirements:

- outer Button is visually transparent and remains the actual clickable/hittable node;
- child `PanelContainer` or equivalent `visual_root` fills the Button and uses semantic accent/surface styles;
- child Label displays `CLICK` using `FONT_DISPLAY`/appropriate fit;
- all children use `MOUSE_FILTER_IGNORE`;
- button-down sets visual child scale around 0.95 immediately;
- button-up returns visual child toward 1.0 with a short micro tween, without touching outer `position`, `size` or `scale`;
- cancel/replace the previous cosmetic tween before starting another;
- update `visual_root.pivot_offset = size / 2` on resize;
- no screen shake, particles or reward labels in Batch A.

- [ ] **Step 4: Run test and smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

- [ ] **Step 5: Commit**

```bash
git add scripts/ui/gameplay/click_target.gd tests/presentation/mobile_shell_test.gd
git commit -m "feat(ui): add dedicated ClickTarget presentation"
```

---

## Task 8: Build Mobile Portrait and Landscape compositions

**Files:**
- Create: `scripts/ui/shell/mobile/mobile_portrait_layout.gd`
- Create: `scripts/ui/shell/mobile/mobile_landscape_layout.gd`
- Create: `scripts/ui/shell/mobile/mobile_game_shell.gd`
- Modify: `tests/presentation/mobile_shell_test.gd`

**Interfaces:**
- Both layout classes expose `adopt(header, playfield, event_status, combo_display, nav)` and named slots.
- `MobileGameShell.setup(state, economy, combo_manager, event_manager, theme, profile)`.
- Orientation changes rebuild/reparent presentation while preserving the same `Playfield`, ClickTarget and gameplay state.

- [ ] **Step 1: Add failing Mobile composition tests**

Instantiate `MobileGameShell` at 360×800 and assert:

- orientation reports Portrait;
- playfield has positive width/height;
- header sits above playfield;
- nav sits below playfield;
- ClickTarget is parented to `playfield.click_target_layer`;
- nav has exactly three primary destinations.

Resize the same shell instance to 800×360, wait two frames, and assert:

- orientation reports Landscape;
- the **same Playfield instance ID** remains;
- the same ClickTarget instance remains;
- landscape header height is smaller than portrait header height;
- no family replacement occurs.

- [ ] **Step 2: Run and verify failure**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
```

- [ ] **Step 3: Implement Portrait layout**

Required structure:

```text
Safe content
└── VBox
    ├── Header slot (~100)
    ├── Playfield slot (expand)
    └── Nav slot (~64)
```

Event and Combo are overlay slots inside/over the Playfield region, not additional rows that steal large vertical space.

- [ ] **Step 4: Implement Landscape layout**

Required structure:

```text
Safe content
└── VBox
    ├── Compact header (~60)
    ├── Playfield region (expand; optional right-side skill space reserved but empty in Batch A)
    └── Compact nav (~54)
```

Do not instantiate Portrait layout and rotate it. This is a separate composition class.

- [ ] **Step 5: Implement MobileGameShell orientation coordinator**

It creates persistent shared nodes once, listens to its own resize, chooses Portrait versus Landscape from current size, and reparents persistent components through each layout's `adopt(...)`. It never asks Main to replace the Mobile shell on rotation.

Shell-level safe area must wrap the family layout exactly once. Child header/nav must not call `DisplayServer.get_display_safe_area()` themselves.

- [ ] **Step 6: Run structural test and commit**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . --editor --quit
git add scripts/ui/shell/mobile tests/presentation/mobile_shell_test.gd
git commit -m "feat(ui): add separate Mobile portrait and landscape shells"
```

---

## Task 9: Add Mobile resource header and primary navigation dock

**Files:**
- Create: `scripts/ui/shell/mobile/mobile_resource_header.gd`
- Create: `scripts/ui/shell/mobile/mobile_nav_dock.gd`
- Modify: `scripts/ui/shell/mobile/mobile_game_shell.gd`
- Modify: `tests/presentation/mobile_shell_test.gd`

**Interfaces:**
- Header consumes GameState/Economy + ThemeController, self-subscribes to `GameState.changed` for Batch-A compatibility, and uses `ResourcePresenter`.
- Dock emits `shop_requested`, `bestiary_requested`, `menu_requested`.
- No `achievements_requested` primary action in new shell.

- [ ] **Step 1: Add failing header/dock state tests**

Verify fresh state shows Money/Income and hides GC/Essence/Prestige. Then set:

```gdscript
state.secret_shop_unlocked = true
state.goober_coins = 42
state.prestige_level = 3
state.poopy_essence = 17
state.changed.emit()
```

Assert header exposes visible values `42`, `17`, `P3` without Main calling `refresh()`.

Assert dock children/actions are exactly Shop, Gooberário, Menu and each visible Button is at least 48 logical px high in touch mode.

- [ ] **Step 2: Run and verify failure**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
```

- [ ] **Step 3: Implement MobileResourceHeader**

Portrait composition: centered Money, Income immediately below, resource chips in a compact row below. Landscape composition: Money/Income and chips in one shallow horizontal cluster. The class may expose `set_orientation(...)`; this is an orientation variant inside the Mobile family, not a cross-family universal layout.

Do not color the whole Money string aggressively; use primary text with a restrained Money semantic accent where practical.

- [ ] **Step 4: Implement MobileNavDock**

Use `PoopyButton` or a composed semantic nav control. Mobile dock remains bottom-aligned through the layout slots. Use text labels now; do not invent mixed emoji iconography.

- [ ] **Step 5: Wire shell signal re-emission and test**

`MobileGameShell` must re-emit dock signals through the `GameShellBase` signal contract.

- [ ] **Step 6: Run and commit**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
git add scripts/ui/shell/mobile tests/presentation/mobile_shell_test.gd
git commit -m "feat(ui): add Mobile resource HUD and navigation dock"
```

---

## Task 10: Add ComboDisplay and EventStatus and mount them in Mobile gameplay

**Files:**
- Create: `scripts/ui/gameplay/combo_display.gd`
- Create: `scripts/ui/gameplay/event_status.gd`
- Modify: `scripts/ui/shell/mobile/mobile_game_shell.gd`
- Modify: `tests/presentation/mobile_shell_test.gd`

**Interfaces:**
- `ComboDisplay.setup(state, combo_manager, theme)`.
- `EventStatus.setup(event_manager, theme)`.
- Both are shared gameplay components; Large-Screen will reuse them but place them differently.

- [ ] **Step 1: Add failing gameplay-overlay tests**

For ComboDisplay:
- initial combo 0 → hidden;
- `combo_manager.register_manual_click()` → visible and includes count/multiplier;
- combo break → hidden.

For EventStatus:
- force/start a deterministic event using existing EventManager test hooks/patterns;
- active event → visible title + progress;
- event end → hidden.

Do not assert animation pixels.

- [ ] **Step 2: Run and verify missing component failure**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
```

- [ ] **Step 3: Implement ComboDisplay**

Batch-A visual scope is intentionally restrained: count, multiplier, semantic accent, small pulse permitted. No final M8 escalation tiers yet. Component must remain outside the static resource header.

- [ ] **Step 4: Implement EventStatus**

Reuse EventManager's existing `event_started`, `event_ended`, `event_progress_changed`. Event-specific color from event definition is allowed as semantic event data, but structural background/border/text styling comes from ThemeController. Keep the existing event description readable but compact.

- [ ] **Step 5: Mount in Mobile layout slots and run tests**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . tests/event_time_test.tscn
"$GODOT_BIN" --headless --path . tests/event_effects_test.tscn
```

- [ ] **Step 6: Commit**

```bash
git add scripts/ui/gameplay scripts/ui/shell/mobile tests/presentation/mobile_shell_test.gd
git commit -m "feat(ui): move combo and event status into gameplay HUD"
```

---

## Task 11: Wire the Mobile shell into Main while preserving legacy Large-Screen

**Files:**
- Modify: `main.gd`
- Create: `tests/integration/batch_a_shell_wiring_test.gd`

**Interfaces:**
- Main creates one ThemeController.
- Main classifies layout once at startup.
- If family is Mobile, Main builds `MobileGameShell` and supplies explicit playfield layers to ClickController/GooberManager.
- If family is Large-Screen during M2, Main uses the existing Hud/EventBanner path unchanged.

- [ ] **Step 1: Write wiring tests around pure/selectable boundaries**

Do not load the user's real save in a test. Test the pieces Main will use:

```gdscript
var mobile_profile := LayoutClassifier.classify("Android", Vector2(360, 800), true)
var large_profile := LayoutClassifier.classify("Windows", Vector2(1366, 768), false)
check(mobile_profile.family == LayoutClassifier.LayoutFamily.MOBILE, "mobile branch selection")
check(large_profile.family == LayoutClassifier.LayoutFamily.LARGE_SCREEN, "legacy large branch selection during M2")
```

Instantiate MobileGameShell with isolated GameState/Economy/Managers and assert its navigation signals can be observed by an external coordinator. Assert Playfield references passed to a ClickController/GooberManager cause explicit-bounds mode.

- [ ] **Step 2: Modify Main composition carefully**

Add variables:

```gdscript
var theme_controller: ThemeController
var game_shell: GameShellBase
var layout_profile: Dictionary = {}
```

Split current UI construction into two explicit paths:

```gdscript
func build_ui() -> void:
    theme_controller = ThemeController.new()
    theme_controller.setup(game_state)
    add_child(theme_controller)
    layout_profile = LayoutClassifier.runtime_profile(get_viewport_rect().size)
    if layout_profile.family == LayoutClassifier.LayoutFamily.MOBILE:
        _build_mobile_ui()
    else:
        _build_legacy_ui()
```

`_build_legacy_ui()` contains the current Hud + Button + EventBanner behavior without semantic redesign.

`_build_mobile_ui()` creates MobileGameShell, connects Shop/Bestiary/Menu, assigns `click_button = game_shell.click_target`, and adds invert overlay to `game_shell.overlay_layer` rather than the root.

- [ ] **Step 3: Update gameplay wiring with optional shell ownership**

In `setup_click_controller()`:

```gdscript
var play_area: Control = null
if game_shell != null:
    play_area = game_shell.playfield.click_target_layer
click_controller.setup(click_button, game_state, play_area)
```

In `setup_goobers()` pass explicit container/bounds only when `game_shell != null`; otherwise preserve old setup call behavior.

- [ ] **Step 4: Make input blocking shell-aware**

If a new shell exists, call `game_shell.set_gameplay_blocked(blocked)`; otherwise preserve the current direct button disable/modulate behavior. Goober input blocking remains unchanged.

- [ ] **Step 5: Guard legacy refresh**

`refresh_ui()` must not assume `hud` exists. New shell components self-refresh from state/signals. Legacy panels continue their current refresh path.

- [ ] **Step 6: Run parser, wiring test, smoke and legacy UI tests**

```bash
"$GODOT_BIN" --headless --path . --editor --quit
"$GODOT_BIN" --headless --path . --script res://tests/integration/batch_a_shell_wiring_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
"$GODOT_BIN" --headless --path . tests/modal_test.tscn
```

- [ ] **Step 7: Manual/simulated Mobile sanity**

On a desktop dev machine, force Mobile without changing family code:

```bash
POOPY_LAYOUT_OVERRIDE=mobile "$GODOT_BIN" --path .
```

Verify at minimum:
- CLICK works/moves;
- Goobers remain inside playfield;
- Shop/Gooberário/Menu buttons open current legacy surfaces;
- surfaces block CLICK/Goober input;
- event status appears when an event starts;
- resize Portrait↔Landscape keeps the same active run.

If no graphical runtime is available, report this under `Not tested`; do not claim visual completion.

- [ ] **Step 8: Commit and run M2 Gate**

```bash
git add main.gd tests/integration/batch_a_shell_wiring_test.gd
git commit -m "feat(ui): activate Poopy 2 Mobile gameplay shell"
```

**M2 Gate:** all targeted tests + smoke pass; forced Mobile Portrait and Landscape are playable; Large-Screen still launches through legacy UI and remains functional. No save/schema or gameplay formula changes.

---

# M3 — Large-Screen Game Shell

## Task 12: Build Large-Screen shell with distinct Compact/Wide composition

**Files:**
- Create: `scripts/ui/shell/large/large_screen_layout.gd`
- Create: `scripts/ui/shell/large/large_screen_game_shell.gd`
- Create: `tests/presentation/large_screen_shell_test.gd`

**Interfaces:**
- `LargeScreenGameShell.setup(state, economy, combo_manager, event_manager, theme, profile)`.
- `LargeScreenLayout` has `COMPACT` and `WIDE` compositions inside the Large-Screen family.
- Wide composition uses a left nav rail; Compact uses a top horizontal nav cluster. Neither switches to Mobile.

- [ ] **Step 1: Write failing layout-family tests**

At 1366×768 with Wide density, assert:
- nav region is left of playfield;
- resource header is above playfield/content;
- Playfield has significantly more area than navigation;
- same shared ClickTarget/Combo/Event components are used.

Resize same LargeScreenGameShell to 800×600 and assert:
- density becomes Compact;
- family remains Large-Screen;
- the same Playfield and ClickTarget instance IDs survive;
- nav relocates to the compact top cluster rather than a Mobile bottom dock.

- [ ] **Step 2: Run and verify missing Large-Screen files**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/large_screen_shell_test.gd
```

- [ ] **Step 3: Implement LargeWide geometry**

Structure:

```text
Safe content
└── HBox
    ├── Left nav rail (104 pointer / 120 touch)
    └── VBox content
        ├── Resource header
        └── Playfield (expand)
```

EventStatus and ComboDisplay are positioned as gameplay overlays, not placed in the navigation rail.

- [ ] **Step 4: Implement LargeCompact geometry**

Structure:

```text
Safe content
└── VBox
    ├── Top row: resource header + horizontal nav cluster
    └── Playfield (expand)
```

This is intentionally not the Mobile dock layout.

- [ ] **Step 5: Implement LargeScreenGameShell density coordinator**

LargeScreenGameShell responds to resize by Compact/Wide re-layout only. It never asks Main to instantiate Mobile. Keep persistent Playfield/ClickTarget/state components while swapping geometry.

- [ ] **Step 6: Run test and commit**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/large_screen_shell_test.gd
"$GODOT_BIN" --headless --path . --editor --quit
git add scripts/ui/shell/large tests/presentation/large_screen_shell_test.gd
git commit -m "feat(ui): add distinct Large-Screen gameplay shell"
```

---

## Task 13: Add Large-Screen resource HUD and navigation profiles

**Files:**
- Create: `scripts/ui/shell/large/large_resource_header.gd`
- Create: `scripts/ui/shell/large/large_nav.gd`
- Modify: `scripts/ui/shell/large/large_screen_game_shell.gd`
- Modify: `tests/presentation/large_screen_shell_test.gd`

**Interfaces:**
- Large resource header uses the same `ResourcePresenter`, not duplicated number/visibility logic.
- `LargeNav` exposes the same three navigation signals and changes geometry based on `LargeDensity`.
- Input profile controls ergonomics, not feature availability.

- [ ] **Step 1: Add failing Tablet/Desktop profile tests**

For `InputProfile.TOUCH` at 800×600:
- every primary nav action is ≥48×48;
- no action requires hover;
- header/resource values are visible.

For `InputProfile.POINTER` at 1366×768:
- focus mode is enabled on nav actions;
- hover styling exists through PoopyButton;
- the Wide rail is used.

For `HYBRID`, keep touch-sized hit targets while retaining focus/hover capability.

- [ ] **Step 2: Run and verify failure**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/large_screen_shell_test.gd
```

- [ ] **Step 3: Implement LargeResourceHeader**

Use a horizontal presentation: Money is dominant, Income subordinate, GC/Essence/Prestige chips to the side when unlocked. Self-subscribe to `GameState.changed`; do not require Main refresh.

- [ ] **Step 4: Implement LargeNav**

- Wide: vertical rail labels `Loja`, `Gooberário`, `Menu`.
- Compact: horizontal cluster in the top row.
- Touch/Hybrid: min control size at least 48×48 and generous spacing.
- Pointer: may use denser visual padding but still maintain accessible focus indication.
- No Achievements primary destination.

- [ ] **Step 5: Run test, foundation test and smoke**

```bash
"$GODOT_BIN" --headless --path . --script res://tests/presentation/large_screen_shell_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
```

- [ ] **Step 6: Commit**

```bash
git add scripts/ui/shell/large tests/presentation/large_screen_shell_test.gd
git commit -m "feat(ui): add Large-Screen resource HUD and navigation"
```

---

## Task 14: Activate Large-Screen shell in Main and retire active legacy HUD/EventBanner wiring

**Files:**
- Modify: `main.gd`
- Modify: `tests/integration/batch_a_shell_wiring_test.gd`

**Interfaces:**
- Main now chooses `MobileGameShell` or `LargeScreenGameShell` for all normal runtime profiles.
- Legacy Hud/EventBanner files remain in repository for later migration cleanup, but Main no longer instantiates them.

- [ ] **Step 1: Extend wiring test for both shell classes**

Create isolated shells from classifier results and assert:
- Mobile profile → MobileGameShell class;
- Large profile → LargeScreenGameShell class;
- both emit the same three primary navigation signals;
- both expose Playfield layer references;
- both provide a Button-compatible ClickTarget.

Do not test by width alone; use LayoutClassifier profiles.

- [ ] **Step 2: Replace the M2 legacy Large-Screen branch**

Main `build_ui()` becomes conceptually:

```gdscript
layout_profile = LayoutClassifier.runtime_profile(get_viewport_rect().size)
if layout_profile.family == LayoutClassifier.LayoutFamily.MOBILE:
    _build_mobile_ui()
else:
    _build_large_screen_ui()
```

Both methods use the same ThemeController and wire the same Shop/Bestiary/Menu handlers. Remove active Hud/EventBanner creation from Main. Do not delete their source files.

- [ ] **Step 3: Make invert overlay shell-owned for both families**

`create_invert_overlay()` attaches the overlay to `game_shell.overlay_layer`. Preserve the exact invert shader/effect behavior.

- [ ] **Step 4: Remove unconditional legacy HUD refresh references**

`refresh_ui()` continues to refresh legacy surfaces still managed by PanelManager, but there is no active Hud dependency. New shell HUD components observe state directly.

- [ ] **Step 5: Run parser + all Batch-A automated tests**

```bash
"$GODOT_BIN" --headless --path . --editor --quit
"$GODOT_BIN" --headless --path . --script res://tests/presentation/ui_foundation_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/presentation/layout_classifier_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/integration/playfield_ownership_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/presentation/mobile_shell_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/presentation/large_screen_shell_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/integration/batch_a_shell_wiring_test.gd
"$GODOT_BIN" --headless --path . --script res://tests/smoke.gd --quit-after 600
"$GODOT_BIN" --headless --path . tests/modal_test.tscn
"$GODOT_BIN" --headless --path . tests/combo_time_test.tscn
"$GODOT_BIN" --headless --path . tests/event_time_test.tscn
"$GODOT_BIN" --headless --path . tests/event_effects_test.tscn
"$GODOT_BIN" --headless --path . tests/prestige_integration_test.tscn
```

Expected: every command exits 0.

- [ ] **Step 6: Manual/simulated Large-Screen sanity**

```bash
POOPY_LAYOUT_OVERRIDE=large "$GODOT_BIN" --path .
```

Verify:
- 1366×768 Wide uses left navigation rail;
- resize below 1100 logical width uses LargeCompact, not Mobile;
- Tablet-sized 800×600 remains Large-Screen;
- Shop/Gooberário/Menu still open legacy surfaces correctly;
- CLICK/Goobers remain inside Playfield;
- Escape closes current legacy surface as before;
- event/combo appear in gameplay overlay;
- theme changes alter shell semantic accent without screen-specific branches.

- [ ] **Step 7: Commit**

```bash
git add main.gd tests/integration/batch_a_shell_wiring_test.gd
git commit -m "feat(ui): activate Poopy 2 Large-Screen shell"
```

---

## Task 15: Run Batch A layout matrix and hardening pass

**Files:**
- Modify only if a failing test exposes a Batch-A bug: files already introduced in Tasks 1–14.
- Do not add Batch-B navigation/surface architecture.

**Interfaces:**
- Consumes: completed M1–M3.
- Produces: evidence for Batch A Gate.

- [ ] **Step 1: Expand shell tests to the approved logical viewport matrix**

The tests must instantiate the correct family explicitly and verify positive Playfield size plus required controls in bounds at:

```text
Mobile Portrait: 320×568, 360×800
Mobile Landscape: 568×320, 800×360
Large touch/compact: 800×600, 1024×768
Large pointer/wide: 1366×768, 1920×1080
```

For each case assert:
- primary navigation remains in shell bounds;
- ClickTarget remains fully inside Playfield after `center_button()` and `keep_button_inside()`;
- playfield has non-zero area;
- no shell family changes due only to orientation/resize inside the family.

- [ ] **Step 2: Run the full Batch-A command set again**

Run exactly the command set from Task 14 Step 5 after adding matrix checks.

Expected: all exit 0.

- [ ] **Step 3: Inspect hardcoded styling in new feature/shell files**

Run:

```bash
grep -R "Color(" scripts/ui/design scripts/ui/components scripts/ui/gameplay scripts/ui/shell
```

Expected:
- raw palette colors are concentrated in `ui_tokens.gd` and `theme_controller.gd`;
- event definition colors may be parsed in `event_status.gd`;
- feature/shell files do not invent unrelated structural colors.

Also run:

```bash
grep -R "selected_ui_theme\|== \"matrix\"\|== \"gold\"\|== \"ice\"\|== \"void\"\|== \"candy\"\|== \"sunset\"" scripts/ui/components scripts/ui/gameplay scripts/ui/shell
```

Expected: no matches in feature/shell components.

- [ ] **Step 4: Check save/schema scope discipline**

```bash
git diff origin/main...HEAD -- scripts/systems/save_manager.gd scripts/core/game_state.gd
```

Expected: no persisted-schema changes. If `game_state.gd` was touched unexpectedly, explain and revert unless strictly required for a tested Batch-A presentation bug.

- [ ] **Step 5: Check that legacy compatibility files were not prematurely deleted**

Confirm these still exist:

```bash
test -f scripts/ui/hud.gd
test -f scripts/ui/event_banner.gd
test -f scripts/ui/edge_bar.gd
test -f scripts/ui/base_panel.gd
test -f scripts/ui/panel_manager.gd
```

Expected: exit 0. They are removed only after later surface migration proves them unused.

- [ ] **Step 6: Commit any matrix-test-only changes**

```bash
git add tests/presentation tests/integration
git commit -m "test(ui): cover Poopy 2 Batch A layout matrix"
```

If no files changed, do not create an empty commit.

---

# Batch A Gate — Required Before Declaring M1+M2+M3 Complete

The agent must verify and report each item. A missing physical-device check belongs under `Not tested`; it must not be silently treated as PASS.

## M1 Gate

- [ ] Semantic palette, spacing, radius, typography, motion and touch metrics exist centrally.
- [ ] ThemeController is the only new UI layer interpreting theme IDs.
- [ ] Core primitives refresh when theme tokens change.
- [ ] No migrated component depends on raw legacy `UiStyles` for its structural design.
- [ ] Legacy panels remain functional.

## M2 Gate

- [ ] Mobile Portrait and Mobile Landscape are separate compositions.
- [ ] Rotation/re-layout preserves the same Playfield and ClickTarget objects.
- [ ] Mobile primary nav is exactly Shop / Gooberário / Menu.
- [ ] Money/Income are always visible; GC/Essence/Prestige use progressive disclosure.
- [ ] Combo is outside the static resource header.
- [ ] EventStatus is compact and inside gameplay presentation.
- [ ] ClickController mechanics/formulas are unchanged.
- [ ] Goober spawn/reward mechanics are unchanged.
- [ ] Explicit playfield bounds keep CLICK/Goobers inside their actual playfield.

## M3 Gate

- [ ] Large-Screen is a distinct shell, not Mobile geometry enlarged.
- [ ] 800×600 Large touch uses LargeCompact and never switches to Mobile.
- [ ] 1366×768 / 1920×1080 use LargeWide.
- [ ] Wide uses a left navigation rail; Compact uses a top horizontal nav cluster.
- [ ] Tablet touch targets are at least 48×48 and no essential behavior depends on hover.
- [ ] Desktop supports visible focus/hover enhancement via shared primitives.
- [ ] Main chooses family once and shells handle in-family resizing.
- [ ] Both shells share the same gameplay/domain managers and semantic design foundation.

## Regression Gate

- [ ] Project parses headlessly.
- [ ] New Batch-A tests pass.
- [ ] Existing smoke passes.
- [ ] Modal, combo, event and Prestige integration tests pass.
- [ ] Save schema/version is unchanged.
- [ ] No new dependency was added.
- [ ] No canonical economy/event/combo/Goober/Prestige formula changed.

## Human/Runtime Gate

Where graphical/runtime access exists, verify:

- [ ] Mobile 360×800.
- [ ] Mobile 800×360.
- [ ] Large touch-equivalent 800×600.
- [ ] Desktop 1366×768.
- [ ] Desktop 1920×1080.
- [ ] CLICK feels immediate and remains hittable.
- [ ] Legacy secondary surfaces still open/block gameplay correctly.
- [ ] Default dark/violet identity is visibly present without RGB overload.
- [ ] Mobile and Large-Screen read as the same product but not the same layout.

A real Android hardware pass is strongly preferred before owner acceptance of Batch A. If the implementing agent cannot perform it, explicitly report that fact.

---

# Branch / Commit Execution Discipline

This is one **plan** for three milestones, not one giant implementation branch.

Recommended milestone branches:

```text
feat/pc2-m1-design-foundation
feat/pc2-m2-mobile-shell
feat/pc2-m3-large-screen-shell
```

Execution order:

1. Create M1 branch from current `main`, execute Tasks 1–4, pass M1 Gate, merge/rebase as project workflow permits.
2. Create M2 branch from the updated main containing M1, execute Tasks 5–11, pass M2 Gate, merge.
3. Create M3 branch from the updated main containing M2, execute Tasks 12–15, pass Batch A Gate, merge.

Do not start M2 on an unreviewed failing M1 foundation. Do not start M3 while Mobile is broken.

Commits in this plan are intentionally granular. Keep them or split them more finely if a reviewer can independently accept/reject the split. Never collapse all Batch A work into `feat: ui redesign`.

---

# Explicit Deferrals — Do Not Pull These Into Batch A

The following belong to later approved milestones and are **out of scope now**:

- SurfaceRouter / navigation stack (M4).
- Progression Hub redesign (M4/M5).
- Shop/Prestige/Gooberário/Achievements/Missions surface redesigns (M5/M6).
- Perks/Stats/Themes Gallery/Settings/Secret Shop redesigns (M7).
- Theme live preview UI (M7).
- Reduced Motion setting UI and effects-quality setting UI (M7/M8; tokens may exist now, settings do not).
- FloatingReward system, final CLICK juice, Goober hit/death FX, combo escalation tiers (M8).
- PresentationQueue, Boss Moment, Prestige Moment (M8).
- PointerInputAdapter, AutoIncomeManager, SessionCoordinator, EventRuntimeBridge extraction unless a Batch-A blocker proves one necessary (M9).
- Smoke decomposition (M9).
- Final performance tuning, 30-minute soak and RC hardening (M10).

Batch A succeeds by establishing **the presentation foundation and both shell families**, not by sneaking the rest of 2.0 into the first implementation batch.

---

# Required Final Agent Report

Use this exact structure when Batch A work stops:

```text
Changed:
- [files/features actually changed]

Tests run:
- [exact commands]

Results:
- [pass/fail counts and milestone gates]

Not tested:
- [physical Android, tablet hardware, graphical states, or nothing]

Known risks:
- [remaining risks; write "None known" only if genuinely none]
```

If any P0/P1 regression is discovered, do not declare Batch A complete. If an authorial visual choice is uncertain but functionality is correct, preserve the tested architecture, document the uncertainty and leave final visual approval to the product owner rather than inventing a new design direction.