extends Node

# RayneDevLibs — shared utility library for Road to Vostok mods.
# Registers itself via Engine meta so any mod can access its APIs
# without a direct script dependency:
#
#   if Engine.has_meta("RayneDevLibs_TraderZones"):
#       var reg = Engine.get_meta("RayneDevLibs_TraderZones")
#       reg.register_zone("my_mod", my_rect)

const _VERSION := "1.0.0"
const _TraderZoneRegistry = preload("res://mods/RayneDevLibs/Trader/TraderZoneRegistry.gd")

var trader_zones = null


func _ready() -> void:
	trader_zones = _TraderZoneRegistry.new()
	trader_zones.name = "TraderZoneRegistry"
	add_child(trader_zones)
	Engine.set_meta("RayneDevLibs", self)
	Engine.set_meta("RayneDevLibs_TraderZones", trader_zones)
	print("[RayneDevLibs] v%s loaded" % _VERSION)


func _exit_tree() -> void:
	if Engine.has_meta("RayneDevLibs"):
		Engine.remove_meta("RayneDevLibs")
	if Engine.has_meta("RayneDevLibs_TraderZones"):
		Engine.remove_meta("RayneDevLibs_TraderZones")
