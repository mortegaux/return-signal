# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Return Signal is a TIC-80 side-scrolling narrative puzzle game written in Lua. The player is VELA, a ship AI controlling a humanoid maintenance robot aboard the generation ship Ardent. The game takes place inside the ship — a side-view cross-section with explorable rooms. Puzzles are integrated into ship terminals, not abstract screens.

**Tone: uneasy coziness** — the ship is warm and functional, but 40 years of solitary operation and a sleeping crew create an undercurrent of wrongness.

**Spiritual predecessor:** Last Relay (PICO-8) — same atmospheric narrative DNA, different mechanics.

## Platform Constraints

- **TIC-80**: 240x136 display, 16-color Sweetie 16 palette, 4-channel audio, Lua scripting
- **CRITICAL**: TIC-80 uses Lua 5.3 WITHOUT `//` floor division. Always use `math.floor(a/b)`. Using `//` causes silent parse failure and blank screen.
- **CRITICAL**: Text carts MUST include `<PALETTE>` section at end of file, or all colors initialize to black.
- **Input**: d-pad (btn 0-3: up/down/left/right), Z (btn 4), X (btn 5). Use `btnp()` for single-press.
- **Cart**: `return-signal.lua` — load in TIC-80 via `load return-signal.lua`
- **Main loop**: `TIC()` is called 60 times/second by the runtime
- **Tiles**: 256 foreground + 256 background 8×8 tiles; 240×136 tile map

## Architecture

Single-file cart (`return-signal.lua`). The PRD at `docs/return-signal-prd.md` is the living design document — update it as decisions are made and phases complete.

### Game States
```
G.state = "title" | "boot" | "ship" | "terminal" | "puzzle" | "vela_log" | "ending"
```

### Code Sections
```
[CONSTANTS] → palette, layout, timing, physics
[DATA]      → TRANSMISSIONS, ROOMS, OBJECTS, VELA_LOGS
[STATE]     → master state table G, init functions
[MAP]       → room definitions, tile collision, object placement
[SPRITES]   → sprite index constants
[UTIL]      → word_wrap, draw_wave, fmt_time, helpers
[DRAW_*]    → per-state rendering functions
[UPDATE]    → all input handling and state transitions
[TIC]       → main loop: update() then draw()
```

### Key Rules
- **Rendering and logic fully separated**: no input handling inside draw functions; state transitions only in update functions
- **All game state lives in the `G` table**
- **Snake_case** for variables/functions, **SCREAMING_SNAKE_CASE** for constants
- **All magic numbers** extracted to named constants at top of file

## Ship Layout

4 rooms connected horizontally: Bridge → Comms → Cryo Bay → Engineering. Side-view cross-section, camera follows robot. Rooms are tile-based using TIC-80 map system.

## Development Phases

Current status tracked in PRD (`docs/return-signal-prd.md`) Status Tracker section.

1. **Phase 1 — Foundation**: Robot movement, camera, tile collision, interaction framework
2. **Phase 2 — Ship Interior**: All rooms tiled, doors, ambient details
3. **Phase 3 — Puzzle Systems**: Terminal views, signal decode puzzles, VELA logs
4. **Phase 4 — Narrative Integration**: Boot sequence, environmental storytelling, ending
5. **Phase 5 — Audio & Polish**: SFX, sprite art, visual effects
6. **Phase 6 — Ship (QA)**: Bug fixing, pacing, release

## Narrative

8 transmissions from Earth tell a collapse/recovery story. Dr. Yuna Park revealed as sender in TX-007/008. VELA's log arc: clinical → emotional. Full transmission data and VELA log texts in PRD Sections 8-9.
