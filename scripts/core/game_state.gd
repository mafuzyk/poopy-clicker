extends RefCounted

signal changed

const SECRET_SHOP_UNLOCK_CLICKS := 40

const GOOBER_CHARM := "charm"
const HEAVY_BUTTON := "heavy"
const LUCKY_PAWS := "lucky"
const SNEAKY_PROFIT := "sneaky"
const PANIC_SHIELD := "panic"

const SECRET_UPGRADE_COSTS := {
	GOOBER_CHARM: 8,
	HEAVY_BUTTON: 12,
	LUCKY_PAWS: 15,
	SNEAKY_PROFIT: 20,
	PANIC_SHIELD: 18,
}

# Canônico constants.py PERK_DEFS: base_cost e max_level exatos.
const PERK_DEFS := [
	{"key": "economy_click", "name": "Economy Click", "desc": "+5% clique por nível", "base_cost": 1, "max_level": 10},
	{"key": "economy_auto", "name": "Economy Auto", "desc": "+5% auto por nível", "base_cost": 1, "max_level": 10},
	{"key": "goober_luck", "name": "Goober Luck", "desc": "Aumenta raros e capacidade", "base_cost": 2, "max_level": 5},
	{"key": "boss_hunter", "name": "Boss Hunter", "desc": "+1% boss, +HP e loot", "base_cost": 2, "max_level": 5},
	{"key": "good_events", "name": "Good Events", "desc": "+7% duração bons eventos", "base_cost": 1, "max_level": 8},
	{"key": "bad_events", "name": "Bad Events", "desc": "-6% duração maus eventos", "base_cost": 1, "max_level": 8},
	{"key": "essence_boost", "name": "Essence Boost", "desc": "Melhora drops de essence", "base_cost": 3, "max_level": 3},
]

const DEFAULT_PERKS := {
	"economy_click": 0, "economy_auto": 0, "goober_luck": 0,
	"boss_hunter": 0, "good_events": 0, "bad_events": 0, "essence_boost": 0,
}

# Canônico COLLECTION_REWARDS (money_bonus/luck_bonus exatos).
const COLLECTION_REWARDS := [
	{"id": "special_seen", "name": "Colecionadora", "desc": "Veja todos os especiais básicos", "money_bonus": 0.04, "luck_bonus": 0.002},
	{"id": "special_clicked", "name": "Mão firme", "desc": "Clique em todos os especiais básicos", "money_bonus": 0.06, "luck_bonus": 0.003},
	{"id": "boss_master", "name": "Mestre dos Boss", "desc": "Derrote 5 bosses", "money_bonus": 0.10, "luck_bonus": 0.004},
	{"id": "collector_20", "name": "Arquivo Vivo", "desc": "Veja 20 tipos", "money_bonus": 0.05, "luck_bonus": 0.002},
	{"id": "hands_on_15", "name": "Mão Certeira", "desc": "Clique em 15 tipos", "money_bonus": 0.07, "luck_bonus": 0.003},
	{"id": "endgame", "name": "Endgame", "desc": "10 bosses, 3 RGB, prestígio 3", "money_bonus": 0.12, "luck_bonus": 0.005},
	{"id": "collector_30", "name": "Bestiário Vivo", "desc": "Veja 30 tipos", "money_bonus": 0.08, "luck_bonus": 0.004},
	{"id": "hands_on_25", "name": "Mão de Mestre", "desc": "Clique em 25 tipos", "money_bonus": 0.10, "luck_bonus": 0.005},
	{"id": "boss_25", "name": "Caça Maior", "desc": "Derrote 25 bosses", "money_bonus": 0.15, "luck_bonus": 0.006},
	{"id": "prestige_10", "name": "Transcendente", "desc": "Prestígio 10+", "money_bonus": 0.10, "luck_bonus": 0.003},
	{"id": "upgrade_master", "name": "Upgrade Total", "desc": "Click e auto level 50", "money_bonus": 0.15, "luck_bonus": 0.005},
]

# Canônico SYNERGY_BONUSES.
const SYNERGY_BONUSES := [
	{"id": "defense", "name": "Muralha", "desc": "Heavy Button + Panic Shield: empurrão reduzido em mais 50%", "click_mult": 0.0, "auto_mult": 0.0, "push_reduce": 0.5},
	{"id": "wealth", "name": "Império", "desc": "Sneaky Profit + Lucky Paws: +15% dinheiro de goobers", "click_mult": 0.0, "auto_mult": 0.0, "goober_money": 0.15},
	{"id": "hunting", "name": "Caçadora", "desc": "Boss Beacon + Essence Magnet: bosses dropam 2x essence", "boss_essence": 2.0},
	{"id": "radar", "name": "Visão Total", "desc": "Mission Radar + Goober Charm: missões rendem mais", "mission_money": 0.05, "mission_coins": 1},
	{"id": "click_master", "name": "Clique Supremo", "desc": "Click e auto level 100: +25% clique e auto", "click_mult": 0.25, "auto_mult": 0.25},
	{"id": "economy", "name": "Economia Total", "desc": "Economy perks no máximo: +20% clique e auto", "click_mult": 0.20, "auto_mult": 0.20},
]

