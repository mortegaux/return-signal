# Gameplay Improvements Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transform Return Signal from functional prototype to polished game across 5 phases: sprites, audio, transitions, onboarding, and atmosphere.

**Architecture:** Single-file TIC-80 Lua cart (`return-signal.lua`, ~1814 lines). All changes are edits to this one file plus `<TILES>` sprite data. No module system, no test framework — verification is build cart + run in TIC-80.

**Tech Stack:** TIC-80 (240x136, 16-color, Lua 5.3 without `//`), Sweetie 16 palette.

**Spec:** `docs/superpowers/specs/2026-03-11-gameplay-improvements-design.md`

---

## Build & Verify Commands

Used throughout the plan. Run after every visual change:

```bash
TIC80="/Applications/tic80.app/Contents/MacOS/tic80"
TIC_FS="$HOME/Library/Application Support/com.nesbox.tic/TIC-80"
rm -f "$TIC_FS/return-signal.tic"
cp return-signal.lua "$TIC_FS/return-signal.lua"
"$TIC80" --cli --fs="$TIC_FS" --cmd "new lua & import code return-signal.lua & save return-signal & exit"
```

To launch and visually verify:
```bash
"$TIC80" --skip --fs="$TIC_FS" --cmd "load return-signal.tic & run" &
```

**CRITICAL:** Never use `//` for floor division. Always use `math.floor(a/b)`.

---

## Chunk 1: Phase 1 — Sprites & Animation

### Task 1: Author tile sprite data

**Files:**
- Modify: `return-signal.lua` — append `<TILES>` section before `<PALETTE>`

**Context:** TIC-80 text carts define sprites in a `<TILES>` section. Each 8x8 tile is 8 rows of 8 hex digits (2 hex chars per row = one pixel per char using palette index). Tile indices 1–12 must match existing `T_FLOOR` through `T_LIGHT` constants. The tile data is placed at the bottom of the file between code and `<PALETTE>`.

**Sprite index allocation:**
- 1–12: Map tiles (T_FLOOR=1 through T_LIGHT=12)
- 13–14: T_CRYO_L_WARM, T_CRYO_R_WARM (Phase 5 warm cryo variants)
- 15–16: T_SCREEN alt frame, T_LIGHT alt frame (ambient anim)
- 17–18: T_CRYO_L alt frame, T_CRYO_R alt frame (ambient anim)

- [ ] **Step 1: Add new tile constants for warm cryo and anim frames**

In `[CONSTANTS]` section after `T_LIGHT = 12` (line 54), add:

```lua
T_CRYO_L_WARM = 13
T_CRYO_R_WARM = 14
T_SCREEN_ALT  = 15
T_LIGHT_ALT   = 16
T_CRYO_L_ALT  = 17
T_CRYO_R_ALT  = 18
```

- [ ] **Step 2: Author tile pixel art in `<TILES>` section**

Add a `<TILES>` section before the `<PALETTE>` section at bottom of file. Each tile is 8 lines of 8 hex digits using Sweetie 16 palette indices (0=black, 1=dark purple, 2=red, 3=dark green, 4=yellow, 5=tan, 6=green, 7=light blue, 8=dark blue, 9=orange, a=amber, b=cyan, c=white, d=light gray, e=cream, f=dark gray):

```
-- <TILES>
-- 001:ffffffff0fffffff0fffffffffffffffffff0ffffffffffff0ffffff0fffffffff
-- 002:8888888888888f8888888888888f888888888888888888f888f88888888888888
-- 003:888888888f88888888888888888f8888888888888888888888888f888f888888
-- 004:11118111111811111111111181111111111181111118111111111111111181111
-- 005:9999999999f99f9999999999999999999999999999f99f99999999999999999
-- 006:0000000000000c0000c00000000000000000000c000000000000000c00000000
-- 007:8888888880b0b0888888888880b0b088888888888888888880b0b08888888888
-- 008:111f1111111f111111111111111f1111111f111111111111111f1111111f1111
-- 009:f0f0f0f00f0f0f0ff0f0f0f00f0f0f0ff0f0f0f00f0f0f0ff0f0f0f00f0f0f0f
-- 010:338b338833333338338b33883333333833333338338b3388333333383388b338
-- 011:338b338833333338338b33883333333833333338338b3388333333383388b338
-- 012:1111111111144111114441111144441111444411111441111114411111111111
-- 013:330b330033333300330b33003333330033333300330b3300333333003300b330
-- 014:330b330033333300330b33003333330033333300330b3300333333003300b330
-- 015:888888888080b088888888888080b08888888888888888888080b08888888888
-- 016:1111111111194111119941111199441111994411111941111119411111111111
-- 017:339b339933333399339b33993333339933333399339b3399333333993399b339
-- 018:339b339933333399339b33993333339933333399339b3399333333993399b339
-- </TILES>
```

Art direction per tile:
- 001 (T_FLOOR): Dark gray with rivet dots (f=dark gray, 0=black dots)
- 002 (T_WALL): Dark blue panels with gray seam lines
- 003 (T_CEIL): Dark blue structural beam pattern
- 004 (T_PANEL): Dark purple paneling with subtle lines
- 005 (T_DOOR): Orange with frame seam marks
- 006 (T_WINDOW): Black space with white star dots
- 007 (T_SCREEN): Dark blue with cyan scan line dots
- 008 (T_PIPE): Dark purple conduit with gray highlight
- 009 (T_GRATE): Gray/black crosshatch
- 010 (T_CRYO_L): Dark green glass with cyan frost highlights
- 011 (T_CRYO_R): Mirror of CRYO_L
- 012 (T_LIGHT): Dark purple with yellow amber glow
- 013 (T_CRYO_L_WARM): Green glass without frost, amber status dot
- 014 (T_CRYO_R_WARM): Mirror of warm L
- 015 (T_SCREEN_ALT): Screen with scan line shifted position
- 016 (T_LIGHT_ALT): Light with orange/warm tint (dimmer)
- 017 (T_CRYO_L_ALT): Frost shimmer shifted
- 018 (T_CRYO_R_ALT): Mirror of alt L

- [ ] **Step 3: Update `is_solid()` to include warm cryo tiles**

At `return-signal.lua:421`, modify `is_solid`:

```lua
function is_solid(tid)
  return tid == T_FLOOR or tid == T_WALL or tid == T_CEIL or tid == T_GRATE
end
```

No change needed — warm cryo tiles don't need to be solid (they're wall-mounted like regular cryo).

- [ ] **Step 4: Build cart and verify tiles render**

Run build commands. Load in TIC-80. Walk through all rooms. Verify each tile type renders its sprite art instead of flat-colored rectangles.

- [ ] **Step 5: Commit**

```bash
git add return-signal.lua
git commit -m "feat: add authored pixel art tiles for all 18 tile types"
```

---

### Task 2: Replace programmatic tile rendering with `map()`

**Files:**
- Modify: `return-signal.lua:708-777` — `draw_ship()` tile rendering

**Context:** Currently `draw_ship()` iterates every tile and draws colored rectangles/effects via `rect()`/`pix()`. With tile sprites defined in `<TILES>`, the TIC-80 `map()` function can render the entire visible area in one call. Ambient animations (screen scan lines, light flicker, cryo shimmer) need to swap tile indices on a timer.

- [ ] **Step 1: Add ambient tile animation to update_ship()**

In `update_ship()` (at line 1356), add tile animation before movement code:

