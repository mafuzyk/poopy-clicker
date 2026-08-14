extends RefCounted

const SUFFIXES: Array[String] = ["", "K", "M", "B", "T", "Q", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]


static func format(n: int) -> String:
	var value: float = float(n)
	var suffix_index: int = 0

	while value >= 1000.0 and suffix_index < SUFFIXES.size() - 1:
		value /= 1000.0
		suffix_index += 1

	if suffix_index == 0:
		return str(n)

	var text: String = "%.1f" % value
	text = text.trim_suffix("0").trim_suffix(".")
	return text + SUFFIXES[suffix_index]