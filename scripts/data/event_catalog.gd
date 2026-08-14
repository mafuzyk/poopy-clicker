extends RefCounted

# Raridades de eventos: pesos e labels EXATOS do canônico (constants.py EVENT_RARITY_INFO).
const RARITY_INFO := {
	"common": {"label": "Comum", "color": "#d9d9d9", "weight": 5.0},
	"rare": {"label": "Raro", "color": "#76d7ff", "weight": 2.5},
	"epic": {"label": "Épico", "color": "#c792ea", "weight": 1.2},
	"legendary": {"label": "Lendário", "color": "#ffcf66", "weight": 0.5},
	"mythic": {"label": "Mítico", "color": "#ff66ff", "weight": 0.15},
}

# 35 EVENT_INFO canônicos (dados completos; comportamentos portados em slices futuros).
const EVENT_INFO := {
	"double_click": {"good": true, "name": "2x click", "rarity": "rare", "desc": "Seus cliques valem o dobro por alguns segundos.", "duration": 8, "color": "#a5ff90", "click_mult": 2.0},
	"double_auto": {"good": true, "name": "2x auto", "rarity": "rare", "desc": "Seu auto click fica dobrado temporariamente.", "duration": 8, "color": "#9cf6ff", "auto_mult": 2.0},
	"big_button": {"good": true, "name": "Botão maior", "rarity": "common", "desc": "O botão fica maior e mais fácil de clicar.", "duration": 7, "color": "#fff199", "scale_mult": 1.22},
	"tiny_button": {"good": false, "name": "Botão menor", "rarity": "common", "desc": "O botão fica menor e mais difícil de clicar.", "duration": 6, "color": "#ffb3b3", "scale_mult": 0.78},
	"chaos": {"good": false, "name": "Caos", "rarity": "rare", "desc": "O botão se move bem mais do que o normal.", "duration": 7, "color": "#ff9f43", "move_mult": 1.35},
	"calm": {"good": true, "name": "Calmaria", "rarity": "common", "desc": "O botão se move menos por um tempo.", "duration": 7, "color": "#b8ffcf", "move_mult": 0.65},
	"invert_colors": {"good": false, "name": "Cores invertidas", "rarity": "epic", "desc": "A interface muda temporariamente para um visual invertido limpo.", "duration": 6, "color": "#fca5ff", "invert_colors": true},
	"invert_move": {"good": false, "name": "Inversão", "rarity": "rare", "desc": "O movimento do botão fica estranho e invertido, mas controlável.", "duration": 6, "color": "#c9b6ff", "invert_move": true},
	"gravity": {"good": false, "name": "Gravidade", "rarity": "rare", "desc": "O botão tende a cair para baixo.", "duration": 7, "color": "#8cb4ff", "gravity": true},
	"sticky": {"good": false, "name": "Grudento", "rarity": "common", "desc": "O botão quase não se move.", "duration": 6, "color": "#c4ff9a", "move_mult": 0.35},
	"frenzy": {"good": true, "name": "Frenesi", "rarity": "epic", "desc": "Mais goobers podem surgir durante o evento.", "duration": 8, "color": "#ffda7a", "spawn_bonus": 4},
	"mouse_flee": {"name": "Fujão", "rarity": "legendary", "desc": "O botão tenta fugir do mouse.", "duration": 7, "color": "#ff8cc6", "mouse_flee": true},
	"blink": {"name": "Pisca-pisca", "rarity": "legendary", "desc": "O botão teleporta de leve quando você chega perto.", "duration": 6, "color": "#9fb8ff", "blink": true},
	"storm_mode": {"good": false, "name": "Storm mode", "rarity": "epic", "desc": "Vento e gravidade bagunçam o botão ao mesmo tempo.", "duration": 7, "color": "#9fb8ff", "move_mult": 1.25, "gravity": true},
	"glitch_flip": {"good": false, "name": "Glitch flip", "rarity": "epic", "desc": "O botão alterna movimentos esquisitos, mas sem quebrar o controle.", "duration": 6, "color": "#ff9de6", "invert_move": true, "blink": true},
	"center_pull": {"name": "Center pull", "rarity": "rare", "desc": "O botão tenta voltar ao centro da tela.", "duration": 7, "color": "#ffd166", "center_pull": true},
	"hyper_button": {"name": "Hyper button", "rarity": "epic", "desc": "O botão cresce e ganha energia.", "duration": 7, "color": "#76d7ff", "scale_mult": 1.18, "move_mult": 1.12},
	"heatwave": {"good": false, "name": "Heatwave", "rarity": "epic", "desc": "A tela entra num calor caótico com o botão mais arisco.", "duration": 7, "color": "#ff9f43", "move_mult": 1.45, "mouse_flee": true},
	"time_dilation": {"good": true, "name": "Time dilation", "rarity": "rare", "desc": "A movimentação desacelera, mas o auto acelera um pouco.", "duration": 7, "color": "#ffd29f", "move_mult": 0.75, "auto_mult": 1.25},
	"treasure_tide": {"good": true, "name": "Treasure tide", "rarity": "epic", "desc": "Goobers especiais rendem mais dinheiro e moedas.", "duration": 8, "color": "#ffd166", "special_money_mult": 1.5, "special_coin_bonus": 2},
	"blessing": {"good": true, "name": "Blessing", "rarity": "legendary", "desc": "Um evento muito bom: mais click, mais auto e menos caos.", "duration": 8, "color": "#fff4bf", "click_mult": 1.6, "auto_mult": 1.6, "move_mult": 0.7, "special_essence_bonus": 1},
	"hellrush": {"good": false, "name": "Hellrush", "rarity": "legendary", "desc": "Poder e caos ao mesmo tempo.", "duration": 7, "color": "#ff6b6b", "click_mult": 1.5, "move_mult": 1.55, "spawn_bonus": 2},
	"void_window": {"good": false, "name": "Void window", "rarity": "legendary", "desc": "A janela do vazio aumenta a chance de raros e RGB.", "duration": 7, "color": "#b48cff", "rare_bonus": 0.01, "invert_colors": true},
	"snack_break": {"good": true, "name": "Snack break", "rarity": "common", "desc": "Seu combo demora mais para cair.", "duration": 6, "color": "#ffd29f", "combo_grace": 900},
	"jackpot_mode": {"good": true, "name": "Jackpot mode", "rarity": "epic", "desc": "Especialistas rendem muito mais goober coins.", "duration": 7, "color": "#76d7ff", "special_coin_bonus": 3},
	"lucky_wave": {"good": true, "name": "Lucky wave", "rarity": "epic", "desc": "Uma onda de sorte melhora bastante os spawns especiais.", "duration": 8, "color": "#ffb6ff", "rare_bonus": 0.008},
	"coin_rain": {"good": true, "name": "Coin rain", "rarity": "rare", "desc": "Cada clique gera uma goober coin extra por um tempo.", "duration": 7, "color": "#ffe082", "click_coin_bonus": 1},
	"essence_bloom": {"good": true, "name": "Essence bloom", "rarity": "legendary", "desc": "Goobers especiais podem render essence extra.", "duration": 8, "color": "#ff9de6", "special_essence_bonus": 1},
	"boss_hour": {"name": "Boss hour", "rarity": "epic", "desc": "A chance de boss sobe durante o evento.", "duration": 8, "color": "#ffcf66", "boss_bonus": 0.05},
	"moonlight": {"good": true, "name": "Moonlight", "rarity": "common", "desc": "Tudo fica mais suave e previsível.", "duration": 7, "color": "#d8e6ff", "move_mult": 0.55, "rare_bonus": 0.002},
	"mirror_world": {"good": false, "name": "Mirror world", "rarity": "epic", "desc": "Visual invertido com movimento espelhado, mas estável.", "duration": 6, "color": "#dcb5ff", "invert_colors": true, "invert_move": true},
	"safe_zone": {"good": true, "name": "Safe zone", "rarity": "rare", "desc": "Os empurrões dos goobers ficam mais fracos.", "duration": 7, "color": "#b8ffcf", "panic_reduce": 8, "move_mult": 0.8},
	"orbital": {"name": "Orbital", "rarity": "epic", "desc": "O botão fica orbitando suavemente em torno do centro.", "duration": 7, "color": "#9fd8ff", "orbit": true},
	"overclock": {"good": true, "name": "Overclock", "rarity": "epic", "desc": "Auto click e spawn de goobers sobem juntos.", "duration": 8, "color": "#8cecff", "auto_mult": 1.8, "spawn_bonus": 3},
	"party_mode": {"good": true, "name": "Party mode", "rarity": "rare", "desc": "Mais especiais e mais moedas por clique em clima de festa.", "duration": 8, "color": "#ffb6d9", "rare_bonus": 0.004, "click_coin_bonus": 1, "special_coin_bonus": 1},
}