```lua
function update_ship()
  local room = ROOMS[G.cur_room]

  -- Ambient tile animations
  if G.t % 30 == 0 then  -- every 0.5 sec
    for ty = 0, room.map_h - 1 do
      for tx = 0, room.map_w - 1 do
        local tid = mget(room.map_x + tx, room.map_y + ty)
        if tid == T_SCREEN then
          mset(room.map_x + tx, room.map_y + ty, T_SCREEN_ALT)
        elseif tid == T_SCREEN_ALT then
          mset(room.map_x + tx, room.map_y + ty, T_SCREEN)
        elseif tid == T_LIGHT and math.random() < 0.3 then
          mset(room.map_x + tx, room.map_y + ty, T_LIGHT_ALT)
        elseif tid == T_LIGHT_ALT then
          mset(room.map_x + tx, room.map_y + ty, T_LIGHT)
        elseif tid == T_CRYO_L and decoded_count() < 7 then
          mset(room.map_x + tx, room.map_y + ty, T_CRYO_L_ALT)
        elseif tid == T_CRYO_L_ALT then
          mset(room.map_x + tx, room.map_y + ty, T_CRYO_L)
        elseif tid == T_CRYO_R and decoded_count() < 7 then
          mset(room.map_x + tx, room.map_y + ty, T_CRYO_R_ALT)
        elseif tid == T_CRYO_R_ALT then
          mset(room.map_x + tx, room.map_y + ty, T_CRYO_R)
        -- Warm cryo tiles (Phase 5) are NOT animated — they stay warm
        end
      end
    end
  end

  local moved = false
  -- ... rest of existing update_ship code
```

- [ ] **Step 2: Replace tile rendering loop with `map()` call**

Replace the tile drawing loop in `draw_ship()` (lines 712–777) with:

```lua
function draw_ship()
  cls(C_BG)
  local room = ROOMS[G.cur_room]

  -- Draw tiles using map()
  local sx = math.floor(-G.cam_x) % TILE
  local sc = math.floor(G.cam_x / TILE)
  local visible_cols = math.floor(SW / TILE) + 2
  local cols = math.min(visible_cols, room.map_w - sc)
  if cols > 0 then
    map(room.map_x + sc, room.map_y, cols, room.map_h, sx - sc * TILE + room.map_x * TILE - G.cam_x, 0, 0)
  end
```

Wait — TIC-80's `map(x, y, w, h, sx, sy, colorkey)` draws map tiles at screen position. Simpler approach:

```lua
function draw_ship()
  cls(C_BG)
  local room = ROOMS[G.cur_room]

  -- Draw tiles using map() — colorkey 0 makes T_EMPTY transparent
  map(room.map_x, room.map_y, room.map_w, room.map_h,
      -math.floor(G.cam_x), 0, 0)
```

This draws the entire room map, offset by camera, with tile index 0 (T_EMPTY) as transparent. One call replaces the entire for-loop.

- [ ] **Step 3: Remove TILE_COLORS table and old tile rendering code**

Delete `TILE_COLORS` table (lines 693–706) and the entire tile-drawing for-loop that was replaced. Keep all code after the tile loop (interactable markers, robot drawing, room label, door arrows, interaction prompt).

- [ ] **Step 4: Build and verify**

Run build commands. Walk through all rooms. Verify:
- All tile types render correctly as sprites
- Screens alternate frames every ~0.5 sec
- Lights occasionally flicker
- Cryo pods shimmer
- T_EMPTY areas show black background

- [ ] **Step 5: Commit**

```bash
git add return-signal.lua
git commit -m "feat: replace programmatic tile rendering with map() and animated tiles"
```

---

### Task 3: Author robot sprites and wire animation

**Files:**
- Modify: `return-signal.lua` — `<TILES>` section (add robot sprite data), `[CONSTANTS]` (sprite indices), `[STATE]` (anim state), `draw_ship()` (robot rendering), `update_ship()` (anim logic)

**Context:** Robot is currently drawn with `rect()`/`pix()` at lines 787–807. Replace with `spr()` calls using 5 frames × 2 tiles each (top/bottom halves). Robot sprites live at indices 32–41 per allocation table.

- [ ] **Step 1: Add robot sprite constants**

After tile constants in `[CONSTANTS]`:

```lua
-- Robot sprite indices (top half of each frame)
-- Bottom half is always index + 1
SPR_IDLE_A  = 32
SPR_IDLE_B  = 34
SPR_WALK_A  = 36
SPR_WALK_B  = 38
SPR_INTERACT = 40

IDLE_TOGGLE  = 30   -- frames between idle A/B
WALK_TOGGLE  = 8    -- frames between walk A/B
INTERACT_DUR = 12   -- frames to hold interact pose
```

- [ ] **Step 2: Add animation state to G table**

In `[STATE]` section (G table, around line 239), add:

```lua
  -- Robot animation
  interact_t = 0,    -- interact frame timer (counts down)
```

- [ ] **Step 3: Add robot sprite data to `<TILES>` section**

Add 10 sprite tiles (5 frames × 2 tiles) at indices 32–41. Each pair is top half then bottom half of the 8×16 robot:

```
-- 032:000dd000000dc00000dddd000ddddd00ddddddd0ddddddd00dd8dd000dd8dd0
-- 033:0dd0dd000d000d000d000d000d000d000d000d000d000d0000d00d00000000000
-- 034:000dd000000db00000dddd000ddddd00ddddddd0ddddddd00dd8dd000dd8dd0
-- 035:0dd0dd000d000d000d000d000d000d000d000d000d000d0000d00d0000000000
-- 036:000dd000000dc00000dddd000ddddd00ddddddd00dddddd00dd8dd000dd8dd0
-- 037:0dd0dd000d000d000d000d000d00d0000d00d0000d000d0000d0000000000d00
-- 038:000dd000000dc00000dddd000ddddd000ddddddd0dddddd00dd8dd000dd8dd0
-- 039:0dd0dd000d000d000d000d0000d000d0000d000d00d000d000000d0000d00000
-- 040:000dd000000dc000d0dddd000ddddd90ddddddd0ddddddd00dd8dd000dd8dd0
-- 041:0dd0dd000d000d000d000d000d000d000d000d000d000d0000d00d0000000000
```

Art direction:
- Head: d (light gray) body, c (white) visor highlight / b (cyan) visor alt for idle B
- Body: d (light gray) torso
- Arms: extend in different poses per walk frame
- Visor: `c` in idle A, `b` in idle B (breathing flicker)
- Interact frame (040–041): arm extended right (9=orange hand highlight)

- [ ] **Step 4: Replace robot drawing with `spr()` calls**

Replace robot drawing code in `draw_ship()` (lines 787–807) with:

```lua
  -- Draw robot
  local rx = G.robot_x - math.floor(G.cam_x)
  local ry = G.robot_y
  local flip = G.robot_dir == -1 and 1 or 0  -- spr() flip: 0=none, 1=horizontal

  local sprite_top
  if G.interact_t > 0 then
    sprite_top = SPR_INTERACT
  elseif G.walk_t > 0 then
    sprite_top = (math.floor(G.walk_t / WALK_TOGGLE) % 2 == 0) and SPR_WALK_A or SPR_WALK_B
  else
    sprite_top = (math.floor(G.t / IDLE_TOGGLE) % 2 == 0) and SPR_IDLE_A or SPR_IDLE_B
  end

  spr(sprite_top, rx, ry, 0, 1, flip, 0, 1, 1)
  spr(sprite_top + 1, rx, ry + 8, 0, 1, flip, 0, 1, 1)
```

