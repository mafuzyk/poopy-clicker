> # SUPERSEDED / NÃO USAR COMO FONTE CANÔNICA
>
> Este documento representa um snapshot antigo da migração.
>
> A fonte canônica atual é:
> `https://github.com/Cherievamp/poopy-clicker`
>
> Use:
> `docs/canonical-migration-spec-v2.md`
> e
> `docs/canonical-source-map-v2.md`
>
> Se este arquivo divergir do repo canônico atual, este arquivo perde.

# Poopy Clicker — Canonical Godot Migration Spec

**Purpose:** handoff/specification for Deep/OpenCode while the game is being rewritten from Python/PyQt6 to Godot 4 + GDScript.

**Canonical legacy source:** `poopy_clicker_ui_achievements_collection_polished.py`  
**Canonical snapshot date:** 2026-04-04 17:18:27 UTC

> This file is newer and more feature-complete than the simplified Python version currently visible in the public GitHub `main`.  
> If the GitHub version and this spec disagree about legacy behavior, prefer this canonical snapshot unless the user explicitly decides otherwise.

---

# 0. NON-NEGOTIABLE WORKFLOW RULES

## 0.1 Before editing anything

Run:

```bash
git status
git branch --show-current
```

If the current branch is `main` or `master`, create a feature branch **before editing any file**:

```bash
git switch -c feat/<short-feature-name>
```

Examples:

```text
feat/goober-core
feat/event-system
feat/achievements
feat/missions
feat/prestige
feat/save-system
refactor/game-state
```

If a branch for the current task already exists, stay on it.

Do **not**:
- edit `main`/`master` directly;
- `reset --hard`;
- `clean -fd`;
- force-push;
- merge;
- push;
- delete user work.

without explicit authorization.

## 0.2 Migration philosophy

Do **not** translate the Python line-by-line.

Preserve:
- game rules;
- balance where intentional;
- Goober identity;
- event behavior;
- progression relationships;
- secret systems;
- achievements/missions/collection goals;
- prestige semantics;
- the moving-button chaos.

Rebuild:
- architecture;
- entity lifecycle;
- signal/event flow;
- save format;
- UI;
- animation pipeline;
- timing;
- input handling;
- performance-sensitive loops.

The target is:

```text
same game identity + cleaner Godot architecture + room to expand
```

---

# 1. TARGET GODOT ARCHITECTURE

Keep the project code-first.

Recommended structure:

```text
poopy-clicker/
├── main.tscn
├── main.gd
├── project.godot
│
├── scripts/
│   ├── core/
│   │   ├── game_state.gd
│   │   ├── game.gd
│   │   └── game_signals.gd
│   │
│   ├── systems/
│   │   ├── economy.gd
│   │   ├── click_system.gd
│   │   ├── combo_system.gd
│   │   ├── event_system.gd
│   │   ├── spawn_system.gd
│   │   ├── achievement_system.gd
│   │   ├── mission_system.gd
│   │   ├── collection_system.gd
│   │   ├── prestige_system.gd
│   │   ├── perk_system.gd
│   │   ├── save_manager.gd
│   │   └── settings_manager.gd
│   │
│   ├── goobers/
│   │   ├── goober.gd
│   │   ├── goober_manager.gd
│   │   ├── goober_catalog.gd
│   │   └── goober_behavior.gd
│   │
│   └── ui/
│       ├── hud.gd
│       ├── shop_ui.gd
│       ├── goober_shop_ui.gd
│       ├── achievements_ui.gd
│       ├── missions_ui.gd
│       ├── collection_ui.gd
│       ├── prestige_ui.gd
│       ├── settings_ui.gd
│       ├── event_banner.gd
│       ├── toast_manager.gd
│       └── number_format.gd
│
├── data/
│   ├── goobers.gd/json/tres
│   ├── events.gd/json/tres
│   ├── achievements.gd/json/tres
│   ├── missions.gd/json/tres
│   └── themes.gd/json/tres
│
└── assets/
    ├── goobers/
    ├── audio/
    ├── fonts/
    └── ui/
```

This is a **direction**, not a demand to create every file immediately.

Apply YAGNI:
- create a module when its responsibility becomes real;
- do not create empty architectural shells.

`main.gd` should remain bootstrap/orchestration, not become another 2,000-line monolith.

---

# 2. CANONICAL GLOBAL CONSTANTS

Canonical latest snapshot:

```gdscript
MAX_GOOBERS = 10
CLICK_SPAWN_THRESHOLD = 15
PASSIVE_SPAWN_INTERVAL = 12.0
SECRET_SHOP_UNLOCK_CLICKS = 40
BOSS_SPAWN_CHANCE = 0.05

EVENT_CHECK_INTERVAL = 9.0
EVENT_TRIGGER_CHANCE = 0.22
AUTO_SAVE_INTERVAL = 60.0

COSMETIC_COLOR_CHANCE = 0.14
```

Legacy rarity levels:

```text
common
rare
epic
legendary
mythic
```

Canonical rarity multipliers:

```text
common      1.00
rare        1.25
epic        1.60
legendary   2.10
mythic      3.00
```

Canonical random-event rarity weights:

```text
common      1.80
rare        1.15
epic        0.75
legendary   0.35
```

---

# 3. GAME STATE

Mutable game state must not be scattered through UI nodes.

Conceptual model:

