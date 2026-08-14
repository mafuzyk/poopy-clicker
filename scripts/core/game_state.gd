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

var money: int = 0
var lifetime_money: int = 0
var stats: Dictionary = {"money_earned": 0, "highest_combo": 0, "events_seen": 0, "prestiges_done": 0}
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