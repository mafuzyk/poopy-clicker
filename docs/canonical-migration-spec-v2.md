# Poopy Clicker — Godot Canonical Migration Spec V2
## “Big Ahh Peak Edition” — source canônica Cherievamp/poopy-clicker

> **STATUS:** SPEC CANÔNICA V2  
> **OBJETIVO:** migrar a versão MAIS RECENTE conhecida do Poopy Clicker para Godot 4/GDScript, preservar comportamento e conteúdo, corrigir o que já foi portado com base em snapshots antigos e só então continuar expandindo.
>
> **Esta especificação SUBSTITUI a autoridade do documento anterior baseado em `poopy_clicker_ui_achievements_collection_polished.py`.**
>
> O documento anterior continua útil como registro histórico e como referência de intenções, mas **NÃO é mais fonte de verdade para números, raridades, fórmulas, quantidade de conteúdo ou comportamento atual**.

---

# 0. TL;DR PARA O DEEP/OPENCODE

A partir de agora:

```text
FONTE CANÔNICA PRIMÁRIA:
https://github.com/Cherievamp/poopy-clicker

BRANCH CANÔNICA:
main

HEAD observado durante a elaboração desta spec:
1e3f4fb1f5e3744720e72d0cb8b97e9bf00feb33

VERSION observada no código:
1.1.0
```

Você deve:

1. parar de usar o clone Python antigo como fonte primária;
2. clonar `Cherievamp/poopy-clicker` diretamente na HOME;
3. registrar o commit exato clonado;
4. tratar o código atual desse repositório como fonte de verdade;
5. comparar o Godot atual contra essa fonte;
6. reconciliar SOMENTE os sistemas que já foram portados;
7. não implementar 10 subsistemas novos durante a reconciliação;
8. depois seguir um roadmap por slices pequenos;
9. preservar a identidade e a lógica do jogo;
10. NÃO copiar a UI PyQt literalmente;
11. NÃO transformar `main.gd` em outro monólito;
12. NÃO inventar valores quando o repositório canônico já possui os valores reais.

---

# 1. HIERARQUIA DAS FONTES

Quando houver divergência:

```text
1. Código atual de Cherievamp/poopy-clicker @ main
2. Dados/tabelas atuais em constants.py / game_state.py / goober.py / game_window.py
3. Outros módulos atuais do mesmo repositório
4. CHANGELOG/README do mesmo repositório
5. Esta spec V2
6. Spec V1 / poopy_clicker_ui_achievements_collection_polished.py
7. mafuzyk/poopy-clicker antigo
8. Julia-Link/poopy-clicker antigo
```

## Código > CHANGELOG

Já existe divergência comprovada:

- CHANGELOG fala de 18 tipos de Goober;
- o código atual registra 38;
- CHANGELOG descreve uma lista de temas diferente;
- `UI_THEMES` atual é o que realmente executa.

Logo:

```text
CODE > CHANGELOG
```

Se docs e runtime discordarem, preserve o runtime atual e documente.

---

# 2. CLONE CANÔNICO — PRIMEIRA AÇÃO

Se existir:

```text
~/poopy-clicker-python
```

ou outro clone antigo:

**não delete.**

Ele vira histórico e deixa de ser fonte primária.

Clone novo em:

```text
~/poopy-clicker-canonical
```

Procedimento seguro:

```bash
cd ~

if [ -e "$HOME/poopy-clicker-canonical" ]; then
    echo "ERRO: ~/poopy-clicker-canonical já existe."
    echo "Inspecione antes de modificar."
    exit 1
fi

git clone --branch main --single-branch \
  https://github.com/Cherievamp/poopy-clicker.git \
  "$HOME/poopy-clicker-canonical"

cd "$HOME/poopy-clicker-canonical"

git status
git branch --show-current
git rev-parse HEAD
git log -1 --oneline
```

Não atualize esse clone silenciosamente no meio de um slice.

Se precisar sincronizar em outra rodada:

```bash
git fetch origin
git status
git pull --ff-only
git rev-parse HEAD
```

Registre o novo SHA.

---

# 3. O CLONE CANÔNICO É READ-ONLY

Durante a migração:

```text
~/poopy-clicker-canonical
```

é referência.

Não edite, não faça commits e não use como workspace.

Idealmente:

```bash
cd ~/poopy-clicker-canonical
git status
```

deve permanecer clean.

O Godot continua em seu próprio repositório.

---

# 4. MAPA DO REPOSITÓRIO PYTHON ATUAL

```text
poopy_clicker/
├── __init__.py
├── __main__.py
├── assets/
│   ├── Algo.png
│   ├── Goober_idle.webp
│   ├── Goober_run.webp
│   ├── Goober_run_scare.webp
│   ├── Goober_scare.webp
│   ├── music/
│   └── sfx/
├── bestiary.py
├── constants.py
├── events.py
├── game_state.py
├── game_window.py
├── goober.py
├── main.py
├── missions.py
├── particles.py
├── play_area.py
├── save_load.py
└── sound_manager.py
```

Também existem arquivos de distribuição:

```text
CHANGELOG.md
README.md
flake.nix
install.sh
pyproject.toml
setup.iss
.github/workflows/release.yml
```

Esses arquivos de packaging NÃO precisam ser portados literalmente para Godot.

---

# 5. RESPONSABILIDADE DOS MÓDULOS

## `constants.py`

É uma das principais fontes canônicas.

Ler para:

```text
constantes globais
raridades
GOOBER_INFO
EXTRA_GOOBER_DATA
EVENT_INFO
EVENT_RARITY_INFO
UI_THEMES
PRESTIGE_MILESTONES
PERK_DEFS
ACHIEVEMENT_DEFS
COLLECTION_REWARDS
SYNERGY_BONUSES
ACTIVE_SKILLS
DEFAULT_SETTINGS
DEFAULT_PERKS
format_number
```

## `game_state.py`

Fonte para:

```text
estado persistente
economia
click value
auto value
custos
prestige
offline cap
collection multipliers
synergies
save state
load compatibility
achievement evaluation
```

## `game_window.py`

Fonte para o comportamento que conecta tudo:

```text
loop principal
HUD
combo
clique
spawn
event runtime
Goober shop
12 itens da loja secreta
active skills
missions
prestige UI/actions
perk UI/actions
theme shop
settings
offline flow
autosave
save manual
boss integration
menu
notificações
pointer interactions
```

Não copie sua arquitetura. Extraia a semântica.

## `goober.py`

Fonte para:

```text
walk / idle / scare / panic
special Goobers
multi-hit
boss
movement
push
click rewards
event-on-click
angry behavior
HP
animations
```

## `bestiary.py`

Fonte para:

```text
Gooberário
seen/clicked
rarity presentation
collection
collection rewards UI
```

## `events.py`

Hoje representa principalmente o `EventBubble`.

Os dados ficam em `EVENT_INFO`, e a execução principal é conectada em `game_window.py`.

## `missions.py`

Representa principalmente o card visual de missão.

A lógica real deve ser procurada também no `game_window.py`.

## `sound_manager.py`

Fonte para:

```text
SFX
music player
loop
SFX/music volume separado
selected track
toggles
```

## `save_load.py`

Fonte do save Python atual:

```text
atomic write
PCLICKER1 magic
CRC32
XOR 0xC7
Base64
JSON payload
corruption validation
```

---

# 6. PRIMEIRO SLICE V2: RECONCILIAÇÃO CANÔNICA

Antes de Events, Prestige, Boss, Skills etc.:

**audite o que JÁ existe no Godot.**

Sugestão:

```bash
cd ~/storage/shared/Documents/poopy-clicker

git status
git branch --show-current
git log -8 --oneline --decorate

git switch -c refactor/canonical-v1.1-reconciliation
```

Se já houver branch equivalente, permaneça nela.

O slice deve apenas:

```text
comparar
corrigir divergências comprovadas
documentar o resto
```

Não implementar subsistemas enormes.

---

# 7. DIVERGÊNCIA CRÍTICA: DIFICULDADE DO BOTÃO

A spec antiga mandou:

```text
min(24 + 2 * (click + auto), 85)
```

A fonte atual diz:

```python
def get_difficulty_step(self):
    total_upgrades = self.upgrade_level + self.auto_level
    return min(28 + (total_upgrades * 3), 120)
```