var money: int = 0
var lifetime_money: int = 0
var stats: Dictionary = {"money_earned": 0, "highest_combo": 0, "events_seen": 0, "prestiges_done": 0, "collection_rewards_claimed": []}
var combo_count: int = 0
var combo_multiplier: float = 1.0
var poopy_essence: int = 0
var prestige_level: int = 0
var perks: Dictionary = DEFAULT_PERKS.duplicate()
var click_level: int = 0
var auto_level: int = 0
var goober_clicks_total: int = 0
var goober_click_progress: int = 0
var button_clicks_total: int = 0
var goober_coins: int = 0
var secret_shop_unlocked: bool = false
var bestiary_counts: Dictionary = {}
var goober_charm_bought: bool = false
var heavy_button_bought: bool = false
var lucky_paws_bought: bool = false
var sneaky_profit_bought: bool = false
var panic_shield_bought: bool = false
var boss_beacon_bought: bool = false
var essence_magnet_bought: bool = false
var mission_radar_bought: bool = false
var mission_state: Dictionary = {"slots": [], "completed_total": 0, "rerolls_used": 0}


func add_money(amount: int) -> void:
	if amount == 0:
		return
	money += amount
	lifetime_money += amount
	stats["money_earned"] = int(stats.get("money_earned", 0)) + amount
	changed.emit()


func get_money_earned_total() -> int:
	return int(stats.get("money_earned", 0))


func increment_combo() -> void:
	combo_count += 1
	combo_multiplier = 1.0 + combo_count * 0.05
	if combo_count > int(stats.get("highest_combo", 0)):
		stats["highest_combo"] = combo_count
	changed.emit()


func reset_combo() -> void:
	if combo_count == 0 and combo_multiplier == 1.0:
		return
	combo_count = 0
	combo_multiplier = 1.0
	changed.emit()


func get_combo_multiplier() -> float:
	return combo_multiplier


func get_highest_combo() -> int:
	return int(stats.get("highest_combo", 0))


func register_event_seen() -> void:
	stats["events_seen"] = int(stats.get("events_seen", 0)) + 1
	changed.emit()


func get_events_seen() -> int:
	return int(stats.get("events_seen", 0))


# ---------- Prestige + Essence ----------


func get_prestige_cost() -> int:
	return maxi(50000, 250000 * (prestige_level + 1))


func get_prestige_bonus_click() -> float:
	return 1.0 + float(prestige_level) * 0.12


func get_prestige_bonus_auto() -> float:
	return 1.0 + float(prestige_level) * 0.10


# Canônico: floor(sqrt(max(0, lifetime_money)) / 120) + perk essência // 2.
func calculate_prestige_gain() -> int:
	var base := maxi(0, int(floor(sqrt(float(maxi(0, lifetime_money))) / 120.0)))
	var bonus: int = get_perk_level("essence_boost") / 2
	return maxi(0, base + bonus)


func get_perk_level(key: String) -> int:
	return int(perks.get(key, 0))


func get_perk_definition(key: String) -> Dictionary:
	for def in PERK_DEFS:
		if str(def["key"]) == key:
			return def
	return {}


func get_perk_cost(key: String) -> int:
	var def := get_perk_definition(key)
	if def.is_empty():
		return 0
	return int(def["base_cost"]) * (get_perk_level(key) + 1)


func get_perk_max_level(key: String) -> int:
	return int(get_perk_definition(key).get("max_level", 0))


func is_perk_maxed(key: String) -> bool:
	return get_perk_level(key) >= get_perk_max_level(key)


func try_buy_perk(key: String) -> bool:
	if get_perk_definition(key).is_empty():
		return false
	if is_perk_maxed(key):
		return false
	var cost := get_perk_cost(key)
	if poopy_essence < cost:
		return false
	poopy_essence -= cost
	perks[key] = get_perk_level(key) + 1
	changed.emit()
	return true


# ---------- Coleções + Sinergias ----------


func get_collection_unique_seen() -> int:
	var count := 0
	for type_id in bestiary_counts:
		if int(bestiary_counts[type_id].get("seen", 0)) > 0:
			count += 1
	return count