# Pool do random check neste slice: apenas eventos com comportamento validado.
const CORE_ENABLED_IDS := [
	"double_click",
	"double_auto",
	"big_button",
	"tiny_button",
	"chaos",
	"calm",
	"snack_break",
]


static func get_event(id: String) -> Dictionary:
	return EVENT_INFO.get(id, {})


static func count() -> int:
	return EVENT_INFO.size()


static func get_rarity_label(rarity: String) -> String:
	return str(RARITY_INFO.get(rarity, {}).get("label", ""))


static func get_rarity_weight(rarity: String) -> float:
	return float(RARITY_INFO.get(rarity, {}).get("weight", 0.0))


# Seleção em duas fases, fiel ao canônico: sorteia a raridade pelos pesos,
# depois escolhe uniformemente um candidato daquela raridade.
# `roll` 0..1 determinístico (testes); < 0 usa randf().
static func pick_rarity_from_roll(rarities: Array, weights: Array, roll: float) -> String:
	var total := 0.0
	for w in weights:
		total += float(w)
	if total <= 0.0:
		return str(rarities[0])
	var target: float = clampf(roll, 0.0, 1.0) * total
	var cumulative := 0.0
	for i in rarities.size():
		cumulative += float(weights[i])
		if target < cumulative:
			return str(rarities[i])
	return str(rarities[rarities.size() - 1])


