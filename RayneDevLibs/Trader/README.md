# RayneDevLibs — Trader

Utilities for working with the Road to Vostok trader interface screen.

---

## TraderLayout

Measures and exposes named layout zones on the trader interface so mods can position UI elements without hardcoding pixel offsets or duplicating measurement logic.

### Accessing the active layout

While the trader interface is open, the current layout is available via Engine meta:

```gdscript
if Engine.has_meta("RayneDevLibs_TraderLayout"):
    var layout = Engine.get_meta("RayneDevLibs_TraderLayout")
    my_node.position = Vector2(layout.panel_x, layout.below_deal_y(8.0))
```

### Creating your own layout

If you need to measure independently (e.g. you inject UI before another mod sets the meta):

```gdscript
const TraderLayout = preload("res://mods/RayneDevLibs/Trader/TraderLayout.gd")

var layout = TraderLayout.new()
layout.measure(iface)   # iface is the Interface node from the hook
if layout.valid:
    my_node.position = Vector2(layout.panel_x, layout.below_deal_y())
```

### Fields

All coordinates are relative to the `Interface` node (iface-local).

| Field | Type | Description |
|---|---|---|
| `valid` | `bool` | `true` if measurement succeeded (key nodes were found) |
| `panel_x` | `float` | Left edge of the centre trader panel |
| `panel_w` | `float` | Width of the centre trader panel |
| `portrait_top_y` | `float` | Top of the trader portrait area |
| `portrait_bot_y` | `float` | Bottom of the trader portrait area |
| `deal_top_y` | `float` | Top of the vanilla deal section |
| `deal_bot_y` | `float` | Bottom of the deal section (0 until `refresh_deal_height()` succeeds) |
| `character_top_y` | `float` | Top of the character stats panel — the lower boundary for safe UI placement |
| `deal_section` | `Node` | The vanilla deal section node |

### Methods

#### `measure(iface) -> void`
Measures all zones from the given Interface node. Call once after the interface opens.

#### `refresh_deal_height() -> bool`
Re-measures the deal section height. Returns `true` when a valid height has been determined. Necessary because `deal_section.size.y` is 0 immediately after reparenting — this method falls back to the accept button's global rect to derive the height. Poll this in `_process` until it returns `true` before positioning UI below the deal section.

#### `below_deal_y(gap: float = 8.0) -> float`
Returns the Y coordinate to start placing UI directly below the deal section, with an optional gap.

#### `available_height() -> float`
Returns the available vertical space between the deal section bottom and the character panel top.

#### `panel_rect() -> Rect2`
Returns the full rect of the centre panel area below the portrait, in iface-local coordinates.

#### `below_deal_rect(gap: float = 0.0) -> Rect2`
Returns a `Rect2` spanning the full panel width from `below_deal_y(gap)` down to `character_top_y`. Useful for registering zones or checking available space.

---

## TraderZoneRegistry

Shared registry of UI regions injected into the trader interface by mods. Lets mods detect conflicts before injecting and provides a live map of what's occupying the screen.

All coordinates are iface-local (the same space TraderLayout uses).

### Accessing the registry

```gdscript
if Engine.has_meta("RayneDevLibs_TraderZones"):
    var reg = Engine.get_meta("RayneDevLibs_TraderZones")
```

### Typical lifecycle

```gdscript
# On interface-open-post, after injecting your UI:
if Engine.has_meta("RayneDevLibs_TraderZones"):
    var reg = Engine.get_meta("RayneDevLibs_TraderZones")
    reg.register_zone("my_mod", Rect2(my_node.position, my_node.size), "MyWidget")

# On interface-close-pre:
if Engine.has_meta("RayneDevLibs_TraderZones"):
    Engine.get_meta("RayneDevLibs_TraderZones").unregister_zones("my_mod")
```

### Methods

#### `register_zone(mod_id: String, rect: Rect2, label: String = "") -> void`
Records that `mod_id` occupies `rect`. `label` is a human-readable name for debugging. Call after injecting UI into the interface.

#### `unregister_zones(mod_id: String) -> void`
Removes all zones registered under `mod_id`. Call on `interface-close-pre`.

#### `clear_all_zones() -> void`
Removes every registered zone regardless of mod. Use sparingly.

#### `get_zones() -> Array`
Returns a copy of all registered zones. Each entry is a `Dictionary` with keys `mod_id`, `rect`, and `label`.

#### `get_zones_for_mod(mod_id: String) -> Array`
Returns all zones registered by a specific mod.

#### `has_conflict(rect: Rect2) -> bool`
Returns `true` if `rect` overlaps any registered zone.

#### `get_conflicts(rect: Rect2) -> Array`
Returns all registered zones that overlap `rect`.

### Checking for conflicts before injecting

```gdscript
const TraderLayout = preload("res://mods/RayneDevLibs/Trader/TraderLayout.gd")

var layout = TraderLayout.new()
layout.measure(iface)

var my_rect := Rect2(layout.panel_x, layout.below_deal_y(), layout.panel_w, 30.0)

if Engine.has_meta("RayneDevLibs_TraderZones"):
    var reg = Engine.get_meta("RayneDevLibs_TraderZones")
    if reg.has_conflict(my_rect):
        push_warning("[MyMod] UI zone conflicts with another mod — skipping inject")
        return

# safe to inject