func get_collection_unique_clicked() -> int:
	var count := 0
	for type_id in bestiary_counts:
		if int(bestiary_counts[type_id].get("clicked", 0)) > 0:
			count += 1
	return count


func _bestiary_clicked(type_id: String) -> int:
	return int(bestiary_counts.get(type_id, {}).get("clicked", 0))


func _special_seen_all() -> bool:
	for t in ["gold", "angry", "tiny", "giant", "frozen", "bomb", "rgb", "boss"]:
		if int(bestiary_counts.get(t, {}).get("seen", 0)) <= 0:
			return false
	return true


func _special_clicked_all() -> bool:
	for t in ["gold", "angry", "tiny", "giant", "frozen", "bomb", "rgb", "boss"]:
		if _bestiary_clicked(t) <= 0:
			return false
	return true


func is_collection_reward_met(id: String) -> bool:
	match id:
		"special_seen":
			return _special_seen_all()
		"special_clicked":
			return _special_clicked_all()
		"boss_master":
			return _bestiary_clicked("boss") >= 5
		"collector_20":
			return get_collection_unique_seen() >= 20
		"hands_on_15":
			return get_collection_unique_clicked() >= 15
		"endgame":
			return _bestiary_clicked("boss") >= 10 and _bestiary_clicked("rgb") >= 3 and prestige_level >= 3
		"collector_30":
			return get_collection_unique_seen() >= 30
		"hands_on_25":
			return get_collection_unique_clicked() >= 25
		"boss_25":
			return _bestiary_clicked("boss") >= 25
		"prestige_10":
			return prestige_level >= 10
		"upgrade_master":
			return click_level >= 50 and auto_level >= 50
	return false


func get_claimed_collection_rewards() -> Array:
	var claimed: Variant = stats.get("collection_rewards_claimed", [])
	return claimed if typeof(claimed) == TYPE_ARRAY else []


func is_collection_reward_claimed(id: String) -> bool:
	return get_claimed_collection_rewards().has(id)


func claim_collection_reward(id: String) -> bool:
	if is_collection_reward_claimed(id) or not is_collection_reward_met(id):
		return false
	var claimed := get_claimed_collection_rewards()
	claimed.append(id)
	stats["collection_rewards_claimed"] = claimed
	changed.emit()
	return true


func get_collection_money_bonus() -> float:
	var bonus := 1.0
	for reward in COLLECTION_REWARDS:
		if is_collection_reward_claimed(str(reward["id"])):
			bonus += float(reward.get("money_bonus", 0.0))
	if prestige_level >= 8:
		bonus = 1.0 + (bonus - 1.0) * 1.25
	return bonus


func get_collection_luck_bonus() -> float:
	var bonus := 0.0
	for reward in COLLECTION_REWARDS:
		if is_collection_reward_claimed(str(reward["id"])):
			bonus += float(reward.get("luck_bonus", 0.0))
	if prestige_level >= 8:
		bonus *= 1.25
	return bonus


func get_active_synergies() -> Array:
	var active: Array = []
	for syn in SYNERGY_BONUSES:
		if is_synergy_active(str(syn["id"])):
			active.append(syn)
	return active


func is_synergy_active(id: String) -> bool:
	match id:
		"defense":
			return heavy_button_bought and panic_shield_bought
		"wealth":
			return sneaky_profit_bought and lucky_paws_bought
		"hunting":
			return boss_beacon_bought and essence_magnet_bought
		"radar":
			return mission_radar_bought and goober_charm_bought
		"click_master":
			return click_level >= 100 and auto_level >= 100
		"economy":
			return get_perk_level("economy_click") >= 10 and get_perk_level("economy_auto") >= 10
	return false


func get_synergy_click_mult() -> float:
	var total := 0.0
	for syn in get_active_synergies():
		total += float(syn.get("click_mult", 0.0))
	return 1.0 + total


func get_synergy_auto_mult() -> float:
	var total := 0.0
	for syn in get_active_synergies():
		total += float(syn.get("auto_mult", 0.0))
	return 1.0 + total


func get_synergy_push_reduce() -> float:
	var total := 0.0
	for syn in get_active_synergies():
		total += float(syn.get("push_reduce", 0.0))
	return 1.0 + total


func get_synergy_goober_money_bonus() -> float:
	var total := 0.0
	for syn in get_active_synergies():
		total += float(syn.get("goober_money", 0.0))
	return total


func can_prestige() -> bool:
	return money >= get_prestige_cost()


func add_poopy_essence(amount: int) -> void:
	if amount <= 0:
		return
	poopy_essence += amount
	changed.emit()