static func pick_candidate_from_roll(candidates: Array, roll: float) -> String:
	if candidates.is_empty():
		return ""
	var index: int = mini(candidates.size() - 1, int(floor(clampf(roll, 0.0, 0.999999) * candidates.size())))
	return str(candidates[index])


# Raridades que possuem ao menos um candidato habilitado (na ordem canônica).
# Com os 35 habilitados, retorna as 5 — algoritmo idêntico ao canônico.
static func get_available_rarities(candidates: Array) -> Array:
	var available: Array = []
	for rarity in RARITY_INFO.keys():
		for id in candidates:
			if str(EVENT_INFO.get(id, {}).get("rarity", "")) == rarity:
				available.append(rarity)
				break
	return available


# candidates: Array de IDs habilitados. rarity_weight_modifiers: hook futuro
# (prestige_level >= 3 -> {"rare": 1.08, "epic": 1.08}).
# Pool parcial: pesa apenas raridades presentes entre os candidatos —
# um roll nunca cai numa raridade sem candidatos e morre em silêncio.
static func choose_event(
	candidates: Array,
	rarity_weight_modifiers: Dictionary = {},
	rarity_roll: float = -1.0,
	candidate_roll: float = -1.0
) -> String:
	var available_rarities: Array = get_available_rarities(candidates)
	if available_rarities.is_empty():
		return ""

	var weights: Array = []
	for rarity in available_rarities:
		var weight: float = get_rarity_weight(rarity)
		if rarity_weight_modifiers.has(rarity):
			weight *= float(rarity_weight_modifiers[rarity])
		weights.append(weight)

	var roll_r: float = randf() if rarity_roll < 0.0 else rarity_roll
	var chosen_rarity := pick_rarity_from_roll(available_rarities, weights, roll_r)

	var filtered: Array = []
	for id in candidates:
		if str(EVENT_INFO.get(id, {}).get("rarity", "")) == chosen_rarity:
			filtered.append(id)
	if filtered.is_empty():
		return ""

	var roll_c: float = randf() if candidate_roll < 0.0 else candidate_roll
	return pick_candidate_from_roll(filtered, roll_c)
