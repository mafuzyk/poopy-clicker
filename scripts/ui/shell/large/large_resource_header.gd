extends Control
class_name LargeResourceHeader

const UiTokens = preload("res://scripts/ui/design/ui_tokens.gd")
const ThemeController = preload("res://scripts/ui/design/theme_controller.gd")
const ResourcePresenter = preload("res://scripts/ui/gameplay/resource_presenter.gd")
const ResourceChip = preload("res://scripts/ui/components/resource_chip.gd")

var state
var economy
var theme_ref: ThemeController

var _money_label: Label
var _income_label: Label
var _gc_chip: ResourceChip
var _essence_chip: ResourceChip
var _prestige_label: Label


func setup(state_ref, econ, theme_controller: ThemeController) -> void:
	state = state_ref
	economy = econ
	theme_ref = theme_controller
	_build()
	state.changed.connect(refresh)
	refresh()


func _build() -> void:
	var row := HBoxContainer.new()
	row.name = "HeaderRow"
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("separation", UiTokens.SPACE_4)
	add_child(row)

	var money_box := VBoxContainer.new()
	money_box.name = "MoneyBox"
	money_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	money_box.alignment = BoxContainer.ALIGNMENT_CENTER
	money_box.add_theme_constant_override("separation", 0)
	row.add_child(money_box)

	_money_label = Label.new()
	_money_label.name = "MoneyLabel"
	_money_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_money_label.add_theme_font_size_override("font_size", UiTokens.FONT_RESOURCE_PRIMARY)
	money_box.add_child(_money_label)

	_income_label = Label.new()
	_income_label.name = "IncomeLabel"
	_income_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_income_label.add_theme_font_size_override("font_size", UiTokens.FONT_SMALL)
	money_box.add_child(_income_label)

	var chips := HBoxContainer.new()
	chips.name = "ChipsRow"
	chips.add_theme_constant_override("separation", UiTokens.SPACE_2)
	row.add_child(chips)

	_gc_chip = ResourceChip.new()
	_gc_chip.setup(theme_ref, "GC", UiTokens.COLOR_RESOURCE_GC)
	chips.add_child(_gc_chip)

	_essence_chip = ResourceChip.new()
	_essence_chip.setup(theme_ref, "Ess", UiTokens.COLOR_RESOURCE_ESSENCE)
	chips.add_child(_essence_chip)

	_prestige_label = Label.new()
	_prestige_label.name = "PrestigeLabel"
	_prestige_label.add_theme_font_size_override("font_size", UiTokens.FONT_SMALL)
	chips.add_child(_prestige_label)

	_apply_theme()


func _apply_theme() -> void:
	if theme_ref == null:
		return
	_money_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_RESOURCE_MONEY))
	_income_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_TEXT_SECONDARY))
	_prestige_label.add_theme_color_override("font_color", theme_ref.get_color(UiTokens.COLOR_PRESTIGE))


func refresh() -> void:
	if state == null or economy == null:
		return
	var snap: Dictionary = ResourcePresenter.snapshot(state, economy)
	_money_label.text = str(snap["money"])
	_income_label.text = str(snap["income"])
	_gc_chip.visible = bool(snap["gc_visible"])
	if _gc_chip.visible:
		_gc_chip.set_amount(str(snap["gc"]))
	_essence_chip.visible = bool(snap["essence_visible"])
	if _essence_chip.visible:
		_essence_chip.set_amount(str(snap["essence"]))
	_prestige_label.visible = bool(snap["prestige_visible"])
	if _prestige_label.visible:
		_prestige_label.text = str(snap["prestige"])


func get_money_text() -> String:
	return _money_label.text if _money_label != null else ""


func get_gc_text() -> String:
	return _gc_chip.get_amount_text() if _gc_chip != null else ""


func get_essence_text() -> String:
	return _essence_chip.get_amount_text() if _essence_chip != null else ""


func get_prestige_text() -> String:
	return _prestige_label.text if _prestige_label != null else ""
