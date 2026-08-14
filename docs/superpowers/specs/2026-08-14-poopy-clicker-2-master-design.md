# Poopy Clicker 2.0 — Master Product, UX & Technical Design Spec

**Status:** Approved design baseline  
**Date:** 2026-08-14  
**Scope:** Poopy Clicker 2.0 refoundation program  
**Authority:** This document is the authoritative Poopy Clicker 2.0 design source of truth. It supersedes earlier partial Poopy Clicker 2.0 block notes where they conflict with this spec, including the earlier Block 1 and Block 2 documents. Legacy canonical migration documents remain authoritative only for behavior intentionally preserved from the Python version.

> **Poopy Clicker is allowed to be stupid. It is not allowed to feel cheaply made.**

---

## 1. Executive Summary

Poopy Clicker 2.0 is not a sequel, mechanical reboot, or content explosion. It is a refoundation of the existing Godot game after canonical feature parity was completed.

The current game already contains the major gameplay systems: click and auto economy, Goobers and rarities, bosses, combo, 35 events, Secret/Goober Shop, active skills, Prestige and Essence, Perks, Missions, Achievements, Collections and Synergies, Themes, sound, offline progress, statistics, saving and migrations.

The 2.0 program makes those systems feel like one intentionally authored product.

The program prioritizes:

- a deliberate visual identity;
- separate Mobile and Large-Screen presentation families;
- clearer information architecture;
- a real semantic design system;
- stronger game feel and feedback;
- platform-native ergonomics;
- progressive architecture cleanup driven by product needs;
- save compatibility;
- disciplined testing and release gates;
- controlled feature growth after 2.0.

The target feeling is:

> Open the game, understand it immediately, enjoy clicking before optimizing anything, notice strange things happening around the playfield, discover systems gradually, and receive satisfying feedback without the interface constantly begging for attention.

The product North Star is:

> **“This is absurdly stupid, but they made the stupid thing extremely well.”**

---

# PART I — PRODUCT IDENTITY

## 2. Product Positioning

Poopy Clicker 2.0 sits between three categories:

### Incremental / clicker

- clear progression;
- numbers grow visibly;
- upgrades remain understandable;
- Prestige creates meaningful run cycles;
- idle and offline progress remain valid.

### Casual arcade

- direct interaction matters;
- Goobers move and demand occasional attention;
- events create short changes in rhythm;
- bosses and special encounters create attention spikes.

### Digital toy / game-feel game

- CLICK should be enjoyable even before optimization matters;
- buying, discovering, defeating, unlocking and resetting should feel good by themselves;
- the game should retain personality even when viewed as a static screenshot.

The center of the product is:

> **Clicker progression + toy-like interaction + controlled chaos.**

Poopy Clicker must not become a spreadsheet-first idle game, nor an arcade game where reflexes make incremental progression irrelevant.

---

## 3. Visual DNA

The approved visual direction is the hybrid option:

> **Dark polished structural layer + expressive, colorful gameplay layer.**

### Structural layer

Used by:

- HUD structure;
- navigation;
- surfaces;
- cards;
- settings;
- economic information;
- utility controls.

It should feel:

- dark;
- calm;
- refined;
- stable;
- predictable;
- highly legible.

### Expressive layer

Used by:

- Goobers;
- CLICK;
- combo;
- rarity;
- events;
- rewards;
- achievements;
- bosses;
- Prestige;
- unlock moments;
- particles and contextual effects.

It may feel:

- colorful;
- elastic;
- goofy;
- exaggerated;
- weird;
- temporarily chaotic.

The structural layer creates contrast so special moments can actually feel special.

### Five target adjectives

- weird;
- cute;
- energetic;
- polished;
- legible.

### Four anti-target adjectives

- corporate;
- generic;
- infantilized;
- overloaded.

Humor must come primarily from content, reactions and timing, not from undisciplined interface design.

---

## 4. Emotional Intensity Hierarchy

Every visible element belongs conceptually to one of five intensity levels.

### Level 0 — Environment

Background, inactive chrome and passive decoration.

Almost silent.

### Level 1 — Information

Money, income, labels, stable resource information.

High readability, low noise.

### Level 2 — Actions

Buttons, upgrades, navigation, selectable cards.

Clear and responsive.

### Level 3 — Gameplay

CLICK, Goobers, combo, active event, active skills.

Attention-seeking by design.

### Level 4 — Moments

Prestige, bosses, rare milestones, major achievements, Mythic discoveries, collection completion.

The game is allowed to become dramatically expressive for a short period.

The interface must never put every element at Level 3 or 4 simultaneously.

---

## 5. UX Principles

### 5.1 Gameplay first

The playfield is the primary product surface. HUD and navigation are built around it rather than consuming it.

### 5.2 Two-second readability

A player should quickly understand:

- current money;
- current income;
- where the main click target is;
- whether a combo is active;
- whether an event is active;
- whether an important resource or action changed.

Deep detail belongs in surfaces.

### 5.3 Progressive disclosure

Locked or irrelevant systems should not all be visible from minute one. UI complexity should grow with the save.

### 5.4 One action, one response

Every important input must produce immediate perceptible feedback. A player should not wonder whether the tap registered.

### 5.5 Frequency defines proximity

Frequently used actions require fewer steps. Infrequent systems may live in the Progression Hub.

### 5.6 Mobile is not compressed desktop

Phone layouts are designed independently for touch, limited height/width and sequential interaction.

### 5.7 Motion has meaning

Motion communicates origin, destination, importance, state change or reward. It is not applied merely because Tween exists.

### 5.8 Preserve context

Secondary surfaces should not feel like unrelated applications. Returning to gameplay must be immediate and predictable.

### 5.9 Failure is explainable

Disabled, locked, unaffordable, cooldown and maxed states must communicate why they are unavailable.

### 5.10 Consistent structure, semantic variety

Screens share interaction grammar, but not composition. Shop should feel like a shop. Gooberário should feel like a collection. Prestige should feel consequential.

### 5.11 Reward attention, do not demand it

The game should acknowledge attention without manufacturing obligation or anxiety.

---

## 6. Product Goals

### G1 — Identity

A screenshot should unmistakably look like Poopy Clicker rather than default Godot dark UI.

### G2 — Clarity

A new player identifies Money, CLICK and the primary action immediately.

### G3 — Platform quality

Phones, tablets and desktops each receive a deliberate composition.

### G4 — Componentization

Shared visual changes should not require editing many feature screens individually.

### G5 — Feedback

Important actions receive feedback proportional to importance.

### G6 — Scalability

New screens and components should extend existing patterns rather than inventing new foundations.

### G7 — Performance

Normal visual quality must be complete and performant on modest Android hardware.

### G8 — Personality

The game must become substantially more alive without sacrificing legibility.

---

## 7. Non-Goals

Poopy Clicker 2.0 does not aim to:

- become a live service;
- add multiplayer;
- add monetization;
- add premium currency;
- add daily-login pressure;
- copy predatory mobile UI patterns;
- convert all code to C++;
- introduce ECS;
- introduce a global EventBus;
- build a dependency injection framework;
- create a second Prestige layer;
- add crafting or equipment;
- add another major currency;
- rewrite correct gameplay solely to fit a new abstraction;
- convert code-first UI to scene-heavy authoring by ideology;
- pursue shaders or expensive effects as the foundation of visual quality.

Engineering remains proportional to the size of the game.

---

# PART II — LAYOUT & NAVIGATION

