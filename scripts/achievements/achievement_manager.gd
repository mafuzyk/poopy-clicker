extends RefCounted

const GameState = preload("res://scripts/core/game_state.gd")

signal unlocked(id: String)

const DEFINITIONS := {
	"first_click": {"name": "Primeiro passo", "hint": "Faça 1 clique e dê início ao caos."},
	"hundred_clicks": {"name": "Clicadora nata", "hint": "Faça 100 cliques."},
	"money_10k": {"name": "Dinheiruda", "hint": "Ganhe $10K no total."},
	"money_1m": {"name": "Economia paralela", "hint": "Ganhe $1M ao longo das runs."},
	"money_10m": {"name": "Milhonária", "hint": "Ganhe $10M no total."},
	"money_1b": {"name": "Bilionária", "hint": "Ganhe $1B no total."},
	"money_1t": {"name": "Trilhonária", "hint": "Ganhe $1T no total."},
	"clicks_1k": {"name": "Dedos ágeis", "hint": "Faça 1.000 cliques."},
	"clicks_10k": {"name": "Mão turbinada", "hint": "Faça 10.000 cliques."},
	"clicks_100k": {"name": "Clicadora implacável", "hint": "Faça 100.000 cliques."},
	"clicks_1m": {"name": "Lenda dos cliques", "hint": "Faça 1.000.000 de cliques."},
	"normal_25": {"name": "Amiga dos goobers", "hint": "Clique 25 goobers normais."},
	"gold_3": {"name": "Caça-ouro", "hint": "Clique 3 goobers gold."},
	"rgb_1": {"name": "Lenda RGB", "hint": "Derrote 1 goober RGB."},
	"rgb_5": {"name": "Arco-íris mortal", "hint": "Derrote 5 RGB goobers."},
	"rgb_10": {"name": "Prisma destruído", "hint": "Derrote 10 RGB goobers."},
	"boss_1": {"name": "Boss hunter", "hint": "Derrote 1 boss."},
	"boss_5": {"name": "Predadora de chefes", "hint": "Derrote 5 bosses."},
	"boss_10": {"name": "Caça-troféus", "hint": "Derrote 10 bosses."},
	"angry_5": {"name": "Rivais", "hint": "Clique 5 angry goobers."},
	"tiny_5": {"name": "Pequenina", "hint": "Clique 5 tiny goobers."},
	"giant_5": {"name": "Gigantona", "hint": "Clique 5 giant goobers."},
	"frozen_5": {"name": "Coração gelado", "hint": "Clique 5 frozen goobers."},
	"bomb_5": {"name": "Desarmadora", "hint": "Clique 5 bomb goobers."},
	"upgrade_50": {"name": "Upgradeira", "hint": "Tenha um upgrade no nível 50."},
	"upgrade_100": {"name": "Upgrade supremo", "hint": "Tenha um upgrade no nível 100."},
	"goober_40": {"name": "Segredo revelado", "hint": "Desbloqueie a loja goobers."},
	"combo_25": {"name": "Flow state", "hint": "Chegue a combo x25."},
	"combo_75": {"name": "Mão impossível", "hint": "Chegue a combo x75."},
	"combo_150": {"name": "Incontrolável", "hint": "Chegue a combo x150."},
	"combo_300": {"name": "Deusa do ritmo", "hint": "Chegue a combo x300."},
	"events_25": {"name": "Eventeira", "hint": "Presencie 25 eventos."},
	"events_100": {"name": "Caos programado", "hint": "Presencie 100 eventos."},
	"essence_25": {"name": "Cheiro de meta", "hint": "Junte 25 poopy essence."},
	"prestige_1": {"name": "Essência poopy", "hint": "Faça 1 prestígio."},
	"prestige_5": {"name": "Recomeço afiado", "hint": "Chegue ao prestígio 5."},
	"prestige_10": {"name": "Renascida", "hint": "Chegue ao prestígio 10."},
	"prestige_25": {"name": "Fênix", "hint": "Chegue ao prestígio 25."},
	"prestige_50": {"name": "Imortal", "hint": "Chegue ao prestígio 50."},
	"missions_10": {"name": "Trabalhadora do mês", "hint": "Complete 10 missões."},
	"missions_30": {"name": "Painel limpo", "hint": "Complete 30 missões."},
	"missions_50": {"name": "Meta cumprida", "hint": "Complete 50 missões."},
	"missions_100": {"name": "Missões infinitas", "hint": "Complete 100 missões."},
	"collector_20": {"name": "Arquivo vivo", "hint": "Veja 20 tipos diferentes de goober."},
	"collector_30": {"name": "Arquivo completo", "hint": "Veja 30 tipos de goober."},
	"collector_all": {"name": "Enciclopédia viva", "hint": "Veja todos os 38 tipos de goober."},
	"hands_on_15": {"name": "Mão certeira", "hint": "Clique em 15 tipos diferentes de goober."},
	"hands_on_25": {"name": "Mão de vaca", "hint": "Clique em 25 tipos."},
	"perk_max": {"name": "Mestre das perks", "hint": "Tenha uma perk no nível máximo."},
	"shop_all": {"name": "Colecionadora GC", "hint": "Compre todos os itens da loja."},
}

