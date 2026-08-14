extends RefCounted
class_name UiTokens

const COLOR_BACKGROUND_DEEP: StringName = &"background_deep"
const COLOR_BACKGROUND: StringName = &"background"
const COLOR_SURFACE_LOW: StringName = &"surface_low"
const COLOR_SURFACE: StringName = &"surface"
const COLOR_SURFACE_HIGH: StringName = &"surface_high"
const COLOR_BORDER_SUBTLE: StringName = &"border_subtle"
const COLOR_BORDER_STRONG: StringName = &"border_strong"
const COLOR_TEXT_PRIMARY: StringName = &"text_primary"
const COLOR_TEXT_SECONDARY: StringName = &"text_secondary"
const COLOR_TEXT_MUTED: StringName = &"text_muted"
const COLOR_ACCENT: StringName = &"accent"
const COLOR_ACCENT_HOVER: StringName = &"accent_hover"
const COLOR_ACCENT_PRESSED: StringName = &"accent_pressed"
const COLOR_SUCCESS: StringName = &"success"
const COLOR_WARNING: StringName = &"warning"
const COLOR_DANGER: StringName = &"danger"
const COLOR_INFO: StringName = &"info"
const COLOR_DISABLED: StringName = &"disabled"
const COLOR_RESOURCE_MONEY: StringName = &"resource_money"
const COLOR_RESOURCE_GC: StringName = &"resource_gc"
const COLOR_RESOURCE_ESSENCE: StringName = &"resource_essence"
const COLOR_PRESTIGE: StringName = &"prestige"
const COLOR_RARITY_COMMON: StringName = &"rarity_common"
const COLOR_RARITY_RARE: StringName = &"rarity_rare"
const COLOR_RARITY_EPIC: StringName = &"rarity_epic"
const COLOR_RARITY_LEGENDARY: StringName = &"rarity_legendary"
const COLOR_RARITY_MYTHIC: StringName = &"rarity_mythic"

const SPACE_1 := 4.0
const SPACE_2 := 8.0
const SPACE_3 := 12.0
const SPACE_4 := 16.0
const SPACE_5 := 24.0
const SPACE_6 := 32.0
const SPACE_7 := 48.0

const RADIUS_SMALL := 6.0
const RADIUS_MEDIUM := 10.0
const RADIUS_LARGE := 16.0
const RADIUS_XL := 22.0
const RADIUS_PILL := 999.0

const FONT_CAPTION := 12
const FONT_SMALL := 14
const FONT_BODY := 16
const FONT_BUTTON := 16
const FONT_CARD_TITLE := 18
const FONT_SECTION_TITLE := 22
const FONT_RESOURCE_PRIMARY := 28
const FONT_DISPLAY := 36
const FONT_HERO := 44

const MOTION_MICRO := 0.10
const MOTION_STANDARD := 0.20
const MOTION_EXPRESSIVE := 0.40

const TOUCH_MIN := 48.0
const MOBILE_NAV_HEIGHT := 64.0
const MOBILE_NAV_HEIGHT_LANDSCAPE := 54.0
const MOBILE_HEADER_HEIGHT := 100.0
const MOBILE_HEADER_HEIGHT_LANDSCAPE := 60.0
const LARGE_NAV_RAIL_POINTER := 104.0
const LARGE_NAV_RAIL_TOUCH := 120.0
const LARGE_COMPACT_BREAKPOINT := 1100.0


static func default_palette() -> Dictionary:
	return {
		COLOR_BACKGROUND_DEEP: Color("#0D0E13"),
		COLOR_BACKGROUND: Color("#12141B"),
		COLOR_SURFACE_LOW: Color("#181B24"),
		COLOR_SURFACE: Color("#20232E"),
		COLOR_SURFACE_HIGH: Color("#292D3A"),
		COLOR_BORDER_SUBTLE: Color("#343948"),
		COLOR_BORDER_STRONG: Color("#4A5062"),
		COLOR_TEXT_PRIMARY: Color("#F5F3FA"),
		COLOR_TEXT_SECONDARY: Color("#B8B6C3"),
		COLOR_TEXT_MUTED: Color("#7F7D8B"),
		COLOR_ACCENT: Color("#A970FF"),
		COLOR_ACCENT_HOVER: Color("#BC8CFF"),
		COLOR_ACCENT_PRESSED: Color("#8C53E8"),
		COLOR_SUCCESS: Color("#6ED99A"),
		COLOR_WARNING: Color("#F1C75B"),
		COLOR_DANGER: Color("#FF6B7A"),
		COLOR_INFO: Color("#69C4FF"),
		COLOR_DISABLED: Color("#666A78"),
		COLOR_RESOURCE_MONEY: Color("#D7F08A"),
		COLOR_RESOURCE_GC: Color("#F6C85F"),
		COLOR_RESOURCE_ESSENCE: Color("#A88BFF"),
		COLOR_PRESTIGE: Color("#E5D9FF"),
		COLOR_RARITY_COMMON: Color("#B5B7C2"),
		COLOR_RARITY_RARE: Color("#62A7FF"),
		COLOR_RARITY_EPIC: Color("#A970FF"),
		COLOR_RARITY_LEGENDARY: Color("#FFB84D"),
		COLOR_RARITY_MYTHIC: Color("#FF5CAA"),
	}