## 8. Platform Presentation Model

Poopy Clicker 2.0 has **two layout families**, not one responsive layout that progressively shrinks.

```text
Presentation
├── Mobile
│   ├── Mobile Portrait
│   └── Mobile Landscape
└── Large-Screen
    ├── Tablet Profile
    └── Desktop Profile
```

Input capability is modeled independently:

```text
Input Profile
├── Touch
├── Pointer + Keyboard
└── Hybrid
```

Examples:

- Phone portrait → Mobile + Touch.
- Phone landscape → Mobile + Touch.
- Tablet → Large-Screen + Touch/Hybrid.
- Touchscreen notebook → Large-Screen + Hybrid.
- Desktop → Large-Screen + Pointer/Keyboard.

### ADR — Layout family is a product decision, not a breakpoint

Phones always remain Mobile, even in landscape. Tablets and desktop-class environments use Large-Screen. Rotation and resizing change composition inside a family but do not transform one product family into the other.

---

## 9. Shared Versus Platform-Specific Presentation

Mobile and Large-Screen share:

- GameState and runtime systems;
- semantic tokens;
- theme definitions;
- typography roles;
- reusable primitives;
- visual semantics;
- feature rules;
- navigation model;
- feedback contracts;
- state queries and domain signals.

They do **not** need to share:

- shell geometry;
- navigation widget geometry;
- panel composition;
- information density;
- master-detail behavior;
- exact HUD positioning.

The design should avoid both extremes:

1. one universal UI full of `if mobile` branches;
2. fully duplicated mobile and desktop feature logic.

Shared logic remains shared; presentation composition may diverge.

---

## 10. Gameplay Shell

Both layout families conceptually contain:

```text
GameShell
├── BackgroundLayer
├── Playfield
│   ├── GooberLayer
│   ├── ClickTargetLayer
│   └── RewardFxLayer
├── HudLayer
├── SurfaceLayer
└── OverlayLayer
```

These are responsibility boundaries, not necessarily visible boxes.

### Playfield principle

The playfield should feel like a deliberate game space rather than an empty gray region between toolbars.

The background may use subtle depth:

- restrained gradient;
- subtle vignette;
- lightweight texture/noise;
- theme-specific decoration;
- gentle center emphasis.

Goobers remain visually dominant against it.

---

## 11. Mobile Composition

### 11.1 Portrait

Phone portrait prioritizes vertical readability and thumb access.

Conceptually:

```text
┌──────────────────────┐
│       MONEY          │
│      +income/s       │
│   GC     Essence     │
│                      │
│   Event Status       │
│                      │
│      Playfield       │
│                      │
│       CLICK          │
│                      │
│       Combo          │
│      Skill Rail      │
│                      │
│ Shop Goobers Menu    │
└──────────────────────┘
```

### 11.2 Landscape

Landscape is a separate Mobile composition rather than portrait rotated.

Height becomes scarce, so:

- resource information becomes more horizontal;
- event status compresses;
- skills may move laterally;
- the bottom navigation remains shallow;
- the playfield receives maximum height.

Rotation must preserve navigation stack, selected details, dialog state and gameplay context.

---

## 12. Large-Screen Composition

Large-Screen is shared by tablet and desktop, with different input ergonomics.

It may use:

- horizontal resource clusters;
- lateral or compact navigation;
- multi-column surfaces;
- master-detail;
- larger visible playfield;
- denser information where useful.

### Tablet profile

Tablet uses Large-Screen composition but remains touch-first:

- touch targets around 48 logical px minimum;
- no required hover;
- comfortable scroll areas;
- larger spacing than pointer-oriented desktop when needed;
- master-detail when space permits.

### Desktop profile

Desktop may add:

- hover enhancements;
- keyboard focus;
- Escape semantics;
- wheel scrolling;
- optional keyboard shortcuts;
- modestly greater information density.

No essential information may exist only in hover state.

---

## 13. Resource Hierarchy

### Tier 1 — Always visible

- Money;
- Income.

### Tier 2 — Visible after unlock

- Goober Coins;
- Poopy Essence;
- Prestige level indicator.

### Tier 3 — Temporary gameplay

- Combo;
- active Event;
- active Skill state/cooldowns.

### Tier 4 — Contextual

- Mission progress;
- collection completion;
- achievement progress;
- offline earnings.

Tier 4 information enters through surfaces, notifications or Moments rather than permanent HUD clutter.

---

## 14. CLICK

CLICK is a unique gameplay component, not a generic button.

It must:

- dominate interaction hierarchy;
- have a large, honest hit target;
- remain comfortable on touch;
- support press/release feedback;
- support event state presentation;
- support combo feedback;
- visually distinguish itself from menu actions.

Mechanical position/scale and cosmetic feedback transforms must be independently owned so Tweens never fight gameplay movement.

---

## 15. Primary Navigation

The approved primary destination hierarchy is:

```text
Shop
Gooberário
Menu / Progression Hub
```

Achievements are removed from permanent primary navigation because they are important as rewards but infrequent as actions.

The navigation model is shared across platforms; the widget is not required to be shared.

Mobile may use a bottom dock. Large-Screen may use a compact dock, rail or lateral cluster.

---

## 16. Progression Hub

The old Menu grid is replaced by a contextual Progression Hub.

It organizes systems by meaning.

### Progression

- Prestige;
- Perks.

### Activities

- Missions;
- Achievements.

### Collection / personalization

- Gooberário links where useful;
- Themes.

### System

- Stats;
- Settings.

### Secret Goober Shop

Invisible before unlock and presented separately afterward to preserve its identity.

Hub entries may expose useful context such as:

- Prestige Essence gain available;
- number of affordable Perks;
- mission completion status;
- achievement count;
- genuinely new information.

Notification dots must never become engagement manipulation.

---

## 17. Surface Navigation

The flat PanelManager navigation model evolves into a stack-based SurfaceRouter.

Conceptual operations:

```text
push_surface()
pop_surface()
replace_surface()
close_all()
```

Expected behavior:

```text
Gameplay
→ Hub
→ Prestige
→ Back
→ Hub
→ Back
→ Gameplay
```

Android Back and Desktop Escape share the same semantic ordering:

```text
Dialog
→ Subview
→ Parent Surface
→ Gameplay
→ system-level exit behavior
```

Gameplay input remains blocked while an interactive Surface stack is open.

---

## 18. Surface Types

### Quick Surface

Small contextual interactions, confirmations and compact selectors.

### Standard Surface

Most systems: Shop, Missions, Prestige, Perks, Achievements.

### Immersive Surface

Systems that benefit substantially from space: Gooberário, Stats, Themes.

### Dialog Surface

Explicit destructive or consequential confirmations.

### Moment Surface

Non-navigation presentation such as Prestige, boss introductions or major reveals. Moment Surfaces do not behave as normal navigation destinations.

All normal surfaces share a structural contract:

```text
Surface
├── Header
│   ├── Back / Close
│   ├── Title
│   └── Context Actions
├── Optional Summary
├── Content
└── Optional Primary Action
```

Content does not decide whether it appears full-screen on phone or floating on desktop.

---

# PART III — DESIGN SYSTEM

## 19. Design-System Architecture

The visual system has three layers:

```text
Foundation
↓
Semantic Tokens
↓
Components
```

### Foundation

Raw scales and primitives:

- color values;
- spacing;
- radius;
- typography sizes;
- durations;
- easing;
- opacity;
- elevation metrics;
- touch metrics.