Godot deve reconciliar para:

```gdscript
func get_difficulty_step() -> int:
    var total := click_level + auto_level
    return min(28 + total * 3, 120)
```

O repositório atual vence a spec V1.

---

# 8. CONSTANTES BÁSICAS ATUAIS

```text
MAX_GOOBERS = 10
CLICK_SPAWN_THRESHOLD = 15
PASSIVE_SPAWN_INTERVAL_MS = 12000
SECRET_SHOP_UNLOCK_CLICKS = 40
BOSS_SPAWN_CHANCE = 0.05
COSMETIC_COLOR_CHANCE = 0.14
EVENT_CHECK_INTERVAL_MS = 9000
EVENT_TRIGGER_CHANCE = 0.22
AUTO_SAVE_INTERVAL_MS = 60000
```

Godot:

```gdscript
const MAX_GOOBERS := 10
const CLICK_SPAWN_THRESHOLD := 15
const PASSIVE_SPAWN_INTERVAL := 12.0
const SECRET_SHOP_UNLOCK_CLICKS := 40
const BOSS_SPAWN_CHANCE := 0.05
const COSMETIC_COLOR_CHANCE := 0.14
const EVENT_CHECK_INTERVAL := 9.0
const EVENT_TRIGGER_CHANCE := 0.22
const AUTO_SAVE_INTERVAL := 60.0
```

---

# 9. ESTADO CANÔNICO ATUAL

O `GameState` atual representa:

```text
count
upgrade_level
auto_level
goober_clicks_total
goober_coins
poopy_essence
prestige_level
lifetime_money

secret_shop_unlocked

goober_charm_bought
heavy_button_bought
lucky_paws_bought
sneaky_profit_bought
panic_shield_bought
boss_beacon_bought
essence_magnet_bought
mission_radar_bought

cleanse_bought
frenzy_bought
skill_shield_bought
coinburst_bought

unlocked_achievements
selected_ui_theme
owned_ui_themes
bestiary_counts
mission_state
perks
stats
settings
skill_cooldowns
combo_count
combo_multiplier
last_saved_at
```

Godot não precisa usar nomes idênticos, mas precisa suportar o mesmo estado.

---

# 10. STATS IMPORTANTES

Inicializados atualmente:

```text
total_clicks
money_earned
goobers_clicked
rgb_defeated
gold_clicked
angry_clicked
tiny_clicked
giant_clicked
frozen_clicked
bomb_clicked
boss_clicked
normal_clicked
rare_seen
boss_defeated
highest_combo
prestiges_done
offline_earned_total
collection_rewards_claimed
```

Outros critérios atuais usam stats como:

```text
events_seen
offline_seconds
```

Prefira mapas extensíveis.

---

# 11. ECONOMIA CANÔNICA

## Click

Fluxo atual:

```text
2 ^ click_level
× prestige click bonus
× collection money bonus
× economy_click perk
× event multiplier
× synergy click multiplier
```

Pseudo:

```gdscript
func get_click_value(event_mult := 1.0) -> int:
    var base := float(2 ** click_level)
    base *= get_prestige_bonus_click()
    base *= get_collection_money_bonus()

    var perk_mult := 1.0 + perks.get("economy_click", 0) * 0.05
    var synergy_mult := get_synergy_click_mult()

    return int(base * perk_mult * event_mult * synergy_mult)
```

## Auto

```text
auto level 0 => 0
base = 2 ^ (auto_level - 1)
Sneaky Profit => ×1.25
× prestige auto
× collection
× economy_auto perk
× event
× synergy
```

## Custos

```text
click upgrade = 200 × 2 ^ click_level
auto upgrade  = 500 × 2 ^ auto_level
```

---

# 12. PRESTIGE — FÓRMULAS ATUAIS

```text
prestige cost:
max(50000, 250000 * (prestige_level + 1))

click bonus:
1.0 + prestige_level * 0.12

auto bonus:
1.0 + prestige_level * 0.10

essence gain:
int(sqrt(max(0, lifetime_money)) // 120)
+ floor(essence_boost_level / 2)
```

Offline cap:

```text
P < 3  => 4h
P >= 3 => 6h
P >=10 => 10h
```

---

# 13. PRESTIGE RESET POLICY ATUAL

Reseta:

```text
count
lifetime_money
upgrade_level
auto_level
goober_clicks_total
goober_coins
secret_shop_unlocked
8 upgrades passivos da Goober Shop
4 skill unlocks
combo_count
combo_multiplier
mission_state
```

Permanece:

```text
poopy_essence
prestige_level
stats
achievements
bestiary
perks
themes
settings
collection rewards claimed
```

Não espalhe reset por vários managers. Centralize uma policy.

---

# 14. IMPORTANTE: `lifetime_money` NÃO É ETERNO

Apesar do nome:

```text
prestige() zera lifetime_money
```

Já:

```text
stats.money_earned
```

continua acumulado e é usado por achievements.

Não fundir:

```text
count
lifetime_money
money_earned
```

São conceitos diferentes.


---

# 15. PRESTIGE MILESTONES

Fonte atual:

```text
P1  Starter boost
    Missões sobem para 4 slots.

P3  Chaos tuning
    Eventos bons ganham mais peso.

P5  Lucky archive
    Chance extra de raro.

P8  Collectionist
    Bônus de coleção ficam mais fortes.

P10 Endgame prep
    Ganhos offline e bosses melhoram.
```

Implemente o efeito real somente quando o subsystem dependente existir.

---

# 16. 38 GOOBERS — CATÁLOGO CANÔNICO ATUAL

```text
normal
gold
angry
tiny
giant
frozen
bomb
rgb
boss
slime
shadow
candy
crystal
storm
glitch
toxic
magnet
sleepy
speedy
royal
plasma
stone
ghost
lava
clockwork
neon
pirate
angel
devil
moss
prism
voidling
chef
samurai
arcade
bubble
crown
fairy
```

---

# 17. RARIDADES ATUAIS

A V1 estava desatualizada em vários tipos.

Use o `GOOBER_INFO` atual:

```text
normal      common
gold        rare
angry       epic
tiny        epic
giant       epic
frozen      rare
bomb        rare
rgb         mythic
boss        legendary

slime       common
shadow      rare
candy       common
crystal     rare
storm       legendary
glitch      legendary
toxic       epic
magnet      epic
sleepy      rare
speedy      common
royal       legendary
plasma      legendary
stone       common
ghost       epic
lava        legendary
clockwork   epic
neon        rare
pirate      legendary
angel       mythic
devil       mythic
moss        common
prism       mythic
voidling    legendary
chef        rare
samurai     epic
arcade      epic
bubble      common
crown       legendary
fairy       legendary
```

Se `main` futuro mudar, o clone futuro vence.

---

# 18. GOOBER DATA — UMA FONTE DE VERDADE

Não duplicar:

```text
raridade em um arquivo
reward em outro
speed em um terceiro
event em um quarto
```

Crie catálogo central Godot.

Exemplo:

```gdscript
const GOOBERS := {
    "storm": {
        "name": "Storm",
        "rarity": "legendary",
        "money_reward": 3600,
        "coin_reward": 3,
        "click_progress_reward": 3,
        "speed_min": 2,
        "speed_max": 3,
        "size_multiplier": 1.05,
        "normal_push": 10,
        "panic_push": 35,
        "event_on_click": "storm_mode",
    }
}
```

Os números acima são apenas exemplo observado; durante implementação compare diretamente com:

```text
constants.py::GOOBER_INFO
constants.py::EXTRA_GOOBER_DATA
goober.py
```

---

# 19. GOOBER STATE MACHINE

Preserve:

```text
WALK
IDLE
SCARE
PANIC
```

Fluxo:

```text
SPAWN
  ↓
WALK
  ├── random → IDLE → WALK
  └── hit/click
       ↓
      SCARE
       ↓
      PANIC
       ↓
      exit/despawn
```

Multi-hit:

```text
hit
 ↓
hp--
 ↓
hp > 0?
├── sim: feedback e continua vivo
└── não: defeat/reward/panic flow
```

---

# 20. MULTI-HIT DEVE SER GENÉRICO

Não faça:

```text
if RGB...
if Boss...
if Prism...
```

para HP.

Use:

```gdscript
max_hp
hp
```

No catálogo.

