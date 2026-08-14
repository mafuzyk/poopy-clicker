extends Node

const GameState = preload("res://scripts/core/game_state.gd")
const GooberCatalog = preload("res://scripts/goobers/goober_catalog.gd")

# Canônico game_window.py make_mission: 17 templates (base + prestige*per).
const MISSION_TEMPLATES := [
	{"key": "clicks", "title": "Spam amigável", "desc": "Faça 60 cliques.", "base": 60, "per": 5, "money": 700, "coins": 2},
	{"key": "money", "title": "Cheirinho de lucro", "desc": "Ganhe dinheiro no total.", "base": 4000, "per": 600, "money": 1500, "coins": 3},
	{"key": "goobers", "title": "Goober patrol", "desc": "Clique goobers especiais.", "base": 5, "per": 1, "money": 2000, "coins": 4},
	{"key": "rare_seen", "title": "Olho clínico", "desc": "Veja goobers raros aparecerem.", "base": 6, "per": 1, "money": 1800, "coins": 2},
	{"key": "boss", "title": "Caça ao boss", "desc": "Derrote 1 boss.", "base": 1, "per": 0, "money": 5000, "coins": 6},
	{"key": "clicks", "title": "Maratona", "desc": "Faça uma sequência longa de cliques.", "base": 140, "per": 10, "money": 2600, "coins": 4},
	{"key": "money", "title": "Boom de caixa", "desc": "Ganhe um grande valor em dinheiro.", "base": 12000, "per": 1000, "money": 4500, "coins": 5},
	{"key": "goobers", "title": "Caçadora variada", "desc": "Clique vários especiais em uma run.", "base": 10, "per": 2, "money": 3200, "coins": 4},
	{"key": "rare_seen", "title": "Radar místico", "desc": "Encontre muitos raros.", "base": 12, "per": 2, "money": 3800, "coins": 4},
	{"key": "money", "title": "Economia girando", "desc": "Faça a run render alto.", "base": 25000, "per": 1500, "money": 7000, "coins": 6},
	{"key": "clicks", "title": "Dedinho turbo", "desc": "Faça muitos cliques rapidamente.", "base": 220, "per": 12, "money": 4200, "coins": 5},
	{"key": "goobers", "title": "Colecionadora", "desc": "Clique muitos goobers especiais.", "base": 18, "per": 2, "money": 5200, "coins": 6},
	{"key": "money", "title": "Fortuna poopy", "desc": "Ganhe muito dinheiro no total.", "base": 50000, "per": 2200, "money": 9000, "coins": 7},
	{"key": "rare_seen", "title": "Visão de raio-x", "desc": "Veja raros sem parar.", "base": 18, "per": 2, "money": 5600, "coins": 5},
	{"key": "boss", "title": "Linha de frente", "desc": "Derrote 2 bosses.", "base": 2, "per": 0, "money": 12000, "coins": 8},
	{"key": "clicks", "title": "Ritmo perfeito", "desc": "Mantenha a mão quente por bastante tempo.", "base": 320, "per": 14, "money": 6800, "coins": 6},
	{"key": "money", "title": "Mercado goober", "desc": "Ganhe muito dinheiro numa run avançada.", "base": 90000, "per": 3000, "money": 13000, "coins": 9},
]

var game_state: GameState
var catalog: GooberCatalog


func setup(state: GameState) -> void:
	game_state = state
	catalog = GooberCatalog.new()


func get_max_mission_slots() -> int:
	var slots := 3
	if game_state.prestige_level >= 1:
		slots += 1
	if game_state.prestige_level >= 6:
		slots += 1
	return slots


func mission_progress_for_key(key: String) -> int:
	match key:
		"clicks":
			return game_state.button_clicks_total
		"money":
			return game_state.get_money_earned_total()
		"goobers":
			var total := 0
			for t in ["gold", "angry", "tiny", "giant", "frozen", "bomb", "rgb"]:
				total += game_state.get_clicked_count(t)
			return total
		"rare_seen":
			var seen := 0
			for t in catalog.TYPES:
				if String(catalog.TYPES[t]["rarity"]) != "common":
					seen += int(game_state.bestiary_counts.get(t, {}).get("seen", 0))
			return seen
		"boss":
			return game_state.get_clicked_count("boss")
	return 0


func make_mission() -> Dictionary:
	var chosen: Dictionary = MISSION_TEMPLATES[randi() % MISSION_TEMPLATES.size()]
	var target := int(chosen["base"]) + game_state.prestige_level * int(chosen["per"])
	var start_value := mission_progress_for_key(str(chosen["key"]))
	var mult := 1.2 if game_state.mission_radar_bought else 1.0
	return {
		"key": str(chosen["key"]),
		"title": str(chosen["title"]),
		"description": str(chosen["desc"]),
		"target": target,
		"progress": 0,
		"start_value": start_value,
		"reward_type": "mixed",
		"reward_money": int(float(chosen["money"]) * mult),
		"reward_coins": int(chosen["coins"]) + (1 if game_state.mission_radar_bought else 0),
		"claimed": false,
	}


func ensure_missions(force: bool = false) -> void:
	var wanted := get_max_mission_slots()
	var raw: Variant = game_state.mission_state.get("slots", [])
	var slots: Array = raw if typeof(raw) == TYPE_ARRAY else []
	if force or slots.is_empty():
		slots = []
		for i in range(wanted):
			slots.append(make_mission())
	else:
		while slots.size() < wanted:
			slots.append(make_mission())
	game_state.mission_state["slots"] = slots


func update_missions() -> void:
	var raw: Variant = game_state.mission_state.get("slots", [])
	var slots: Array = raw if typeof(raw) == TYPE_ARRAY else []
	var completed_count := 0
	var claimed_money := 0
	var claimed_coins := 0

	for mission in slots:
		if bool(mission.get("claimed", false)):
			continue
		var key := str(mission.get("key", ""))
		var start_value := int(mission.get("start_value", 0))
		var current := mission_progress_for_key(key)
		var progress := maxi(0, current - start_value)
		mission["progress"] = mini(progress, int(mission.get("target", 0)))
		if int(mission["progress"]) >= int(mission.get("target", 0)):
			claimed_money += int(mission.get("reward_money", 0))
			claimed_coins += int(mission.get("reward_coins", 0))
			mission["claimed"] = true
			completed_count += 1

	if completed_count == 0:
		return

	if claimed_coins > 0:
		game_state.goober_coins += claimed_coins
	if claimed_money > 0:
		game_state.add_money(claimed_money)
	game_state.mission_state["completed_total"] = int(game_state.mission_state.get("completed_total", 0)) + completed_count
	var remaining: Array = []
	for m in slots:
		if not bool(m.get("claimed", false)):
			remaining.append(m)
	game_state.mission_state["slots"] = remaining
	ensure_missions()
	game_state.changed.emit()