### Semantic Tokens

Meaningful roles such as:

- `surface_card`;
- `text_primary`;
- `resource_gc`;
- `rarity_legendary`;
- `status_danger`.

Feature panels should not hardcode raw colors for common semantics.

### Components

Reusable controls consume semantic tokens. Screens compose them.

---

## 20. Default Theme Direction

The default palette is a dark expressive theme with a violet-family primary accent.

Exact color values remain implementation-tunable, but the intended hierarchy is:

```text
Background Deep
Background
Surface Low
Surface
Surface High
Border Subtle
Border Strong
Text Primary
Text Secondary
Text Muted
Accent Violet
```

Violet is chosen as the structural accent because it leaves semantic space for:

- gold/yellow GC;
- Essence lilac/cyan family;
- green success;
- red danger;
- rarity colors.

Colors must communicate meaning rather than merely decoration.

---

## 21. Semantic Color Families

### Status

- success;
- warning;
- danger;
- info;
- disabled.

### Resources

- Money;
- Goober Coins;
- Essence;
- Prestige state.

### Rarity

- Common;
- Rare;
- Epic;
- Legendary;
- Mythic.

Rarity must be communicated by color plus text, badge or symbol. Color alone is insufficient.

---

## 22. Typography

Mono is not the primary interface font.

The system defines functional roles:

### Display

Used for:

- Money;
- CLICK;
- important titles;
- Prestige;
- boss presentation;
- achievement reveal.

Friendly/geometric and expressive.

### UI

Used for:

- labels;
- descriptions;
- buttons;
- stats;
- cards.

Highly legible and neutral enough not to compete with gameplay.

### Numeric

Optional role for aligned stats, prices, timers and cooldowns if the selected typeface supports tabular figures or a dedicated numeric style is justified.

Typography uses semantic roles, not arbitrary sizes chosen per panel.

---

## 23. Spacing, Radius and Elevation

Spacing is based on a 4 px foundation with a deliberate scale, approximately:

```text
4 / 8 / 12 / 16 / 24 / 32 / 48
```

Radius roles are approximately:

```text
small / medium / large / extra-large / pill
```

Not every component is a capsule.

Elevation levels are conceptually:

- flat;
- raised;
- floating.

Depth may use background contrast, restrained border and small shadow rather than expensive blur.

Cards only group meaningful units. Nested card-on-card composition is discouraged.

---

## 24. Core Components

Initial primitives are created by need rather than building a theoretical component zoo.

Expected core primitives include:

- `PoopyButton`;
- `IconButton`;
- `ResourceChip`;
- `StatusChip`;
- `PoopyCard`;
- `ProgressBar`;
- `SectionHeader`;
- `EmptyState`.

Gameplay components include:

- `ClickTarget`;
- `ComboDisplay`;
- `EventStatus`;
- `SkillButton`;
- `FloatingReward`;
- `RarityBadge`;
- `BossBar`.

A generic base component must not accumulate dozens of feature-specific booleans.

---

## 25. Theme Runtime

Themes modify semantic presentation, not ergonomics.

They may change:

- background;
- accent;
- surface tint;
- decoration;
- particles;
- display typography in limited cases;
- effect flavor.

They must not change:

- minimum touch target;
- navigation semantics;
- core spacing hierarchy;
- layout family;
- contrast below acceptable levels.

Screens never branch on individual theme IDs.

Correct direction:

```text
selected theme id
→ ThemeController
→ semantic token set
→ components
```

Not:

```text
if theme == "matrix":
    ShopButton.color = green
```

---

# PART IV — SURFACE INFORMATION DESIGN

## 26. Shop

Shop is a high-frequency surface and must be extremely fast to scan.

Upgrades are presented as Upgrade Lanes showing:

- name;
- current level;
- current output;
- next output;
- price;
- affordability state;
- clear purchase action.

Unaffordable state should explain missing amount where useful instead of merely disabling the button.

Purchase feedback updates level and output visibly without unnecessary confirmation modals.

---

## 27. Secret Goober Shop

Secret Goober Shop has a distinct identity inside the same structural system.

Content is separated into:

- passive upgrades;
- active skills.

Active skill entries must communicate purchased/available/active/cooldown state distinctly.

The Shop remains hidden before canonical unlock.

---

## 28. Gooberário

The table-first presentation is replaced by a Collection Grid.

Each entry communicates:

- sprite/visual representation;
- discovered/unknown state;
- name when known;
- rarity marker.

Unknown entries use silhouette/`???` and only reveal hints when behaviorally appropriate.

### Goober detail

Detail presentation may show existing information such as:

- large Goober visual;
- rarity;
- seen count;
- clicked/defeated count;
- HP/reward information where meaningful;
- collection/synergy relationships;
- future flavor text.

Mobile uses sequential Grid → Detail navigation. Large-Screen may use master-detail.

Basic rarity/discovery filters are allowed. Text search is deferred unless collection scale later justifies it.

---

## 29. Achievements

Achievements become a progress surface rather than a wall of identical cards.

Header shows:

- unlocked count;
- total count;
- overall completion.

Filters may include:

- All;
- In progress;
- Unlocked.

Individual entries show name, hint and progress when locked/in-progress. Completed entries simplify visually.

Achievement reveal during gameplay is a separate Moment/notification behavior and must be more expressive than browsing the archive.

---

## 30. Missions

Missions are active task cards, not a catalog.

Cards show:

- title;
- description;
- progress;
- reward;
- completed state.

Canonical auto-claim behavior remains. The redesign must not invent a manual Claim button simply because other games use one.

Routine progress remains visually quiet. Completion receives a proportional reward presentation.

---

## 31. Prestige

Prestige receives its own consequential visual language.

The surface shows:

- current Prestige level;
- next level;
- estimated Essence gain;
- current bonuses;
- next bonuses;
- clearly separated RESET and KEEP information;
- one explicit final action.

Long explanatory paragraphs are replaced by structured information.

The confirmation dialog repeats the consequence and actual previewed gain without generic `Are you sure?` wording.

After successful domain transaction, final presentation uses the returned result object rather than recalculating values in UI.

---

## 32. Perks

Perks remain independent modules rather than an invented skill tree.

Each module shows:

- name;
- effect;
- current level / max;
- next effect;
- Essence cost;
- ready / unavailable / max state.

MAX is a completed presentation state rather than simply a dead disabled button.

---

## 33. Stats

Stats permits higher information density.

It uses sections such as:

- Current Run;
- All Time;
- Progression.

Rows and separators are preferred over a card per statistic.

Large-Screen may use multiple columns where useful.

---

## 34. Themes

Themes become a visual gallery rather than a plain text list.

Each card includes:

- compact preview;
- theme name;
- ownership state;
- cost or Apply action.

A later 2.0 slice adds live preview:

```text
select theme
→ temporary preview
→ Apply or Cancel
```

Leaving without Apply restores the committed theme.

---

## 35. Settings

Settings prioritizes utility over spectacle.

Expected 2.0 controls:

- Sound;
- Reduced Motion;
- Text Size;
- Visual Effects quality.

Haptics may be added when haptic feedback exists.

Settings should apply immediately when technically reasonable.

---

# PART V — GAME FEEL

## 36. Feedback Intensity Tiers

### Tier 1 — Micro

Frequent actions: CLICK, button press, small counter updates.

Purpose: “Yes, it registered.”

### Tier 2 — Reward