```gdscript
class GameState:
    var money: int = 0
    var lifetime_money: int = 0

    var click_level: int = 0
    var auto_level: int = 0

    var goober_click_progress: int = 0
    var goober_coins: int = 0
    var secret_shop_unlocked: bool = false

    var poopy_essence: int = 0
    var prestige_level: int = 0

    var purchased_goober_upgrades: Dictionary = {}
    var owned_ui_themes: Array[String] = ["default"]
    var selected_ui_theme: String = "default"

    var stats: Dictionary = {}
    var bestiary_counts: Dictionary = {}
    var mission_state: Dictionary = {}
    var perks: Dictionary = {}
    var settings: Dictionary = {}
```

Prefer explicit methods/signals over arbitrary writes from every system.

Example:

```gdscript
signal money_changed(new_value)
signal goober_coins_changed(new_value)
signal prestige_changed(new_level)
signal secret_shop_unlocked
```

---

# 4. CORE ECONOMY

## 4.1 Click value

Legacy latest:

```text
base click = 2 ^ click_level
final click = base click × prestige click multiplier
minimum = 1
```

Pseudo:

```gdscript
func get_click_value() -> int:
    var base := 2 ** state.click_level
    return max(1, int(base * prestige.get_click_multiplier()))
```

## 4.2 Auto value

```text
if auto_level == 0:
    base_auto = 0
else:
    base_auto = 2 ^ (auto_level - 1)

if Sneaky Profit:
    base_auto *= 1.25

final auto = base_auto × prestige auto multiplier
```

Pseudo:

```gdscript
func get_auto_value() -> int:
    var base := 0

    if state.auto_level > 0:
        base = 2 ** (state.auto_level - 1)

    if upgrades.has("sneaky_profit"):
        base = int(base * 1.25)

    return max(0, int(base * prestige.get_auto_multiplier()))
```

## 4.3 Costs

```text
click upgrade cost = 200 × 2 ^ click_level
auto upgrade cost  = 500 × 2 ^ auto_level
```

Pseudo:

```gdscript
func click_upgrade_cost() -> int:
    return 200 * (2 ** state.click_level)

func auto_upgrade_cost() -> int:
    return 500 * (2 ** state.auto_level)
```

## 4.4 Purchase flow

```gdscript
func buy_click_upgrade():
    var cost := click_upgrade_cost()

    if state.money < cost:
        return false

    state.money -= cost
    state.click_level += 1

    signals.upgrade_purchased.emit("click", state.click_level)
    return true
```

Same pattern for auto.

---

# 5. COMBO SYSTEM

The canonical game has a click combo.

Conceptually:

```text
manual clicks build combo
combo raises a multiplier
combo has a decay timeout
some events extend combo grace
highest combo is recorded in stats
```

Pseudo:

```gdscript
func register_manual_click():
    combo_count += 1

    # Preserve exact canonical growth curve when porting.
    combo_multiplier = calculate_combo_multiplier(combo_count)

    stats.highest_combo = max(stats.highest_combo, combo_count)

    var grace_ms := BASE_COMBO_GRACE_MS

    if event_system.active_event_has("combo_grace"):
        grace_ms += event_system.get("combo_grace")

    decay_timer.start(grace_ms / 1000.0)
```

On decay:

```gdscript
func reset_combo():
    combo_count = 0
    combo_multiplier = 1.0
```

Manual click payout:

```gdscript
gain =
    click_value
    * combo_multiplier
    * active_event_click_multiplier

state.money += gain
state.lifetime_money += gain
stats.total_clicks += 1
stats.money_earned += gain
```

---

# 6. CLICK BUTTON / JIGGLE SYSTEM

The moving button is historical identity and must remain.

Latest canonical difficulty:

```text
difficulty = min(24 + ((click_level + auto_level) × 2), 85)
```

Button also slowly shrinks with progression:

```text
base_scale = max(0.82, 1.0 - total_upgrade_levels × 0.004)
final_scale = base_scale × current event size multiplier
```

Minimum button size:

```text
82 × 34
```

Pseudo:

```gdscript
func move_button_after_click():
    var active := events.current_effects()
    var step := int(get_difficulty_step() * events.button_move_multiplier())

    if settings.low_power_mode:
        step = max(3, int(step * 0.8))

    var drift_x := randi_range(-step, step)
    var drift_y := randi_range(-step / 2, step / 2)

    if active.gravity:
        drift_y += 16

    if randf() < 0.18:
        drift_x += random_sign() * (step / 2)

    if active.invert_move:
        drift_x = int(-drift_x * 0.85)
        drift_y = int(-drift_y * 0.85)

    move_button_clamped(drift_x, drift_y)
```

Always clamp to play area with a margin.

Do not hardcode desktop-only dimensions.

---

# 7. GOOBER SYSTEM — CORE IDENTITY

Goobers are **living chaotic game entities**, not just collectible cards.

Canonical behavior states:

```text
walk
idle
scare
panic
```

State machine:

```text
SPAWN
  ↓
WALK
  ├── random chance → IDLE → WALK
  └── player click → SCARE → PANIC → exits area/despawns
```

Goobers:
- move continuously;
- bounce on play-area edges while not panicking;
- face movement direction;
- may enter idle;
- collide with the click button;
- push the button;
- become scared when clicked;
- jump;
- enter panic;
- run rapidly off-screen;
- award progression/rewards;
- may trigger events;
- are tracked in the Gooberário.

In Godot, prefer:

```text
Goober
├── AnimatedSprite2D
├── Area2D / collision
└── one behavior state machine
```

Avoid one dedicated high-frequency Timer per Goober if `_process(delta)` / `_physics_process(delta)` + manager scheduling is simpler.

---

# 8. GOOBER SPAWN LOGIC

Two basic spawn paths:

```text
passive spawn every 12 seconds
manual-click spawn every 15 click-button clicks
```

Visible limit:

```text
base MAX_GOOBERS = 10
```

Event/perk bonuses may increase this.

Boss logic:

```text
base boss chance = 5%
boss cannot spawn if one is already active
player must have earned > $10,000 lifetime/run stats threshold
boss chance can be increased by:
- boss_hunter perk
- prestige >= 10
- Boss Beacon
- active event boss bonus
maximum final boss chance = 20%
```

Rare luck:

```text
luck =
    goober_luck perk × 0.0015
    + collection luck bonus
    + prestige bonuses
    + active event rare bonus
```

Each Goober's spawn weight is adjusted by rarity:

```text
common      factor 1.0
rare        factor 1.2
epic        factor 1.4
legendary   factor 1.8
mythic      factor 2.2
```

Pseudo:

```gdscript
func choose_goober_type() -> String:
    if can_roll_boss():
        return "boss"

    var luck := calculate_luck_bonus()

    var adjusted_weights := {}

    for id in GOOBER_SPAWN_WEIGHTS:
        var rarity := catalog[id].rarity
        var rarity_factor := RARITY_LUCK_FACTOR[rarity]

        adjusted_weights[id] = (
            GOOBER_SPAWN_WEIGHTS[id]
            * (1.0 + luck * 18.0 * rarity_factor)
        )

    return weighted_roll_or_normal(adjusted_weights)
```

---

# 9. CANONICAL GOOBER CATALOG

There are **38 canonical Goober types** in the latest snapshot.

## 9.1 Base / historical types

| ID | Rarity | HP | Money | GC | Secret progress | Speed | Size | Push normal/panic | Special |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---|
| normal | common | 1 | 0 | 1 | 1 | 1–2 | 1.00 | 6 / 28 | 14% cosmetic tint chance |
| gold | rare | 1 | 5000 | 5 | 4 | 1–2 | 1.12 | 7 / 30 | high reward |
| angry | epic | 1 | 1500 | 2 | 2 | 2–3 | 1.00 | 10 / 34 | aggressive push |
| tiny | epic | 1 | 1200 | 2 | 2 | 3–4 | 0.74 | 4 / 22 | tiny + fast |
| giant | epic | 1 | 7000 | 6 | 5 | 1 | 1.42 | 9 / 32 | huge/high reward |
| frozen | rare | 1 | 2500 | 3 | 3 | 1–2 | 1.05 | 5 / 24 | triggers Frozen Blessing |
| bomb | rare | 1 | 3000 | 3 | 3 | 2 | 1.08 | 8 / 38 | triggers Bomb Chaos |
| rgb | mythic | 5 | 25000 | 15 | 10 | 2–3 | 1.45 | 8 / 36 | multi-hit/jackpot/RGB visuals |
| boss | legendary | 18 + prestige bonus | 60000 | 18 | 20 | 1–2 | 1.95 | 13 / 45 | boss bar, essence reward |

Boss and some legendary/mythic Goobers can give **Poopy Essence**.

## 9.2 Extended canonical types

| ID | Rarity | Money | GC | Progress | Speed | Size | Push N/P | Effect |
|---|---|---:|---:|---:|---|---:|---|---|
| slime | common | 220 | 1 | 1 | 1–2 | .95 | 5/20 | — |
| shadow | rare | 1500 | 2 | 2 | 2–3 | 1.00 | 9/32 | — |
| candy | common | 480 | 1 | 1 | 1–2 | 1.00 | 6/24 | — |
| crystal | rare | 2400 | 3 | 2 | 1–2 | 1.10 | 6/26 | — |
| storm | epic | 3600 | 3 | 3 | 2–3 | 1.05 | 10/35 | `storm_mode` |
| glitch | epic | 4200 | 4 | 3 | 2–3 | 1.05 | 8/30 | `glitch_flip` |
| toxic | rare | 2100 | 2 | 2 | 1–2 | 1.02 | 7/27 | `sticky` |
| magnet | rare | 2600 | 3 | 2 | 1–2 | 1.02 | 5/24 | `center_pull` |
| sleepy | common | 260 | 1 | 1 | 1 | 1.08 | 3/15 | `calm` |
| speedy | common | 340 | 1 | 1 | 3–4 | .88 | 7/26 | — |
| royal | legendary | 8000 | 7 | 5 | 1–2 | 1.18 | 7/28 | +1 essence |
| plasma | epic | 5200 | 5 | 4 | 2–3 | 1.10 | 9/32 | `hyper_button` |
| stone | common | 650 | 1 | 1 | 1 | 1.18 | 4/16 | — |
| ghost | rare | 3000 | 3 | 2 | 1–3 | .98 | 6/22 | `blink` |
| lava | epic | 6000 | 5 | 4 | 2 | 1.15 | 9/34 | `heatwave` |
| clockwork | rare | 2800 | 3 | 2 | 1–2 | 1.00 | 5/22 | `time_dilation` |
| neon | rare | 2500 | 2 | 2 | 2–3 | 1.00 | 7/28 | — |
| pirate | rare | 3600 | 4 | 3 | 1–2 | 1.08 | 8/30 | `treasure_tide` |
| angel | legendary | 7000 | 5 | 4 | 1–2 | 1.12 | 5/18 | +1 essence, `blessing` |
| devil | legendary | 7600 | 6 | 4 | 2–3 | 1.12 | 10/36 | `hellrush` |
| moss | common | 300 | 1 | 1 | 1 | 1.00 | 4/18 | — |
| prism | mythic | 12000 | 8 | 5 | 2–3 | 1.22 | 9/30 | 3 HP, +1 essence |
| voidling | legendary | 9200 | 6 | 4 | 2–3 | 1.12 | 9/32 | `void_window` |
| chef | common | 420 | 1 | 1 | 1–2 | 1.00 | 5/18 | `snack_break` |
| samurai | epic | 4700 | 4 | 3 | 2–3 | 1.05 | 8/30 | — |
| arcade | rare | 2600 | 3 | 2 | 2–3 | .96 | 7/24 | `jackpot_mode` |
| bubble | common | 380 | 1 | 1 | 1–2 | .92 | 4/16 | — |
| crown | legendary | 9800 | 7 | 5 | 1–2 | 1.18 | 7/26 | +1 essence |
| fairy | epic | 3600 | 3 | 3 | 2–4 | .82 | 5/18 | `lucky_wave` |

