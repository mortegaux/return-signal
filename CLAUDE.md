# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Return Signal is a TIC-80 narrative puzzle game written in Lua. Players decode transmissions through two puzzle stages (waveform reconstruction + message sequencing), then read VELA log entries. Single-session only, no save system.

## Platform Constraints

- **TIC-80**: 240x136 display, 16-color default palette, 4-channel audio, Lua scripting
- **Input**: d-pad (btn 0-3: up/down/left/right), Z (btn 4), X (btn 5)
- **Cart**: `return-signal.lua` — load in TIC-80 via `load return-signal.lua`
- **Main loop**: `TIC()` is called 60 times/second by the runtime

## Architecture

Single-file cart (`return-signal.lua`) organized in labeled sections:

```
[CONSTANTS] → palette indices (C_BG, C_HFNT, etc.), layout coords, timing values
[DATA]      → TX table (transmission definitions), LOCKED placeholder entries
[STATE]     → game state machine, per-screen state tables (s1, s2, vl, hub)
[DRAW]      → all rendering functions (draw_hub, draw_s1, draw_s2, draw_vl + helpers)
[UPDATE]    → input handling and state transitions (update_hub, update_s1, update_s2, update_vl)
[AUDIO]     → sfx trigger stubs (play_sfx)
[TIC]       → main loop dispatches update() then draw() based on `state`
```

## Game State Machine

```
state = "hub" | "stage1" | "stage2" | "vela_log"
```

- **hub** → Z selects TX → `init_s1()` → **stage1**
- **stage1** → all gaps correct → `init_s2()` → **stage2**
- **stage2** → correct submission → typewriter → `init_vl()` → **vela_log**
- **vela_log** → Z after last line → sets `decoded[tx]` → **hub**

## Key Design Rules

- **Rendering and logic fully separated**: no input handling inside draw functions; state transitions only in update functions
- **Snake_case** for variables/functions, **SCREAMING_SNAKE_CASE** for constants
- **All magic numbers** extracted to named constants at top of file
- **Matching in Stage 1** is by fragment INDEX, not visual similarity
- **Stage 2 wrong submissions** flash specific wrong slots — never full-reset
- **VELA log text is lowercase** (voice register shift); all transmission text is UPPERCASE

## Transmission Data Structure

Each TX entry contains: `id`, `origin`, `year`, `gaps` (fractional positions), `fragments` (amp/freq/correct_gap), `seq_frags` (ordered text), `seq_solution`, `seq_decoys`, `vela_log`.

## Phase 1 Scope

Only TX-001 is implemented. Audio is stubbed (`play_sfx` is a no-op). No boot sequence, no unlock logic, no ending sequence. TX-001 is always available.

## Screen Layouts (y-coordinates)

**Stage 1**: header 0-9, divider 10, waveform 11-79, divider 80, fragments 81-120, divider 121, status 122-135
**Stage 2**: header 0-9, divider 10, slots 11-67, divider 68, pool 69-126, divider 127, status 128-135
**VELA log**: header 0-9, text 11-100, divider 101, prompt area 102-135

## Slot Layout Rules (Stage 2)

1-3 slots → single row; 4 → 2x2; 5 → 3 top + 2 bottom; 6 → 3x2