# Transação atômica: nenhuma mutação em falha (zero emissões); sucesso emite
# exatamente um changed e não usa helpers emissores internos.
func try_prestige() -> Dictionary:
	var previous_level := prestige_level
	if not can_prestige():
		return {
			"success": false,
			"essence_gain": 0,
			"previous_level": previous_level,
			"new_level": previous_level,
		}

	var essence_gain := calculate_prestige_gain()

	poopy_essence += essence_gain
	prestige_level += 1
	stats["prestiges_done"] = int(stats.get("prestiges_done", 0)) + 1

	money = 0
	lifetime_money = 0
	click_level = 0
	auto_level = 0
	goober_clicks_total = 0
	goober_click_progress = 0
	goober_coins = 0
	secret_shop_unlocked = false
	goober_charm_bought = false
	heavy_button_bought = false
	lucky_paws_bought = false
	sneaky_profit_bought = false
	panic_shield_bought = false
	combo_count = 0
	combo_multiplier = 1.0

	changed.emit()

	return {
		"success": true,
		"essence_gain": essence_gain,
		"previous_level": previous_level,
		"new_level": prestige_level,
	}


func set_money(value: int) -> void:
	if value == money:
		return
	money = value
	changed.emit()


func level_up_click() -> void:
	click_level += 1
	changed.emit()


func level_up_auto() -> void:
	auto_level += 1
	changed.emit()


func try_buy_click_upgrade(cost: int) -> bool:
	if money < cost:
		return false
	money -= cost
	click_level += 1
	changed.emit()
	return true


func try_buy_auto_upgrade(cost: int) -> bool:
	if money < cost:
		return false
	money -= cost
	auto_level += 1
	changed.emit()
	return true


func register_goober_click(type_id: String, progress_reward: int, base_coins: int, extra_coins: int = 0) -> void:
	goober_clicks_total += 1
	goober_click_progress += maxi(0, progress_reward)
	if not secret_shop_unlocked and goober_click_progress >= SECRET_SHOP_UNLOCK_CLICKS:
		secret_shop_unlocked = true
	if secret_shop_unlocked:
		var coins: int = maxi(0, base_coins)
		coins += prestige_level / 2
		if lucky_paws_bought and type_id != "normal":
			coins += 1
		coins += maxi(0, extra_coins)
		goober_coins += coins
	changed.emit()


func register_goober_seen(type_id: String) -> void:
	var entry: Dictionary = bestiary_counts.get(type_id, {"seen": 0, "clicked": 0})
	entry["seen"] = int(entry.get("seen", 0)) + 1
	bestiary_counts[type_id] = entry
	changed.emit()


func register_goober_defeated(type_id: String) -> void:
	var entry: Dictionary = bestiary_counts.get(type_id, {"seen": 0, "clicked": 0})
	entry["clicked"] = int(entry.get("clicked", 0)) + 1
	bestiary_counts[type_id] = entry


func get_clicked_count(type_id: String) -> int:
	var entry: Dictionary = bestiary_counts.get(type_id, {})
	return int(entry.get("clicked", 0))


func register_button_click() -> void:
	button_clicks_total += 1
	changed.emit()


func get_secret_upgrades_bought_count() -> int:
	var count := 0
	if goober_charm_bought:
		count += 1
	if heavy_button_bought:
		count += 1
	if lucky_paws_bought:
		count += 1
	if sneaky_profit_bought:
		count += 1
	if panic_shield_bought:
		count += 1
	return count


func get_secret_upgrade_cost(upgrade: String) -> int:
	return SECRET_UPGRADE_COSTS[upgrade]


func is_secret_upgrade_bought(upgrade: String) -> bool:
	if upgrade == GOOBER_CHARM:
		return goober_charm_bought
	if upgrade == HEAVY_BUTTON:
		return heavy_button_bought
	if upgrade == LUCKY_PAWS:
		return lucky_paws_bought
	if upgrade == SNEAKY_PROFIT:
		return sneaky_profit_bought
	if upgrade == PANIC_SHIELD:
		return panic_shield_bought
	return false


func try_buy_secret_upgrade(upgrade: String) -> bool:
	var cost: int = get_secret_upgrade_cost(upgrade)
	if is_secret_upgrade_bought(upgrade) or goober_coins < cost:
		return false

	goober_coins -= cost
	if upgrade == GOOBER_CHARM:
		goober_charm_bought = true
	elif upgrade == HEAVY_BUTTON:
		heavy_button_bought = true
	elif upgrade == LUCKY_PAWS:
		lucky_paws_bought = true
	elif upgrade == SNEAKY_PROFIT:
		sneaky_profit_bought = true
	elif upgrade == PANIC_SHIELD:
		panic_shield_bought = true

	changed.emit()
	return true