Exemplo conhecido:

```text
Prism = 3 hits
RGB/Boss também possuem multi-hit
```

---

# 21. GOOBER MOVEMENT NO GODOT

Não copiar literalmente os timers do PyQt.

Preferir:

```text
_process(delta)
_physics_process(delta)
state_elapsed
manager scheduling
```

Timers continuam válidos quando representam evento discreto.

Evite um timer de 30ms + outro timer + outro timer por cada Goober sem necessidade.

---

# 22. BESTIARY STATE

Modelo:

```gdscript
bestiary_counts[type] = {
    "seen": 0,
    "clicked": 0
}
```

Usos:

```text
Gooberário
Collection
Achievements
Rare seen
Progression
Luck
Money bonus
```

---

# 23. COLLECTION MONEY/LUCK

A fonte atual calcula bonus a partir de rewards já claimed.

Money:

```text
começa em 1.0
+ soma de money_bonus claimed

Prestige >= 8:
fortalece a parte extra em 25%
```

Pseudo:

```gdscript
func get_collection_money_bonus() -> float:
    var bonus := 1.0

    for reward in claimed_rewards:
        bonus += reward.money_bonus

    if prestige_level >= 8:
        bonus = 1.0 + (bonus - 1.0) * 1.25

    return bonus
```

Luck segue mesma filosofia.

---

# 24. 35 EVENTOS CANÔNICOS

A fonte atual define:

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

coin_rain
essence_bloom
boss_hour
moonlight
mirror_world
safe_zone
orbital
overclock
party_mode
```

Total observado:

```text
35
```

---

# 25. EVENT EFFECT VOCABULARY

O Event Manager deve suportar dados como:

```text
click_mult
auto_mult
scale_mult
move_mult

invert_colors
invert_move
gravity
mouse_flee
blink
center_pull
orbit

spawn_bonus
rare_bonus
boss_bonus

special_money_mult
special_coin_bonus
click_coin_bonus
special_essence_bonus

combo_grace
panic_reduce
```

Não criar um `if/elif` de 35 eventos para coisas que são só multiplicadores.

---

# 26. EVENT MANAGER API

Sugestão:

```gdscript
signal event_started(id, definition)
signal event_ended(id)
signal event_progress_changed(ratio)

var active_event_id: StringName
var active_definition: Dictionary
var remaining_seconds := 0.0
var blocked_until := 0.0
```

Queries:

```gdscript
func effect_float(key: StringName, default := 1.0) -> float
func effect_int(key: StringName, default := 0) -> int
func effect_bool(key: StringName) -> bool
```

Uso:

```gdscript
var click_mult := events.effect_float("click_mult", 1.0)
var move_mult := events.effect_float("move_mult", 1.0)

if events.effect_bool("gravity"):
    apply_gravity()
```

---

# 27. RANDOM EVENT FLOW

Base atual:

```text
check a cada 9s
22% chance base
quando events estão permitidos
```

Pseudo:

```gdscript
func try_random_event():
    if has_active_event():
        return

    if skills.events_blocked():
        return

    if randf() >= EVENT_TRIGGER_CHANCE:
        return

    var id := choose_event_using_current_rarity_logic()
    start_event(id)
```

Prestige/perks podem modificar weighting/duração.

Use o Python atual para valores exatos.

---

# 28. GOOBER-TRIGGERED EVENTS

Exemplos atuais:

```text
Storm     -> storm_mode
Glitch    -> glitch_flip
Toxic     -> sticky
Magnet    -> center_pull
Sleepy    -> calm
Plasma    -> hyper_button
Ghost     -> blink
Lava      -> heatwave
Clockwork -> time_dilation
Pirate    -> treasure_tide
Angel     -> blessing
Devil     -> hellrush
Voidling  -> void_window
Chef      -> snack_break
Arcade    -> jackpot_mode
Fairy     -> lucky_wave
```

Leia `EXTRA_GOOBER_DATA` para lista completa.

---

# 29. POINTER/TUCH EVENTS

`mouse_flee` e `blink` foram concebidos em desktop.

Android não possui hover permanente.

Adapte com:

```text
last pointer position
active touch
touch proximity durante interação
```

Não desative a mecânica só por falta de mouse.

---

# 30. 12 ITENS DA GOOBER SHOP — CUSTOS ATUAIS

Fonte atual em `game_window.py::SHOP_ITEM_DEFS`:

```text
Goober Charm      8 GC
Heavy Button     12 GC
Lucky Paws       15 GC
Sneaky Profit    20 GC
Panic Shield     18 GC
Boss Beacon      25 GC
Essence Magnet   22 GC
Mission Radar    18 GC

🧹 Limpeza        30 GC
⚡ Frenesi         40 GC
🛡️ Escudo         35 GC
💰 Explosão       50 GC
```

A spec antiga tinha números diferentes para alguns desses itens.

Use esses valores atuais, salvo alteração futura no clone.

---

# 31. 8 PASSIVOS DA GOOBER SHOP

## Goober Charm

```text
Goobers param/descansam com menor frequência.
```

## Heavy Button

```text
reduz força do push normal.
```

## Lucky Paws

```text
+ moeda extra segundo regra runtime atual.
```

## Sneaky Profit

```text
auto ×1.25
```

## Panic Shield

```text
reduz panic push.
```

## Boss Beacon

UI atual descreve:

```text
+3% boss spawn chance
```

## Essence Magnet

UI atual:

```text
18% chance de Essence extra em Goobers especiais
```

## Mission Radar

Atual:

```text
mission money ×1.2
+1 GC
```

Confirme runtime exato antes de implementar.

---

# 32. 4 ACTIVE SKILLS

## 🧹 Limpeza

```text
key: cleanse
cooldown: 60s

destrói todos os Goobers na tela
ganha o dinheiro deles
```

## ⚡ Frenesi

```text
key: frenzy
cooldown: 90s

2× click por 8s
```

## 🛡️ Escudo

```text
key: skill_shield
cooldown: 75s

cancela event atual
bloqueia novos por 10s
```

## 💰 Explosão

```text
key: coinburst
cooldown: 120s

Goober coins ×3 por 12s
```

---

# 33. SKILL MANAGER

Não coloque cooldown lógico no botão UI.

```gdscript
class SkillManager:
    signal skill_used(id)
    signal cooldown_changed(id, remaining)
    signal effect_started(id)
    signal effect_ended(id)

    var cooldown_until := {}
    var effect_until := {}
```

Pseudo:

```gdscript
func can_use(id: StringName) -> bool:
    return state.is_skill_bought(id) and cooldown_remaining(id) <= 0.0

func use(id: StringName) -> bool:
    if not can_use(id):
        return false

    match id:
        &"cleanse":
            _use_cleanse()
        &"frenzy":
            _start_frenzy()
        &"skill_shield":
            _start_shield()
        &"coinburst":
            _start_coinburst()

    _begin_cooldown(id)
    return true
```

---

# 34. 7 PERKS

```text
economy_click
  +5% click por nível
  base_cost 1
  max 10

economy_auto
  +5% auto por nível
  base_cost 1
  max 10

goober_luck
  raros/capacidade
  base_cost 2
  max 5

boss_hunter
  boss chance/HP/loot
  base_cost 2
  max 5

good_events
  +7% duração de bons events
  base_cost 1
  max 8

bad_events
  -6% duração de maus events
  base_cost 1
  max 8

essence_boost
  melhora Essence
  base_cost 3
  max 3
```

Leia fórmula de custo real antes de implementar purchases.

---

# 35. 6 SYNERGIES

## Muralha

```text
Heavy Button + Panic Shield
=> push reduzido em mais 50%
```

## Império

```text
Sneaky Profit + Lucky Paws
=> +15% Goober money
```

## Caçadora

```text
Boss Beacon + Essence Magnet
=> boss Essence ×2
```

## Visão Total

```text
Mission Radar + Goober Charm
=> missions +5% money e +1 coin
```

## Clique Supremo

```text
click >= 100 e auto >= 100
=> +25% click e auto
```

## Economia Total

```text
economy_click max + economy_auto max
=> +20% click e auto
```

Synergies devem ser derivadas dos requisitos; não salve boolean desnecessário.

---

# 36. 54 ACHIEVEMENTS

A fonte atual contém:

```text
19 base
+ 35 adicionais
= 54
```

Os 6 já portados no Godot continuam válidos como subset.

Não são a lista final.

---

# 37. ACHIEVEMENT IDS

Base:

```text
first_click
hundred_clicks
money_10k
money_1m
normal_25
gold_3
rgb_1
boss_1
boss_5
combo_25
combo_75
missions_10
missions_30
collector_20
hands_on_15
essence_25
prestige_1
prestige_5
goober_40
```

Adicionais:

```text
clicks_1k
clicks_10k
clicks_100k
clicks_1m