`spr(id, x, y, colorkey, scale, flip, rotate, w, h)` — colorkey=0 makes black transparent, w=1 h=1 means one 8x8 tile.

- [ ] **Step 5: Wire interact animation trigger**

In `update_ship()`, after the Z interaction check (around line 1432), add interact animation:

```lua
  -- Z: interact
  if btnp(4) and G.near_obj then
    G.interact_t = INTERACT_DUR
    -- ... existing interaction code
```

And at top of `update_ship()`, tick down the interact timer:

```lua
  if G.interact_t > 0 then G.interact_t = G.interact_t - 1 end
```

- [ ] **Step 6: Build and verify**

Run build commands. Verify:
- Robot renders as sprite, not rectangles
- Idle animation toggles (visor flicker)
- Walk cycle alternates frames
- Interact gesture plays when pressing Z near object
- Robot flips when changing direction

- [ ] **Step 7: Commit**

```bash
git add return-signal.lua
git commit -m "feat: replace robot rect drawing with animated sprites"
```

---

## Chunk 2: Phase 2 — Audio

### Task 4: Define SFX waveforms in cart

**Files:**
- Modify: `return-signal.lua` — add `<SFX>` section before `<TILES>`

**Context:** TIC-80 text carts define SFX in a `<SFX>` section. Each SFX slot is a 4-digit header + 64-char waveform data. Format: `-- NNN:TTFFVVWWWWWWWWWW...` where NNN=slot, TT=type, FF=frequency... The simplest approach is to define waveform patterns that match the design spec's sound descriptions.

TIC-80 SFX format per slot: `-- NNN:AAAA...` where the data is a hex-encoded set of speed, loop and note values followed by 30 note entries (each 9 hex chars: 3 for note+octave, 2 for volume, 2 for waveform, 2 for effect). We can use shorthand — TIC-80 also supports a simpler encoding.

- [ ] **Step 1: Add `<SFX>` section with all 15 sound effects**

Add before `<TILES>` at bottom of file. SFX definitions using TIC-80 text format:

```
-- <SFX>
-- 000:0600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600060006000600307000
-- 001:040004000400040004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000200000
-- 002:0a000800060004000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030000
-- 003:020004000600080006000400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 004:060008000a000c000a000800060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 005:0c000a0008000600040002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 006:060008000a000c000e000c000a0008000600000000000000000000000000000000000000000000000000000000000000000000000000000000000030000
-- 007:0400040003000300020002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 008:0f000d000b0009000700050003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
-- 009:0300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000300030003000600
-- 010:0800060004000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 011:0400060008000600040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020000
-- 012:0200020002000200010001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
-- 013:0300050003000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
-- 014:0600080006000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000010000
-- </SFX>
```

**Note:** These are placeholder waveforms. The exact hex data will need tuning in TIC-80's SFX editor to match the design descriptions. The important thing is that all 15 slots are defined and callable. The step provides the structure; tuning happens in-engine.

- [ ] **Step 2: Build and verify SFX section loads**

Build cart. Open in TIC-80. Open SFX editor (press ESC → click SFX). Verify 15 slots have data. Play each to confirm they produce sound (even if not perfectly tuned yet).

- [ ] **Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: add SFX waveform data for all 15 sound slots"
```

---

### Task 5: Wire play_sfx() and add audio calls

**Files:**
- Modify: `return-signal.lua:568-570` — `play_sfx()` function
- Modify: `return-signal.lua` — `update_ship()`, `update_terminal()`, `update_boot()`, `draw_vela_log()` update path

**Context:** `play_sfx()` is currently a no-op stub called in 11 places. Existing call sites use old ID numbers that must be remapped to the new SFX slot table. New call sites need to be added for footsteps, doors, terminal enter/exit, boot chars, and VELA log lines.

- [ ] **Step 1: Implement play_sfx() with channel routing**

Replace the no-op at line 568:

```lua
-- SFX slot constants
SFX_AMBIENT    = 0
SFX_FOOTSTEP   = 1
SFX_DOOR       = 2
SFX_TERM_ENTER = 3
SFX_CORRECT    = 4
SFX_INCORRECT  = 5
SFX_DECODED    = 6
SFX_TYPEWRITER = 7
SFX_STATIC     = 8
SFX_CRYO_HUM   = 9
SFX_TERM_EXIT  = 10
SFX_VELA_LINE  = 11
SFX_BOOT_CHAR  = 12
SFX_PROMPT     = 13
SFX_FRAG_CLICK = 14

-- Channel routing: which channel each SFX plays on
SFX_CHANNEL = {
  [SFX_AMBIENT]    = 0,
  [SFX_FOOTSTEP]   = 1,
  [SFX_DOOR]       = 1,
  [SFX_TERM_ENTER] = 3,
  [SFX_CORRECT]    = 2,
  [SFX_INCORRECT]  = 2,
  [SFX_DECODED]    = 2,
  [SFX_TYPEWRITER] = 3,
  [SFX_STATIC]     = 2,
  [SFX_CRYO_HUM]   = 0,
  [SFX_TERM_EXIT]  = 3,
  [SFX_VELA_LINE]  = 3,
  [SFX_BOOT_CHAR]  = 3,
  [SFX_PROMPT]     = 3,
  [SFX_FRAG_CLICK] = 2,
}

function play_sfx(id, note)
  local ch = SFX_CHANNEL[id] or 2
  sfx(id, note or -1, -1, ch)
end
```

- [ ] **Step 2: Remap existing play_sfx calls to new SFX constants**

Current calls and their remapping:

| Location | Old call | New call |
|----------|----------|----------|
| Line 1508 (s1: pick fragment) | `play_sfx(6)` | `play_sfx(SFX_FRAG_CLICK)` |
| Line 1529 (s1: correct place) | `play_sfx(1)` | `play_sfx(SFX_CORRECT)` |
| Line 1536 (s1: all gaps filled) | `play_sfx(3)` | `play_sfx(SFX_DECODED)` |
| Line 1544 (s1: incorrect) | `play_sfx(2)` | `play_sfx(SFX_INCORRECT)` |
| Line 1566 (s1: pick from gap) | `play_sfx(6)` | `play_sfx(SFX_FRAG_CLICK)` |
| Line 1592 (s2: wrong solution) | `play_sfx(2)` | `play_sfx(SFX_INCORRECT)` |
| Line 1603 (s2: correct solution) | `play_sfx(4)` | `play_sfx(SFX_DECODED)` |
| Line 1651 (s2: pick from pool) | `play_sfx(6)` | `play_sfx(SFX_FRAG_CLICK)` |
| Line 1671 (s2: place in slot) | `play_sfx(1)` | `play_sfx(SFX_CORRECT)` |
| Line 1675 (s2: pick from slot) | `play_sfx(6)` | `play_sfx(SFX_FRAG_CLICK)` |
| Line 1680 (s2: remove from slot) | `play_sfx(6)` | `play_sfx(SFX_FRAG_CLICK)` |

- [ ] **Step 3: Add footstep audio to update_ship()**

In `update_ship()`, after walk animation toggle (around line 1382), add:

```lua
  -- Walk anim
  if moved then
    G.walk_t = G.walk_t + 1
    if G.walk_t % 8 == 1 then
      play_sfx(SFX_FOOTSTEP)
    end
  else
    G.walk_t = 0; G.robot_frm = 1
  end
