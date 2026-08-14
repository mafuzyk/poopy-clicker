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
| `events.py` | Eventos ativos com duração | Event Core portado (motor/lifecycle/catálogo) | `scripts/systems/event_manager.gd` + `scripts/data/event_catalog.gd` |
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
| Achievements (54 total) | ✅ | ⚠ subset 33 portado (27 + 4 combo + 2 events) |
| Bestiário | ✅ | ✅ |
| Prestígio + essence | ✅ | ❌ |
| Perks | ✅ | ❌ |
| Missões | ✅ | ❌ |
| Eventos ativos | ✅ | ✅ 35/35 behaviours (efeitos de rare_bonus/boss_bonus/special_essence_bonus deferidos até spawn-raridade/boss/essence existirem) |
| Combo/multiplicador | ✅ | ✅ (decay 1.8s; sem eventos de grace) |
| Coleções/sinergias | ✅ | ❌ |
| Temas UI | ✅ | ❌ |
| Partículas | ✅ | ❌ |
| Som | ✅ | ❌ |
| Offline progress | ✅ | ❌ |
| Save/autosave 60s | ✅ | ✅ (v3 + migrações v1→v3, autosave 60s; sem eventos de save pós-compra — pendente) |

## Divergências conhecidas (status: reconciliado)

**Reconciliadas nesta sessão:**
- `goober_catalog.gd` — 16 raridades corrigidas (storm/glitch/plasma/lava/pirate/fairy → legendary; toxic/magnet/ghost/clockwork/arcade → epic; sleepy/chef → rare; angel/devil → mythic). Todos os 38 tipos agora batem campo a campo (money, gc, progress, speed, scale, push, hp, essence) com o canônico via execução real em proot Alpine com PyQt6.
- `goober_catalog.gd` — removidos `event_on_click` inventados (`frozen_blessing`, `bomb_chaos`) que não existem no `EVENT_INFO` canônico.
- `click_controller.gd` — fórmula de dificuldade corrigida para `min(28 + (click_level + auto_level) * 3, 120)` (era `24 + total*2`, cap 85).
- `combo_manager.gd` (novo) — Combo portado fiel: `multiplier = 1.0 + combo_count * 0.05`, decay 1.8s single-shot reiniciado a cada clique manual, ganho usa o multiplicador atual e só então `add_combo()`, `stats.highest_combo` nunca reseta, label `"🔥 Combo x{count} ({multiplier:.1f}x)"`. Sem grace de eventos (pronto para `extra_grace_seconds` quando snack_break for portado). Auto loop NÃO alimenta combo (fiel ao canônico).
- `achievement_manager.gd` — hints alinhados ao canônico; subset expandido de 6 → 27 → 31 → 33 (adicionados combo_25/75/150/300 + events_25/100, critério `stats.events_seen`).
- `save_manager.gd` — `save_version` 3 com migração sequencial v1→v2→v3 (v1→v2: `stats.money_earned ← lifetime_money`; v2→v3: `combo_count=0`, `combo_multiplier=1.0`, `stats.highest_combo=0`) + normalização retroativa de campos opcionais de stats (`events_seen` ganha default 0 sem bump de schema).
- `event_catalog.gd` (novo) — 35 EVENT_INFO canônicos exatos (dados completos) + EVENT_RARITY_INFO com pesos 5.0/2.5/1.2/0.5/0.15 e labels Comum/Raro/Épico/Lendário/Mítico.
- `event_manager.gd` (novo) — Event Core: random check a cada 9s com chance 0.22 (`roll > 0.22` retorna), seleção em duas fases (raridade ponderada → candidato uniforme, como `random.choices` + `random.choice` do canônico), um evento ativo por vez (random nunca substitui ativo), lifecycle start/end com timers, `events_seen += 1` no start, API de modifiers (`get_float_modifier`/`get_bool_modifier`) sem expor IDs ao main, `force_start_event` para testes (substituição emite `event_ended` do antigo antes do novo), hooks futuros `triggers_blocked` (Skill Shield) e `rarity_weight_modifiers` (prestige ≥ 3), `get_effective_duration` pronto para perks de duração. Pool random limitado a `CORE_ENABLED_IDS` (7 validados): double_click, double_auto, big_button, tiny_button, chaos, calm, snack_break.
- `event_catalog.gd` (novo) — seleção com pool parcial pesa APENAS raridades com candidatos habilitados (roll nunca cai em raridade sem candidatos e morre em silêncio; corrigido em revisão). Com os 35 habilitados o filtro naturalmente coincide com o canônico — nota: o canônico não tem eventos mythic, então mythic fica fora até existir algum.
- `event_banner.gd` (novo) — UI neutra: título "Nome • Raridade", descrição, barra de progresso (poll 0.15s), cor do evento na borda/barra, mouse_filter IGNORE (não bloqueia touch/click), some sem evento ativo.
- `click_controller.gd` — clamp de posição e centralização usam o tamanho EFETIVO do botão (`size × scale`): big/tiny_button não vazam pelas bordas nem passam por baixo das barras (corrigido em revisão).
- Integrações do Event Core — click: `int(base × event click_mult × combo)`; auto: `int(auto × event auto_mult)` (sem combo, fiel); movimento: `difficulty_step × event move_mult` (fórmula base intacta); escala: `progression_scale × event scale_mult` composto (nunca substitui); combo: `combo_grace` convertido ms → s (`900 ms = 0.9 s` → decay 2.7s no snack_break).
- `feat/canonical-events` — os 28 comportamentos restantes, capability-based (EventManager continua lifecycle-only; main empurra snapshots sem ramificar por ID):
  - Movimento (tick de efeito 260 ms, fiel ao canônico): gravity `drift_y += 16` antes do invert_move `int(-drift × 0.85)`; edge rebound canônico (zona 8 px redireciona drift para dentro — portado junto do movimento base); center_pull lerp 8% por tick; orbit ângulo 0.12/raio 42 com reset no fim; blink 180 px/14%/±55 com roll injetável para teste; mouse_flee range `220 + difficulty*1.5`, strength `28 + min(lifetime/300k, 2.5) + upgrades*0.6` (termo prestige = 0 até existir); sticky jitter ±5x/±3y por clique via adaptador de dados `EventCatalog.derived_capabilities` (única exceção fora de main.gd, documentada).
  - Ponteiro virtual compartilhado (mouse + touch Android) com janela de frescor 800 ms: flee/blink só reagem a ponteiro recente e dentro da área de jogo — adaptação mobile deliberada (canônico assume cursor de desktop).
  - GooberManager snapshot: `spawn_bonus` (cap = MAX_GOOBERS + bonus), `panic_reduce` (`max(1, push - reduce)` antes do clamp), `special_money_mult` só não-normal após o rarity mult, `special_coin_bonus` só não-normal + secret shop, `click_coin_bonus` por clique manual só com secret shop.
  - invert_colors via overlay full-screen com shader SCREEN_TEXTURE, input-transparent, removido no end/replace (não toca na UI provisória; compatível com o redesign futuro).
  - Composite data-driven: storm_mode/glitch_flip/hyper_button/heatwave/time_dilation/blessing/mirror_world/safe_zone/overclock/party_mode funcionam por múltiplos capabilities simultâneos, sem branch de ID.
  - Pool natural = 35/35 habilitados.