money_10m
money_1b
money_1t

angry_5
tiny_5
giant_5
frozen_5
bomb_5

boss_10
boss_25
boss_50

rgb_5
rgb_10

combo_150
combo_300

missions_50
missions_100

collector_30
collector_all
hands_on_25

prestige_10
prestige_25
prestige_50

upgrade_50
upgrade_100

perk_max
shop_all
events_25
events_100
sound_off
offline_10h
```

---

# 38. ACHIEVEMENTS SEM PROXY FALSO

Se dependência não existe:

```text
definição pode ser cadastrada
checker espera dado real
```

Não faça:

```text
boss_50 -> goobers_clicked
```

Não faça:

```text
normal_25 -> total Goober clicks
```

Critério atual:

```text
normal_25 = stats["normal_clicked"] >= 25
```

---

# 39. COLLECTION REWARDS

`COLLECTION_REWARDS` é gameplay.

Cada reward combina:

```text
requirement
money_bonus
luck_bonus
claimed state
```

Não tratar só como medalha visual.

---

# 40. BESTIARY != COLLECTION

```text
Bestiary:
descoberta / seen / clicked / info

Collection:
milestones e bonuses derivados do bestiary
```

Podem compartilhar UI, mas não precisam compartilhar responsabilidade interna.


---

# 41. COMBO SYSTEM

A versão atual mantém:

```text
combo_count
combo_multiplier
stats.highest_combo
decay timer
event combo_grace
```

Procure no `game_window.py`:

```text
click()
reset_combo()
combo_decay_timer
combo multiplier update
highest_combo update
```

No Godot:

```gdscript
class ComboSystem:
    signal changed(count, multiplier)
    signal broken(previous_count)

    var count := 0
    var multiplier := 1.0
    var grace_remaining := 0.0
```

Não copie QTimer literalmente.

---

# 42. MISSIONS

Estado atual:

```text
mission_state = {
    "slots": [],
    "completed_total": 0,
    "rerolls_used": 0
}
```

Dependências importantes:

```text
Prestige 1 -> 4 slots
Mission Radar -> reward boost
Visão Total synergy -> reward boost
Achievements -> completed_total
```

`missions.py` é principalmente UI.

A lógica de geração/progresso/claim deve ser lida no `game_window.py`.

Não invente templates sem consultar o clone.

---

# 43. BOSS

Boss não é apenas um Goober grande.

Depende de:

```text
BOSS_SPAWN_CHANCE
boss_active
HP
multi-hit
loot
Essence
Boss Beacon
Boss Hunter perk
Prestige
boss_hour event
synergies
```

Crie subsystem próprio ou responsabilidade clara dentro de GooberManager.

---

# 44. THEMES — CÓDIGO ATUAL VENCE DOC ANTIGA

`UI_THEMES` observado no código atual:

```text
default
gold
ice
void
candy
matrix
sunset
```

Docs/changelog antigos descrevem outra lista.

Logo:

```text
constants.py atual > changelog
```

Se o clone que Deep baixar possuir outra lista:

use o clone.

---

# 45. SETTINGS CANÔNICAS

`DEFAULT_SETTINGS` atual:

```text
show_floating_text = true
show_particles = true
animate_goobers = true
reduced_motion = false
low_power_mode = false
offline_progress = true
ui_scale = "normal"
onboarding_done = false
sound_enabled = true
music_enabled = true
sfx_volume = 0.7
music_volume = 0.5
selected_music_track = ""
```

Toda opção deve:

```text
ter equivalente Godot
OU
ter decisão explícita de não portar
```

Nada deve desaparecer sem registro.

---

# 46. AUDIO

O Python atual possui `SoundManager`.

Features:

```text
SFX on/off
Music on/off
volume SFX
volume música
track selection
loop automático
scan assets/sfx
scan assets/music
```

Extensões Python aceitas:

```text
.mp3
.ogg
.wav
.flac
.m4a
.wma
```

Godot não precisa garantir cada codec em todas as plataformas.

Mas a feature de music player e controle separado é canônica.

---

# 47. SFX

O repo possui vários arquivos, incluindo exemplos como:

```text
achievement
auto_tick
boss_death
boss_hit
buy
click
click_combo
coin
collection
combo_break
combo_up
essence
event_end
event_start
gold_hit
goober_pop
goober_spawn
...
```

Use os assets atuais como fonte.

Não volte aos GIFs/assets antigos por padrão.

---

# 48. ASSETS GOOBER ATUAIS

A fonte atual usa:

```text
Goober_idle.webp
Goober_run.webp
Goober_scare.webp
Goober_run_scare.webp
```

Inspecione esses assets antes de decidir pipeline Godot.

Possíveis destinos:

```text
AnimatedSprite2D
SpriteFrames
spritesheet
```

Não manter `.gif` antigo apenas porque a primeira migração começou assim.

---

# 49. PARTICLES / FLOATING TEXT

Godot pode fazer melhor que o PyQt.

Pode usar:

```text
GPUParticles2D
CPUParticles2D
Tween
floating Label
```

Mas deve respeitar:

```text
show_particles
show_floating_text
reduced_motion
low_power_mode
```

---

# 50. SAVE PYTHON ATUAL

Pipeline:

```text
state.to_dict()
↓
JSON UTF-8
↓
prefix "PCLICKER1"
↓
CRC32
↓
XOR key 0xC7
↓
Base64
↓
.tmp
↓
atomic os.replace
```

Isso é:

```text
obfuscation + corruption detection
```

não criptografia real.

---

# 51. SAVE GODOT NOVO

Recomendado:

```json
{
  "save_version": 2,
  "source": "godot",
  "game": {},
  "progression": {},
  "collection": {},
  "meta": {},
  "settings": {},
  "timestamps": {}
}
```

Path:

```text
user://save.json
```

O formato interno Godot não precisa reproduzir a Base64/XOR.

---

# 52. LEGACY PYTHON SAVE IMPORT

Como temos o formato real final, deixar arquitetura pronta para import.

Pseudo:

```gdscript
func import_python_save(path: String) -> ImportResult:
    var encoded := FileAccess.get_file_as_bytes(path)
    var obfuscated := Marshalls.base64_to_raw(encoded.get_string_from_utf8())

    var payload := xor_bytes(obfuscated, 0xC7)

    if not validate_magic(payload, "PCLICKER1"):
        return INVALID_MAGIC

    if not validate_crc(payload):
        return INVALID_CHECKSUM

    var json_bytes := strip_magic_and_checksum(payload)
    var data := JSON.parse_string(json_bytes.get_string_from_utf8())

    return migrate_python_state(data)
```

Nunca sobrescrever o save legado original durante import.

---

# 53. SAVE VERSIONING

Use:

```text
save_version
```

e migrations explícitas.

Exemplo:

```gdscript
func migrate_save(data: Dictionary) -> Dictionary:
    var version := int(data.get("save_version", 0))

    while version < CURRENT_SAVE_VERSION:
        match version:
            0:
                data = migrate_v0_to_v1(data)
            1:
                data = migrate_v1_to_v2(data)

        version += 1

    return data