```

- [ ] **Step 4: Add door transition SFX**

In `update_ship()`, inside both door transition blocks (lines 1400–1411), add SFX:

```lua
  if room.exits.left and G.robot_x <= TILE + 1 then
    play_sfx(SFX_DOOR)
    -- ... existing transition code
```

Same for the right exit.

- [ ] **Step 5: Add terminal enter/exit SFX**

In `update_ship()` at the Z interaction (line 1432):
```lua
  if btnp(4) and G.near_obj then
    play_sfx(SFX_TERM_ENTER)
    -- ... existing code
```

In `update_terminal()` at X exit (line 1450):
```lua
  if btnp(5) then
    play_sfx(SFX_TERM_EXIT)
    G.state = "ship"
    return
  end
```

- [ ] **Step 6: Add boot sequence and typewriter SFX**

In `update_boot()`, when advancing character (line 1336):
```lua
    if G.boot_t % BOOT_CHAR_SPEED == 0 then
      G.boot_char = G.boot_char + 1
      if G.boot_t % (BOOT_CHAR_SPEED * 3) == 0 then
        play_sfx(SFX_BOOT_CHAR)
      end
    end
```

In `update_vela_log()`, when advancing line (line 1720):
```lua
    if btnp(4) or G.vl_timer >= VL_LINE_DUR then
      G.vl_line = G.vl_line + 1
      G.vl_timer = 0
      play_sfx(SFX_VELA_LINE)
    end
```

- [ ] **Step 7: Add ambient drone loop**

In `TIC()` main loop, after `G.t = G.t + 1`:

```lua
function TIC()
  G.t = G.t + 1

  -- Ambient drone: re-trigger every 4 seconds on channel 0
  if G.state == "ship" and G.t % 240 == 1 then
    local note = 12  -- base note
    if G.cur_room == "engineering" then note = 8 end
    if G.cur_room == "cryo" then note = 6 end
    sfx(SFX_AMBIENT, note, 240, 0)
  end

  update()
  -- ... existing draw dispatch
```

- [ ] **Step 8: Build and verify**

Build and run. Verify:
- Footsteps play while walking
- Door transitions have hiss sound
- Terminal access/exit chirps
- Puzzle correct/incorrect sounds play
- Fragment pick/place clicks
- Boot sequence has terminal blips
- VELA log lines have tone
- Ambient drone plays in ship state, shifts pitch per room

- [ ] **Step 9: Commit**

```bash
git add return-signal.lua
git commit -m "feat: wire all SFX — footsteps, doors, puzzles, ambient drone"
```

---

## Chunk 3: Phase 3 — Transitions & Visual Feedback

### Task 6: Room transition fade

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add fade state), `update_ship()` (trigger fade), `TIC()` (check fade), add `draw_fade()` helper

- [ ] **Step 1: Add fade state to G table**

In G table:

```lua
  -- Fade
  fade_t     = 0,     -- fade counter (0 = no fade)
  fade_max   = 16,    -- total fade frames (8 out + 8 in)
  fade_dest  = nil,   -- {room, x, y} destination after fade midpoint
```

- [ ] **Step 2: Add fade constants**

In `[CONSTANTS]`:

```lua
FADE_HALF = 8   -- frames for fade-out, then same for fade-in
```

- [ ] **Step 3: Modify door transitions to trigger fade**

In `update_ship()`, replace instant room transitions with fade trigger. Replace both door transition blocks:

```lua
  -- Door transitions
  if G.fade_t == 0 then
    if room.exits.left and G.robot_x <= TILE + 1 then
      local dest = room.exits.left
      local dr = ROOMS[dest]
      G.fade_t = 1
      G.fade_dest = {room=dest, x=dr.map_w * TILE - TILE * 3, y=80}
      play_sfx(SFX_DOOR)
    elseif room.exits.right and G.robot_x >= rpw - TILE - ROBOT_W - 1 then
      local dest = room.exits.right
      G.fade_t = 1
      G.fade_dest = {room=dest, x=TILE * 2, y=80}
      play_sfx(SFX_DOOR)
    end
  end
```

- [ ] **Step 4: Add fade processing to TIC()**

In `TIC()`, between `update()` and draw dispatch:

```lua
  -- Process fade
  if G.fade_t > 0 then
    G.fade_t = G.fade_t + 1
    -- At midpoint, swap room
    if G.fade_t == FADE_HALF + 1 and G.fade_dest then
      G.cur_room = G.fade_dest.room
      G.robot_x = G.fade_dest.x
      G.robot_y = G.fade_dest.y
      G.fade_dest = nil
    end
    -- Fade complete
    if G.fade_t > FADE_HALF * 2 then
      G.fade_t = 0
    end
  end
```

- [ ] **Step 5: Skip input during fade**

At top of `update_ship()`:

```lua
function update_ship()
  if G.fade_t > 0 then return end
  -- ... rest of function
```

- [ ] **Step 6: Draw fade overlay**

Add helper function in `[UTIL]`:

```lua
function draw_fade()
  if G.fade_t <= 0 then return end
  local progress
  if G.fade_t <= FADE_HALF then
    progress = G.fade_t / FADE_HALF  -- 0→1 fade out
  else
    progress = 1 - (G.fade_t - FADE_HALF) / FADE_HALF  -- 1→0 fade in
  end
  -- Draw black overlay with increasing opacity via dithered pattern
  for y = 0, SH - 1, 2 do
    for x = 0, SW - 1, 2 do
      if math.random() < progress then
        pix(x, y, C_BG)
        pix(x + 1, y, C_BG)
        pix(x, y + 1, C_BG)
        pix(x + 1, y + 1, C_BG)
      end
    end
  end
end
```

Actually, random dithering per frame will flicker badly. Use a deterministic pattern:

```lua
function draw_fade()
  if G.fade_t <= 0 then return end
  local progress
  if G.fade_t <= FADE_HALF then
    progress = G.fade_t / FADE_HALF
  else
    progress = 1 - (G.fade_t - FADE_HALF) / FADE_HALF
  end
  -- Scanline wipe: fill rows proportional to progress
  local rows = math.floor(SH * progress)
  for y = 0, rows - 1 do
    line(0, y, SW - 1, y, C_BG)
  end
  local bottom_rows = math.floor(SH * progress)
  for y = SH - bottom_rows, SH - 1 do
    line(0, y, SW - 1, y, C_BG)
  end
end
```

Simpler: closing/opening iris from top and bottom:

```lua
function draw_fade()
  if G.fade_t <= 0 then return end
  local progress
  if G.fade_t <= FADE_HALF then
    progress = G.fade_t / FADE_HALF
  else
    progress = 1 - (G.fade_t - FADE_HALF) / FADE_HALF
  end
  local half = math.floor(SH * 0.5 * progress)
  if half > 0 then
    rect(0, 0, SW, half, C_BG)
    rect(0, SH - half, SW, half, C_BG)
  end
end
```

Call `draw_fade()` at the end of `TIC()` after the draw dispatch (draws over everything):

```lua
  -- ... draw dispatch
  end

  draw_fade()
end
```

- [ ] **Step 7: Build and verify**

Walk to a door boundary. Verify:
- Screen darkens from top/bottom
- At midpoint, room swaps
- Screen reopens
- No input accepted during fade

- [ ] **Step 8: Commit**

```bash
git add return-signal.lua
git commit -m "feat: add fade-through-black room transitions"
```

---

### Task 7: Terminal scanline transition

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add terminal transition state), `update_ship()`, `update_terminal()`, `TIC()`, add `draw_scanline_transition()`

- [ ] **Step 1: Add terminal transition state to G**

```lua
  -- Terminal transition
  term_trans    = 0,     -- 0=none, positive=opening, negative=closing
  term_trans_max = 12,