- Plumbing deferido (registrado, não simulado): `rare_bonus` (exige port do modelo de spawn por raridade `RARITY_SPAWN_WEIGHT × (1 + luck*40*(i+1))`), `boss_bonus` (boss sem spawn natural no Godot: `spawn_weight 0.0`/bloqueado), `special_essence_bonus` (Essence não existe até Prestige). Valores fluem pelo snapshot e são testados; efeitos de payout/spawn chegam com seus subsistemas.

**Pendentes (sistemas NÃO portados, fora da reconciliação):**
- Achievements que dependem de prestígio/perks/missões/coleções/som/offline (21 restantes).
- Efeitos de evento com subsistema ausente (plumbing já exposto): `rare_bonus` aguarda o modelo de spawn por raridade; `boss_bonus` aguarda spawn natural de boss; `special_essence_bonus` aguarda Essence/Prestige.
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
- Eventos: o canônico mede duração por wall-clock (`time.time()`), pausa não importa no desktop. No Godot, a duração usa `Timer` de cena — o evento NÃO expira com o jogo pausado/background (evita evento "fantasma" ao voltar). Mesma experiência visual; adaptação aceita.
- Eventos: o canônico NÃO persiste evento ativo no save (só `stats.events_seen`). Godot igual: evento ativo morre ao sair; `events_seen` persiste via `stats`.
- Eventos: mouse_flee/blink no canônico assumem cursor de desktop (`QCursor.pos()`). No Godot, um ponteiro virtual compartilhado (mouse + touch) com frescor de 800 ms e exigência de estar dentro da área de jogo — toque velho não faz o botão fugir para sempre. Adaptação mobile deliberada.
- Eventos: raridades sem candidatos habilitados não entram nos pesos de sorteio (correção deliberada de dead roll; com os 35 habilitados o canônico tem 0 eventos mythic e mythic fica fora da roleta).
- invert_colors: overlay full-screen com shader SCREEN_TEXTURE (input-transparent) em vez de re-tematizar a UI — a UI atual é provisória; o visual invertido definitivo vem com o sistema de temas.
- Combo no load: o canônico (PyQt) não persiste o timer — ao carregar, o combo persiste de forma indefinida até o próximo clique/decay. No Godot, após `load()` com `combo_count > 0`, o decay base (1.8s) é reiniciado uma vez (`combo_manager.restart_decay()`), garantindo que o combo ativo expire — o resto do timer (parcial de 1.8s) não é persistido e começa do zero. Fidelidade aceita no slice; revisitar com save de timer se o feel pedir.
- Aplicação temporal do push: o Python canônico aplica `push_x = vx * push` / `push_y = vy * push` com `push_cooldown = 8` ticks (~240 ms). No Godot, o deslocamento é `velocity * (força atual / 6.0) * delta` contínuo enquanto há contato, preservando a identidade "goober carrega o botão" sem teleporte. Forças e fórmulas de Heavy/Panic são idênticas ao canônico (`max(2, push-3)` / `max(12, push-10)`); apenas a integração temporal difere. Validar o *feel* no Android antes de considerar fidelidade fechada; alinhar o ritmo de push ao canônico se o feel pedir.

**Dívida técnica conhecida (desnecessário corrigir agora):**
- `save_manager.load()` aplica os campos via setters, e `set_money()` emite `changed` com estado parcial; a emissão final de `changed` ao término do load é o que garante que consumidores (achievements/painéis) reavaliem só com o estado completo. Nenhum comportamento quebra, mas quando o save crescer (prestige/perks/events/etc.), consolidar em bulk-load: aplicar todos os campos sem emitir `changed` e emitir uma única vez ao final (`_apply_bulk(data)` + `changed.emit()`).

## Processo / padrões Godot (Spec V2)

- Sempre registrar o commit canônico ao sincronizar (tabela acima).
- Arquitetura: `core/game_signals.gd` + `core/game_runtime.gd`, `data/*_catalog.gd`, `systems/*_manager.gd`, `ui/*`.
- Cenas reutilizáveis OK (Goober.tscn, Toast.tscn, MissionCard.tscn, EventBanner.tscn, painel genérico).
- UI final é decisão autoral: propor → mostrar → review → aprovar → implementar (sem redesign durante paridade).
- Cache stale do editor: fechar projeto / `rm -rf .godot`; não apagar `.uid`.
- Não copiar UI PyQt literal; não remover tipagem GDScript.