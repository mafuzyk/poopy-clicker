extends RefCounted

const NORMAL_ID := "normal"

const RARITY_MULTIPLIERS := {
	"common": 1.0,
	"rare": 1.25,
	"epic": 1.6,
	"legendary": 2.1,
	"mythic": 3.0,
}

# Canônico RARITY_SPAWN_WEIGHT (spawn por raridade; luck escala cada peso).
const RARITY_SPAWN_WEIGHT := {
	"common": 1.0, "rare": 0.6, "epic": 0.35, "legendary": 0.15, "mythic": 0.08,
}

# Reservado: usado quando coleção/perks de luck existirem (spec §8).
const RARITY_LUCK_FACTORS := {
	"common": 1.0,
	"rare": 1.2,
	"epic": 1.4,
	"legendary": 1.8,
	"mythic": 2.2,
}

# Todos os 38 tipos habilitados: eventos/boss/essence agora têm subsistemas.
# (Mantido vazio; goobers com event_on_click disparam o evento ao serem derrotados.)
const SPAWN_BLOCKED_REASON := {}

# TEMP: cores provisórias por tipo até o arquivo canônico definir as identidades visuais.
const TYPES := {
	"normal": {"name": "Normal", "rarity": "common", "hp": 1, "money": 0, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.0, "push_normal": 6, "push_panic": 28, "spawn_weight": 0.0, "essence": 0, "event_on_click": ""},
	"gold": {"name": "Gold", "rarity": "rare", "hp": 1, "money": 5000, "gc": 5, "progress": 4, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.12, "push_normal": 7, "push_panic": 30, "spawn_weight": 0.0100, "essence": 0, "event_on_click": "", "color": "ffd700"},
	"angry": {"name": "Angry", "rarity": "epic", "hp": 1, "money": 1500, "gc": 2, "progress": 2, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.0, "push_normal": 10, "push_panic": 34, "spawn_weight": 0.0160, "essence": 0, "event_on_click": "", "color": "ff5544"},
	"tiny": {"name": "Tiny", "rarity": "epic", "hp": 1, "money": 1200, "gc": 2, "progress": 2, "speed_min": 3.0, "speed_max": 4.0, "scale": 0.74, "push_normal": 4, "push_panic": 22, "spawn_weight": 0.0200, "essence": 0, "event_on_click": "", "color": "8fd8ff"},
	"giant": {"name": "Giant", "rarity": "epic", "hp": 1, "money": 7000, "gc": 6, "progress": 5, "speed_min": 1.0, "speed_max": 1.0, "scale": 1.42, "push_normal": 9, "push_panic": 32, "spawn_weight": 0.0080, "color": "b08868", "essence": 0, "event_on_click": ""},
	"frozen": {"name": "Frozen", "rarity": "rare", "hp": 1, "money": 2500, "gc": 3, "progress": 3, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.05, "push_normal": 5, "push_panic": 24, "spawn_weight": 0.0100, "essence": 0, "event_on_click": ""},
	"bomb": {"name": "Bomb", "rarity": "rare", "hp": 1, "money": 3000, "gc": 3, "progress": 3, "speed_min": 2.0, "speed_max": 2.0, "scale": 1.08, "push_normal": 8, "push_panic": 38, "spawn_weight": 0.0100, "essence": 0, "event_on_click": ""},
	"rgb": {"name": "RGB", "rarity": "mythic", "hp": 5, "money": 25000, "gc": 15, "progress": 10, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.45, "push_normal": 8, "push_panic": 36, "spawn_weight": 0.0085, "color": "ffffff", "essence": 0, "event_on_click": ""},
	"boss": {"name": "Boss", "rarity": "legendary", "hp": 18, "money": 60000, "gc": 18, "progress": 20, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.95, "push_normal": 13, "push_panic": 45, "spawn_weight": 0.0, "essence": 1, "event_on_click": ""},
	"slime": {"name": "Slime", "rarity": "common", "hp": 1, "money": 220, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 2.0, "scale": 0.95, "push_normal": 5, "push_panic": 20, "spawn_weight": 0.0240, "color": "8ce08c", "essence": 0, "event_on_click": ""},
	"shadow": {"name": "Shadow", "rarity": "rare", "hp": 1, "money": 1500, "gc": 2, "progress": 2, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.0, "push_normal": 9, "push_panic": 32, "spawn_weight": 0.0120, "color": "666666", "essence": 0, "event_on_click": ""},
	"candy": {"name": "Candy", "rarity": "common", "hp": 1, "money": 480, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.0, "push_normal": 6, "push_panic": 24, "spawn_weight": 0.0220, "color": "ff9ad5", "essence": 0, "event_on_click": ""},
	"crystal": {"name": "Crystal", "rarity": "rare", "hp": 1, "money": 2400, "gc": 3, "progress": 2, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.10, "push_normal": 6, "push_panic": 26, "spawn_weight": 0.0110, "color": "8fe8ef", "essence": 0, "event_on_click": ""},
	"storm": {"name": "Storm", "rarity": "legendary", "hp": 1, "money": 3600, "gc": 3, "progress": 3, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.05, "push_normal": 10, "push_panic": 35, "spawn_weight": 0.0085, "essence": 0, "event_on_click": "storm_mode"},
	"glitch": {"name": "Glitch", "rarity": "legendary", "hp": 1, "money": 4200, "gc": 4, "progress": 3, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.05, "push_normal": 8, "push_panic": 30, "spawn_weight": 0.0075, "essence": 0, "event_on_click": "glitch_flip"},
	"toxic": {"name": "Toxic", "rarity": "epic", "hp": 1, "money": 2100, "gc": 2, "progress": 2, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.02, "push_normal": 7, "push_panic": 27, "spawn_weight": 0.0115, "essence": 0, "event_on_click": "sticky"},
	"magnet": {"name": "Magnet", "rarity": "epic", "hp": 1, "money": 2600, "gc": 3, "progress": 2, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.02, "push_normal": 5, "push_panic": 24, "spawn_weight": 0.0105, "essence": 0, "event_on_click": "center_pull"},
	"sleepy": {"name": "Sleepy", "rarity": "rare", "hp": 1, "money": 260, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 1.0, "scale": 1.08, "push_normal": 3, "push_panic": 15, "spawn_weight": 0.0180, "essence": 0, "event_on_click": "calm"},
	"speedy": {"name": "Speedy", "rarity": "common", "hp": 1, "money": 340, "gc": 1, "progress": 1, "speed_min": 3.0, "speed_max": 4.0, "scale": 0.88, "push_normal": 7, "push_panic": 26, "spawn_weight": 0.0170, "color": "ffe066", "essence": 0, "event_on_click": ""},
	"royal": {"name": "Royal", "rarity": "legendary", "hp": 1, "money": 8000, "gc": 7, "progress": 5, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.18, "push_normal": 7, "push_panic": 28, "spawn_weight": 0.0055, "essence": 1, "event_on_click": ""},
	"plasma": {"name": "Plasma", "rarity": "legendary", "hp": 1, "money": 5200, "gc": 5, "progress": 4, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.10, "push_normal": 9, "push_panic": 32, "spawn_weight": 0.0070, "essence": 0, "event_on_click": "hyper_button"},
	"stone": {"name": "Stone", "rarity": "common", "hp": 1, "money": 650, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 1.0, "scale": 1.18, "push_normal": 4, "push_panic": 16, "spawn_weight": 0.0180, "color": "a8a8a8", "essence": 0, "event_on_click": ""},
	"ghost": {"name": "Ghost", "rarity": "epic", "hp": 1, "money": 3000, "gc": 3, "progress": 2, "speed_min": 1.0, "speed_max": 3.0, "scale": 0.98, "push_normal": 6, "push_panic": 22, "spawn_weight": 0.0100, "essence": 0, "event_on_click": "blink"},
	"lava": {"name": "Lava", "rarity": "legendary", "hp": 1, "money": 6000, "gc": 5, "progress": 4, "speed_min": 2.0, "speed_max": 2.0, "scale": 1.15, "push_normal": 9, "push_panic": 34, "spawn_weight": 0.0075, "essence": 0, "event_on_click": "heatwave"},
	"clockwork": {"name": "Clockwork", "rarity": "epic", "hp": 1, "money": 2800, "gc": 3, "progress": 2, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.0, "push_normal": 5, "push_panic": 22, "spawn_weight": 0.0100, "essence": 0, "event_on_click": "time_dilation"},
	"neon": {"name": "Neon", "rarity": "rare", "hp": 1, "money": 2500, "gc": 2, "progress": 2, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.0, "push_normal": 7, "push_panic": 28, "spawn_weight": 0.0120, "color": "ff5cff", "essence": 0, "event_on_click": ""},
	"pirate": {"name": "Pirate", "rarity": "legendary", "hp": 1, "money": 3600, "gc": 4, "progress": 3, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.08, "push_normal": 8, "push_panic": 30, "spawn_weight": 0.0090, "essence": 0, "event_on_click": "treasure_tide"},
	"angel": {"name": "Angel", "rarity": "mythic", "hp": 1, "money": 7000, "gc": 5, "progress": 4, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.12, "push_normal": 5, "push_panic": 18, "spawn_weight": 0.0045, "essence": 1, "event_on_click": "blessing"},
	"devil": {"name": "Devil", "rarity": "mythic", "hp": 1, "money": 7600, "gc": 6, "progress": 4, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.12, "push_normal": 10, "push_panic": 36, "spawn_weight": 0.0045, "essence": 0, "event_on_click": "hellrush"},
	"moss": {"name": "Moss", "rarity": "common", "hp": 1, "money": 300, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 1.0, "scale": 1.0, "push_normal": 4, "push_panic": 18, "spawn_weight": 0.0200, "color": "7d9b3f", "essence": 0, "event_on_click": ""},
	"prism": {"name": "Prism", "rarity": "mythic", "hp": 3, "money": 12000, "gc": 8, "progress": 5, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.22, "push_normal": 9, "push_panic": 30, "spawn_weight": 0.0038, "essence": 1, "event_on_click": ""},
	"voidling": {"name": "Voidling", "rarity": "legendary", "hp": 1, "money": 9200, "gc": 6, "progress": 4, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.12, "push_normal": 9, "push_panic": 32, "spawn_weight": 0.0048, "essence": 0, "event_on_click": "void_window"},
	"chef": {"name": "Chef", "rarity": "rare", "hp": 1, "money": 420, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.0, "push_normal": 5, "push_panic": 18, "spawn_weight": 0.0190, "essence": 0, "event_on_click": "snack_break"},
	"samurai": {"name": "Samurai", "rarity": "epic", "hp": 1, "money": 4700, "gc": 4, "progress": 3, "speed_min": 2.0, "speed_max": 3.0, "scale": 1.05, "push_normal": 8, "push_panic": 30, "spawn_weight": 0.0078, "color": "c84c6e", "essence": 0, "event_on_click": ""},
	"arcade": {"name": "Arcade", "rarity": "epic", "hp": 1, "money": 2600, "gc": 3, "progress": 2, "speed_min": 2.0, "speed_max": 3.0, "scale": 0.96, "push_normal": 7, "push_panic": 24, "spawn_weight": 0.0100, "essence": 0, "event_on_click": "jackpot_mode"},
	"bubble": {"name": "Bubble", "rarity": "common", "hp": 1, "money": 380, "gc": 1, "progress": 1, "speed_min": 1.0, "speed_max": 2.0, "scale": 0.92, "push_normal": 4, "push_panic": 16, "spawn_weight": 0.0200, "color": "c8ecff", "essence": 0, "event_on_click": ""},
	"crown": {"name": "Crown", "rarity": "legendary", "hp": 1, "money": 9800, "gc": 7, "progress": 5, "speed_min": 1.0, "speed_max": 2.0, "scale": 1.18, "push_normal": 7, "push_panic": 26, "spawn_weight": 0.0040, "essence": 1, "event_on_click": ""},
	"fairy": {"name": "Fairy", "rarity": "legendary", "hp": 1, "money": 3600, "gc": 3, "progress": 3, "speed_min": 2.0, "speed_max": 4.0, "scale": 0.82, "push_normal": 5, "push_panic": 18, "spawn_weight": 0.0080, "essence": 0, "event_on_click": "lucky_wave"},
}