Upgrade purchase, normal Goober defeat, GC gain, routine mission completion.

Purpose: “Good.”

### Tier 3 — Special

Rare discovery, achievement, powerful skill, major perk state.

Purpose: “Oh.”

### Tier 4 — Moment

Prestige, boss, Mythic discovery, major collection completion.

Purpose: “Whoa.”

Tier determines motion duration, sound intensity, particles, size and presentation priority.

---

## 37. CLICK Feedback

Press feedback is immediate and cheap.

A typical sequence:

```text
1.00 scale
→ 0.92–0.96 on press
→ small overshoot on release
→ 1.00
```

Cosmetic animation must never prevent another valid click.

Floating reward text may appear near the action but must be pooled/capped/aggregated enough to avoid label storms.

---

## 38. Money and Auto Feedback

Money counters may use restrained pulse for meaningful gains.

Auto income must not spam floating text every tick. Presentation may sample or aggregate updates even when domain state changes more frequently.

Manual action feedback is intentionally more expressive than passive auto income.

---

## 39. Combo

Combo moves out of the static economic header and into gameplay presentation.

Presentation intensity scales by ranges such as:

- low;
- energized;
- hot;
- intense;
- extreme.

Exact thresholds are tunable presentation values and must not silently alter combo mathematics.

Breaking a very low combo is almost silent. Breaking a high combo is visible but never guilt-driven.

---

## 40. Goober Feedback

Goobers receive:

- spawn feedback;
- immediate hit reaction;
- restrained HP/progress feedback for multi-hit entities;
- defeat/pop feedback;
- proportional rarity accent;
- reward presentation.

Mechanical movement and cosmetic hit transforms remain independent.

New Goober discovery receives a Tier 3 discovery card with optional action to view in Gooberário.

---

## 41. Rarity

Rarity increases presentation intensity without changing the fundamental visual grammar.

Common remains quiet. Rare/Epic add controlled accent. Legendary may receive a stronger burst/sound. Mythic may receive a short mini-Moment.

The player must remain able to interact quickly with rare Goobers.

---

## 42. Events and Skills

Event entry is more expressive than event exit.

Event presentation should be driven by semantic capabilities/tags where possible rather than a giant 35-event UI switch.

Skills expose:

- ready;
- active;
- cooldown;
- unavailable.

Cleanse, Frenzy, Shield and Coinburst may each receive recognizable semantic feedback without creating expensive bespoke full-screen systems.

---

## 43. Bosses

Boss is Tier 4.

A short boss sequence may:

- dim ambience;
- present boss incoming;
- spawn boss;
- reveal BossBar;
- restore immediate interaction.

The player should wait no more than roughly one second before being able to interact unless later testing proves otherwise.

Boss death aggregates rewards and receives a major presentation moment.

---

## 44. Prestige Moment

Prestige is the largest normal progression Moment.

After confirmation and successful transaction:

- destructive input locks briefly;
- current run presentation collapses/fades;
- Prestige level transitions;
- actual returned Essence gain is celebrated;
- the new run returns.

Target presentation duration is roughly 1.2–2.0 seconds, tunable by feel.

Reduced Motion replaces large travel/collapse with clear fades and number transitions.

---

## 45. PresentationQueue

When multiple important events occur in one frame, they are prioritized rather than overlapped.

Conceptual ordering:

```text
Critical Moment
→ major Collection / Boss result
→ Achievement
→ Mission
```

Routine toasts may coexist when they do not conflict.

PresentationQueue owns priority/lifecycle, not gameplay logic.

---

## 46. Silence Principle

Not every change deserves visible animation.

Examples deliberately quiet:

- ordinary auto-income tick;
- ordinary mission +1 progress;
- stats updates;
- autosave success.

Special moments work only if ordinary moments remain quiet.

---

# PART VI — TECHNICAL ARCHITECTURE

## 47. Target Architecture

Poopy Clicker remains a modular monolith.

```text
Main / Composition Root
│
├── Domain State
│   └── GameState
│
├── Runtime Systems
│   ├── Economy
│   ├── ClickController
│   ├── ComboManager
│   ├── EventManager
│   ├── GooberManager
│   ├── MissionManager
│   ├── SkillManager
│   └── AutoIncomeManager (when extracted)
│
├── Application Coordination
│   ├── SessionCoordinator (when needed)
│   ├── PrestigeCoordinator (if still justified)
│   └── EventRuntimeBridge
│
├── Infrastructure
│   ├── SaveManager
│   ├── SoundManager
│   └── PointerInputAdapter
│
└── Presentation
    ├── MobileGameShell
    ├── LargeScreenGameShell
    ├── SurfaceRouter
    ├── ThemeController
    └── Feedback / PresentationQueue
```

The architecture must fit in a developer’s head.

---

## 48. GameState Remains Aggregate Root

GameState is intentionally **not** exploded into many sub-state objects.

It continues to own persistent game state and atomic transactions such as:

- money changes;
- purchases;
- Prestige transaction;
- Perk state;
- ownership state;
- progression queries.

Static catalogs are gradually extracted only when touched by relevant work.

Examples of candidates:

- Perk definitions;
- Theme definitions;
- Collection definitions;
- Synergy definitions.

GameState should know what the player owns, not necessarily remain the permanent home of every static definition in the game.

---

## 49. Main Becomes Composition Root Gradually

Current `main.gd` is both composition root and broad runtime/application coordinator. This was acceptable for the canonical port.

The 2.0 goal is that Main primarily:

- creates dependencies;
- wires dependencies;
- mounts the selected GameShell;
- starts the session.

Responsibilities leave Main only when a real boundary exists.

File length alone is not a refactoring justification.

---

## 50. Runtime Ownership

A system that owns timers, transient runtime state or lifecycle should generally own its runtime behavior.

Examples:

- Combo decay → ComboManager;
- event lifecycle → EventManager;
- Goober spawn/lifecycle → GooberManager;
- skill runtime → SkillManager;
- auto-income timer → eventual AutoIncomeManager.

Offline progression is session lifecycle, not simply an auto-income tick and therefore remains separately coordinated.

---

## 51. Application Coordination

Coordinators are introduced only for cross-system operations.

Prestige is a valid example because after the GameState transaction the application may need to coordinate:

- combo reset;
- Goober reset;
- save;
- presentation;
- post-Prestige spawn.

Simple purchases do not receive individual use-case classes merely for architectural fashion.

---

## 52. Typed State Signals

The current broad `GameState.changed` signal is retained during migration but gradually supplemented with category signals where distinct consumers need distinct reactions.

Potential categories include:

- economy changed;
- progression changed;
- collection changed;
- settings/theme changed;
- specific successful transactions such as Prestige.

The target is not dozens of tiny signals.

No global EventBus singleton is introduced.

Consumers receive dependencies and connect directly where practical.

---

## 53. Presentation State

Presentation-only data such as:

- selected Goober;
- selected filter;
- active Surface stack;
- scroll position where preserved;
- theme preview;
- open confirmation;

must not pollute persistent GameState unless it genuinely needs persistence.

State local to a single screen remains local. Shared presentation state is centralized only when it must survive navigation or be shared.

---

## 54. GameShell Layer Ownership

Visual runtime systems receive explicit containers rather than relying on root child ordering.

Examples:

- GooberManager → GooberLayer;
- floating rewards → RewardFxLayer;
- SurfaceRouter → SurfaceLayer;
- Moment presentation → OverlayLayer.

