# Return Signal — Phase 1 Handoff

## What Was Built

Phase 1 of Return Signal: a TIC-80 narrative puzzle game (240x136px, 16-color, Lua). Players decode transmissions through waveform reconstruction (Stage 1) and message sequencing (Stage 2), then read VELA log entries.

**Cart file:** `return-signal.lua` (single-file, ~1330 lines)
**Load in TIC-80:** `load return-signal.lua`

## What Works

The full game loop is playable end-to-end:

1. **Title screen** — blinking "Z: BEGIN" prompt, diamond logo
2. **Hub screen** — 8 TX entries listed; TX-001/002/003 selectable, rest locked with garbled text; decoded entries show first fragment text
3. **Stage 1 (waveform)** — compound sine target wave with gaps; fragment row at bottom; pick/place by index matching; correct = green snap + chime; incorrect = shake + error SFX; all gaps filled = flash + auto-advance
4. **Stage 2 (sequencing)** — slot grid (dynamic layout 1-6 slots) + fragment pool; select from pool, place in slots; submit with Z when all filled; wrong slots flash red; correct = typewriter reveal of assembled message
5. **VELA log** — typewriter line-by-line reveal; Z advances or dismisses; marks TX as decoded; returns to hub
6. **State transitions** — title → hub → stage1 → stage2 → vela_log → hub, all wired

## What's Stubbed / Not Built

- **Audio**: `play_sfx()` is a no-op. SFX IDs are called but produce no sound.
- **TX-004 through TX-008**: Data is defined but entries show as `[LOCKED]` in hub. No unlock logic.
- **Boot sequence**: No animated boot/startup sequence.
- **Ending sequence**: No end-game after all transmissions decoded.
- **Replay**: Decoded transmissions cannot be re-entered (Z does nothing on decoded entries).

## Architecture

All code is in `return-signal.lua`, organized by section comments:

| Section | Lines (approx) | Purpose |
|---------|----------------|---------|
| `[CONSTANTS]` | 1-50 | Palette colors, layout coords, timing |
| `[DATA]` | 51-250 | `TRANSMISSIONS` table (all 8 TX entries) |
| `[STATE]` | 251-260 | Master state table `G`, init functions |
| `[UTIL]` | 261-440 | `draw_wave`, `word_wrap`, `compute_gap_ranges`, `frag_box_w`, `s2_available_pool`, `fmt_time` |
| `[DRAW]` | 441-910 | Per-screen rendering: `draw_title`, `draw_hub`, `draw_s1`, `draw_s2`, `draw_vl` |
| `[UPDATE]` | 911-1300 | Per-screen input/state: `update_title`, `update_hub`, `update_s1`, `update_s2`, `update_vl` |
| `[AUDIO]` | 1301-1310 | `play_sfx` stub |
| `[TIC]` | 1311-1330 | Main loop: `update()` then `draw()` dispatch on `G.state` |

**Key rule:** Draw functions never mutate state. Update functions never render. All state lives in the `G` table.

## Resolved: Black Screen Issue

The cart originally rendered a black screen because it had no `<PALETTE>` section. TIC-80 text carts (at least v1.1 Pro on macOS) initialize all palette colors to black without an explicit palette definition, so the game ran correctly but everything was invisible. **Fix**: Added `<PALETTE>` section with Sweetie 16 colors at the end of the cart. Also removed a debug `trace()` call from `TIC()`.

## Known Issues From Code Review

None critical. Notable items:

- **No held-fragment indicator in Stage 1**: When carrying a fragment, its box goes dim but there's no `^` or other marker showing which one is held. Players may lose track.
- **VELA log dismiss is instant**: The "Z: CONTINUE" prompt appears the same frame the last line finishes revealing. No pause.
- **`time()` seed reuse**: `math.randomseed(time())` is called in both `init_stage1` and `init_stage2` in quick succession — could produce identical shuffle patterns.
- **Hub SFX missing**: No `play_sfx()` call when entering Stage 1 from hub.
- **Naming**: Spec says `C_BRIGHT`, code uses `C_WHITE` (same value: 12).
- **Gap dashes**: Spec says 2px-on/2px-off dashed line; code does 1px-on/1px-off dotted line.

## Transmission Data

All 8 TX entries are defined in the `TRANSMISSIONS` table with complete waveform params, sequence fragments, solutions, decoys, and VELA logs. Only TX-001/002/003 are reachable in Phase 1.

| TX | Gaps | Seq Frags | Decoys (wave/seq) | Status |
|----|------|-----------|-------------------|--------|
| TX-001 | 2 | 3 | 2/0 | Available |
| TX-002 | 2 | 3 | 2/1 | Available |
| TX-003 | 3 | 4 | 2/1 | Available |
| TX-004 | 3 | 4 | 3/2 | Locked |
| TX-005 | 3 | 5 | 3/2 | Locked |
| TX-006 | 4 | 5 | 3/2 | Locked |
| TX-007 | 4 | 6 | 4/2 | Locked |
| TX-008 | 4 | 6 | 4/3 | Locked |

## Commit History

```
02ee7cf chore: update CLAUDE.md and remove stale (stub) section markers
175d354 fix: end-to-end integration — verify transitions, fix edge cases
79a5010 feat: VELA log — typewriter line reveal, Z to dismiss, decoded status
5b2c9cb feat: stage 2 interaction — select, place, submit, error flash, typewriter
24925da feat: stage 2 rendering — slots, pool, text wrapping, error flash
8a70b7b feat: stage 1 interaction — pick, place, correct/incorrect feedback, completion
26211f8 feat: stage 1 waveform rendering — target wave, gaps, fragment row
702ce5d feat: hub navigation — cursor wraps selectables, Z enters stage1
33f737e feat: hub screen rendering — entries, statuses, garbled locks
c8bcaa9 feat: title screen with blinking prompt, Z advances to hub
98f068b feat: add utility functions — draw_wave, word_wrap, helpers
be9fb82 feat: scaffold constants, all 8 TX data, state table, main loop
8c300b7 docs: Phase 1 implementation plan
```

## Phase 2 Priorities

1. **Unlock logic** — progressive TX availability (decode TX-N to unlock TX-N+1, or by narrative triggers)
2. **Audio** — replace `play_sfx` stub with real SFX (chime, error, typewriter tick, ambient)
3. **Boot sequence** — animated startup before title screen
4. **Ending sequence** — after all 8 TX decoded
5. **Polish** — held-fragment indicator, VELA log pause, replay decoded TXs, seed entropy fix
6. **TX-004 through TX-008** — wire unlock conditions so locked entries become available

## Critical TIC-80 Gotchas

1. **No `//` floor division** — TIC-80's Lua does NOT support `//` (Lua 5.3+ syntax). Using it causes a silent parse failure — `TIC()` becomes undefined and the screen goes blank with no error. Always use `math.floor(a/b)`.
2. **Text carts MUST include `<PALETTE>`** — Without a `<PALETTE>` section, TIC-80 initializes all colors to black. The game runs but is invisible. Always include Sweetie 16 (or desired) palette at the end of the cart file.