```

- [ ] **Step 2: Trigger scanline transition on terminal enter**

In `update_ship()`, when entering terminal (the Z interaction), instead of immediately setting `G.state`:

```lua
  if btnp(4) and G.near_obj then
    G.interact_t = INTERACT_DUR
    G.term_type = G.near_obj.type
    G.near_obj_label = G.near_obj.label
    G.term_trans = 1  -- start opening transition
    play_sfx(SFX_TERM_ENTER)
  end
```

- [ ] **Step 3: Process terminal transition in TIC()**

In `TIC()`, after fade processing:

```lua
  -- Terminal transition
  if G.term_trans > 0 then
    G.term_trans = G.term_trans + 1
    if G.term_trans > G.term_trans_max then
      G.term_trans = 0
      -- Now actually enter terminal
      if G.term_type == "signal_log" then
        G.state = "terminal"
        G.term_cur = 1
        for i = 1, #TRANSMISSIONS do
          if is_selectable(i) then G.term_cur = i; break end
        end
      else
        G.state = "terminal"
      end
    end
  elseif G.term_trans < 0 then
    G.term_trans = G.term_trans - 1
    if G.term_trans < -G.term_trans_max then
      G.term_trans = 0
      G.state = "ship"
    end
  end
```

- [ ] **Step 4: Trigger close transition on terminal exit**

In `update_terminal()`, replace instant exit:

```lua
  if btnp(5) then
    play_sfx(SFX_TERM_EXIT)
    G.term_trans = -1  -- start closing transition
    return
  end
```

Skip terminal input during closing:

```lua
function update_terminal()
  if G.term_trans ~= 0 then return end
  -- ... rest of function
```

- [ ] **Step 5: Draw scanline transition effect**

```lua
function draw_scanline_trans()
  if G.term_trans == 0 then return end
  local progress
  if G.term_trans > 0 then
    progress = G.term_trans / G.term_trans_max
  else
    progress = math.abs(G.term_trans) / G.term_trans_max
  end
  -- Scanlines sweep down: draw horizontal lines
  local rows = math.floor(SH * progress)
  for y = 0, rows - 1 do
    local col = (y % 2 == 0) and C_BG2 or C_BG
    line(0, y, SW - 1, y, col)
  end
end
```

Call after main draw in `TIC()`:

```lua
  draw_fade()
  draw_scanline_trans()
end
```

- [ ] **Step 6: Build and verify**

Approach terminal, press Z. Verify scanlines sweep down, then terminal appears. Press X. Verify scanlines sweep, then ship view returns.

- [ ] **Step 7: Commit**

```bash
git add return-signal.lua
git commit -m "feat: add scanline transition for terminal enter/exit"
```

---

### Task 8: Camera smoothing

**Files:**
- Modify: `return-signal.lua:1413-1418` — camera logic in `update_ship()`

- [ ] **Step 1: Replace snap camera with lerp**

Replace camera code in `update_ship()`:

```lua
  -- Camera
  room = ROOMS[G.cur_room]
  local target = G.robot_x - math.floor(SW/2) + math.floor(ROBOT_W/2)
  local max_cam = room.map_w * TILE - SW
  if max_cam < 0 then max_cam = 0 end
  target = clamp(target, 0, max_cam)
  G.cam_x = math.floor(G.cam_x + (target - G.cam_x) * 0.15)
```

- [ ] **Step 2: Build and verify**

Walk left and right. Camera should smoothly follow with slight drift, no jittering or tile shimmer.

- [ ] **Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: smooth camera lerp with math.floor for pixel stability"
```

---

### Task 9: Interaction prompt and HUD

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add prompt_fade, prev_near_obj, room_label_t, prev_room), `draw_ship()` (prompt + HUD), `update_ship()` (prompt tracking)

- [ ] **Step 1: Add state fields**

In G table:

```lua
  prompt_fade   = 0,
  prev_near_obj = nil,
  room_label_t  = 0,
  prev_room     = nil,
```

- [ ] **Step 2: Track prompt fade and room change in update_ship()**

After interaction proximity check in `update_ship()`:

```lua
  -- Prompt fade
  if G.near_obj and not G.prev_near_obj then
    G.prompt_fade = 0
    play_sfx(SFX_PROMPT)
  end
  if G.near_obj then
    G.prompt_fade = math.min(G.prompt_fade + 1, 4)
  else
    G.prompt_fade = 0
  end
  G.prev_near_obj = G.near_obj

  -- Room label fade
  if G.cur_room ~= G.prev_room then
    G.room_label_t = 60
    G.prev_room = G.cur_room
  end
  if G.room_label_t > 0 then G.room_label_t = G.room_label_t - 1 end
```

- [ ] **Step 3: Replace interaction prompt drawing**

Replace the current prompt drawing (lines 824–832) with floating prompt above robot:

```lua
  -- Interaction prompt (floating above robot)
  if G.near_obj and G.prompt_fade > 0 then
    local prompt = "Z: " .. G.near_obj.label
    local pw = #prompt * 6
    local px = rx + math.floor(ROBOT_W / 2) - math.floor(pw / 2)
    px = clamp(px, 2, SW - pw - 2)
    local bob = math.floor(math.sin(G.t * 0.1) * 1)
    local py = clamp(ry - 10 + bob, 2, SH - 10)
    local alpha = G.prompt_fade / 4
    if alpha > 0.5 then
      rect(px - 2, py - 1, pw + 4, 9, C_BG)
      rectb(px - 2, py - 1, pw + 4, 9, C_BDR)
      print(prompt, px, py, C_HFNT)
    end
  end
```

- [ ] **Step 4: Replace room label with fading version**

Replace the static room label code (lines 809–814):

```lua
  -- Room label (fades in on entry)
  if G.room_label_t > 0 then
    local room_labels = {
      bridge="BRIDGE", comms="COMMS", cryo="CRYO BAY", engineering="ENGINEERING"
    }
    local label = room_labels[G.cur_room] or ""
    local col = G.room_label_t > 30 and C_DIM or C_BG2
    print(label, 4, 2, col)
  end

  -- Decoded count HUD
  local dc = decoded_count()
  if dc > 0 then
    local hud = dc .. "/8"
    print(hud, SW - #hud * 6 - 4, 2, C_DIM)
  end
```

- [ ] **Step 5: Build and verify**

Walk between rooms. Verify:
- Room name appears on entry, fades after ~1 second
- Decoded count shows in top-right (after decoding at least one TX)
- Interaction prompt floats above robot head, fades in, bobs gently
- Prompt appears with subtle ping sound

- [ ] **Step 6: Commit**

```bash
git add return-signal.lua
git commit -m "feat: floating interaction prompt, fading room label, decoded HUD"
```

---

### Task 10: Enhanced puzzle feedback

**Files:**
- Modify: `return-signal.lua` — `draw_puzzle_s1()` (green pulse, red border), `draw_puzzle_s2()` (noise overlay), `[STATE]` (add s1_pulse_t)

- [ ] **Step 1: Add pulse state**

In G table:

```lua
  s1_pulse_t  = 0,
  s1_pulse_gi = 0,
```

