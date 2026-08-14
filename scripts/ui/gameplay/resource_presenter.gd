extends RefCounted
class_name ResourcePresenter

const NumberFormat = preload("res://scripts/ui/number_format.gd")


static func snapshot(state, economy) -> Dictionary:
	return {
		"money": "$" + NumberFormat.format(state.money),
		"income": NumberFormat.format(economy.get_auto_value()) + "/s",
		"gc_visible": state.secret_shop_unlocked,
		"gc": NumberFormat.format(state.goober_coins),
		"essence_visible": state.prestige_level > 0 or state.poopy_essence > 0,
		"essence": NumberFormat.format(state.poopy_essence),
		"prestige_visible": state.prestige_level > 0,
		"prestige": "P%d" % state.prestige_level,
	}