```

---

# 54. SAVE COMPATIBILITY

Carregamento deve tolerar:

```text
chave faltando
chave antiga extra
novo Goober type
novo achievement
nova perk
nova setting
theme inválido
```

Fallbacks seguros.

---

# 55. OFFLINE PROGRESS

Canonical concepts:

```text
last_saved_at
offline_progress setting
offline hours cap
offline_earned_total
offline_seconds
```

Offline cap depende de Prestige.

Nunca payout infinito sem cap.

---

# 56. AUTOSAVE

Atual:

```text
60s
```

Também considerar save após:

```text
prestige
perk purchase
theme purchase
major unlock
manual save
```

Não salvar a cada click.

---

# 57. ARQUITETURA GODOT RECOMENDADA

Direção, não obrigação de criar tudo imediatamente:

```text
scripts/
├── core/
│   ├── game_state.gd
│   ├── game_signals.gd
│   └── game_runtime.gd
│
├── data/
│   ├── goober_catalog.gd
│   ├── event_catalog.gd
│   ├── achievement_catalog.gd
│   ├── perk_catalog.gd
│   ├── skill_catalog.gd
│   └── theme_catalog.gd
│
├── systems/
│   ├── economy.gd
│   ├── combo_system.gd
│   ├── click_controller.gd
│   ├── spawn_system.gd
│   ├── event_manager.gd
│   ├── achievement_manager.gd
│   ├── mission_manager.gd
│   ├── collection_manager.gd
│   ├── prestige_manager.gd
│   ├── perk_manager.gd
│   ├── synergy_manager.gd
│   ├── skill_manager.gd
│   ├── save_manager.gd
│   ├── audio_manager.gd
│   └── settings_manager.gd
│
├── goobers/
│   ├── goober.gd
│   └── goober_manager.gd
│
└── ui/
    ├── hud.gd
    ├── panel_manager.gd
    ├── toast_manager.gd
    ├── event_banner.gd
    └── ...
```

---

# 58. YAGNI

Não criar 25 managers vazios.

Um módulo nasce quando:

```text
possui responsabilidade real
possui dados reais
possui consumidores reais
```

Arquitetura limpa ≠ arquitetura inflada.

---

# 59. MAIN.GD

Responsabilidade:

```text
bootstrap
high-level ownership
wiring
```

Não deve virar:

```text
economia
Goober AI
Events
Missions
Skills
Prestige
Save
UI
Audio
```

tudo em 3 mil linhas.

---

# 60. SIGNAL FLOW

Exemplo:

```text
ClickController
   ↓ manual_click
Economy
Combo
Achievements
Missions
Spawn
ButtonMovement

Goober
   ↓ defeated
GooberManager
   ↓
Rewards
Bestiary
Achievements
Missions
Events
Collection

EventManager
   ↓
HUD
Economy queries
Button queries
Spawn queries

PrestigeManager
   ↓
Reset policy
Mission reset
Shop reset
Save
HUD
```

UI consome estado/sinais.

UI não deve ser dona da lógica.

---

# 61. DATA-DRIVEN

Preferir:

```gdscript
GOOBERS["storm"]
EVENTS["storm_mode"]
ACHIEVEMENTS["boss_50"]
SKILLS["cleanse"]
```

Evitar switch gigante.

Comportamento estrutural especial pode ter handler.

---

# 62. RECONCILIAÇÃO DO GOOBER CATALOG JÁ PORTADO

Comparar com:

```text
constants.py::GOOBER_INFO
constants.py::EXTRA_GOOBER_DATA
goober.py
```

Checklist:

```text
[ ] 38 IDs
[ ] raridade
[ ] money reward
[ ] GC reward
[ ] secret progress
[ ] speed min/max
[ ] size multiplier
[ ] normal push
[ ] panic push
[ ] max HP/hits
[ ] Essence reward
[ ] event_on_click
[ ] behavior tags
[ ] spawn data
```

Corrija só divergências.

---

# 63. RECONCILIAÇÃO DOS ACHIEVEMENTS JÁ PORTADOS

Verificar:

```text
ID
nome
descrição
critério
stat real
unlock once
save
toast
```

Não criar os 54 durante o audit.

---

# 64. RECONCILIAÇÃO DO BUTTON CONTROLLER

Além de:

```text
28 + 3×levels, cap 120
```

comparar:

```text
drift behavior
size progression
event move/scale modifiers
recenter
pointer effects
clamping
```

Não assumir valores V1.

---

# 65. RECONCILIAÇÃO DA ECONOMIA

A API deve conseguir crescer para:

```text
Prestige
Collection
Perks
Events
Synergies
Skills
```

Sem reescrever tudo depois.

---

# 66. RECONCILIAÇÃO DO SAVE

Verifique se estrutura atual consegue futuramente persistir:

```text
54 achievements
38-type bestiary
mission state
prestige
Essence
7 perks
12 shop items
4 skills
themes
settings
stats
collection rewards
```

Use version migration.

---

# 67. ROADMAP APÓS A RECONCILIAÇÃO

## Slice 0

```text
refactor/canonical-v1.1-reconciliation
```

Somente audit/fixes em coisas existentes.

## Slice 1

```text
feat/core-ui-shell
```

se ainda faltar navegabilidade básica.

## Slice 2

```text
feat/combo
```

## Slice 3

```text
feat/goober-shop-passives
```

8 passivos.

## Slice 4

```text
feat/event-core
```

motor.

## Slice 5

```text
feat/canonical-events
```

35 events.

## Slice 6

```text
feat/active-skills
```

4 skills.

## Slice 7

```text
feat/boss
```

## Slice 8

```text
feat/missions
```

## Slice 9

```text
feat/collection-rewards
```

## Slice 10

```text
feat/achievements-full
```

54 quando dependências existirem.

## Slice 11

```text
feat/prestige
```

## Slice 12

```text
feat/perks-synergies
```

## Slice 13

```text
feat/offline-progress
```

## Slice 14

```text
feat/audio
```

## Slice 15

```text
feat/themes-settings
```

## Slice 16

```text
feat/particles-gamefeel-baseline
```

## Slice 17

```text
refactor/ui-redesign
```

**UI final só depois de parity.**

A ordem pode ser ajustada se dependências reais pedirem.

---

# 68. DEPENDENCY GRAPH

```text
GameState
 ├─ Economy
 │   ├─ Click
 │   ├─ Auto
 │   ├─ Combo
 │   └─ Shop
 │
 ├─ Goober Catalog
 │   ├─ Goober Entity
 │   ├─ Spawn
 │   ├─ Bestiary
 │   ├─ Boss
 │   └─ Collection
 │
 ├─ Events
 │   ├─ Goober event-on-click
 │   ├─ Skills/Shield
 │   ├─ Spawn modifiers
 │   ├─ Economy modifiers
 │   └─ Button modifiers
 │
 ├─ Missions
 │   └─ Achievements
 │
 ├─ Prestige
 │   ├─ Essence
 │   ├─ Perks
 │   ├─ Synergies
 │   ├─ Event weighting
 │   └─ Offline cap
 │
 └─ Save
     └─ tudo
