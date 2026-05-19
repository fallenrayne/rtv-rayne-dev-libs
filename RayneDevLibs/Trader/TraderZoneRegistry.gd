extends Node

# ==============================================================
# TraderZoneRegistry — tracks UI regions injected into the trader
# interface by mods, so conflicts can be detected and free space
# can be queried.
#
# Access via Engine meta (set by RayneDevLibsMain on load):
#
#   if Engine.has_meta("RayneDevLibs_TraderZones"):
#       var reg = Engine.get_meta("RayneDevLibs_TraderZones")
#       reg.register_zone("my_mod", my_rect, "MyWidget")
#
# Zones are in iface-local coordinates — the same space that
# TraderLayout uses. Register on interface-open-post and
# unregister on interface-close-pre.
# ==============================================================

# Array of { mod_id: String, rect: Rect2, label: String }
var _zones: Array = []


# Register a UI rect. Call after injecting UI into the trader interface.
func register_zone(mod_id: String, rect: Rect2, label: String = "") -> void:
	_zones.append({ "mod_id": mod_id, "rect": rect, "label": label })
	print("[RayneDevLibs] Zone registered: %s '%s' %s" % [mod_id, label, rect])


# Remove all zones registered by a given mod. Call on interface-close-pre.
func unregister_zones(mod_id: String) -> void:
	var remaining: Array = []
	for z in _zones:
		if z["mod_id"] != mod_id:
			remaining.append(z)
	_zones = remaining


# Remove all registered zones.
func clear_all_zones() -> void:
	_zones.clear()


# Returns all currently registered zones.
func get_zones() -> Array:
	return _zones.duplicate()


# Returns all zones registered by a specific mod.
func get_zones_for_mod(mod_id: String) -> Array:
	var result: Array = []
	for z in _zones:
		if z["mod_id"] == mod_id:
			result.append(z)
	return result


# Returns true if rect overlaps any registered zone.
func has_conflict(rect: Rect2) -> bool:
	for z in _zones:
		if rect.intersects(z["rect"]):
			return true
	return false


# Returns all registered zones that overlap rect.
func get_conflicts(rect: Rect2) -> Array:
	var result: Array = []
	for z in _zones:
		if rect.intersects(z["rect"]):
			result.append(z)
	return result