This creates predictable z-order and lifecycle ownership.

---

## 55. SurfaceRouter Migration

The old PanelManager remains temporarily during migration.

Preferred strategy:

1. build SurfaceRouter in parallel;
2. migrate Wave 1 surfaces;
3. preserve compatibility for unmigrated surfaces;
4. migrate Waves 2 and 3;
5. remove compatibility bridge and PanelManager after final migration.

Compatibility code must have an explicit removal condition.

---

## 56. ThemeController

GameState persists ownership and selected theme ID. ThemeController translates that ID into semantic presentation.

Screens do not know theme IDs.

This boundary is mandatory for theme scalability.

---

## 57. Feedback and Sound Boundaries

Runtime systems should emit semantic gameplay events rather than manipulate UI or device behavior directly.

GooberManager must not know ToastUI. SkillManager must not update SkillButton directly. Domain code must not vibrate the phone.

Sound/haptic presentation may use focused bridges if direct wiring becomes noisy.

---

## 58. Save Architecture

SaveManager remains infrastructure.

Rules:

- domain state does not save itself;
- application/session lifecycle coordinates persistence;
- UI redesign alone does not cause schema bumps;
- save version changes occur only for persisted-model changes;
- old saves remain supported where existing migration policy promises support.

---

## 59. Offline Progress

Offline calculation is a candidate for a pure/testable `OfflineProgressService` returning a result such as:

```text
elapsed
capped_elapsed
money_gain
```

SessionCoordinator applies the result; presentation decides whether a Welcome Back surface is warranted.

Very short interruptions should not create ridiculous “WELCOME BACK — YOU EARNED $8” moments.

---

## 60. Code-First Policy

Code-first GDScript remains the default UI authoring method.

Scenes are appropriate when they materially improve:

- complex composite visuals;
- authored animation;
- particle systems;
- reusable visual assets;
- editor-driven composition.

The project does not become `.tscn`-heavy by ideology.

---

## 61. Architecture Guardrails

Do not introduce without demonstrated need:

- global EventBus;
- dependency injection framework;
- service locator;
- ECS;
- manager singletons everywhere;
- repository/use-case layers for simple purchases;
- file splitting based only on LOC;
- broad directory moves with no functional reason.

Architecture refactors require a product, correctness, maintenance or performance benefit.

> **No architecture refactor without demonstrated pain.**

---

# PART VII — RESPONSIVE, ACCESSIBILITY & PERFORMANCE CONTRACT

## 62. Reference Viewports

Logical reference targets, not physical pixel guarantees:

### Mobile portrait

- reference around 360×800;
- minimum target around 320×568.

### Mobile landscape

- reference around 800×360;
- minimum target around 568×320.

### Large-Screen

- tablet reference around 800×600 or greater;
- desktop gates at 1366×768 and 1920×1080;
- one compact desktop window case.

The implementation may enforce a reasonable minimum desktop window size rather than supporting absurdly tiny windows.

---

## 63. Safe Areas

Mobile/Tablet shells own safe-area application.

Content is placed inside safe bounds, then normal layout padding is applied.

Child components must not duplicate safe-area padding.

---

## 64. Touch

Normal interactive touch targets should be approximately 48×48 logical px minimum.

Visual icons may be smaller while retaining larger hit regions.

CLICK is intentionally larger but its invisible hit area must remain spatially honest.

Feedback begins on touch-down to minimize perceived latency.

---

## 65. Keyboard and Focus

Desktop surface interaction supports:

- Tab / Shift+Tab traversal;
- Enter / Space activation;
- Escape back semantics;
- visible focus styling.

Hover is optional enhancement, never required for understanding or action.

---

## 66. Text Scaling

2.0 supports a deliberate text-size setting such as Default / Large / Extra Large or equivalent scale levels.

Scaling is applied through typography roles rather than scaling entire Controls.

Layouts must survive larger text without critical clipping.

---

## 67. Reduced Motion

Reduced Motion is a first-class accessibility setting.

It removes/reduces:

- screen shake;
- large translations;
- strong overshoot;
- dense particles;
- parallax.

It preserves:

- feedback meaning;
- rarity state;
- boss state;
- event state;
- Prestige information;
- input confirmation.

Reduced Motion is not Reduced Feedback.

---

## 68. Flash Safety and Color

No strobe-like presentation is permitted.

Bright transitions are brief, isolated and semantically justified.

Color is never the only state channel. Rarity, errors, cooldowns, completion and locked states also use text, iconography, structure or progress.

---

## 69. Visual Effects Quality

The architecture supports conceptually:

```text
Minimal
Normal
High
```

Normal is the complete intended Android experience.

High adds luxury.

Minimal may reduce:

- particle density;
- glow;
- background decoration;
- shadow complexity;
- simultaneous reward effects.

It must preserve identity and functional feedback.

---

## 70. Performance Target

Primary target: **60 FPS** across supported platforms.

Normal quality on the reference Android device must aim for stable, responsive gameplay without recurring stutter.

The design avoids making blur/full-screen shader stacks foundational.

Performance work must be measured against representative scenarios rather than claimed from code inspection alone.

---

## 71. Mobile Lifecycle

When the app backgrounds:

- relevant state is safely persisted;
- presentation-only expensive processing stops;
- timestamping supports correct offline calculation;
- hidden particles/Tweens do not continue unnecessarily.

On resume:

- progress is not duplicated;
- navigation/presentation state is restored where appropriate;
- Welcome Back presentation appears only when meaningful.

SessionCoordinator is the intended lifecycle boundary when that slice is implemented.

---

## 72. Soak Test

A major 2.0 gate is at least one 30-minute real Android gameplay session exercising:

- CLICK;
- Goobers;
- events;
- skills;
- surfaces;
- rotation;
- background/resume;
- Shop;
- Prestige when practical.

The run checks for:

- sustained performance;
- memory growth;
- input degradation;
- duplicate audio;
- navigation corruption;
- lifecycle bugs.

---

# PART VIII — TESTING & QUALITY

## 73. Risk Classes

### R1 — Low risk

Examples: text, icon, spacing token, semantic color polish.

Requires targeted automated check plus relevant visual sanity.

### R2 — Medium risk

Examples: new component, HUD change, Surface, navigation behavior, ThemeController, Game Feel feature.

Requires targeted tests, smoke, affected layout verification and visual review.

### R3 — High risk

Examples: SaveManager, Prestige, GameState transaction, event runtime, offline progress, global navigation lifecycle, SessionCoordinator, input system.

Requires full relevant automated suite, integration tests, save compatibility where applicable and runtime verification on Android/Desktop.

---

## 74. Regression Severity

### P0 — Catastrophic

Save corruption/loss, game does not boot, recurring crash/infinite loop, duplicated progression/resource exploit.

Absolute blocker.

### P1 — Critical

Primary gameplay or navigation unusable, CLICK broken, Prestige wrong, Android Back exits incorrectly in a core flow.

Blocker.

### P2 — Major

Important orientation broken, major clipping, animation interferes with gameplay, severe performance regression, major secondary feature failure.

Normally blocks the affected slice.

### P3 — Minor

Polish issue, typo, small spacing/transitional imperfection without functional impact.

May be follow-up if consciously recorded.

---

## 75. Test Taxonomy

Target structure:

```text
tests/
├── unit/
├── domain/
├── integration/
├── presentation/
└── smoke/
```

Existing tests are migrated gradually rather than rewritten for taxonomy alone.