var _enabled_ids: Array[String] = []
var _enabled_weight_total := 0.0
var _canonical_weight_total := 0.0
var _normal_remainder := 0.0


func _init() -> void:
	for id in TYPES:
		var type_data: Dictionary = TYPES[id]
		_canonical_weight_total += float(type_data["spawn_weight"])
		if not SPAWN_BLOCKED_REASON.has(id):
			_enabled_ids.append(id)
			_enabled_weight_total += float(type_data["spawn_weight"])
	_normal_remainder = maxf(0.0, 1.0 - _canonical_weight_total)


func get_type(id: String) -> Dictionary:
	return TYPES.get(id, {})


func get_name(id: String) -> String:
	return String(TYPES.get(id, {}).get("name", id))


func get_rarity_multiplier(rarity: String) -> float:
	return float(RARITY_MULTIPLIERS.get(rarity, 1.0))


func is_enabled(id: String) -> bool:
	return TYPES.has(id) and not SPAWN_BLOCKED_REASON.has(id)


func get_blocked_reason(id: String) -> String:
	return String(SPAWN_BLOCKED_REASON.get(id, ""))


func get_enabled_ids() -> Array[String]:
	return _enabled_ids.duplicate()


# Canônico: seleção de spawn em duas fases — sorteia a raridade pelos pesos
# RARITY_SPAWN_WEIGHT escalados por luck (1 + luck*40*(i+1)), depois escolhe
# uniformemente um candidato habilitado daquela raridade (excluindo boss, que
# tem gate próprio). Rolls < 0 usam randf() real.
func roll_type(luck_bonus: float = 0.0, rarity_roll: float = -1.0, candidate_roll: float = -1.0) -> String:
	var rarities: Array = ["common", "rare", "epic", "legendary", "mythic"]
	var weights: Array = []
	for i in range(rarities.size()):
		var w := float(RARITY_SPAWN_WEIGHT[rarities[i]])
		w *= 1.0 + luck_bonus * 40.0 * float(i + 1)
		weights.append(w)

	var roll := randf() if rarity_roll < 0.0 else rarity_roll
	var chosen := _weighted_pick(rarities, weights, roll)

	var candidates: Array = []
	for id in _enabled_ids:
		if id == "boss":
			continue
		if String(TYPES[id]["rarity"]) == chosen:
			candidates.append(id)
	if candidates.is_empty():
		return NORMAL_ID

	var croll := randf() if candidate_roll < 0.0 else candidate_roll
	return str(candidates[mini(candidates.size() - 1, int(floor(clampf(croll, 0.0, 0.999999) * candidates.size())))])


static func _weighted_pick(rarities: Array, weights: Array, roll: float) -> String:
	var total := 0.0
	for w in weights:
		total += float(w)
	if total <= 0.0:
		return str(rarities[0])
	var target := clampf(roll, 0.0, 1.0) * total
	var cumulative := 0.0
	for i in rarities.size():
		cumulative += float(weights[i])
		if target < cumulative:
			return str(rarities[i])
	return str(rarities[rarities.size() - 1])