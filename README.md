# VEX FiveM Developer Panel

An ACE-gated, server-authorized FiveM development resource with a dark purple NUI panel.

## Installation
1. Copy `vex-fivem` into your FiveM server's `resources` directory.
2. Add `ensure vex-fivem` to `server.cfg`.
3. Grant access to your own admin group, e.g. `add_ace group.admin vex.devpanel allow` and configure `add_principal identifier.license:YOUR_LICENSE_HERE group.admin` (replace with your actual license identifier).
4. Restart the server. In game, run `/vexpanel`.

## Features
- Player markers: nearby streamed players are outlined (including through geometry where supported by the FiveM client) and appear as map blips. Not a global player scanner.
- Aim training: manual crosshair overlay, **no aimbot**.
- God mode: authorized player invincibility.
- Speed control: sprint multiplier, capped at 2x.
- Built-in Lua module: coordinates HUD (reviewed and preinstalled, no arbitrary Lua execution).\n- Toggle state round-trips through server ACE authorization.

All player highlighting is limited to locally streamed entities; admin authorization is required. Aimbot is not implemented; the aim option remains a manual training guide.\n\nDesigned for owned/authorized test servers. Not a client injector, anti-cheat bypass or public-server cheat. All features start disabled.