### Unit

Pure utilities such as NumberFormat, LayoutClassifier, offline calculation, reward aggregation, queue ordering.

### Domain

Economy, Prestige, Perks, Collections, Synergies, Mission rules, Goober rewards, Theme purchases.

### Integration

Cross-system flows such as Prestige aftermath, Event runtime bridge, Surface navigation stack, save/load/system boundaries.

### Presentation contracts

Bounds, required actions, resource visibility, theme propagation, Reduced Motion state, rotation context preservation.

### Smoke

Future smoke becomes a compact “is the game fundamentally alive?” suite rather than the sole home of every invariant.

---

## 76. Existing Smoke Decomposition

The large smoke suite is not deleted or rewritten in one step.

Assertions move into focused suites only when equivalence is proven. The final smoke retains critical boot/integration sanity.

---

## 77. Golden Saves

Representative save fixtures should include at least:

- fresh;
- midgame;
- Prestige-capable;
- high progression;
- relevant legacy schema.

Persisted-model changes must test:

```text
old save
→ load current
→ validate
→ save current
→ reload
→ validate
```

Save regressions are P0.

---

## 78. Automated Layout Matrix

Presentation tests should exercise representative logical viewports such as:

```text
320×568
360×800
568×320
800×360
800×600
1024×768
1366×768
1920×1080
```

Automated checks look for structural invariants such as required controls remaining in bounds and safe margins remaining valid. They do not replace visual review.

---

## 79. Human Visual Gate

Significant visual work is not considered approved merely because tests pass.

Important states must be viewed on representative layouts.

The human product owner has final authority on authorial visual decisions.

---

## 80. Agent Completion Contract

Agents must report:

```text
Changed:
- ...

Tests run:
- ...

Results:
- ...

Not tested:
- ...

Known risks:
- ...
```

They must not claim tests passed when tests were not run.

UI work additionally reports which layouts/viewports were verified.

---

## 81. Branch and Commit Discipline

Poopy Clicker 2.0 uses short-lived branches and granular commits.

Examples:

```text
feat/pc2-semantic-tokens
feat/pc2-mobile-shell
feat/pc2-surface-router
feat/pc2-shop-redesign
refactor/pc2-event-runtime-bridge
fix/pc2-android-back-stack
```

The 3-milestone execution batches defined later are **orchestration units, not mega-branches**. Each milestone still consists of independently reviewable slices/branches and atomic commits.

One conceptual change per commit is preferred where practical.

---

## 82. Evidence Before Merge

> **Evidence before merge. The amount of evidence scales with the amount of risk.**

CI is a safety net, not the first place tests should run.

A slice must satisfy relevant correctness, presentation, platform, architecture, performance and save gates before merge.

---

# PART IX — FEATURE EVOLUTION AFTER 2.0

## 83. Version Intent

### 2.0 — ReFoundation

Make the whole existing game excellent.

Focus:

- UX;
- UI;
- Game Feel;
- platform quality;
- accessibility;
- architecture cleanup;
- quality discipline.

### 2.1 — Depth

Make existing systems interact more meaningfully.

Potential directions:

- richer Collection presentation;
- synergy discovery;
- more interesting Missions;
- stronger event identity;
- stronger boss identity;
- progression tuning based on real 2.0 playtesting.

### 2.2 — Expansion

Introduce at most one major new way to play.

Current leading candidate: Challenge Runs / Mutators.

### 2.3+

Not planned in detail until actual playtesting reveals the next need.

---

## 84. 2.0 Feature Freeze

Large new gameplay systems are frozen during core 2.0 work.

Allowed additions are limited to features necessary to deliver the approved redesign, for example:

- Theme Preview;
- Surface navigation stack;
- PresentationQueue;
- accessibility settings;
- Goober detail presentation;
- useful contextual badges;
- developer layout overrides.

New currencies, progression layers, crafting, equipment, daily quests and other major systems are deferred.

---

## 85. Feature Growth Rules

Before a new major feature is accepted, answer:

1. What new behavior does it create?
2. Which existing system does it strengthen?
3. What cognitive load does it add?
4. When is it unlocked?
5. Is the game still good if it is ignored?
6. Is it still fun after repeated use?

New currency additionally requires proof that Money, GC or Essence cannot represent the new economy cleanly.

---

## 86. 2.1 Depth Direction

Preferred depth improvements strengthen existing relationships rather than adding isolated menus.

Strong candidates:

- Collection-set presentation and milestone moments;
- Synergy discovery moments;
- richer Mission objectives using existing systems;
- event archive/mastery presentation without turning Events into another leveling grind;
- stronger Goober behavioral identity;
- lightweight boss phases/patterns;
- Prestige milestones only if playtesting shows current Prestige lacks qualitative depth;
- cosmetic Theme rewards tied to achievements/collections/milestones.

Daily-login pressure is explicitly rejected.

---

## 87. 2.2 Candidate — Challenge Runs

Challenge Runs are the current favored expansion because they make existing systems mean something new.

Examples may include:

- No Auto;
- Goober Apocalypse;
- Chaos Run;
- Glass Button;
- Boss-focused modifiers.

Before productionizing a challenge system, mutators may be prototyped in an experimental branch/debug harness.

Prototype code is research, not automatically production code.

---

## 88. Anti-Dark-Pattern Contract

Poopy Clicker does not use:

- energy timers;
- punishment for missed daily login;
- fake limited-time offers;
- premium progression currency;
- ads for progression;
- random paid loot;
- notification guilt.

Stats should celebrate play, not shame absence.

---

## 89. Idle Versus Active Philosophy

Idle play remains valid through Auto and offline progress.

Active play remains more engaging through:

- Goobers;
- combo;
- events;
- skills;
- discoveries;
- bosses;
- progression decisions.

Active play may be more efficient without making idle play invalid.

---

# PART X — MASTER IMPLEMENTATION PROGRAM

## 90. Program Structure

The implementation program contains a preflight milestone (`M0`) and ten numbered implementation milestones (`M1`–`M10`).

### User-approved execution batching

Implementation planning and execution proceed in groups of three milestones, with only the final milestone isolated:

```text
PRE-FLIGHT
M0 — Baseline & Guardrails
(not counted as an implementation batch)

BATCH A
M1 — Shared Design Foundation
M2 — Mobile Game Shell
M3 — Large-Screen Game Shell

BATCH B
M4 — Navigation & Surface Foundation
M5 — Surface Wave 1
M6 — Surface Wave 2

BATCH C
M7 — Surface Wave 3 & Theme Completion
M8 — Game Feel & Presentation
M9 — Architecture Consolidation

FINAL ISOLATED BATCH
M10 — Hardening & Release Candidate
```

This batching controls **implementation-plan scope and execution cadence**. It does not merge the three milestones into one giant branch. Inside each batch, slices remain short-lived, independently testable and mergeable.

The next implementation plan after this design spec is therefore **Batch A: M1–M3**, after the user reviews and approves this written spec.

---

## 91. M0 — Baseline & Guardrails

M0 is required preflight and is not counted among the 3-at-a-time implementation groups.

### M0.1 Current-main baseline

Capture:

- current source commit;
- critical feature matrix;
- current save schema;
- known bugs/debt;
- Android behavior;
- baseline screenshots/video of gameplay and major surfaces.

### M0.2 Regression characterization

Cover dangerous boundaries that will be touched early:

- gameplay input blocking;
- PanelManager behavior;
- Android Back/Escape;
- ClickController transform ownership;
- Shop transactions;
- Prestige transaction;
- save/load;
- event capability reset.

### M0.3 Test fixtures

Add representative golden saves and verify round-trip.

### M0 Gate

- current build boots;
- critical smoke passes;
- saves reload;
- input/navigation baseline is characterized;
- visual baseline is captured.

---

## 92. Batch A — M1 + M2 + M3

Batch A establishes the entire presentation foundation and both platform families.

### M1 — Shared Design Foundation

#### M1.1 Semantic token foundation

Create minimum token system required for real product work:

- semantic colors;
- spacing;
- radius;
- typography;
- motion;
- touch metrics;
- surface metrics.

#### M1.2 Core primitives

Create only immediately required primitives such as:

- PoopyButton;
- IconButton;
- ResourceChip;
- StatusChip;
- PoopyCard;
- SectionHeader.

#### M1.3 Layout classification contract

Create shared classification for:

- Mobile versus Large-Screen;
- orientation;
- Touch/Pointer/Hybrid;
- debug override.

#### M1.4 Theme runtime base

Prove:

```text
selected theme
→ ThemeController
→ semantic tokens
```

Default theme must be complete enough for shell work.

#### M1 Gate

A small representative interface can be built without structural styling hardcoded in a feature screen and can render under both layout families.

---

### M2 — Mobile Game Shell

#### M2.1 Mobile shell layers

Create explicit Background, Playfield, HUD, Surface and Overlay ownership with shell-level safe areas.

#### M2.2 Mobile resource header

Implement Money/Income and progressive GC/Essence/Prestige visibility.

Introduce typed updates only where the new HUD needs them.

#### M2.3 Mobile CLICK target

Create dedicated ClickTarget while preserving gameplay mechanics exactly.

Separate mechanical transform from cosmetic feedback.

#### M2.4 Mobile navigation

Implement Shop / Gooberário / Menu primary destinations.

#### M2.5 Event and Combo placement

Move Combo into gameplay presentation and add compact EventStatus.

#### M2.6 Mobile Landscape

Build a distinct landscape composition optimized for limited height.

#### M2 Gate

Phone portrait and landscape are fully playable with the new gameplay shell even if secondary surfaces remain legacy temporarily.

---

### M3 — Large-Screen Game Shell

#### M3.1 Large-Screen shell

Create a distinct shell rather than reusing Mobile geometry.

#### M3.2 Large-Screen HUD

Use wider resource grouping and increased simultaneous context where useful.

#### M3.3 Large-Screen navigation

Present the same primary destinations using an appropriate Large-Screen control.

#### M3.4 Tablet touch profile

Validate large touch targets, touch scroll and no hover dependency.

#### M3.5 Desktop profile

Add focus, hover enhancement, mouse and keyboard semantics.

#### M3.6 LargeCompact

Support narrower desktop/large windows without switching to Mobile.

#### Batch A Gate

- both layout families exist;
- Mobile Portrait/Landscape are deliberate;
- Tablet uses Large-Screen touch profile;
- Desktop uses Large-Screen pointer profile;
- gameplay remains functionally canonical;
- design language remains shared despite layout separation.

---

## 93. Batch B — M4 + M5 + M6

Batch B replaces flat navigation and redesigns the most important surfaces.

### M4 — Navigation & Surface Foundation

#### M4.1 SurfaceRouter core

Add stack-based push/pop/replace/close-all behavior.

#### M4.2 Back contract

Unify Android Back and Desktop Escape semantics.

#### M4.3 Responsive Surface chrome

Implement Quick, Standard, Immersive and Dialog presentation contracts.

#### M4.4 Progression Hub foundation

Build new Hub navigation, initially allowed to bridge to legacy surfaces.

#### M4.5 Legacy compatibility bridge

Explicitly support temporary PanelManager coexistence with removal scheduled after M7 migration.

---

### M5 — Surface Wave 1

#### M5.1 Shop redesign

Upgrade Lanes, affordability explanation and purchase feedback.

#### M5.2 Rich Progression Hub

Progression, Activities, System and Secret Shop sections with meaningful context.

#### M5.3 Prestige information design

Current/next comparison, Essence gain, Reset/Keep structure.

#### M5.4 Prestige dialog

Clear consequential confirmation.

#### M5 Gate

Human visual review before further screens. Fix design-system drift now, not after M7.

---

### M6 — Surface Wave 2

#### M6.1 Gooberário collection grid

Replace table UX with collection-first grid.

#### M6.2 Goober detail

Mobile sequential detail; Large-Screen master-detail.

#### M6.3 Bestiary filters

Basic rarity/discovery filters.

#### M6.4 Achievements redesign

Summary, completion, filters and clearer progress states.

#### M6.5 Missions redesign

Active task cards with canonical auto-claim.

#### Batch B Gate

The design system must now successfully support commerce, progression, collection, master-detail, long progress lists and task cards without losing consistency.

---

## 94. Batch C — M7 + M8 + M9

Batch C completes all major screens, adds game feel, then consolidates architecture based on actual pain revealed by the redesign.

### M7 — Surface Wave 3 & Theme Completion

#### M7.1 Perks redesign

Module/grid presentation without inventing a tree.

#### M7.2 Stats redesign

Structured high-density sections.

#### M7.3 Theme gallery

Visual theme cards/previews.

#### M7.4 Live theme preview

Preview → Apply/Cancel with semantic token runtime.

#### M7.5 Settings

Sound, Reduced Motion, Text Size and Visual Effects.

#### M7.6 Secret Goober Shop redesign

Separate passive upgrades and active skill language.

#### M7.7 Remove legacy panel system

After all surfaces migrate:

- remove compatibility bridge;
- remove PanelManager if unused;
- remove BasePanel if unused;
- remove stale registration/import/test code.

---

### M8 — Game Feel & Presentation

#### M8.1 Feedback foundation

Floating rewards, motion policy, effect quality and presentation layers.

#### M8.2 CLICK feedback

Tactile response, reward feedback and coordinated sound.

#### M8.3 Goober feedback

Spawn, hit, multi-hit, defeat and reward.

#### M8.4 Combo escalation

Presentation intensity ranges and proportional break feedback.

#### M8.5 Purchase and Perk feedback

Make power increase perceptible.

#### M8.6 Event and Skill presentation

Semantic event transitions and Cleanse/Frenzy/Shield/Coinburst feedback.

#### M8.7 PresentationQueue

Priority/lifecycle infrastructure now justified by real competing moments.

#### M8.8 Discovery / Achievement / Mission / Collection

Queue-based reward moments.

#### M8.9 Boss moment

Boss introduction, BossBar and death presentation.

#### M8.10 Prestige moment

Largest normal progression presentation using actual transaction result.

#### M8 Gate

Run a real Android gameplay session and perform a “silence review.” Remove effects where the product became too noisy.

---

### M9 — Architecture Consolidation

M9 is not a mandatory checklist of refactors. Each extraction is reevaluated against actual pain after M7/M8.

Potential slices:

#### M9.1 Main responsibility audit

Identify remaining cross-system responsibilities.

#### M9.2 PointerInputAdapter

Extract shared mouse/touch pointer adaptation if still in Main.

#### M9.3 AutoIncomeManager

Move auto-income timer/lifecycle if still valuable.

#### M9.4 EventRuntimeBridge

Extract cross-system event capability integration if still valuable.

