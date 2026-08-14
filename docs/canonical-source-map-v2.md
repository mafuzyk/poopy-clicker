# Poopy Clicker — Canonical Source Map (Spec V2)

**Status da spec de migração:** o documento `canonical-migration-spec.md` (Spec V1, snapshot poopy_clicker_ui_achievements_collection_polished.py) está **SUPERSEDED** pela Spec V2 (`docs/canonical-migration-spec-v2.md`).

## Fonte canônica

| Item | Valor |
|---|---|
| Repositório | `https://github.com/Cherievamp/poopy-clicker` |
| Branch | `main` |
| Commit | `1e3f4fb1f5e3744720e72d0cb8b97e9bf00feb33` |
| Versão | `1.1.0` (`__init__.py` / constants) |
| Clone local | `~/poopy-clicker-canonical` (worktree limpo) |
| Sync date | 2026-08-12 |
| Linguagem | Python 3 / PyQt6 (referência de comportamento e dados — não de UI) |

> O antigo clone local `~/poopy-clicker-python` (fork `mafuzyk`, versão simplificada) foi descartado junto do legado `poopy clicker.py` monolítico. A fonte de verdade é o repo da conta `Cherievamp`.

## Módulos canônicos (Python) e seu mapa no Godot

| Módulo Python | Conteúdo | Status no Godot | Arquivo Godot |
|---|---|---|---|
| `constants.py` | GOOBER_INFO (38), EXTRA_GOOBER_DATA (29), EVENT_INFO (35), RARITY_INFO, RARITY_SPAWN_WEIGHT, COLLECTION_REWARDS, SYNERGY_BONUSES, ACTIVE_SKILLS, UI_THEMES, PERK_DEFS, ACHIEVEMENT_DEFS (54), DEFAULT_SETTINGS, DEFAULT_PERKS, constantes | Parcial: catálogo de goobers + constantes core reconciliadas | `scripts/goobers/goober_catalog.gd` |
| `goober.py` | Dados dos 9 tipos base (normal, gold, angry, tiny, giant, frozen, bomb, rgb, boss), física, push, cosmético | Parcial (dados reconciliados; física/movimento fora de escopo atual) | `scripts/goobers/goober_manager.gd` (dados via catalog) |
| `game_state.py` | Estado, economia, prestígio, perks, stats, combos, missões | Parcial: subset secret shop + upgrades | `scripts/core/game_state.gd` |
| `game_window.py` | Botão, dificuldade, eventos, spawn | Parcial: dificuldade + área de jogo | `scripts/systems/click_controller.gd` |
| `save_load.py` | Save JSON com versionamento e autosave 60s | Alinhado (schema local com nomes equivalentes) | `scripts/systems/save_manager.gd` |
| `bestiary.py` | Contagem seen/clicked por tipo | Portado | `scripts/core/game_state.gd` + `scripts/ui/bestiary_panel.gd` |
| `missions.py` | Missões com slots/rerolls | NÃO portado | — |
| `events.py` | Eventos ativos com duração | NÃO portado | — |
| `particles.py` | Partículas de toque | NÃO portado | — |
| `sound_manager.py` | Sons/música | NÃO portado | — |
| `play_area.py` | Área de jogo | Portado (conceito) | `scripts/systems/click_controller.gd` |

## Feature matrix

| Feature | Canônico | Godot |
|---|---|---|
| Cliques no botão + dificuldade `28 + upgrades*3` (cap 120) | ✅ | ✅ reconciliado |
| Upgrades click/auto (custos `200*2^n`, `500*2^n`) | ✅ | ✅ |
| Goobers (38 tipos), recompensas/push/hp/essência | ✅ | ✅ dados reconciliados 100% |
| Raridades (RARITY_INFO v2) | ✅ | ✅ reconciliado |
| Spawn (RARITY_SPAWN_WEIGHT / pesos) | ✅ | ⚠ parcial (catalog usa `spawn_weight` sem validar distribuição) |
| Secret shop (5 upgrades) | ✅ | ⚠ parcial: 5 passivos portados |
| Goober Shop (loja goobers) | 12 itens canônicos (8 passivos + 4 active skills) | ⚠ parcial: 5 passivos portados (Goober Charm, Heavy Button, Lucky Paws, Sneaky Profit, Panic Shield); faltam Boss Beacon, Essence Magnet, Mission Radar, Cleanse, Frenzy, Skill Shield, Coinburst |
| Achievements (54 total) | ✅ | ⚠ subset 27 portado |
| Bestiário | ✅ | ✅ |
| Prestígio + essence | ✅ | ❌ |
| Perks | ✅ | ❌ |
| Missões | ✅ | ❌ |
| Eventos ativos | ✅ | ❌ |
| Combo/multiplicador | ✅ | ❌ |
| Coleções/sinergias | ✅ | ❌ |
| Temas UI | ✅ | ❌ |
| Partículas | ✅ | ❌ |
| Som | ✅ | ❌ |
| Offline progress | ✅ | ❌ |
| Save/autosave 60s | ✅ | ✅ (autosave 60s; sem eventos de save pós-compra — pendente) |

