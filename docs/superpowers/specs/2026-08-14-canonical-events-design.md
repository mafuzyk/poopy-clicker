# Canonical Events — Design

Date: 2026-08-14
Branch: `feat/canonical-events`
Base: `4b5d67585a916f5befb68a70428a598fdbb50440`
Canonical source: `Cherievamp/poopy-clicker@1e3f4fb1f5e3744720e72d0cb8b97e9bf00feb33`

## Goal

Complete the 28 event behaviours still deferred after Event Core, while preserving the Event Core architecture: `EventManager` owns selection/lifecycle/data access, consumers receive capabilities/modifiers, and `main.gd` must not become a chain of event-ID conditionals.

The final state of this slice is: all 35 canonical events can enter the natural random pool, all event modifiers that have a currently existing Godot subsystem are functional, runtime side effects clean up on replacement/end, and tests cover deterministic behaviour plus temporal effects.

## Scope

Already complete and unchanged except for shared plumbing:

- `double_click`
- `double_auto`
- `big_button`
- `tiny_button`
- `chaos`
- `calm`
- `snack_break`

Implement in this slice:

- movement/visual: `invert_colors`, `invert_move`, `gravity`, `sticky`, `mouse_flee`, `blink`, `storm_mode`, `glitch_flip`, `center_pull`, `hyper_button`, `heatwave`, `time_dilation`, `mirror_world`, `orbital`
- spawn/reward modifiers: `frenzy`, `treasure_tide`, `blessing`, `hellrush`, `void_window`, `jackpot_mode`, `lucky_wave`, `coin_rain`, `essence_bloom`, `boss_hour`, `moonlight`, `safe_zone`, `overclock`, `party_mode`

Do not add Prestige, Perks, Skill Shield, active skills, final theme system, or unrelated Goober systems in this slice. Hooks may remain ready for those systems, but missing dependencies must not be faked.

## Chosen architecture

### 1. EventManager remains lifecycle-only

`EventManager` keeps:

- 9 second random check
- 22% trigger gate
- one active event
- start/end/progress signals
- generic float/bool modifier queries
- replacement cleanup signal ordering
- `events_seen`

It does not learn gameplay implementation details.

When this slice is complete, the enabled natural-event pool becomes all 35 `EVENT_INFO` IDs.

The current intentional adaptation for empty event rarities remains: only rarities with enabled candidates are weighted. The canonical Python currently gives mythic a rarity weight despite defining no mythic events, creating a dead roll. Godot will keep filtering empty rarities and document this as a deliberate correction rather than claiming mathematical identity.

### 2. Runtime effects are capability-based

`ClickController` becomes the home for button-motion mechanics because it already owns button position and bounds. It receives a runtime effect snapshot/setters, never an event ID.

Supported button capabilities:

- `move_mult`
- `scale_mult`
- `gravity`
- `invert_move`
- `center_pull`
- `orbit`
- `mouse_flee`
- `blink`
- sticky click jitter

Canonical constants/behaviour to preserve where possible:

- gravity adds +16 vertical drift on manual movement
- invert movement multiplies inverted drift by 0.85
- center pull nudges toward play-area centre by 6 px per effect tick
- orbit increments angle by 0.12 and uses radius 42 px
- blink: within 180 px, 14% chance per effect tick, jump up to 55 px
- mouse flee range: `220 + difficulty * 1.5`; base flee strength begins at 28 and grows from progression that exists in Godot
- sticky adds small per-click jitter in addition to `move_mult = 0.35`

Effects must use the existing scaled-size-aware clamp from `4b5d675`.

### 3. Pointer adaptation for Android

The Python implementation assumes a desktop cursor for `mouse_flee` and `blink`. Godot must work on touch devices.

Use a shared pointer position with a short freshness window:

- mouse motion updates continuously on desktop
- touch/motion updates the same virtual pointer on Android
- flee/blink run only while the pointer is recent and inside the play area
- no stale touch coordinate may make the button flee indefinitely

This is a deliberate mobile adaptation, not a new feature.

### 4. Inverted-colour effect is isolated from final UI design

Do not redesign the UI. Implement a temporary full-screen, input-transparent CanvasItem shader/overlay that inverts the rendered scene while the capability `invert_colors` is active. It must be removed/disabled on event end or replacement.

This avoids hard-coding current temporary UI colours and remains compatible with the later total UI refactor.

### 5. GooberManager owns event-driven spawn/reward effects

`GooberManager` receives current modifier values through setters/snapshot; it does not import or inspect `EventManager` and does not branch on event IDs.

Implement currently representable modifiers:

- `spawn_bonus`: raises maximum simultaneous goobers
- `rare_bonus`: adjusts rarity selection using the canonical rarity-weight model when natural spawn selection is upgraded in this slice
- `boss_bonus`: affects boss chance only if/when the existing boss type can be selected safely; do not fake unavailable boss progression gates
- `panic_reduce`: subtracts from goober push before clamp
- `special_money_mult`: only non-normal goobers
- `special_coin_bonus`: only non-normal goobers, only when the secret shop is unlocked
- `click_coin_bonus`: manual CLICK grants GC only when secret shop is unlocked
- `special_essence_bonus`: wire only if a real Essence field/system already exists; otherwise expose/test the modifier plumbing and mark payout deferred until Prestige/Essence lands

The existing Goober rarity reward multiplier remains part of the payout composition.

### 6. Composite events are data-driven

Composite events work because multiple capabilities are active simultaneously; no special event-ID branch belongs in `main.gd`.

Examples:

- `storm_mode` = move 1.25 + gravity
- `glitch_flip` = invert movement + blink
- `hyper_button` = scale 1.18 + move 1.12
- `heatwave` = move 1.45 + mouse flee
- `time_dilation` = move 0.75 + auto 1.25
- `blessing` = click 1.6 + auto 1.6 + move 0.7 + special essence bonus
- `mirror_world` = invert colours + invert movement
- `safe_zone` = panic reduction 8 + move 0.8
- `overclock` = auto 1.8 + spawn bonus 3
- `party_mode` = rare bonus + click GC + special GC

If a behaviour is not fully expressible by canonical EVENT_INFO alone (notably sticky's extra click jitter), use a small derived behaviour adapter close to the event integration layer. Keep these exceptions out of `main.gd` and document them.

## Main.gd responsibilities

`main.gd` may:

- read generic modifiers from EventManager
- push a synchronized modifier/effect snapshot into ClickController and GooberManager on start/end
- compose click and auto payouts
- maintain the visual inversion node/controller

`main.gd` may not contain logic like `if active_event_id == "gravity"` or a `match` over canonical event IDs.

## Lifecycle and cleanup

On start:

1. EventManager commits active definition.
2. `events_seen` increments.
3. listeners synchronize current modifier snapshot.
4. transient visual/movement effect state starts.

On replacement:

1. `event_ended(old_id)` is emitted first.
2. old transient side effects are cleared.
3. new event starts and new snapshot is applied.

On normal end:

- movement flags return false
- multipliers return 1.0 / bonuses 0
- inversion is disabled
- orbit state may reset to zero
- scaled click button returns to progression scale, never an unconditional 1.0
- no active event is persisted in save

## Testing strategy

Extend headless smoke tests for:

- all 35 IDs enabled at slice completion
- composite modifier snapshots
- no main-ID branching contract where practical
- spawn cap = base + `spawn_bonus`
- `panic_reduce`
- special money/coin and click-coin gating
- natural rarity pool and empty-rarity adaptation
- replacement resets old capabilities before new ones

Extend timed scene tests for:

- gravity drift direction
- invert-move sign/0.85 factor
- center pull convergence
- orbit movement and bounds
- blink deterministic injected roll / proximity
- pointer freshness expiration
- sticky jitter bounds
- inverted overlay enable/disable and touch transparency
- composite start/end cleanup

Keep all existing combo, modal, save and Event Core tests passing.

Android manual validation must include:

- big/tiny scaled edges remain correct
- mouse_flee/blink feel sane on touch and do not continue reacting to stale touches
- orbit/center-pull never cross safe play-area bounds
- invert-colours overlay does not block touch
- rapid replacement via force-test leaves no stuck effect

## Deferred after this slice

Still out of scope even though event hooks exist:

- Prestige rarity-weight bonus (+8% rare/epic at P3)
- good/bad duration perks
- Skill Shield blocking/cancel
- full Essence economy where absent
- final UI/theme polish
- full Goober roster/boss progression if not already implemented
- event-on-Goober-click activation for blocked Goober types until those types are enabled by their dependencies

## Approaches considered

1. **Recommended: capability-based controllers** — keeps EventManager generic, makes composite events natural, isolates movement and Goober concerns, scales to future systems.
2. **ID switch in main.gd** — fastest initially, but recreates the monolith and makes cleanup/composite events fragile. Rejected.
3. **One script/class per event** — clean in theory but excessive for mostly data-defined modifiers and would create 35 tiny runtime objects. Rejected as unnecessary complexity.

## Acceptance criteria

The slice is complete when:

- all 35 canonical events can be naturally selected
- all 28 previously deferred behaviours are implemented where their underlying Godot subsystem exists
- unavailable dependent rewards are explicitly documented rather than simulated
- event replacement/end always clears transient effects
- no canonical event ID branching is added to `main.gd`
- existing tests remain green and new deterministic/temporal tests pass
- source map changes Events from `⚠ Event Core 7/35` to `✅ 35/35 behaviours`, with any dependency-specific exceptions named precisely
- Android manual pass is the final gate before merge to `main`
