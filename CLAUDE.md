# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Return Signal is a TIC-80 narrative puzzle game written in Lua. Players decode transmissions through two puzzle stages (waveform reconstruction + message sequencing), then read VELA log entries. Single-session only, no save system.

## Platform Constraints

- **TIC-80**: 240x136 display, 16-color default palette, 4-channel audio, Lua scripting
- **CRITICAL**: TIC-80 uses Lua 5.3 WITHOUT `//` floor division. Always use `math.floor(a/b)`. Using `//` causes silent parse failure and blank screen.
- **Input**: d-pad (btn 0-3: up/down/left/right), Z (btn 4), X (btn 5). Use `btnp()` for single-press.
- **Cart**: `return-signal.lua` — load in TIC-80 via `load return-signal.lua`
- **Main loop**: `TIC()` is called 60 times/second by the runtime

## Architecture

Single-file cart (`return-signal.lua`) organized in labeled sections:

```
[CONSTANTS] → palette indices (C_BG, C_HFNT, C_WHITE, etc.), layout coords, timing values
[DATA]      → TRANSMISSIONS table (8 entries, TX-001 through TX-008)
[STATE]     → master state table G, per-screen init functions (init_stage1, init_stage2, init_vela_log)
[UTIL]      → word_wrap, fmt_time, draw_wave, compute_gap_ranges, frag_box_w, s2_available_pool
[DRAW]      → per-screen rendering: draw_title, draw_hub, draw_s1, draw_s2, draw_vl + helpers
[UPDATE]    → per-screen input/logic: update_title, update_hub, update_s1, update_s2, update_vl
[AUDIO]     → sfx trigger stubs (play_sfx is a no-op)
[TIC]       → main loop dispatches update() then draw() based on G.state
```

## Game State Machine

```
G.state = "title" | "hub" | "stage1" | "stage2" | "vela_log"
```

- **title** → Z → **hub**
- **hub** → Z selects TX → `init_stage1()` → **stage1**
- **stage1** → all gaps correct → `init_stage2()` → **stage2**
- **stage2** → correct submission → typewriter reveal → `init_vela_log()` → **vela_log**
- **vela_log** → Z after last line → marks `G.decoded[tx]` → **hub**

## Key Design Rules

- **Rendering and logic fully separated**: no input handling inside draw functions; state transitions only in update functions
- **Snake_case** for variables/functions, **SCREAMING_SNAKE_CASE** for constants
- **All magic numbers** extracted to named constants at top of file
- **Matching in Stage 1** is by fragment INDEX, not visual similarity
- **Stage 2 wrong submissions** flash specific wrong slots — never full-reset
- **VELA log text is lowercase** (voice register shift); all transmission text is UPPERCASE
- **Stage 1 navigation**: Left/Right moves cursor in fragment row; Up/Down switches between fragment row and gap row
- **Stage 2 submit**: When all slots filled and nothing held, Z submits (priority over pick-up)

## Transmission Data

8 transmissions defined in `TRANSMISSIONS` table. Each entry has: `id`, `origin`, `year`, `gaps` (fractional positions), `fragments` (amp/freq/correct_gap), `seq_frags` (ordered text), `seq_solution`, `seq_decoys`, `vela_log`. TX-001/002/003 available in Phase 1; rest show as locked with garbled display.

## Phase 1 Scope

TX-001 through TX-003 playable. Audio stubbed (`play_sfx` is a no-op). No boot sequence or ending sequence. Locked TXs display garbled origin text.

## Screen Layouts (y-coordinates)

**Stage 1**: header 0-9, divider 10, waveform 11-79, divider 80, fragments 81-120, divider 121, status 122-135
**Stage 2**: header 0-9, divider 10, slots 11-67, divider 68, pool 69-126, divider 127, status 128-135
**VELA log**: header 0-9, text 11-100, divider 101, prompt area 102-135
**Hub**: header 0-9, divider 10, TX list 11-125 (14px each), divider 126, status 127-135

## Key Functions

- `draw_wave(x, w, y, h, amp, freq, col)` — renders compound sine (primary + 0.4× harmonic at 2× freq)
- `compute_gap_ranges(tx)` — converts fractional gap positions to pixel ranges within waveform area
- `frag_box_w(n)` — dynamic fragment box width for n fragments in 240px
- `word_wrap(str, max)` — returns line1, line2 for 2-line text boxes
- `s2_available_pool(s2)` — returns indices of unplaced fragments for stage 2 pool reflow
