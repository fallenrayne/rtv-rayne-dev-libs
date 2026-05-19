# RayneDevLibs

Shared utility library for Road to Vostok mods by [fallenrayne](https://modworkshop.net/user/fallenrayne).

Provides common APIs that multiple mods can share without duplicating logic or conflicting with each other. All APIs are exposed via Engine meta so dependent mods stay loosely coupled — no hard script path dependencies required.

## Installation

Place `RayneDevLibs.vmz` in your Road to Vostok mods folder alongside any mods that depend on it. Load order doesn't matter; dependent mods check for the library's presence at runtime and fail gracefully if it isn't there.

## What's included

### Trader (`RayneDevLibs/Trader/`)

Utilities for working with the trader interface screen.

- **TraderLayout** — measures named layout zones on the trader interface (portrait area, deal section, character panel) and exposes coordinates for safe UI placement. Handles edge cases like the deal section reporting `size.y = 0` after reparenting.
- **TraderZoneRegistry** — shared registry where mods record the screen regions they occupy. Lets mods detect conflicts and query for available space before injecting UI.

See [`RayneDevLibs/Trader/README.md`](RayneDevLibs/Trader/README.md) for full API documentation.

## Usage pattern

RayneDevLibs registers itself via Engine meta on load. Dependent mods access it through those meta keys rather than preloading scripts directly:

```gdscript
# Check for the library before using it
if Engine.has_meta("RayneDevLibs_TraderZones"):
    var reg = Engine.get_meta("RayneDevLibs_TraderZones")
    reg.register_zone("my_mod", my_rect, "MyWidget")
```

This means your mod will still load and run if RayneDevLibs isn't installed — it just won't participate in zone tracking. For APIs your mod can't function without (like TraderLayout), document the requirement and let the preload fail loudly.

## Building from source

1. Copy `build.local.ps1.example` to `build.local.ps1` and set `$modsDir` to your Road to Vostok mods folder.
2. Run `.\build.ps1` from a PowerShell prompt in the repo root.

## License

MIT — see [LICENSE](LICENSE).

### Developed with the help of Claude Code