```

---

# 69. CORE UI SHELL

Antes da UI bonita:

precisa existir navegação funcional para:

```text
Loja
Goober Shop
Achievements
Gooberário
Missions
Prestige
Perks
Stats
Themes
Settings
Save
```

Subsystem inexistente pode abrir uma shell claramente marcada como pending.

Não fake functionality.

---

# 70. UI DURANTE MIGRAÇÃO

A UI intermediária pode ser neutra.

Mas deve corrigir:

```text
clipping
ilegibilidade
elementos fora da viewport
touch target inviável
debug exposto
navegação sem saída
```

Não fazer redesign autoral final agora.

---

# 71. RESPONSIVIDADE

Viewport de referência atual:

```text
1152×648
```

Suportar:

```text
Android landscape
desktop 16:9
resoluções menores
proporções próximas
safe margins
```

Usar:

```text
Containers
anchors
size flags
minimum sizes
responsive logic
```

Evitar posições mágicas espalhadas.

---

# 72. TOUCH TARGETS

Navegação:

```text
targets confortáveis
```

CLICK button:

é gameplay e pode encolher por design.

Não aumentar hitbox invisível de modo a anular dificuldade.

---

# 73. REDUCED MOTION

Quando ativo:

reduzir:

```text
flash
screen shake
tween exagerado
particle burst
motion decorativo
```

Não remover lógica de gameplay.

---

# 74. LOW POWER MODE

Pode reduzir:

```text
particle count
visual update frequency
decorative animation
```

Não alterar:

```text
RNG
economy
reward
spawn probability
```

---

# 75. ACHIEVEMENT TOAST

Versão atual:

```text
toast in-game
não modal
não rouba foco
```

Preserve.

Crie queue.

Não sobrepor 8 toasts ilegíveis.

---

# 76. EVENT BANNER

Deve mostrar:

```text
nome
descrição
tempo/progresso
```

Sem bloquear gameplay.

---

# 77. MANUAL CPS

Versão atual diferencia:

```text
manual CPS
auto/s
```

Quando auto > 0, HUD pode exibir ambos.

Não usar auto como se fosse manual CPS.

---

# 78. FINAL UI REDESIGN

Só depois da feature parity.

Fases:

```text
information architecture
UX flow
wireframes
design system
HUD
menus
responsive
motion
themes
accessibility
final polish
```

A UI PyQt é inventário funcional, não design target.


---

# 79. ÁUDIO GODOT

API sugerida:

```gdscript
func play_sfx(id: StringName)
func play_music(track_id: String)
func stop_music()
func set_sfx_enabled(value: bool)
func set_music_enabled(value: bool)
func set_sfx_volume(value: float)
func set_music_volume(value: float)
func available_tracks() -> Array
```

Settings controla persistência.

---

# 80. AUTO-UPDATE

A versão Python recente adicionou checker de atualização.

Isso é uma feature de distribuição.

Não portar agora por obrigação.

Marcar como:

```text
product/distribution follow-up
```

Godot terá seu próprio export/update strategy.

---

# 81. PACKAGING LEGACY NÃO É GAMEPLAY

Não migrar:

```text
pip
pyproject.toml
Inno Setup
flake.nix
install.sh
PyInstaller workflow
```

Godot possui pipeline próprio.

---

# 82. GDSCRIPT PRIMEIRO

Não adicionar C++/Rust/GDExtension por moda.

Somente se:

```text
profiling
bottleneck real
binding necessário
```

mostrar necessidade.

10–14 Goobers visíveis não justificam engine nativa custom.

---

# 83. RNG

Preferir manager/RandomNumberGenerator quando ajudar teste.

Dev:

```text
seed determinística opcional
```

Release:

```text
random normal
```

Não alterar spawn weights permanentemente para testar tipos raros.

---

# 84. DEBUG SPAWN

API de desenvolvimento:

```gdscript
goober_manager.spawn_forced("storm")
```

Sem mudar RNG real.

---

# 85. DEBUG EVENT

```gdscript
event_manager.start_for_debug("party_mode")
```

Dev-only.

---

# 86. DEV UI

Controles como:

```text
DEV: gold
DEV: boss
DEV: event
```

devem estar:

```text
hidden by default
behind debug flag
removed/disabled in release
```

---

# 87. CATÁLOGO VALIDATION

Em dev:

```gdscript
func validate_catalogs() -> PackedStringArray:
    var errors := PackedStringArray()

    for id in GOOBERS:
        var e = GOOBERS[id].get("event_on_click", "")
        if e != "" and not EVENTS.has(e):
            errors.append("%s references missing event %s" % [id, e])

    return errors
```

Também validar:

```text
rarity válida
reward >= 0
hits >= 1
speed range válida
achievement dependency
skill key
theme id
```

---

# 88. COUNTS DE SNAPSHOT

No baseline observado desta spec:

```text
38 Goobers
35 Events
54 Achievements
12 Goober Shop items
8 passive shop upgrades
4 active skills
7 perks
6 synergies
```

Temas atuais observados no código:

```text
7 entries
```

Se o clone do Deep mudar:

não force esses números.

Atualize matrix.

---

# 89. BIG NUMBER ALERT — CRÍTICO

Python possui inteiro de precisão arbitrária.

Godot `int` é int64.

A versão atual possui achievements até:

```text
upgrade level 100
```

E economia usa:

```text
2 ^ level
```

Logo:

```text
2^100
```

não cabe em int64.

Isso é uma divergência estrutural Python → Godot.

---

# 90. BIG NUMBER FOLLOW-UP OBRIGATÓRIO

Antes de declarar endgame parity:

analisar estratégia.

Opções:

```text
float64 economy
mantissa+exponent
BigNumber custom
decimal/scientific class
```

Critérios:

```text
comparação
custos
save/load
format_number
click payout
prestige
achievement thresholds
```

Não ignorar overflow.

---

# 91. NÃO CORRER PARA BIGNUMBER AGORA SE EARLY GAME FUNCIONA

Pode manter implementação atual temporariamente.

Mas abrir/documentar:

```text
BLOCKER: endgame integer range compatibility
```

antes de lvl100.

---

# 92. ROUNDING

Python usa `int()` em muitos multiplicadores.

Isso trunca.

Não substituir por `round()` sem motivo.

Quando ordem dos modifiers alterar resultado:

confira runtime canônico.

---

# 93. MODIFIER PIPELINE

Arquitetura deve comportar:

```text
base
→ prestige
→ collection
→ perk
→ event
→ synergy
→ skill
```

A ordem exata deve ser conferida no Python quando houver truncation.

---

# 94. NÃO MUTAR BASE PARA EVENTOS

Ruim:

```gdscript
button_speed *= 2.0
# depois tentar desfazer
```

Bom:

```gdscript
func current_move_mult():
    return event_manager.effect_float("move_mult", 1.0) \
        * skill_manager.move_multiplier()