- [ ] **Step 2: Trigger pulse on correct Stage 1 placement**

In `update_puzzle_s1()`, after correct placement (line 1527–1528):

```lua
            G.s1_placed[gi] = G.s1_held
            G.s1_pulse_t = 8
            G.s1_pulse_gi = gi
            G.s1_held = nil
```

- [ ] **Step 3: Add green pulse to Stage 1 draw**

In `update_puzzle_s1()`, near the top where `s1_shake_t` is decremented, add:

```lua
  if G.s1_pulse_t > 0 then G.s1_pulse_t = G.s1_pulse_t - 1 end
```

In `draw_puzzle_s1()` (around line 1017), after drawing gap regions, add:

```lua
  -- Green pulse on recently placed gap
  if G.s1_pulse_t > 0 then
    local gr = gap_ranges[G.s1_pulse_gi]
    if gr then
      local expand = G.s1_pulse_t
      rectb(gr.x0 - expand, WCY - 12 - expand, gr.x1 - gr.x0 + expand * 2, 24 + expand * 2, C_OK)
    end
  end
```

- [ ] **Step 4: Add red border flash on Stage 1 incorrect**

In `draw_puzzle_s1()`, when `G.s1_shake_t > 0`:

```lua
  if G.s1_shake_t > 0 then
    rectb(0, 0, SW, SH, C_ERR)
    rectb(1, 1, SW - 2, SH - 2, C_ERR)
  end
```

- [ ] **Step 5: Add static noise overlay on Stage 2 wrong slots**

In `draw_puzzle_s2()`, when `G.s2_err_t > 0`, after drawing error-flashed slots, add:

```lua
  -- Static noise on wrong slots
  if G.s2_err_t > 0 then
    for si = 1, ns do
      if G.s2_err_sl[si] then
        local sx = slot_x(si)
        local sy = slot_y(si)
        for ny = sy, sy + SLOT_H - 1, 3 do
          for nx = sx, sx + slot_w - 1, 3 do
            if (nx + ny + G.t) % 4 == 0 then
              pix(nx, ny, C_DIM)
            end
          end
        end
      end
    end
  end
```

Note: The exact slot position functions will need to match how `draw_puzzle_s2` currently calculates slot positions. Read those coordinates from the existing draw code.

- [ ] **Step 6: Build and verify**

Enter a puzzle. Verify:
- Correct fragment placement shows expanding green rectangle
- Incorrect shows red border + shake
- Stage 2 wrong slots show static noise pattern

- [ ] **Step 7: Commit**

```bash
git add return-signal.lua
git commit -m "feat: enhanced puzzle feedback — pulse, border flash, static noise"
```

---

## Chunk 4: Phase 4 — Onboarding & UX

### Task 11: First-time hint system

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add hints_shown, hint_t, hint_text), `update_boot()`, `update_ship()`, `update_terminal()`, `update_puzzle()`, `draw_ship()`, draw functions for hint overlay

- [ ] **Step 1: Add hint state to G**

```lua
  hints_shown = {},
  hint_t      = 0,
  hint_text   = "",
```

- [ ] **Step 2: Add hint helper functions**

In `[UTIL]`:

```lua
function show_hint(id, text, duration)
  if G.hints_shown[id] then return end
  G.hints_shown[id] = true
  G.hint_text = text
  G.hint_t = duration
end

function update_hint()
  if G.hint_t > 0 then G.hint_t = G.hint_t - 1 end
end

function draw_hint_overlay()
  if G.hint_t <= 0 then return end
  local alpha = 1
  if G.hint_t < 20 then alpha = G.hint_t / 20 end
  if alpha > 0.5 then
    local tw = #G.hint_text * 6
    local tx = math.floor((SW - tw) / 2)
    rect(tx - 4, 14, tw + 8, 12, C_BG2)
    rectb(tx - 4, 14, tw + 8, 12, C_BDR)
    print(G.hint_text, tx, 17, C_TXT)
  end
end
```

- [ ] **Step 3: Trigger hints at key moments**

In `update_boot()`, when transitioning to ship (line 1346):
```lua
    if G.boot_t >= 90 or btnp(4) then
      G.state = "ship"
      -- ... existing code
      show_hint("first_ship", "signal detected on comms array. routing to terminal.", 120)
    end
```

In `update_ship()`, when `near_obj` becomes the comms terminal for the first time:
```lua
  if G.near_obj and G.near_obj.type == "signal_log" and not G.hints_shown["first_comms"] then
    G.hints_shown["first_comms"] = true
  end
```

In `draw_ship()`, make the interaction prompt pulse brighter on first comms approach. In the prompt drawing code, replace the static `C_HFNT` color:
```lua
    local prompt_col = C_HFNT
    if G.near_obj.type == "signal_log" and G.hints_shown["first_comms"] and not G.hints_shown["first_comms_done"] then
      -- Pulse brighter: alternate between white and cyan
      prompt_col = (math.floor(G.t / 10) % 2 == 0) and C_WHITE or C_HFNT
    end
    print(prompt, px, py, prompt_col)
```

Mark the pulse as done when the player enters the terminal:
```lua
  -- In update_ship() Z interaction, after entering comms terminal:
  if G.near_obj.type == "signal_log" then
    G.hints_shown["first_comms_done"] = true
  end
```

In `update_terminal()`, after entering signal log for the first time:
```lua
  if G.term_type == "signal_log" then
    show_hint("first_log", "incoming signal -- select to decode", 120)
```

In `update_puzzle()`, at start of stage 1:
```lua
function update_puzzle()
  if G.puz_stage == 1 then
    show_hint("first_s1", "match fragments to gaps in the waveform", 180)
    update_puzzle_s1()
  else
    show_hint("first_s2", "arrange fragments in sequence", 180)
    update_puzzle_s2()
  end
end
```

- [ ] **Step 4: Wire hint update and draw into relevant states**

Call `update_hint()` at the top of `update()` (in the main update dispatch, before state-specific updates).

Call `draw_hint_overlay()` at end of `draw_ship()`, `draw_terminal()`, and `draw_puzzle()`.

- [ ] **Step 5: Build and verify**

Start new game. Verify:
- "signal detected" hint appears after boot
- "incoming signal" hint appears near comms terminal
- Stage 1 and Stage 2 hints appear once each
- Hints fade out, don't repeat

- [ ] **Step 6: Commit**

```bash
git add return-signal.lua
git commit -m "feat: first-time hint system with fade-out"
```

---

### Task 12: Puzzle exit confirmation

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add puz_confirm), `update_puzzle_s1()`, `update_puzzle_s2()`, `draw_puzzle()`

- [ ] **Step 1: Add confirmation state**

In G table:
```lua
  puz_confirm = false,
```

- [ ] **Step 2: Handle confirmation in puzzle updates**

At the top of both `update_puzzle_s1()` and `update_puzzle_s2()`, add:

```lua
  -- Exit confirmation
  if G.puz_confirm then
    if btnp(4) then  -- Z: yes, abort
      G.puz_confirm = false
      G.state = "terminal"
      return
    elseif btnp(5) then  -- X: no, resume
      G.puz_confirm = false
      return
    end
    return  -- skip all other input
  end
```

Then change the existing X-exit handling. Currently puzzles exit via the terminal's X handler. Find where X exits during puzzle and replace with confirmation trigger. Looking at the code — actually, puzzles don't have an X exit currently. The terminal does. Let me check: `update_puzzle_s1` and `update_puzzle_s2` don't check for `btnp(5)` to exit — only the terminal update does. So we need to add X handling to puzzles:

In `update_puzzle_s1()`, before the existing `btnp(5)` checks (which are used to drop held fragment):

Actually, `btnp(5)` in stage 1 (line 1548) is used to drop held fragment or go back to frag mode. In stage 2 (line 1678), it drops held or removes from slot. We need to distinguish: X when nothing is held = exit attempt.

Add to `update_puzzle_s1()`:
```lua
  -- X with nothing held = exit attempt
  if G.s1_mode == "frags" and not G.s1_held and btnp(5) then
    G.puz_confirm = true
    return
  end
```

Add to `update_puzzle_s2()`:
```lua
  if not G.s2_held and btnp(5) and G.s2_phase == "place" then
    local any_placed = false
    for s = 1, #TRANSMISSIONS[G.tx_idx].seq do
      if G.s2_slots[s] then any_placed = true; break end
    end
    if not any_placed then
      -- Nothing placed, just exit
      G.puz_confirm = true
      return
    else
      G.puz_confirm = true
      return
    end
  end
```

- [ ] **Step 3: Draw confirmation overlay**

In `draw_puzzle()`, after drawing the puzzle stage, add:

```lua
function draw_puzzle()
  if G.puz_stage == 1 then draw_puzzle_s1()
  else draw_puzzle_s2() end

  -- Exit confirmation overlay
  if G.puz_confirm then
    rect(40, 50, 160, 36, C_BG)
    rectb(40, 50, 160, 36, C_ERR)
    local t1 = "ABORT DECODE?"
    print(t1, math.floor((SW - #t1 * 6) / 2), 56, C_WHITE)
    local t2 = "Z:YES  X:NO"
    print(t2, math.floor((SW - #t2 * 6) / 2), 70, C_DIM)
  end

  draw_hint_overlay()
end
```

- [ ] **Step 4: Build and verify**

Enter a puzzle. Press X (with nothing held). Verify:
- "ABORT DECODE?" overlay appears
- Z exits to terminal
- X dismisses overlay and resumes puzzle

- [ ] **Step 5: Commit**

```bash
git add return-signal.lua
git commit -m "feat: puzzle exit confirmation dialog"
```

---

### Task 13: Replay decoded transmissions

**Files:**
- Modify: `return-signal.lua` — `[STATE]` (add replay flag), `update_terminal()`, `update_vela_log()`, `draw_vela_log()`, `draw_terminal_signal_log()`

- [ ] **Step 1: Add replay state**

In G table:
```lua
  replay        = false,
  replay_msg    = "",
  replay_phase  = "msg",  -- "msg" or "log"
```

- [ ] **Step 1b: Reset replay flags on title return**

In `update_ending()`, where the game returns to title (line 1770), add replay flag resets:

```lua
    if btnp(4) then
      -- Reset to title
      G.state = "title"
      G.decoded = {}
      G.t = 0
      G.replay = false
      G.replay_msg = ""
      G.replay_phase = "msg"
      G.hints_shown = {}
      G.hint_t = 0
    end
```

This also resets hints so they re-appear on a new playthrough.

- [ ] **Step 2: Update terminal signal log to allow selecting decoded entries**

In `draw_terminal_signal_log()`, change the hint bar for decoded entries (line 877–878):

```lua
  elseif G.decoded[G.term_cur] then
    hint = "Z: READ LOG   X: EXIT"
```

In `update_terminal()`, update the Z handler for signal_log (line 1460):

```lua
    if btnp(4) then
      if is_available(G.term_cur) and not G.decoded[G.term_cur] then
        G.tx_idx = G.term_cur
        init_stage1(G.term_cur)
        G.state = "puzzle"
      elseif G.decoded[G.term_cur] then
        -- Replay decoded transmission
        G.tx_idx = G.term_cur
        local tx = TRANSMISSIONS[G.term_cur]
        local parts = {}
        for _, s in ipairs(tx.seq) do parts[#parts + 1] = s end
        G.replay_msg = table.concat(parts, " // ")
        G.replay = true
        G.replay_phase = "msg"
        G.state = "vela_log"
        init_vela_log()
      end
    end
```

- [ ] **Step 3: Update draw_vela_log() for replay mode**

Modify `draw_vela_log()` to show decoded message first:

```lua
function draw_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]

  cls(C_BG)

  if G.replay and G.replay_phase == "msg" then
    -- Show decoded message
    rect(0, 0, SW, 10, C_BG2)
    print("VELA // DECODED MESSAGE // " .. tx.id, 4, 2, C_HFNT)
    draw_divider(10)
    local lines_out = {}
    local remaining = G.replay_msg
    while remaining and #remaining > 0 do
      local l, r = word_wrap(remaining, 36)
      lines_out[#lines_out + 1] = l
      remaining = r
    end
    for i, ln in ipairs(lines_out) do
      print(ln, 8, 14 + (i - 1) * 10, C_TXT)
    end
    draw_divider(119)
    rect(0, 120, SW, 16, C_BG2)
    print("Z: VIEW VELA LOG", SW - 17 * 6 - 4, 126, C_DIM)
    return
  end

  -- Normal VELA log display (existing code)
  local vela = tx.vela
  rect(0, 0, SW, 10, C_BG2)
  print("VELA // INTERNAL LOG // " .. tx.id, 4, 2, C_HFNT)
  draw_divider(10)

  for i = 1, G.vl_line do
    if i <= #vela and #vela[i] > 0 then
      print(vela[i], 8, 14 + (i-1) * 12, C_WHITE)
    end
  end

  draw_divider(119)
  rect(0, 120, SW, 16, C_BG2)
  if G.vl_done then
    local p = "Z: CONTINUE"
    print(p, SW - #p*6 - 4, 126, C_DIM)
  end
end
```

- [ ] **Step 4: Update update_vela_log() for replay mode**

Modify `update_vela_log()`:

```lua
function update_vela_log()
  -- Replay message phase: Z advances to log
  if G.replay and G.replay_phase == "msg" then
    if btnp(4) then
      G.replay_phase = "log"
      init_vela_log()
    end
    return
  end

  local tx = TRANSMISSIONS[G.tx_idx]
  local vela = tx.vela

  if G.vl_done then
    if btnp(4) then
      if G.replay then
        -- Return to terminal without re-marking decoded
        G.replay = false
        G.state = "terminal"
      else
        G.decoded[G.tx_idx] = true
        if G.tx_idx == 8 then
          G.state = "ending"
          G.end_stage = 1
          G.end_t = 0
          G.end_char = 0
          G.end_done = false
        else
          G.state = "ship"
        end
      end
    end
    return
  end

  -- ... rest of existing vela log update (line advance)
```

- [ ] **Step 5: Build and verify**

Decode TX-001. Return to signal log. Select TX-001 (should show "[DECODED]"). Press Z. Verify:
- Decoded message text appears
- Z advances to VELA log
- Z again returns to terminal (not ship)
- TX-001 stays decoded, no re-marking

- [ ] **Step 6: Commit**

```bash
git add return-signal.lua
git commit -m "feat: replay decoded transmissions from signal log"
```

---

### Task 14: Visual difficulty reinforcement

**Files:**
- Modify: `return-signal.lua` — `draw_puzzle_s1()` (add static noise proportional to TX index)

- [ ] **Step 1: Add visual noise to waveform display**

In `draw_puzzle_s1()`, after drawing the target waveform, add noise scaled by TX index:

```lua
  -- Visual noise — increases with TX number
  local noise_level = G.tx_idx - 1  -- 0 for TX-001, 7 for TX-008
  if noise_level > 0 then
    for i = 1, noise_level * 3 do
      local nx = WAVE_X0 + math.random(0, WAVE_W)
      local ny = WCY + math.random(-15, 15)
      pix(nx, ny, C_DIM)
    end
    -- Static bars for higher levels
    if noise_level >= 4 then
      for i = 1, noise_level - 3 do
        local bx = WAVE_X0 + math.random(0, WAVE_W - 10)
        local by = WCY + math.random(-10, 10)
        line(bx, by, bx + math.random(4, 10), by, C_BDR)
      end
    end
  end
```

- [ ] **Step 2: Build and verify**

Decode through several transmissions. Verify later puzzles have progressively more visual noise/static on the waveform display.

- [ ] **Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: visual static noise scales with transmission difficulty"
```

---

## Chunk 5: Phase 5 — Environmental Storytelling

### Task 15: Ship environmental progression

**Files:**
- Modify: `return-signal.lua` — `build_room()` (tile swaps based on decoded count), `draw_ship()` (overlay effects), `update_ship()` (contextual idle)

- [ ] **Step 1: Add rebuild_room() function**

In `[MAP]` section after `init_map()`:

```lua
function rebuild_room(name)
  build_room(name)
  local room = ROOMS[name]
  local dc = decoded_count()
  local mx, my = room.map_x, room.map_y
  local h = room.map_h

  -- Cryo pod warming (7+ decoded): swap frost tiles to warm clear glass
  if name == "cryo" and dc >= 7 then
    local pod_xs = {7, 12, 17, 22}
    for _, px in ipairs(pod_xs) do
      for ty = h - 5, h - 3 do
        mset(mx + px, my + ty, T_CRYO_L_WARM)
        mset(mx + px + 1, my + ty, T_CRYO_R_WARM)
      end
    end
  end
end
```

- [ ] **Step 2: Call rebuild_room() after decoding a transmission**

In `update_vela_log()`, after `G.decoded[G.tx_idx] = true`:

```lua
      G.decoded[G.tx_idx] = true
      -- Rebuild current room to reflect progression
      for _, name in ipairs(ROOM_ORDER) do
        rebuild_room(name)
      end
```

- [ ] **Step 3: Add draw-based environmental overlays in draw_ship()**

After the `map()` call in `draw_ship()`, add progression overlays:

```lua
  -- Environmental progression overlays
  local dc = decoded_count()

  -- Comms signal indicator (1+ decoded)
  if G.cur_room == "comms" and dc >= 1 then
    local blink = math.floor(G.t / 20) % 2
    if blink == 0 then
      pix(112 - math.floor(G.cam_x), 42, C_OK)
    end
  end

  -- Nav console text (3+ decoded)
  if G.cur_room == "bridge" and dc >= 3 then
    local sx = 48 - math.floor(G.cam_x)
    print("SIG", sx, 100, C_OK)
  end

  -- Cryo pod flicker (3+ decoded)
  if G.cur_room == "cryo" and dc >= 3 then
    if G.t % 180 < 3 then
      local fx = 56 - math.floor(G.cam_x)
      rectb(fx, 88, 12, 24, C_ERR)
    end
  end

  -- Viewport Earth glow (5+ decoded)
  if G.cur_room == "bridge" and dc >= 5 then
    local wx = 160 - math.floor(G.cam_x)
    local pulse = math.floor(math.sin(G.t * 0.03) * 2)
    circ(wx, 48, 3 + pulse, C_WARM)
  end
```

- [ ] **Step 4: Add contextual robot idle behavior**

In `update_ship()`, after movement and before camera:

```lua
  -- Contextual idle (not walking, periodic)
  if G.walk_t == 0 and G.t % 300 == 0 then
    local dc = decoded_count()
    if dc >= 5 and G.cur_room == "cryo" then
      -- VELA looks at nearest cryo pod: brief direction flip
      G.robot_dir = -G.robot_dir
    end
  end
```

- [ ] **Step 5: Adjust ambient drone pitch by progression**

In `TIC()`, modify the ambient drone trigger to account for progression:

```lua
  if G.state == "ship" and G.t % 240 == 1 then
    local note = 12
    if G.cur_room == "engineering" then note = 8 end
    if G.cur_room == "cryo" then note = 6 end
    -- Progression: pitch shifts up as more decoded
    local dc = decoded_count()
    if dc >= 6 then note = note + 2 end
    if dc >= 8 then note = note + 4 end
    sfx(SFX_AMBIENT, note, 240, 0)
  end
```

- [ ] **Step 6: Build and verify**

Play through several transmissions. Verify:
- Comms signal indicator appears after first decode
- Nav console changes after 3 decodes
- Cryo pod flickers occasionally after 3 decodes
- Earth glow appears in viewport after 5 decodes
- Cryo pods warm (tile swap) after 7 decodes
- Ambient drone pitch rises in late game
- Robot occasionally flips direction when idle in cryo (5+ decoded)

- [ ] **Step 7: Commit**

```bash
git add return-signal.lua
git commit -m "feat: environmental storytelling — ship changes as transmissions decode"
```

---

### Task 16: Static environmental detail sprites

**Files:**
- Modify: `return-signal.lua` — `draw_ship()` (draw detail sprites), `<TILES>` (detail sprite data at indices 48–51)

- [ ] **Step 1: Add detail sprite data**

Add to `<TILES>` section at indices 48–51:

```
-- 048:0000000000099000009aa90000999000000000000000000000000000000000000
-- 049:000000000000f000000ff00000fff0000ffff0000000000000000000000000000
-- 050:0000000000000f0000f0f000000f0000000000000000000000000000000000000
-- 051:0000000000600060006006000060600000000000000000000000000000000000
```

- 048: Mug (orange/amber small object)
- 049: Tool marks (gray scratches)
- 050: Scuff marks (subtle gray)
- 051: Signal indicator (green dots pattern)

- [ ] **Step 2: Draw static detail sprites in draw_ship()**

After environmental progression overlays, add:

```lua
  -- Static environmental details
  if G.cur_room == "comms" then
    -- Mug on console edge
    spr(48, 104 - math.floor(G.cam_x), 92, 0)
  end
  if G.cur_room == "bridge" then
    -- Tool marks near nav console
    spr(49, 64 - math.floor(G.cam_x), 100, 0)
  end
  if G.cur_room == "engineering" then
    -- Scuff marks on floor near grates
    spr(50, 72 - math.floor(G.cam_x), 112, 0)
  end
```

- [ ] **Step 3: Build and verify**

Walk through all rooms. Verify mug, tool marks, and scuff marks are visible at the expected positions.

- [ ] **Step 4: Commit**

```bash
git add return-signal.lua
git commit -m "feat: static environmental detail sprites in ship rooms"
```

---

## Final Notes

- All sprite hex data in `<TILES>` and `<SFX>` sections are initial placeholders. They should be refined in TIC-80's built-in editors for visual/audio quality.
- The ambient tile animation (Task 2) swaps tiles in the map every 30 frames. If this causes visible popping, adjust the interval or add intermediate frames.
- Camera lerp factor (0.15) may need tuning — lower = more drift, higher = snappier.
- Fade duration (8 frames each way = ~0.27 sec total) should feel brisk. Increase to 12 if it feels too fast.