var game_state: GameState
var unlocked_ids: Array[String] = []


func setup(state: GameState) -> void:
	game_state = state
	game_state.changed.connect(evaluate)


func get_unlocked_ids() -> Array[String]:
	return unlocked_ids.duplicate()


func set_unlocked_ids(ids: Array) -> void:
	unlocked_ids.clear()
	for id in ids:
		var id_text: String = str(id)
		if get_definition(id_text) != {} and not unlocked_ids.has(id_text):
			unlocked_ids.append(id_text)


func get_definition(id: String) -> Dictionary:
	return DEFINITIONS.get(id, {})


func is_unlocked(id: String) -> bool:
	return unlocked_ids.has(id)


func get_progress(id: String) -> Vector2i:
	if id == "first_click":
		return Vector2i(game_state.button_clicks_total, 1)
	if id == "hundred_clicks":
		return Vector2i(game_state.button_clicks_total, 100)
	if id == "clicks_1k":
		return Vector2i(game_state.button_clicks_total, 1000)
	if id == "clicks_10k":
		return Vector2i(game_state.button_clicks_total, 10000)
	if id == "clicks_100k":
		return Vector2i(game_state.button_clicks_total, 100000)
	if id == "clicks_1m":
		return Vector2i(game_state.button_clicks_total, 1000000)
	if id == "money_10k":
		return Vector2i(game_state.get_money_earned_total(), 10000)
	if id == "money_1m":
		return Vector2i(game_state.get_money_earned_total(), 1000000)
	if id == "money_10m":
		return Vector2i(game_state.get_money_earned_total(), 10000000)
	if id == "money_1b":
		return Vector2i(game_state.get_money_earned_total(), 1000000000)
	if id == "money_1t":
		return Vector2i(game_state.get_money_earned_total(), 1000000000000)
	if id == "normal_25":
		return Vector2i(game_state.get_clicked_count("normal"), 25)
	if id == "gold_3":
		return Vector2i(game_state.get_clicked_count("gold"), 3)
	if id == "rgb_1":
		return Vector2i(game_state.get_clicked_count("rgb"), 1)
	if id == "rgb_5":
		return Vector2i(game_state.get_clicked_count("rgb"), 5)
	if id == "rgb_10":
		return Vector2i(game_state.get_clicked_count("rgb"), 10)
	if id == "boss_1":
		return Vector2i(game_state.get_clicked_count("boss"), 1)
	if id == "boss_5":
		return Vector2i(game_state.get_clicked_count("boss"), 5)
	if id == "boss_10":
		return Vector2i(game_state.get_clicked_count("boss"), 10)
	if id == "angry_5":
		return Vector2i(game_state.get_clicked_count("angry"), 5)
	if id == "tiny_5":
		return Vector2i(game_state.get_clicked_count("tiny"), 5)
	if id == "giant_5":
		return Vector2i(game_state.get_clicked_count("giant"), 5)
	if id == "frozen_5":
		return Vector2i(game_state.get_clicked_count("frozen"), 5)
	if id == "bomb_5":
		return Vector2i(game_state.get_clicked_count("bomb"), 5)
	if id == "upgrade_50":
		return Vector2i(maxi(game_state.click_level, game_state.auto_level), 50)
	if id == "upgrade_100":
		return Vector2i(maxi(game_state.click_level, game_state.auto_level), 100)
	if id == "goober_40":
		return Vector2i(1 if game_state.secret_shop_unlocked else 0, 1)
	if id == "combo_25":
		return Vector2i(game_state.get_highest_combo(), 25)
	if id == "combo_75":
		return Vector2i(game_state.get_highest_combo(), 75)
	if id == "combo_150":
		return Vector2i(game_state.get_highest_combo(), 150)
	if id == "combo_300":
		return Vector2i(game_state.get_highest_combo(), 300)
	if id == "events_25":
		return Vector2i(game_state.get_events_seen(), 25)
	if id == "events_100":
		return Vector2i(game_state.get_events_seen(), 100)
	if id == "essence_25":
		return Vector2i(game_state.poopy_essence, 25)
	if id == "prestige_1":
		return Vector2i(game_state.prestige_level, 1)
	if id == "prestige_5":
		return Vector2i(game_state.prestige_level, 5)
	if id == "prestige_10":
		return Vector2i(game_state.prestige_level, 10)
	if id == "prestige_25":
		return Vector2i(game_state.prestige_level, 25)
	if id == "prestige_50":
		return Vector2i(game_state.prestige_level, 50)
	if id == "missions_10":
		return Vector2i(int(game_state.mission_state.get("completed_total", 0)), 10)
	if id == "missions_30":
		return Vector2i(int(game_state.mission_state.get("completed_total", 0)), 30)
	if id == "missions_50":
		return Vector2i(int(game_state.mission_state.get("completed_total", 0)), 50)
	if id == "missions_100":
		return Vector2i(int(game_state.mission_state.get("completed_total", 0)), 100)
	if id == "collector_20":
		return Vector2i(game_state.get_collection_unique_seen(), 20)
	if id == "collector_30":
		return Vector2i(game_state.get_collection_unique_seen(), 30)
	if id == "collector_all":
		return Vector2i(game_state.get_collection_unique_seen(), 38)
	if id == "hands_on_15":
		return Vector2i(game_state.get_collection_unique_clicked(), 15)
	if id == "hands_on_25":
		return Vector2i(game_state.get_collection_unique_clicked(), 25)
	if id == "perk_max":
		return Vector2i(1 if game_state.has_maxed_perk() else 0, 1)
	if id == "shop_all":
		return Vector2i(game_state.get_secret_upgrades_bought_count(), 12)
	return Vector2i(-1, -1)