Canonical base spawn weights for extended/special types:

```text
rgb        .0085
gold       .0100
angry      .0160
tiny       .0200
giant      .0080
frozen     .0100
bomb       .0100
slime      .0240
shadow     .0120
candy      .0220
crystal    .0110
storm      .0085
glitch     .0075
toxic      .0115
magnet     .0105
sleepy     .0180
speedy     .0170
royal      .0055
plasma     .0070
stone      .0180
ghost      .0100
lava       .0075
clockwork  .0100
neon       .0120
pirate     .0090
angel      .0045
devil      .0045
moss       .0200
prism      .0038
voidling   .0048
chef       .0190
samurai    .0078
arcade     .0100
bubble     .0200
crown      .0040
fairy      .0080
```

`normal` is the fallback after weighted rolls.

---

# 10. GOOBER CLICK / REWARD FLOW

Pseudo:

```gdscript
func on_goober_clicked(goober):
    if goober.state in [SCARE, PANIC]:
        return

    goober.hp -= 1
    goober.jump()

    if goober.hp > 0:
        show_hit_progress(goober)
        return

    stats.register_goober_defeat(goober.type)
    collection.register_clicked(goober.type)

    give_goober_rewards(goober)

    if goober.event_on_click != "":
        events.start(goober.event_on_click)

    achievements.evaluate()
    missions.update_progress()
    collection.evaluate_rewards()

    goober.enter_scare()
```

Then:

```text
SCARE for ~260 ms
→ PANIC
→ high velocity
→ leaves play area
→ hidden/despawned
```

## 10.1 Reward flow

Special Goober payout:

```text
money payout =
    goober money reward
    × rarity money multiplier
    × active event specialist-money multiplier
    × collection/prestige modifiers if applicable
```

Before secret shop unlock:

```text
goober click progress += type.click_progress_reward

if progress >= 40:
    unlock Goober Shop
```

After unlock:

```text
goober coins +=
    base coin reward
    + prestige coin bonus
    + active event special coin bonus
```

Lucky Paws:

```text
if Lucky Paws and goober != normal:
    +1 GC
```

Essence rewards:
- boss;
- royal;
- angel;
- prism;
- crown;
- other canonical essence-enabled sources.

---

# 11. GOOBER PUSH PHYSICS

Normal and panic push strengths come from each Goober type.

Heavy Button:

```text
normal push -= 3
minimum normal push = 2
```

Panic Shield:

```text
panic push -= 10
minimum panic push = 12
```

Event interactions:

```text
invert_move:
    push multiplier *= -0.75

gravity:
    push_y += 18
```

Pseudo:

```gdscript
func push_button(goober):
    if not intersects_button(goober):
        return

    var push := goober.panic_push if goober.state == PANIC else goober.normal_push

    push = upgrades.modify_push(goober.state, push)
    push = events.modify_push(push)

    click_button.position += goober.velocity * push
    clamp_button()
```

---

# 12. SECRET GOOBER SHOP

Unlock at:

```text
40 secret Goober click progress
```

Canonical purchases include:

| Upgrade | Cost | Behavior |
|---|---:|---|
| Goober Charm | 8 GC | Goobers idle/stop less |
| Heavy Button | 12 GC | Reduced normal Goober push |
| Lucky Paws | 15 GC | Extra Goober Coin on special Goobers |
| Sneaky Profit | 20 GC | +25% auto-click |
| Panic Shield | 18 GC | Reduced panic push |
| Boss Beacon | 22 GC | Increases boss chance |
| Essence Magnet | 24 GC | Improves Essence-related gain/chance per canonical logic |
| Mission Radar | 16 GC | Better mission rewards |

Purchases are one-time and persisted.

Architecture:

```gdscript
UPGRADES = {
    "goober_charm": {...},
    "heavy_button": {...},
    ...
}
```

Do not create one hard-coded buy function per item if a clean data-driven purchase path works.

---

# 13. EVENT SYSTEM

The canonical game has:
- random timed events;
- Goober-triggered events;
- event rarities;
- one active event at a time;
- event banner/progress;
- event effects consumed by economy/button/spawn/combo systems.