## Divergências conhecidas (status: reconciliado)

**Reconciliadas nesta sessão:**
- `goober_catalog.gd` — 16 raridades corrigidas (storm/glitch/plasma/lava/pirate/fairy → legendary; toxic/magnet/ghost/clockwork/arcade → epic; sleepy/chef → rare; angel/devil → mythic). Todos os 38 tipos agora batem campo a campo (money, gc, progress, speed, scale, push, hp, essence) com o canônico via execução real em proot Alpine com PyQt6.
- `goober_catalog.gd` — removidos `event_on_click` inventados (`frozen_blessing`, `bomb_chaos`) que não existem no `EVENT_INFO` canônico.
- `click_controller.gd` — fórmula de dificuldade corrigida para `min(28 + (click_level + auto_level) * 3, 120)` (era `24 + total*2`, cap 85).
- `achievement_manager.gd` — hints alinhados ao canônico; subset expandido de 6 → 27 (viáveis com dados portados: cliques, money acumulado, gold/rgb/boss/angry/tiny/giant/frozen/bomb por tipo, upgrades 50/100).

**Pendentes (sistemas NÃO portados, fora da reconciliação):**
- Achievements que dependem de prestígio/perks/missões/combos/coleções/eventos/som/offline (27 restantes).
- `RARITY_SPAWN_WEIGHT` do canônico (1.0/0.6/0.35/0.15/0.08) não é usado pelo catalog (usa `spawn_weight` por tipo) — validar quando o spawn completo for portado.
- `event_on_click` é tupla `(id, duration, name, desc, color)` no canônico — no Godot só o id é armazenado no catalog; duração/desc/cores do EVENT_INFO a portar junto do sistema de eventos.
- Cores `color` RGBA dos EXTRA_GOOBER_DATA (ex.: slime `(168, 224, 168, 255)`) não aplicadas (catalog usa hex provisórios).
- Boss: `max_hits = 18 + prestige*3 + boss_hunter*2` dinâmico — catalog tem base 18 estática; depende de prestígio/perks.
- Save: falta `last_saved_at` + saves pós-eventos (prestígio/compra/tema/unlock) e offline progress (Spec V2 §55/§56).
- `goober_click_progress` (arena progress) é conceito local; canônico usa `goober_clicks_total` simples para secret shop — validar semântica no port do secret shop.

**Fidelity pending (registrado no slice core-regressions-fidelity):**
- Angry chase behavior (canônico persegue o botão; Godot trata como comum com stats diferentes).
- Progression speed multiplier (se houver no canônico).
- Cosmetic tint chance 14% do `normal` (EXTRA_GOOBER_DATA).
- HP bar de multi-hit (HP > 1 funciona logicamente; sem barra visual).
- Boss: `max_hits = 18 + prestige*3 + boss_hunter*2` — catalog tem base 18 estática; depende de prestígio/perks.
- Essence payout (boss/royal/angel/prism/crown) bloqueado até Prestige.
- `event_on_click` execution — portar apenas os IDs reais do `EVENT_INFO` canônico (storm_mode, glitch_flip, sticky, center_pull, calm, hyper_button, blink, heatwave, time_dilation, treasure_tide, blessing, hellrush, void_window, snack_break, jackpot_mode, lucky_wave) junto do sistema de Events. `frozen_blessing`/`bomb_chaos` NÃO existem no canônico (inventados e removidos acima) — não reintroduzir.
- Stats UI completa (`stats` tem só `money_earned`; `total_clicks`/`goobers_clicked` chegam com stats system).

**Divergência deliberada (adaptação):**
- Aplicação temporal do push: o Python canônico aplica `push_x = vx * push` / `push_y = vy * push` com `push_cooldown = 8` ticks (~240 ms). No Godot, o deslocamento é `velocity * (força atual / 6.0) * delta` contínuo enquanto há contato, preservando a identidade "goober carrega o botão" sem teleporte. Forças e fórmulas de Heavy/Panic são idênticas ao canônico (`max(2, push-3)` / `max(12, push-10)`); apenas a integração temporal difere. Validar o *feel* no Android antes de considerar fidelidade fechada; alinhar o ritmo de push ao canônico se o feel pedir.

## Processo / padrões Godot (Spec V2)

- Sempre registrar o commit canônico ao sincronizar (tabela acima).
- Arquitetura: `core/game_signals.gd` + `core/game_runtime.gd`, `data/*_catalog.gd`, `systems/*_manager.gd`, `ui/*`.
- Cenas reutilizáveis OK (Goober.tscn, Toast.tscn, MissionCard.tscn, EventBanner.tscn, painel genérico).
- UI final é decisão autoral: propor → mostrar → review → aprovar → implementar (sem redesign durante paridade).
- Cache stale do editor: fechar projeto / `rm -rf .godot`; não apagar `.uid`.
- Não copiar UI PyQt literal; não remover tipagem GDScript.