#### M9.5 SessionCoordinator

Own load/offline/resume/autosave lifecycle.

#### M9.6 PrestigeCoordinator

Create only if the final Prestige side-effect flow still justifies it.

#### M9.7 SoundFeedbackBridge

Create only if composition wiring remains noisy.

#### M9.8 Static data extraction

Move theme/perk/collection/synergy definitions only where work already benefits from it.

#### M9.9 Typed-signal cleanup

Audit broad `changed` consumers; retain it where it remains useful.

#### M9.10 Smoke decomposition

Move remaining broad assertions into focused suites while preserving coverage.

#### Batch C Gate

- every major surface is 2.0;
- game feel is coherent rather than noisy;
- transitional panel architecture is gone;
- architecture boundaries reflect demonstrated product needs;
- Main is substantially closer to composition/wiring without arbitrary LOC targets.

---

## 95. Final Isolated Batch — M10

M10 is intentionally isolated. No other milestone is bundled with it.

### M10 — Hardening & Release Candidate

Feature freeze applies.

#### M10.1 Full regression

Run unit/domain/integration/presentation/smoke/save/layout verification.

#### M10.2 Mobile polish

Validate:

- minimum/reference portrait;
- minimum/reference landscape;
- rotation;
- safe area;
- Back;
- background/resume.

#### M10.3 Large-Screen polish

Validate:

- tablet touch;
- 1366×768;
- 1920×1080;
- compact desktop window;
- focus/keyboard/mouse.

#### M10.4 Accessibility pass

Validate text scaling, Reduced Motion, effects quality, semantic color, touch/focus and disabled states.

#### M10.5 Performance pass

Profile real hotspots. Normal Android quality is the primary mobile target.

#### M10.6 Save compatibility pass

Run all golden saves and current round trips.

#### M10.7 30-minute Android soak

Real session covering gameplay, surfaces, rotation, lifecycle, Events, Goobers, Skills and Prestige where practical.

#### M10.8 Visual consistency review

Review all major screens side by side for design drift and cross-platform family consistency.

#### M10.9 Architecture cleanup

Remove only completed migration scaffolding, dead assets/imports and accidental debug leftovers.

No “one last giant refactor.”

#### M10.10 Release Candidate

Only P0–P2 fixes and necessary release polish are accepted during RC freeze.

### M10 Gate

Release Poopy Clicker 2.0 only when:

- existing gameplay behavior is intentionally preserved or documented as changed;
- Mobile and Large-Screen are deliberate separate presentations;
- every major surface uses 2.0 language;
- Themes materially affect presentation;
- CLICK and Goobers feel alive;
- Moments are proportional;
- navigation is coherent;
- accessibility contracts work;
- Android performance is healthy;
- old saves remain valid;
- transitional architecture is removed;
- critical tests pass;
- the entire game feels authored.

---

# PART XI — PROGRAM DISCIPLINE

## 96. Three-Milestone Batch Rule

The user-approved cadence is:

```text
Batch A = 1 + 2 + 3
Batch B = 4 + 5 + 6
Batch C = 7 + 8 + 9
Batch Final = 10 only
```

M0 is preflight, not part of the numbered implementation cadence.

For each batch:

1. write one detailed implementation plan covering the three milestones;
2. preserve milestone/slice ordering inside that plan;
3. implement slice by slice on short-lived branches/commits;
4. run milestone gates before crossing to the next milestone inside the batch;
5. run the batch gate before declaring the batch complete;
6. reassess assumptions before planning the next batch.

This provides large enough planning context for coherent architecture while retaining granular rollback and review.

---

## 97. Dependency Ordering

Critical dependency lines include:

```text
Semantic Tokens
→ GameShells
→ SurfaceRouter
→ Surface Redesign
→ Game Feel
```

```text
Theme Tokens
→ ThemeController
→ Theme Gallery
→ Live Preview
```

```text
SurfaceRouter
→ Goober Detail navigation
```

```text
PresentationQueue
→ final Boss / Prestige Moments
```

A later slice must not build competing infrastructure because an earlier dependency was skipped.

---

## 98. Parallelism

Parallel work is allowed only when units are genuinely independent and shared interfaces are stable.

Good candidates after design-system stabilization may include separate Achievements and Missions work.

Bad candidates include simultaneously rewriting tokens and multiple dependent screens before token APIs settle.

Parallelism must reduce time without multiplying integration uncertainty.

---

## 99. Scope Expansion Policy

During a slice:

- related blocker → fix with evidence;
- related non-blocker → small fix or recorded follow-up;
- unrelated problem → record separately.

No branch becomes a miscellaneous cleanup bucket.

New gameplay ideas during 2.0 go to the Feature Parking Lot unless necessary to fulfill this spec.

---

## 100. Documentation Authority

From this point forward:

- current Godot main + approved 2.x design are product source of truth;
- Python canonical source remains legacy behavioral reference;
- canonical migration specs document parity history;
- this Master Design Spec governs Poopy Clicker 2.0 product direction;
- implementation plans derived from this spec govern execution details for each batch.

If a future implementation plan conflicts with this spec, the conflict must be resolved explicitly rather than silently changing product direction.

---

# PART XII — APPROVED ARCHITECTURE DECISIONS

## ADR-001 — Hybrid visual identity

Dark polished structure with expressive colorful gameplay.

## ADR-002 — Separate Mobile and Large-Screen layout families

Mobile and Desktop/Tablet are not the same layout at different widths.

## ADR-003 — Tablet uses Large-Screen composition with Touch ergonomics

Tablet is closer to Desktop structurally, not an enlarged phone UI.

## ADR-004 — Navigation model shared, navigation widget platform-specific

Shop / Gooberário / Hub hierarchy remains common.

## ADR-005 — Progression Hub replaces flat Menu grid

The Hub communicates what matters now, not merely where systems exist.

## ADR-006 — Gooberário becomes collection-first

Grid + detail replaces table as primary UX.

## ADR-007 — Perks remain modules, not a fabricated skill tree

The UI reflects the actual system.

## ADR-008 — Semantic themes

Themes swap semantic tokens rather than screen-specific colors.

## ADR-009 — GameState remains aggregate root

No fragmentation into many persisted substates without demonstrated need.

## ADR-010 — Main moves toward Composition Root gradually

No big-bang architectural rewrite.

## ADR-011 — Typed signals supplement broad `changed` gradually

No global EventBus.

## ADR-012 — Code-first remains default

Scenes/resources are introduced where they provide concrete value.

## ADR-013 — Refactor follows product pain

Architecture cleanup is interleaved with real product slices.

## ADR-014 — Normal quality is the complete Android experience

High quality adds luxury; Normal is not a degraded design.

## ADR-015 — Evidence before merge

Verification effort scales with risk.

## ADR-016 — Add depth before breadth

2.1 deepens existing systems; 2.2 may add one major new way to play.

## ADR-017 — Implementation batches are 1–3, 4–6, 7–9, then 10 alone

Batching affects planning/execution cadence, not branch granularity.

---

# 101. Final Success Definition

Poopy Clicker 2.0 succeeds when the old and new versions can be placed side by side and the difference is not merely a new skin.

The new product should be:

- easier to understand;
- more satisfying to operate;
- more expressive;
- more consistent;
- more platform-native;
- easier to maintain;
- safer to extend;
- recognizably Poopy Clicker.

The final standard is:

> **The whole game feels authored.**

The project may stay small. The execution should not feel small-minded.