func evaluate() -> void:
	for id in DEFINITIONS.keys():
		if is_unlocked(id):
			continue
		if not _is_met(id):
			continue
		unlocked_ids.append(id)
		unlocked.emit(id)


func _is_met(id: String) -> bool:
	if id == "first_click":
		return game_state.button_clicks_total >= 1
	if id == "hundred_clicks":
		return game_state.button_clicks_total >= 100
	if id == "clicks_1k":
		return game_state.button_clicks_total >= 1000
	if id == "clicks_10k":
		return game_state.button_clicks_total >= 10000
	if id == "clicks_100k":
		return game_state.button_clicks_total >= 100000
	if id == "clicks_1m":
		return game_state.button_clicks_total >= 1000000
	if id == "money_10k":
		return game_state.get_money_earned_total() >= 10000
	if id == "money_1m":
		return game_state.get_money_earned_total() >= 1000000
	if id == "money_10m":
		return game_state.get_money_earned_total() >= 10000000
	if id == "money_1b":
		return game_state.get_money_earned_total() >= 1000000000
	if id == "money_1t":
		return game_state.get_money_earned_total() >= 1000000000000
	# Canônico: conta apenas goobers do tipo "normal" derrotados (bestiário por tipo).
	if id == "normal_25":
		return game_state.get_clicked_count("normal") >= 25
	if id == "gold_3":
		return game_state.get_clicked_count("gold") >= 3
	if id == "rgb_1":
		return game_state.get_clicked_count("rgb") >= 1
	if id == "rgb_5":
		return game_state.get_clicked_count("rgb") >= 5
	if id == "rgb_10":
		return game_state.get_clicked_count("rgb") >= 10
	if id == "boss_1":
		return game_state.get_clicked_count("boss") >= 1
	if id == "boss_5":
		return game_state.get_clicked_count("boss") >= 5
	if id == "boss_10":
		return game_state.get_clicked_count("boss") >= 10
	if id == "angry_5":
		return game_state.get_clicked_count("angry") >= 5
	if id == "tiny_5":
		return game_state.get_clicked_count("tiny") >= 5
	if id == "giant_5":
		return game_state.get_clicked_count("giant") >= 5
	if id == "frozen_5":
		return game_state.get_clicked_count("frozen") >= 5
	if id == "bomb_5":
		return game_state.get_clicked_count("bomb") >= 5
	if id == "upgrade_50":
		return game_state.click_level >= 50 or game_state.auto_level >= 50
	if id == "upgrade_100":
		return game_state.click_level >= 100 or game_state.auto_level >= 100
	if id == "goober_40":
		return game_state.secret_shop_unlocked
	if id == "combo_25":
		return game_state.get_highest_combo() >= 25
	if id == "combo_75":
		return game_state.get_highest_combo() >= 75
	if id == "combo_150":
		return game_state.get_highest_combo() >= 150
	if id == "combo_300":
		return game_state.get_highest_combo() >= 300
	if id == "events_25":
		return game_state.get_events_seen() >= 25
	if id == "events_100":
		return game_state.get_events_seen() >= 100
	if id == "essence_25":
		return game_state.poopy_essence >= 25
	if id == "prestige_1":
		return game_state.prestige_level >= 1
	if id == "prestige_5":
		return game_state.prestige_level >= 5
	if id == "prestige_10":
		return game_state.prestige_level >= 10
	if id == "prestige_25":
		return game_state.prestige_level >= 25
	if id == "prestige_50":
		return game_state.prestige_level >= 50
	if id == "missions_10":
		return int(game_state.mission_state.get("completed_total", 0)) >= 10
	if id == "missions_30":
		return int(game_state.mission_state.get("completed_total", 0)) >= 30
	if id == "missions_50":
		return int(game_state.mission_state.get("completed_total", 0)) >= 50
	if id == "missions_100":
		return int(game_state.mission_state.get("completed_total", 0)) >= 100
	if id == "collector_20":
		return game_state.get_collection_unique_seen() >= 20
	if id == "collector_30":
		return game_state.get_collection_unique_seen() >= 30
	if id == "collector_all":
		return game_state.get_collection_unique_seen() >= 38
	if id == "hands_on_15":
		return game_state.get_collection_unique_clicked() >= 15
	if id == "hands_on_25":
		return game_state.get_collection_unique_clicked() >= 25
	if id == "perk_max":
		return game_state.has_maxed_perk()
	if id == "shop_all":
		return game_state.get_secret_upgrades_bought_count() >= 12
	return false