Random event check:

```text
every 9 seconds
if no active event:
    22% chance to roll an event
```

Event roll uses rarity weights.

Prestige affects event weighting:
- prestige >= 3 slightly improves rare/epic weights;
- some endgame events are strongly suppressed before prestige 2.

Pseudo:

```gdscript
func try_random_event():
    if active_event != null:
        return

    if randf() > 0.22:
        return

    var weighted_pool := build_event_weight_pool()
    var id := weighted_choice(weighted_pool)

    start_event(id)
```

Core event state:

```gdscript
class ActiveEvent:
    var id: String
    var started_at: float
    var duration: float
    var remaining: float
    var effects: Dictionary
```

Systems should query effects, not switch on every event ID where avoidable:

```gdscript
event_system.get_float("click_mult", 1.0)
event_system.get_float("auto_mult", 1.0)
event_system.get_float("move_mult", 1.0)
event_system.get_bool("gravity")
event_system.get_bool("invert_move")
```

## 13.1 Canonical event/effect vocabulary

Known canonical events include:

```text
double_click
double_auto
big_button
tiny_button
chaos
calm
invert_colors
invert_move
gravity
sticky
frenzy
mouse_flee
blink

storm_mode
glitch_flip
center_pull
hyper_button
heatwave
time_dilation
treasure_tide
blessing
hellrush
void_window
snack_break
jackpot_mode
lucky_wave

frozen_blessing
bomb_chaos

essence_bloom
boss_hour
mirror_world
safe_zone
orbital
overclock
party_mode
```

Important known semantics:

```text
double_click      → click ×2
double_auto       → auto ×2
big_button        → size ×1.22
tiny_button       → size ×0.78
chaos             → movement ×1.35
calm              → movement ×0.65
sticky            → movement ×0.35
gravity           → downward drift
invert_move       → reversed movement
invert_colors     → temporary alternate UI appearance
frenzy            → +4 Goober capacity/spawn pressure
mouse_flee        → button runs from pointer
blink             → short button teleports when pointer gets close

storm_mode        → movement ×1.25 + gravity
glitch_flip       → invert movement + blink
center_pull       → button drifts toward center
hyper_button      → size ×1.18 + movement ×1.12
heatwave          → movement ×1.45 + mouse flee
time_dilation     → movement ×0.75 + auto ×1.25
treasure_tide     → increased specialist rewards
blessing          → more click/auto, less chaos
hellrush          → more click + more chaos
void_window       → increased rare-Goober chance
snack_break       → slower combo decay
jackpot_mode      → specialist Goober coin/reward boost
lucky_wave        → increased rare luck
orbital           → button orbits the play-area center
overclock         → stronger auto + increased spawning
party_mode        → more rare Goobers/coins/visual celebration
safe_zone         → reduced Goober pressure
mirror_world      → visual/movement inversion mix
boss_hour         → higher boss presence
essence_bloom     → increased Essence opportunity
```

When implementing, copy the **exact values** from the canonical legacy `EVENT_INFO` table when available.

---

# 14. POINTER-INTERACTION EVENTS

Some events continuously alter button behavior.

Center pull:

```gdscript
button.position += (play_area_center - button.position) * 0.08
```

Orbital:

```gdscript
orbit_angle += 0.12
radius = 42

button.x = center.x + cos(orbit_angle) * radius
button.y = center.y + sin(orbit_angle) * radius
```

Blink:
- when pointer is within ~180 px;
- random ~14% chance per relevant update;
- jump up to ~55 px.

Mouse flee:
- relevant within ~170 px;
- move away in ~18 px steps.

On touch devices, adapt pointer-based behavior sensibly:
- use last touch position while actively touching;
- do not make gameplay impossible when there is no hover concept.

---

# 15. BOSS GOOBER

Boss is not just another skin.

Canonical:
- separate `boss_active` flag;
- only one boss at a time;
- HP bar;
- base HP = `18 + prestige_bonus_hits()`;
- 60,000 money;
- 18 GC;
- 1 Essence;
- 20 secret progress;
- 1.95 size;
- push 13/45;
- tracked separately in stats/achievements;
- boss defeat clears active state.

Pseudo:

```gdscript
func spawn_boss():
    if boss_active:
        return

    boss_active = true

    var boss := goober_factory.create("boss")
    boss.defeated.connect(on_boss_defeated)

    hud.show_boss_bar(boss.hp, boss.max_hp)
```

On hit:

```gdscript
hud.update_boss_bar(boss.hp)
```

On defeat:

```gdscript
boss_active = false
stats.boss_defeated += 1
hud.hide_boss_bar()
```

---

# 16. GOOBERÁRIO / COLLECTION

The game tracks at minimum:
- which Goober types have been seen;
- which have been clicked/defeated;
- counts;
- rarity;
- descriptions;
- collection milestones.

There are 38 types in the latest canonical catalog.

Collection produces gameplay bonuses, not only completion percentage.

Canonical luck-bonus milestones add:

```text
special seen complete      +0.002
special clicked complete   +0.003
boss master complete       +0.004
field guide complete       +0.002
hands on complete          +0.003
endgame complete           +0.005
```

Pseudo:

```gdscript
func collection_luck_bonus() -> float:
    var value := 0.0

    if special_seen_complete():
        value += 0.002

    if special_clicked_complete():
        value += 0.003

    if boss_master_complete():
        value += 0.004

    if field_guide_complete():
        value += 0.002

    if hands_on_complete():
        value += 0.003

    if endgame_complete():
        value += 0.005

    return value
```

Collection also has a money bonus. Preserve the canonical milestone logic from the legacy source.

The UI should show:
- discovered state;
- clicked/defeated state;
- count;
- rarity;
- description;
- reward/effect;
- collection summary;
- current collection bonuses.

---

# 17. ACHIEVEMENTS

Achievements:
- have stable IDs;
- are evaluated from state/stats;
- unlock only once;
- persist;
- show a non-blocking toast;
- are viewable in an achievements screen.

Known canonical achievements include:

```text
first_click
  Primeiro passo
  1 click

hundred_clicks
  Clicadora nata
  100 clicks

money_10k
  Dinheiruda
  $10K earned total

money_1m
  Economia paralela
  $1M earned total

normal_25
  Amiga dos goobers
  25 normal Goobers clicked

gold_3
  Caça-ouro
  3 Gold clicked

rgb_1
  Lenda RGB
  defeat 1 RGB

boss_1
  Boss hunter
  defeat 1 boss

boss_5
  Predadora de chefes
  defeat 5 bosses

combo_25
  Flow state
  reach combo 25

combo_75
  Mão impossível
  reach combo 75

missions_10
  Trabalhadora do mês
  complete 10 missions

missions_30
  Painel limpo
  complete 30 missions

collector_20
  Arquivo vivo
  see 20 Goober types

hands_on_15
  Mão certeira
  click/defeat 15 different Goober types

prestige_1
  Essência poopy
  prestige once

prestige_5
  Recomeço afiado
  prestige level 5

goober_40
  Segredo revelado
  unlock Goober Shop
```

The canonical file contains additional endgame/Essence/collection achievements. Preserve every definition from the source when porting.

Recommended data form:

```gdscript
ACHIEVEMENTS = {
    "first_click": {
        "name": "Primeiro passo",
        "description": "...",
        "stat": "total_clicks",
        "threshold": 1
    },
    ...
}
```

For complex achievements use a checker function or criterion object.

---

# 18. MISSION SYSTEM

Missions are repeatable/generated progression objectives.

Canonical mission progress categories:

```text
clicks
money
goobers
rare_seen
boss
```

Examples of canonical templates:

```text
Dedinho turbo
- many clicks
- target scales with prestige

Colecionadora
- click special Goobers
- target scales with prestige

Fortuna poopy
- earn money
- target scales with prestige

Visão de raio-x
- see rare Goobers
- target scales with prestige

Linha de frente
- defeat 2 bosses

Ritmo perfeito
- high click target

Mercado goober
- advanced money target
```

Canonical mission reward type is mixed:

```text
money + Goober Coins
```

Mission Radar:
- boosts money reward ~20%;
- adds +1 GC to mission reward.

Pseudo:

```gdscript
func generate_mission():
    var template := weighted_or_random_template()

    var mission = {
        "key": template.key,
        "title": template.title,
        "description": template.description,
        "target": scaled_target(template),
        "start_value": current_progress_value(template.key),
        "progress": 0,
        "reward_money": calculate_money_reward(template),
        "reward_coins": calculate_coin_reward(template),
        "claimed": false,
    }

    return mission
```

Progress:

```gdscript
progress =
    current_stat_value(key)
    - mission.start_value
```

Claim:
- only once;
- grants both rewards;
- increments completed mission count;
- generates/replaces slot according to canonical mission-slot behavior;
- autosaves.

---

# 19. PRESTIGE + POOPY ESSENCE

Prestige is a canonical subsystem, not a speculative new feature.

Persistent meta-state:
- `prestige_level`;
- `poopy_essence`;
- perk levels;
- lifetime stats/collection/progression that the canonical reset rules retain.

Prestige modifies:
- click multiplier;
- auto multiplier;
- Goober coin gain;
- boss behavior/chance;
- rare luck at milestones;
- event weighting;
- boss HP scaling;
- mission scaling.

The Godot port should isolate reset rules explicitly:

```gdscript
class PrestigeResetPolicy:
    var reset_fields := [...]
    var preserved_fields := [...]
```

Pseudo:

```gdscript
func can_prestige() -> bool:
    return meets_canonical_prestige_requirement()

func perform_prestige():
    if not can_prestige():
        return false

    var essence_gain := calculate_canonical_essence_gain()

    state.poopy_essence += essence_gain
    state.prestige_level += 1

    reset_run_state()
    preserve_meta_state()

    signals.prestiged.emit(state.prestige_level, essence_gain)
    save_manager.save()

    return true
```

**Important:** use the exact requirement/reward formulas from the canonical Python source when implementing this subsystem. Do not substitute generic Cookie Clicker formulas.

---

# 20. PERK SYSTEM

Perks are purchased with Poopy Essence and survive normal run resets.

Known canonical perk interactions include at least:

```text
goober_luck
boss_hunter
```

There are additional canonical permanent perks affecting click, auto, event duration/behavior, progression, etc.

Architecture:

```gdscript
PERKS = {
    "goober_luck": {
        "max_level": ...,
        "base_cost": ...,
        "effect_per_level": ...
    },
    ...
}
```

Pseudo:

```gdscript
func perk_value(id: String) -> int:
    return state.perks.get(id, 0)

func buy_perk(id: String) -> bool:
    var level := perk_value(id)

    if level >= catalog[id].max_level:
        return false

    var cost := cost_for(id, level)

    if state.poopy_essence < cost:
        return false

    state.poopy_essence -= cost
    state.perks[id] = level + 1

    save_manager.save()
    return true
```

Never bake perk effects directly into UI code.

---

# 21. UI THEMES

Canonical themes:

```text
default
gold
ice
void
candy
matrix
sunset
```

Themes are purchased using Goober Coins and persist.

Godot implementation should use `Theme`/StyleBox resources or a centralized theme mapper rather than individually restyling every control.

Pseudo:

```gdscript
func apply_theme(id):
    var theme_data := THEMES[id]

    hud.apply_palette(theme_data)
    dialogs.apply_palette(theme_data)
    event_banner.apply_palette(theme_data)
```

Theme purchase:

```gdscript
if id not in owned_themes and goober_coins >= cost:
    goober_coins -= cost
    owned_themes.append(id)
```

---

# 22. SETTINGS / ACCESSIBILITY / PERFORMANCE

The latest canonical build includes persisted settings and a low-power concept.

Godot settings manager should support at minimum every canonical setting discovered in the source, including animation/performance toggles.

Important mobile considerations:
- touch targets must remain usable;
- pointer-only events need touch equivalents;
- low-power mode can reduce visual update intensity;
- animations can be reduced/disabled without breaking state transitions;
- gameplay must not depend solely on hover.

Do not conflate:
- low-power mode;
- reduced animation;
- gameplay difficulty.

They are separate concerns.

---

# 23. SAVE SYSTEM

Canonical legacy save contains:

```json
{
  "count": "...",
  "upgrade_level": "...",
  "auto_level": "...",
  "goober_clicks_total": "...",
  "goober_coins": "...",
  "poopy_essence": "...",
  "prestige_level": "...",
  "lifetime_money": "...",

  "secret_shop_unlocked": "...",

  "goober_charm_bought": "...",
  "heavy_button_bought": "...",
  "lucky_paws_bought": "...",
  "sneaky_profit_bought": "...",
  "panic_shield_bought": "...",
  "boss_beacon_bought": "...",
  "essence_magnet_bought": "...",
  "mission_radar_bought": "...",

  "selected_ui_theme": "...",
  "owned_ui_themes": "...",

  "stats": "...",
  "combo_count": "...",
  "combo_multiplier": "...",
  "bestiary_counts": "...",
  "mission_state": "...",
  "perks": "...",
  "settings": "...",

  "last_saved_at": "..."
}
```

Godot must save under:

```text
user://
```

Recommended new format:

```json
{
  "save_version": 1,
  "game": {},
  "progression": {},
  "collection": {},
  "meta": {},
  "settings": {},
  "timestamps": {}
}
```

Do not require exact legacy JSON shape internally.

Do provide a migration/import layer if importing Python saves is desired.

Autosave:
- every 60 seconds;
- after important purchases/unlocks;
- on clean exit where possible.

---

# 24. OFFLINE EARNINGS

The canonical game stores `last_saved_at` and grants auto-click earnings for time away.

Pseudo:

```gdscript
func calculate_offline_gain(last_saved_at: int) -> Dictionary:
    var elapsed := current_unix_time - last_saved_at

    if elapsed <= 0:
        return {"seconds": 0, "money": 0}

    var effective_seconds := clamp_offline_duration_if_canonical_requires_it(elapsed)

    var gain := int(
        economy.get_auto_value()
        * prestige/offline modifiers
        * effective_seconds
    )

    return {
        "seconds": effective_seconds,
        "money": gain
    }
```

On load:
- calculate;
- add to money/lifetime stats according to canonical rules;
- show a non-blocking offline earnings dialog/card.

---

# 25. STATS

Stats feed:
- achievements;
- missions;
- Gooberário;
- prestige/meta UI.

Known canonical counters include:

```text
total_clicks
money_earned
goobers_clicked

normal_clicked
gold_clicked
angry_clicked
tiny_clicked
giant_clicked
frozen_clicked
bomb_clicked

rgb_defeated

boss_clicked
boss_defeated

rare_seen
highest_combo

achievements_unlocked
```

Do not infer every Goober variant needs a dedicated top-level stat field.

For the expanded 38-Goober catalog, prefer a generic map:

```gdscript
stats.goober_seen[type] += 1
stats.goober_clicked[type] += 1
```

while maintaining compatibility aliases if needed for achievements.

---

# 26. UI / GAME FEEL

The PyQt UI is **not** the design target.

Godot should preserve information hierarchy while becoming game-like.

Required surfaces:

```text
HUD
- money
- auto / second
- combo
- Goober Coins
- Poopy Essence
- prestige level
- mission summary
- event banner
- boss HP

menus / panels
- main shop
- Goober Shop
- Gooberário / collection
- achievements
- missions
- prestige
- perks
- settings
- stats
- themes
```

Game feel:
- floating money numbers;
- reward text over Goobers;
- click feedback;
- short button squash/pulse;
- Goober scare jump;
- event banner progress;
- achievement toast;
- boss announcement;
- optional particles;
- optional sound.

Do not implement huge visual redesigns during mechanical migration unless specifically requested.

---

# 27. SIGNAL / EVENT FLOW RECOMMENDATION

Use a small central signal hub or direct bounded signals.

Example:

```text
ClickSystem
  manual_click
      ↓
Economy → money_changed
ComboSystem → combo_changed
AchievementSystem → maybe achievement_unlocked
MissionSystem → progress_changed
SpawnSystem → maybe spawn Goober
ButtonController → jiggle

Goober
  defeated
      ↓
GooberManager
      ↓
Economy rewards
CollectionSystem
AchievementSystem
MissionSystem
EventSystem (if event_on_click)
SaveManager dirty
```

Avoid:
- every system knowing every UI node;
- circular references;
- `main.gd` manually forwarding everything.

UI subscribes to state/signals.

---

# 28. RECOMMENDED MIGRATION ORDER

Do not port all systems in one giant branch.

## Stage A — Canonical baseline

1. `GameState`
2. economy
3. manual click
4. auto click
5. button movement
6. combo
7. basic shop

## Stage B — Goober foundation

8. Goober entity/state machine
9. animation pipeline
10. normal Goober
11. push interaction
12. secret unlock
13. Goober Coins
14. Goober Shop

## Stage C — Canonical Goober catalog

15. historical special Goobers
16. data-driven catalog
17. remaining 29 extended Goobers
18. weighted spawn/luck
19. boss

## Stage D — Chaos systems

20. event system
21. random event rolling
22. Goober-triggered events
23. pointer/touch special events
24. event banner

## Stage E — Progression/collection

25. stats
26. Gooberário
27. collection rewards
28. achievements
29. missions

## Stage F — Meta progression

30. Prestige
31. Poopy Essence
32. perks
33. late-game event/prestige interactions

## Stage G — Persistence/product polish

34. versioned save
35. autosave
36. offline earnings
37. themes
38. settings
39. performance mode
40. UI/game-feel pass

Each stage should end in:
- clean parser;
- runtime smoke test on Godot Android;
- no regressions to previously ported systems;
- commit on feature branch;
- short handoff.

---

# 29. TEST MATRIX

## Core

```text
[ ] starts at $0
[ ] click increases correct amount
[ ] auto works at level >= 1
[ ] click cost doubles correctly
[ ] auto cost doubles correctly
[ ] button stays inside play area
[ ] button difficulty scales
[ ] combo builds
[ ] combo decays
```

## Goobers

```text
[ ] passive spawn
[ ] click-based spawn
[ ] max population
[ ] walk
[ ] idle
[ ] scare
[ ] panic
[ ] facing
[ ] button push
[ ] push upgrades
[ ] reward
[ ] secret unlock
[ ] GC payout
[ ] every catalog type can spawn
[ ] multi-hit types work
[ ] event-on-click types work
```

## Events

```text
[ ] no two random events overlap unless explicitly designed
[ ] duration expires
[ ] UI progress works
[ ] effects are removed cleanly
[ ] button size resets
[ ] movement resets
[ ] economy multiplier resets
[ ] spawn bonus resets
[ ] touch adaptation works
```

## Boss

```text
[ ] only one boss
[ ] HP bar visible
[ ] multi-hit
[ ] correct rewards
[ ] defeat clears boss_active
[ ] next boss can eventually spawn
```

## Persistence

```text
[ ] save/load roundtrip
[ ] settings persist
[ ] collection persists
[ ] achievements persist
[ ] missions persist
[ ] perks persist
[ ] prestige persists
[ ] offline income is sane
[ ] corrupted/missing keys fall back safely
```

---

# 30. DEEP/OPENCODE EXECUTION CONTRACT

When given this spec:

1. Inspect current repository state first.
2. Do not assume the branch or architecture from this document is already present.
3. Run `git status`.
4. Create/switch to the appropriate feature branch before editing.
5. Compare current Godot implementation with this canonical spec.
6. Implement only the requested migration slice.
7. Preserve already-working Godot code unless there is a concrete reason to refactor it.
8. Keep systems modular.
9. Prefer GDScript.
10. Do not introduce C++/Rust/GDExtension without a proven need.
11. Do not fake runtime verification if Godot CLI is unavailable.
12. If Godot CLI cannot run in Termux, say:
   - static validation completed;
   - runtime must be tested in Godot Android.
13. Never merge or push without permission.

At completion report:

```text
Branch:
Commits:
Files created:
Files changed:
Canonical systems ported:
Behavioral differences:
Static checks:
Godot runtime test required:
Known follow-ups:
```

---

# 31. CANONICALITY RULE

When unsure whether a feature is "new" or "legacy":

1. Check this spec.
2. Check `poopy_clicker_ui_achievements_collection_polished.py`.
3. Prefer the latest canonical implementation.
4. Only use older Python snapshots to clarify history.
5. Do not resurrect an older removed feature unless explicitly approved.
6. Do not invent a replacement for an existing canonical subsystem before understanding it.

The current goal is:

```text
PHASE 1:
recover the complete latest Poopy Clicker feature set in a clean Godot architecture

THEN:
design genuinely new content on top
```

---

# 32. FINAL PRINCIPLE

Poopy Clicker is not merely:

```text
click → number increases
```

Its identity is:

```text
click
→ button runs away
→ Goobers invade the play area
→ Goobers push the button
→ player harasses Goobers
→ Goobers panic
→ weird Goobers trigger events
→ secret currency appears
→ collections / missions / achievements feed progression
→ bosses and prestige extend the loop
→ chaos remains readable and funny
```

Port **that loop**, not PyQt.
