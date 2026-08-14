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

var money: int = 0
var lifetime_money: int = 0
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
	changed.emit()


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


func register_goober_click(type_id: String, progress_reward: int, base_coins: int) -> void:
	goober_clicks_total += 1
	goober_click_progress += maxi(0, progress_reward)
	if not secret_shop_unlocked and goober_click_progress >= SECRET_SHOP_UNLOCK_CLICKS:
		secret_shop_unlocked = true
	if secret_shop_unlocked:
		var coins: int = maxi(0, base_coins)
		if lucky_paws_bought and type_id != "normal":
			coins += 1
		goober_coins += coins
	changed.emit()


func register_goober_seen(type_id: String) -> void:
	var entry: Dictionary = bestiary_counts.get(type_id, {"seen": 0, "clicked": 0})
	entry["seen"] = int(entry.get("seen", 0)) + 1
	bestiary_counts[type_id] = entry


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