```

Fim do event remove definition ativa e automaticamente volta a 1.

---

# 95. EVENT CLEANUP TEST

Cada evento deve garantir:

```text
size volta
movement volta
colors voltam
spawn cap volta
rare chance volta
auto/click voltam
pointer behavior para
```

Sem estado fantasma.

---

# 96. UI NÃO É DONA DO GAME STATE

UI:

```text
shop.purchase()
skills.use()
prestige.request()
settings.set()
```

Não:

```gdscript
state.goober_coins -= 20
```

direto num `Button.pressed`.

---

# 97. PURCHASE RESULT

Pode usar:

```gdscript
enum PurchaseResult {
    OK,
    NOT_ENOUGH,
    ALREADY_OWNED,
    LOCKED,
    INVALID
}
```

Isso facilita feedback/UI/teste.

---

# 98. PRESTIGE RESET CENTRALIZADO

Não espalhar:

```text
foo = 0
bar = false
baz = []
```

por UI/manager.

Uma função/policy central deve resetar run state.

---

# 99. ACHIEVEMENT `shop_all`

No código atual:

```text
todos os 12 itens
```

Não apenas 8 passivos.

---

# 100. ACHIEVEMENT `sound_off`

Critério atual usa:

```text
settings.sound_enabled == false
```

Settings change precisa poder disparar achievement evaluation.

---

# 101. ACHIEVEMENT `offline_10h`

É tempo offline acumulado.

Não uma sessão única.

---

# 102. ACHIEVEMENT `collector_all`

Baseline atual:

```text
38 Goober types seen
```

Se catálogo futuro mudar, confira definição atualizada.

---

# 103. PYTHON FIXES RECENTES QUE NÃO DEVEM REGREDIR

Histórico atual cita correções para:

```text
Goober panic/edge oscillation
multi-hit freeze
event durations
dialog close crashes
achievement modal focus
flash-label race
manual CPS
```

Godot deve evitar regressões equivalentes.

---

# 104. MULTI-HIT NÃO DEVE CONGELAR ENTIDADE

Hit:

```text
feedback
hp--
continue
```

Só defeat troca para fluxo de derrota/panic quando apropriado.

---

# 105. GOOBER EDGE

Panic/exiting Goober não deve ficar eternamente rebatendo na borda.

Preserve saída limpa.

---

# 106. MOBILE INPUT

Suportar:

```text
touch
mouse
```

Goober click pode usar:

```text
Area2D.input_event
Control.gui_input
```

conforme arquitetura.

Não depender de `mouse_entered` para uma mecânica necessária no Android.

---

# 107. GODOT ANDROID É RUNTIME TEST

Se Termux não tem Godot CLI:

relatório deve dizer:

```text
Static validation: PASS
Runtime: requires Godot Android
```

Nunca fingir execução.

---

# 108. CACHE GODOT ANDROID

`.godot/` é cache e deve permanecer gitignored.

Se scripts fisicamente existem mas editor não indexa:

```bash
# com Godot fechado
rm -rf .godot
```

e reabrir.

Isso é fix direcionado, não ritual.

Não deletar source `.uid` sem motivo.

---

# 109. CLASS RESOLUTION

Pode usar:

```text
class_name
preload
typed references
```

Não remover typing apenas para silenciar cache bug.

---

# 110. CODE-FIRST UI

Continuar code-first é aceitável.

Mas cenas reutilizáveis também são úteis.

Possíveis:

```text
Goober.tscn
Toast.tscn
MissionCard.tscn
EventBanner.tscn
generic panel
```

Code-first não significa “proibido usar cenas”.

---

# 111. UI FINAL É DECISÃO AUTORAL

Refactors mecânicos/reversíveis podem ser autônomos.

Design final:

```text
propor
mostrar
review
aprovar
implementar
```

Não redesenhar tudo sozinho no meio da parity.

---

# 112. SOURCE MAP V2

Deep deve criar no Godot:

```text
docs/canonical-source-map-v2.md
```

Com:

```text
canonical URL
canonical SHA
canonical version
sync date
module map
feature matrix
Godot status
known divergences
pending systems
```

---

# 113. MARCAR SPEC V1 COMO SUPERSEDED

Se existir:

```text
docs/canonical-migration-spec.md
```

não deletar.

Adicionar topo:

```markdown
> SUPERSEDED: use canonical-migration-spec-v2.md and
> Cherievamp/poopy-clicker as the canonical source.
```

---

# 114. FEATURE MATRIX RECOMENDADA

```markdown
| System | Python source | Canonical status | Godot status | Notes |
|---|---|---|---|---|
| Click | game_state.py/game_window.py | current | ported | reconcile multipliers |
| Combo | game_window.py | current | missing | ... |
| Events | constants.py/game_window.py | current | missing | 35 |
```

---

# 115. GOOBER MATRIX

```markdown
| ID | Rarity | Data ported | Behavior ported | Event dependency | Tested |
```

38 rows.

---

# 116. EVENT MATRIX

```markdown
| Event | Data | Runtime effect | Mobile adaptation | Tested |
```

35 rows.

---

# 117. ACHIEVEMENT MATRIX

```markdown
| ID | Criterion | Dependency | Implemented | Tested |
```

54 rows.

---

# 118. SOURCE READING ORDER

Deep deve ler:

```text
1. CHANGELOG.md        # contexto
2. constants.py        # dados atuais
3. game_state.py       # formulas/state
4. goober.py           # entity behavior
5. game_window.py      # runtime integration
6. bestiary.py
7. missions.py
8. events.py
9. save_load.py
10. sound_manager.py
11. particles.py
```

Mas:

```text
CODE > CHANGELOG
```

---

# 119. COMO LER `game_window.py`

Não tratar 100kB como um bloco.

Mapear funções por domínio:

```text
click
combo
spawn
events
shop
skills
missions
prestige
perks
themes
settings
save/load
offline
menu
audio
boss
```

Registrar nomes/funções relevantes no source map.

---

# 120. DEAD CODE

Não portar automaticamente algo apenas porque existe em arquivo.

Perguntar:

```text
é chamado?
é alcançável?
é usado pelo runtime?
```

Se morto:

documentar como dead/legacy.

---

# 121. BUG ÓBVIO NO PYTHON

Não copiar cegamente.

Relatar:

```text
Observed canonical bug:
Likely intended behavior:
Proposed Godot behavior:
Impact:
```

Se altera balance/design, aguardar decisão.

---

# 122. UI BUG

Pode corrigir sem preservar:

```text
texto cortado
botão fora da tela
dialog apertado
hierarquia ruim
```

Isso não é gameplay canônico.

---

# 123. BALANCE “ESTRANHO”

Não mudar sem consulta.

Pode ser intencional.

---

# 124. GIT RULES

Antes de todo slice:

```bash
git status
git branch --show-current
git log -5 --oneline --decorate
```

Se worktree tiver mudanças preexistentes:

```text
preservar
não resetar
não descartar
```

---

# 125. BRANCHES

Exemplos:

```text
refactor/canonical-v1.1-reconciliation
feat/combo
feat/event-core
feat/canonical-events
feat/active-skills
feat/boss
feat/missions
feat/prestige
```

Nunca trabalhar direto em `main`/`master`.

---

# 126. NÃO FORCE

Proibido sem autorização:

```text
git reset --hard
git clean -fd
git push --force
force ref update
destructive rebase
```

---

# 127. COMMITS

Pequenos e semânticos:

```text
docs: register v1.1 canonical source
fix: align button difficulty with v1.1
fix: reconcile goober rarity metadata
refactor: prepare save schema for current canonical state
```

---

# 128. CANONICAL RECONCILIATION REPORT

Ao terminar primeiro slice:

```text
Canonical source:
Canonical SHA:
Canonical VERSION:

Godot branch:
Godot base commit:

Systems audited:
Divergences found:
Divergences fixed:
Divergences deferred:

Old-spec assumptions invalidated:

Files created:
Files changed:

Static checks:
Godot Android runtime:
Known regressions:
Next recommended slice:
```

---

# 129. REPORT DE CADA SLICE

```text
Branch:
Base commit:
Canonical source SHA:
Commits:

Files created:
Files changed:

Canonical behavior implemented:
Canonical behavior deferred:

Differences from Python:
Reason for each difference:

Static checks:
Runtime test:
Android test required:

Save migration impact:
Known regressions:
Next recommended slice:
```

---

# 130. TEST MATRIX — CORE

```text
[ ] fresh start
[ ] manual click
[ ] auto
[ ] click upgrade
[ ] auto upgrade
[ ] current canonical difficulty
[ ] button movement
[ ] clamp
[ ] save/load
[ ] autosave
```

---

# 131. TEST MATRIX — GOOBERS

```text
[ ] 38 IDs
[ ] rarity matches
[ ] forced spawn
[ ] seen
[ ] clicked
[ ] rewards
[ ] speed
[ ] scale
[ ] push
[ ] multi-hit
[ ] scare
[ ] panic
[ ] clean exit
[ ] event references
[ ] Essence metadata
```

---

# 132. TEST MATRIX — COMBO

```text
[ ] count
[ ] multiplier
[ ] decay
[ ] highest combo
[ ] snack_break grace
[ ] achievement thresholds
```

---

# 133. TEST MATRIX — EVENTS

```text
[ ] 35 definitions
[ ] 9s check
[ ] 22% trigger base
[ ] start
[ ] progress
[ ] end
[ ] full cleanup
[ ] click mult
[ ] auto mult
[ ] scale
[ ] move
[ ] gravity
[ ] inversion
[ ] spawn bonus
[ ] rare bonus
[ ] boss bonus
[ ] pointer/touch effects
[ ] shield blocking
```

---

# 134. TEST MATRIX — SHOP

```text
[ ] 12 items
[ ] current costs
[ ] insufficient GC
[ ] buy once
[ ] persist
[ ] prestige reset
[ ] shop_all achievement
```

---

# 135. TEST MATRIX — SKILLS

```text
[ ] purchase required
[ ] cleanse
[ ] frenzy
[ ] shield
[ ] coinburst
[ ] cooldown
[ ] effect duration
[ ] UI countdown
[ ] prestige reset
```

---

# 136. TEST MATRIX — BOSS

```text
[ ] spawn chance
[ ] one active
[ ] HP
[ ] hit
[ ] defeat
[ ] rewards
[ ] Essence
[ ] Boss Beacon
[ ] Boss Hunter
[ ] boss_hour
[ ] prestige effects
[ ] synergy
```

---

# 137. TEST MATRIX — MISSIONS

```text
[ ] slot generation
[ ] progress
[ ] claim once
[ ] reward
[ ] reroll
[ ] Mission Radar
[ ] Visão Total
[ ] P1 slots
[ ] prestige reset
[ ] achievements
```

---

# 138. TEST MATRIX — PRESTIGE

```text
[ ] cost
[ ] condition
[ ] Essence gain
[ ] level increments
[ ] reset fields
[ ] preserved meta
[ ] missions reset
[ ] shop reset
[ ] skills reset
[ ] perks persist
[ ] bestiary persists
[ ] achievements persist
[ ] themes persist
```

---

# 139. TEST MATRIX — AUDIO/SETTINGS

```text
[ ] SFX on/off
[ ] music on/off
[ ] SFX volume
[ ] music volume
[ ] track select
[ ] loop
[ ] particles
[ ] floating text
[ ] Goober animations
[ ] reduced motion
[ ] low power
[ ] offline toggle
[ ] UI scale
[ ] sound_off achievement
```

---

# 140. TEST MATRIX — SAVE

```text
[ ] fresh save
[ ] reload
[ ] autosave
[ ] manual save
[ ] invalid/corrupt safe
[ ] missing keys
[ ] invalid theme
[ ] bestiary expansion
[ ] achievement expansion
[ ] version migration
[ ] timestamp/offline
```

---

# 141. LEGACY IMPORT TEST

Quando implementado:

```text
[ ] valid PCLICKER1
[ ] invalid Base64
[ ] bad checksum
[ ] bad magic
[ ] state maps correctly
[ ] original remains untouched
```

---

# 142. BIG NUMBER TEST

Antes de endgame:

```text
[ ] lvl 50 click
[ ] lvl 100 click
[ ] lvl 100 auto
[ ] costs
[ ] comparison
[ ] save
[ ] formatting
[ ] achievements
[ ] prestige
```

---

# 143. PARITY NÃO É BUG-FOR-BUG

Preserve:

```text
mechanics
balance
content
observable behavior relevante
```

Pode melhorar:

```text
architecture
crash handling
touch support
race conditions
broken UI
performance
```

---

# 144. DEFINITION OF DONE — PHASE 1

Tudo que a fonte Cherievamp atual possui deve estar:

```text
portado
OU
explicitamente intentionally omitted
```

Nada “esquecido”.

Macro checklist:

```text
[ ] core economy
[ ] moving button
[ ] combo
[ ] 38 Goobers
[ ] 35 Events
[ ] Goober Shop 12 items
[ ] 4 Active Skills
[ ] Boss
[ ] Bestiary
[ ] Collection rewards
[ ] Missions
[ ] 54 Achievements
[ ] Prestige
[ ] Essence
[ ] 7 Perks
[ ] 6 Synergies
[ ] Themes
[ ] Settings
[ ] Save
[ ] Autosave
[ ] Offline progress
[ ] Audio/music/SFX
[ ] Particles/floating text baseline
[ ] usable navigation
```

Auto-update/export podem ser produto/distribuição separado.

---

# 145. PHASE 2 — CLEANUP

Depois de parity:

```text
remove migration shims
consolidate duplicate code
profile
big-number finalization
save migration cleanup
test coverage
```

---

# 146. PHASE 3 — UI/UX REFACTOR TOTAL

Depois da lógica estabilizada:

```text
rethink information hierarchy
progressive disclosure
navigation
HUD
panels
touch
responsive
themes
motion
accessibility
game feel
```

Não maquiar a UI velha.

Redesenhar.

---

# 147. PHASE 4 — CONTEÚDO NOVO

Só aqui:

```text
new Goober behaviors
new Events
new progression
new surprises
new systems
```

Antes disso, consultar canon para não “inventar” algo que já existia.

---

# 148. IDENTIDADE DO POOPY CLICKER

Não é:

```text
click => number
```

É:

```text
click
→ botão foge
→ combo cresce
→ Goobers aparecem
→ Goobers empurram
→ player interage com Goobers
→ Goobers panicam
→ especiais alteram a partida
→ Goober Shop desbloqueia
→ skills entram
→ events bagunçam regras
→ missions/achievements/collection sustentam progress
→ boss aparece
→ prestige/Essence/perks/synergies estendem endgame
```

Portar isso.

---

# 149. PRIMEIRA RESPOSTA ESPERADA DO DEEP APÓS LER

Algo como:

```text
1. Vou inspecionar o Godot repo atual sem editar.
2. Vou clonar Cherievamp/poopy-clicker em ~/poopy-clicker-canonical.
3. Vou registrar HEAD/version.
4. Vou mapear módulos/features.
5. Vou abrir uma branch de reconciliação.
6. Vou comparar somente sistemas já portados.
7. Vou corrigir divergências comprovadas.
8. Vou criar canonical-source-map-v2.md.
9. Não vou iniciar subsistemas novos nesse mesmo slice.
10. Vou exigir runtime no Godot Android antes de considerar concluído.
```

---

# 150. COMANDOS INICIAIS ESPERADOS

Godot:

```bash
cd ~/storage/shared/Documents/poopy-clicker

git status
git branch --show-current
git log -8 --oneline --decorate
```

Canonical:

```bash
cd ~

git clone --branch main --single-branch \
  https://github.com/Cherievamp/poopy-clicker.git \
  ~/poopy-clicker-canonical

cd ~/poopy-clicker-canonical

git status
git branch --show-current
git rev-parse HEAD
git log -5 --oneline --decorate
```

Depois retornar ao Godot repo.

---

# 151. CHECKPOINT ANTES DE EDITAR

Reportar:

```text
Godot current branch:
Godot worktree status:
Canonical HEAD:
Canonical VERSION:
Main divergences found:
Reconciliation scope:
```

Se houver worktree sujo:

não apagar nada.

---

# 152. CHECKPOINT DEPOIS DA RECONCILIAÇÃO

Reportar:

```text
button formula reconciled?
Goober catalog reconciled?
achievement subset reconciled?
save schema reviewed?
old spec marked superseded?
source map V2 created?
Android runtime passed?
```

---

# 153. PROIBIÇÕES

```text
NO force push
NO reset --hard
NO clean -fd
NO deleting old clone
NO deleting user saves
NO direct main edits
NO giant rewrite for cleanliness
NO literal PyQt UI port
NO invented canonical values
NO old spec > current repo
NO fake runtime claims
```

---

# 154. PRINCÍPIO DE QUALIDADE

Código alvo:

```text
modular
data-driven
readable
testable
mobile-aware
save-compatible
easy to extend
```

Sem overengineering acadêmico.

---

# 155. PRINCÍPIO DE PORT

Pergunta:

```text
“O que o jogador observa e quais regras produzem isso?”
```

Não:

```text
“qual GDScript corresponde a esta linha PyQt?”
```

---

# 156. EXEMPLO

Python:

```python
QTimer.singleShot(...)
```

Godot pode usar:

```gdscript
await get_tree().create_timer(...).timeout
```

ou state timers.

Sem tradução 1:1.

---

# 157. SOURCE IS KING

Se em algum momento você pensar:

```text
“acho que era X”
```

pare.

Abra:

```text
~/poopy-clicker-canonical
```

e confira.

---

# 158. HANDOFF / PROMPT MESTRE

> Você está migrando Poopy Clicker para Godot 4/GDScript.
>
> A fonte canônica anterior usada na migração estava incompleta/desatualizada. A partir de agora, a fonte de verdade primária é `https://github.com/Cherievamp/poopy-clicker`, branch `main`.
>
> Antes de qualquer novo desenvolvimento, clone esse repositório em `~/poopy-clicker-canonical`, registre `git rev-parse HEAD` e use o clone como referência read-only. Não delete o clone Python antigo, mas não o use como fonte primária.
>
> O código do repositório canônico vence CHANGELOG, spec V1 e snapshots antigos quando houver divergência.
>
> Faça primeiro uma reconciliação limitada dos sistemas já portados no Godot. Não comece Events, Prestige, Boss, Skills ou outros sistemas grandes durante esse audit.
>
> Crie branch própria antes de editar e preserve qualquer trabalho não commitado.
>
> Mantenha a migração data-driven, modular e apropriada para Godot. Não traduza PyQt linha-a-linha e não copie a UI antiga.
>
> O alvo é feature parity funcional com a versão Python atual, incluindo o catálogo de 38 Goobers, 35 Events, 54 Achievements, 12 itens da Goober Shop, 4 Active Skills, Boss, Missions, Bestiary/Collection, Prestige/Essence, 7 Perks, 6 Synergies, Themes, Settings, Save/Offline e Audio conforme o código canônico.
>
> Sempre consulte os arquivos reais do clone para valores exatos. Se esta spec e o clone discordarem, use o clone e documente.
>
> Testes de runtime devem ser feitos no Godot Android quando Godot CLI não estiver disponível. Nunca diga que testou algo que não executou.
>
> Ao final de cada slice, entregue branch, commits, source SHA, arquivos alterados, comportamento portado, diferenças intencionais, testes, pendências e próximo slice recomendado.

---

# 159. ÚLTIMA REGRA

**Sem mais arqueologia baseada em memória.**

```text
clone
pin SHA
inspect
map
reconcile
port
test
```

Depois de parity:

```text
refactor UI
add genuinely new content
```

Fim.
