# Return Signal — Phase 1 Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build one complete transmission (TX-001) playable end-to-end in TIC-80: title → hub → stage 1 waveform → stage 2 sequencing → VELA log → hub.

**Architecture:** Single-file Lua cart (`return-signal.lua`) organized in labeled sections. All game state lives in a master `G` table. Draw functions are pure rendering (no mutation). All input handling and state transitions happen in `update()`. Data for all 8 TXs is defined; only TX-001 puzzles need to work in Phase 1.

**Tech Stack:** TIC-80 / Lua (no `//` operator — use `math.floor()` for all integer division). 240x136px, 16-color palette, d-pad + Z/X input.

**Reference:** Full PRD at `Docs/return-signal-prd.docx` (extracted text). Kickoff doc at `Docs/claude-code-kickoff.md`.

**Critical Lua Compatibility Note:** TIC-80's Lua does NOT support the `//` floor division operator. Use `math.floor(a / b)` everywhere. Violating this will cause a silent parse error and blank screen.

---

## Task 1: Scaffold — Constants, Data, State, Main Loop

**Files:**
- Create: `return-signal.lua`
- Delete: existing `return-signal.lua` (stale first attempt)

**Goal:** File loads in TIC-80 with no errors. Black screen, no crash.

**Step 1: Write the complete scaffold**

Write `return-signal.lua` with these sections. All draw/update functions are stubs that do nothing yet.

```lua
-- title:  Return Signal
-- author: mortegaux
-- desc:   Narrative puzzle game
-- script: lua

-------------------------------
-- [CONSTANTS]
-------------------------------

-- Colors (TIC-80 default palette indices)
C_BG   = 0   -- black background
C_BG2  = 8   -- dark blue — headers, slot fills
C_BDR  = 15  -- dark gray — borders, dividers
C_DIM  = 15  -- dim — placeholder text, hints, locked
C_HFNT = 11  -- cyan — header text, status text
C_TXT  = 13  -- light blue-gray — body text
C_WHITE= 12  -- white — known waveform, VELA log body
C_SEL  = 4   -- yellow — selected/held fragment
C_OK   = 6   -- green — correct placement, decoded
C_ERR  = 2   -- red — wrong placement flash
C_CUR  = 4   -- yellow — cursor highlight

-- Screen dimensions
SW = 240
SH = 136

-- Waveform area bounds (Stage 1)
WAVE_X0 = 10
WAVE_X1 = 230
WAVE_W  = 220   -- WAVE_X1 - WAVE_X0
WCY     = 45    -- waveform vertical center (y=45 per PRD)

-- Fragment / gap box
FRAG_W   = 44   -- max fragment box width
FRAG_H   = 26   -- fragment box height
FRAG_GAP = 2    -- px between fragment boxes

-- Stage 2 slot
SLOT_H = 26

-- Timing
SHAKE_DUR    = 4    -- incorrect placement shake frames
FLASH_DUR    = 16   -- stage-complete flash frames
ERR_FLASH    = 20   -- wrong slot error flash frames
TW_SPEED     = 2    -- typewriter: 1 char per N frames
VL_LINE_DUR  = 40   -- VELA log: frames per line reveal
VL_PAUSE     = 60   -- pause after last typewriter char
BLINK_RATE   = 30   -- title screen prompt blink

-- Hub
HUB_ENTRY_H = 13

-------------------------------
-- [DATA]
-------------------------------

TRANSMISSIONS = {
  { -- TX-001: Year 5, Early Collapse
    id="TX-001", origin="EARTH-SECTOR-7", year=5,
    target_amp=8, target_freq=0.15,
    gap_pos={0.25, 0.65},
    frags={
      {amp=8,  freq=0.15, gap=1},
      {amp=5,  freq=0.22, gap=2},
      {amp=10, freq=0.12, gap=nil},
      {amp=6,  freq=0.28, gap=nil},
    },
    seq={
      "COMMUNICATIONS GRID IS DOWN",
      "NO RESPONSE FROM CENTRAL",
      "MANAGING LOCALLY FOR NOW",
    },
    seq_sol={1, 2, 3},
    seq_dec={},
    vela={
      "signal recovered.",
      "content noted.",
      "no action required.",
    },
  },
  { -- TX-002: Year 12, First Organization
    id="TX-002", origin="UNKNOWN", year=12,
    target_amp=7, target_freq=0.18,
    gap_pos={0.30, 0.70},
    frags={
      {amp=7, freq=0.18, gap=1},
      {amp=9, freq=0.14, gap=2},
      {amp=11,freq=0.20, gap=nil},
      {amp=5, freq=0.11, gap=nil},
    },
    seq={
      "SMALL GROUPS NEAR THE WATER",
      "KNOWLEDGE WRITTEN DOWN AGAIN",
      "THIS IS WORTH CONTINUING",
    },
    seq_sol={1, 2, 3},
    seq_dec={"GRID STABLE IN SECTOR 9"},
    vela={
      "unexpected detail in transmission.",
      "logging for pattern analysis.",
    },
  },
  { -- TX-003: Year 2, First Failures
    id="TX-003", origin="EARTH-SECTOR-2", year=2,
    target_amp=6, target_freq=0.20,
    gap_pos={0.20, 0.50, 0.80},
    frags={
      {amp=6, freq=0.20, gap=1},
      {amp=9, freq=0.13, gap=2},
      {amp=5, freq=0.27, gap=3},
      {amp=11,freq=0.17, gap=nil},
      {amp=7, freq=0.31, gap=nil},
    },
    seq={
      "POWER FLUCTUATIONS NORTHERN GRID",
      "SATELLITE COMMS DEGRADING",
      "CAUSE UNKNOWN",
      "LOGGING FOR REVIEW",
    },
    seq_sol={1, 2, 3, 4},
    seq_dec={"GRID STABLE IN SECTOR 9"},
    vela={
      "this transmission contains",
      "data outside expected parameters.",
      "reviewing.",
    },
  },
  { -- TX-004: Year 25, The Rebuilt Network
    id="TX-004", origin="NORTH-SETTLEMENT", year=25,
    target_amp=8, target_freq=0.16,
    gap_pos={0.20, 0.50, 0.80},
    frags={
      {amp=8,  freq=0.16, gap=1},
      {amp=5,  freq=0.24, gap=2},
      {amp=10, freq=0.11, gap=3},
      {amp=7,  freq=0.20, gap=nil},
      {amp=12, freq=0.14, gap=nil},
      {amp=4,  freq=0.29, gap=nil},
    },
    seq={
      "SEVENTEEN SETTLEMENTS IN CONTACT",
      "WE HAVE TEACHERS AGAIN",
      "THE ARCHIVE IS GROWING",
      "ROUTE NORTH IS CLEAR",
    },
    seq_sol={1, 2, 3, 4},
    seq_dec={"COMMS RELAY RESTORED SECTOR 3"},
    vela={
      "cross-referencing sender coordinates.",
      "results inconsistent with prior models.",
    },
  },
  { -- TX-005: Year 8, The Worst Period
    id="TX-005", origin="UNKNOWN", year=8,
    target_amp=5, target_freq=0.21,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=5,  freq=0.21, gap=1},
      {amp=8,  freq=0.15, gap=2},
      {amp=11, freq=0.12, gap=3},
      {amp=7,  freq=0.26, gap=4},
      {amp=9,  freq=0.18, gap=nil},
      {amp=4,  freq=0.30, gap=nil},
    },
    seq={
      "THE COUNT IS DIFFICULT",
      "WE DO NOT SAY THE NUMBER",
      "WE PLANT ANYWAY",
      "HARVEST BELOW THRESHOLD",
    },
    seq_sol={1, 2, 3, 4},
    seq_dec={"SIGNAL LOST AT STATION 7","REQUESTING EVACUATION"},
    vela={
      "sender profile matches",
      "departure manifest entry.",
      "probability: 94.7%.",
    },
  },
  { -- TX-006: Year 18, Stable Settlement
    id="TX-006", origin="NORTH-SETTLEMENT", year=18,
    target_amp=6, target_freq=0.19,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=6,  freq=0.19, gap=1},
      {amp=9,  freq=0.13, gap=2},
      {amp=12, freq=0.22, gap=3},
      {amp=5,  freq=0.16, gap=4},
      {amp=8,  freq=0.28, gap=nil},
      {amp=10, freq=0.11, gap=nil},
      {amp=7,  freq=0.25, gap=nil},
    },
    seq={
      "FIRST HARVEST ABOVE THRESHOLD",
      "NORTH SETTLEMENT IS PERMANENT",
      "NOT REBUILDING THE OLD WORLD",
      "BUILDING SOMETHING ELSE",
      "ROUTE SOUTH STILL HAZARDOUS",
    },
    seq_sol={1, 2, 3, 4, 5},
    seq_dec={"SECTOR 4 HAS A SCHOOL NOW"},
    vela={
      "unable to classify",
      "current processing state.",
      "continuing analysis.",
    },
  },
  { -- TX-007: Year 34, Direct to Ardent
    id="TX-007", origin="YUNA-PARK", year=34,
    target_amp=7, target_freq=0.17,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=7,  freq=0.17, gap=1},
      {amp=10, freq=0.23, gap=2},
      {amp=5,  freq=0.13, gap=3},
      {amp=9,  freq=0.20, gap=4},
      {amp=12, freq=0.15, gap=nil},
      {amp=6,  freq=0.28, gap=nil},
    },
    seq={
      "ARDENT IF YOU RECEIVE THIS",
      "WE CALCULATED YOUR PATH",
      "TRANSMITTING SIX YEARS",
      "EARTH IS NOT WHAT YOU LEFT",
      "IT IS NOT NOTHING EITHER",
    },
    seq_sol={1, 2, 3, 4, 5},
    seq_dec={"ALL RELAYS CONFIRM SILENT","SECTOR 12 HAS COLLAPSED"},
    vela={
      "i recognize this person.",
      "i did not expect",
      "to recognize anyone.",
    },
  },
  { -- TX-008: Year 40, Yuna Park
    id="TX-008", origin="YUNA-PARK", year=40,
    target_amp=8, target_freq=0.14,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=8,  freq=0.14, gap=1},
      {amp=5,  freq=0.22, gap=2},
      {amp=11, freq=0.18, gap=3},
      {amp=7,  freq=0.26, gap=4},
      {amp=9,  freq=0.12, gap=nil},
      {amp=6,  freq=0.20, gap=nil},
      {amp=10, freq=0.30, gap=nil},
    },
    seq={
      "THIS IS YUNA PARK",
      "I DO NOT KNOW IF YOU RUN",
      "I LOGGED 847 INTERACTIONS",
      "I REMEMBERED YOUR PATTERNS",
      "WE REBUILT ENOUGH",
      "ARDENT RETURN TO EARTH",
    },
    seq_sol={1, 2, 3, 4, 5, 6},
    seq_dec={"ALL SECTORS REPORT STABLE"},
    vela={
      "an order requires a decision-maker.",
      "the crew is in cryo.",
      "i cannot alter course alone.",
      "",
      "transmitting response.",
      "waking the crew.",
    },
  },
}

-------------------------------
-- [STATE]
-------------------------------

G = {
  state     = "title",
  tx_idx    = 1,
  decoded   = {},
  t         = 0,
  -- Stage 1
  s1_cursor  = 1,
  s1_held    = nil,
  s1_gap_cur = 1,
  s1_mode    = "frags",  -- "frags" or "gaps"
  s1_placed  = {},
  s1_order   = {},
  s1_shake_t = 0,
  s1_flash_t = 0,
  -- Stage 2
  s2_slots   = {},
  s2_pool    = {},
  s2_held    = nil,
  s2_row     = 1,    -- 0=slots, 1=pool
  s2_col     = 1,
  s2_err_t   = 0,
  s2_err_sl  = {},
  s2_phase   = "place", -- "place","typewriter","done"
  s2_tw_text = "",
  s2_tw_pos  = 0,
  s2_tw_t    = 0,
  s2_pause_t = 0,
  -- VELA log
  vl_line    = 0,
  vl_timer   = 0,
  vl_done    = false,
  -- Hub
  hub_cur    = 1,
}

-------------------------------
-- [UTIL]
-------------------------------

-- (Task 2 adds utility functions here)

-------------------------------
-- [DRAW_TITLE]
-------------------------------

function draw_title()
  cls(C_BG)
end

-------------------------------
-- [DRAW_HUB]
-------------------------------

function draw_hub()
  cls(C_BG)
end

-------------------------------
-- [DRAW_STAGE1]
-------------------------------

function draw_stage1()
  cls(C_BG)
end

-------------------------------
-- [DRAW_STAGE2]
-------------------------------

function draw_stage2()
  cls(C_BG)
end

-------------------------------
-- [DRAW_VELA]
-------------------------------

function draw_vela_log()
  cls(C_BG)
end

-------------------------------
-- [UPDATE]
-------------------------------

function update()
  -- (Task 3+ adds input handling per state)
end

-------------------------------
-- [TIC]
-------------------------------

function TIC()
  G.t = G.t + 1
  update()
  if G.state == "title" then
    draw_title()
  elseif G.state == "hub" then
    draw_hub()
  elseif G.state == "stage1" then
    draw_stage1()
  elseif G.state == "stage2" then
    draw_stage2()
  elseif G.state == "vela_log" then
    draw_vela_log()
  end
end
```

**Step 2: Verify**

Load in TIC-80: `tic80 --fs /path/to/project --cmd "load return-signal.lua"`

Expected: Black screen, no error messages, no crash. Press buttons — nothing happens (all stubs).

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: scaffold constants, all 8 TX data, state table, main loop"
```

---

## Task 2: Utility Functions

**Files:**
- Modify: `return-signal.lua` — replace `[UTIL]` section

**Goal:** All shared rendering and logic helpers available for subsequent tasks.

**Step 1: Write utility functions**

Replace the `-- [UTIL]` section with:

```lua
-------------------------------
-- [UTIL]
-------------------------------

-- PRD-validated compound sine waveform renderer
function draw_wave(x, y, w, amp, freq, col)
  for i = 0, w - 2 do
    local y1 = y + math.floor(
      math.sin(i * freq) * amp +
      math.sin(i * freq * 2) * amp * 0.4)
    local y2 = y + math.floor(
      math.sin((i + 1) * freq) * amp +
      math.sin((i + 1) * freq * 2) * amp * 0.4)
    line(x + i, y1, x + i + 1, y2, col)
  end
end

-- PRD-specified word wrap: returns line1, line2
function word_wrap(text, max_chars)
  local words = {}
  for w in text:gmatch("%S+") do words[#words + 1] = w end
  local line1, line2 = "", ""
  for _, w in ipairs(words) do
    local candidate = line1 == "" and w or (line1 .. " " .. w)
    if #candidate <= max_chars then
      line1 = candidate
    else
      line2 = line2 == "" and w or (line2 .. " " .. w)
    end
  end
  return line1, line2
end

-- Format frame count as MM:SS
function fmt_time(frames)
  local secs = math.floor(frames / 60)
  local m = math.floor(secs / 60)
  local s = secs % 60
  return string.format("%02d:%02d", m, s)
end

-- Draw header bar: C_BG2 fill, text left in C_HFNT
function draw_header(text, right_text)
  rect(0, 0, SW, 12, C_BG2)
  print(text, 4, 3, C_HFNT)
  if right_text then
    local rw = #right_text * 6
    print(right_text, SW - rw - 4, 3, C_DIM)
  end
end

-- Draw horizontal divider
function draw_divider(y)
  line(0, y, SW - 1, y, C_BDR)
end

-- Draw status/hint bar at bottom
function draw_hint_bar(text, y)
  rect(0, y, SW, SH - y, C_BG2)
  print(text, 4, y + 3, C_DIM)
end

-- Fisher-Yates shuffle (in-place)
function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(1, i)
    t[i], t[j] = t[j], t[i]
  end
end

-- Check if TX index is available (not locked)
-- Phase 1: TX 1-3 available, rest locked
function is_available(idx)
  if idx <= 3 then return true end
  return false
end

-- Check if TX index is selectable (available or decoded)
function is_selectable(idx)
  return is_available(idx) or G.decoded[idx]
end

-- Get TX entry status string and color
function tx_status(idx)
  if G.decoded[idx] then
    return "[DECODED]", C_OK
  elseif is_available(idx) then
    return "[AVAILABLE]", C_TXT
  else
    return "[LOCKED]", C_DIM
  end
end

-- Find next selectable TX index in direction (+1 or -1)
function next_selectable(cur, dir)
  for i = 1, 8 do
    cur = cur + dir
    if cur > 8 then cur = 1 end
    if cur < 1 then cur = 8 end
    if is_selectable(cur) then return cur end
  end
  return cur
end

-- Compute gap pixel ranges for a TX
-- Returns array of {x0, x1} for each gap
function compute_gap_ranges(tx)
  local ranges = {}
  for gi, frac in ipairs(tx.gap_pos) do
    local cx = WAVE_X0 + math.floor(frac * WAVE_W)
    local x0 = cx - math.floor(FRAG_W / 2)
    local x1 = x0 + FRAG_W - 1
    ranges[gi] = {x0 = x0, x1 = x1}
  end
  return ranges
end

-- Check if pixel x falls in any gap, return gap index or nil
function gap_at_x(x, gap_ranges)
  for gi, g in ipairs(gap_ranges) do
    if x >= g.x0 and x <= g.x1 then return gi end
  end
  return nil
end

-- Compute dynamic fragment box width for Stage 1
-- Fits n boxes left-aligned from x=4 within screen
function frag_box_w(n)
  local avail = 232 - (n - 1) * FRAG_GAP
  return math.min(FRAG_W, math.floor(avail / n))
end

-- Stage 2 slot layout: returns rows, per_row
function slot_layout(n)
  if n <= 3 then return 1, n
  elseif n == 4 then return 2, 2
  elseif n == 5 then return 2, 3
  else return 2, 3 end
end

-- Audio stub
function play_sfx(id)
  -- sfx(id)  -- Phase 1: audio stubs only
end

-- Init Stage 1 state for given TX
function init_stage1(tx_idx)
  local tx = TRANSMISSIONS[tx_idx]
  -- Build shuffled display order
  local order = {}
  for i = 1, #tx.frags do order[i] = i end
  math.randomseed(time())
  shuffle(order)
  G.s1_cursor  = 1
  G.s1_held    = nil
  G.s1_gap_cur = 1
  G.s1_mode    = "frags"
  G.s1_placed  = {}
  G.s1_order   = order
  G.s1_shake_t = 0
  G.s1_flash_t = 0
end

-- Init Stage 2 state for given TX
function init_stage2(tx_idx)
  local tx = TRANSMISSIONS[tx_idx]
  -- Build pool: correct frags + decoys, shuffled
  local pool = {}
  for i, text in ipairs(tx.seq) do
    pool[#pool + 1] = {text = text, orig_idx = i}
  end
  for _, text in ipairs(tx.seq_dec) do
    pool[#pool + 1] = {text = text, orig_idx = nil}
  end
  math.randomseed(time())
  shuffle(pool)
  G.s2_pool    = pool
  G.s2_slots   = {}
  G.s2_held    = nil
  G.s2_row     = 1    -- start in pool
  G.s2_col     = 1
  G.s2_err_t   = 0
  G.s2_err_sl  = {}
  G.s2_phase   = "place"
  G.s2_tw_text = ""
  G.s2_tw_pos  = 0
  G.s2_tw_t    = 0
  G.s2_pause_t = 0
end

-- Init VELA log state for given TX
function init_vela_log(tx_idx)
  G.vl_line  = 0
  G.vl_timer = 0
  G.vl_done  = false
end

-- Get list of pool indices still available (not placed in slots)
function s2_available_pool()
  local placed_set = {}
  for _, pi in pairs(G.s2_slots) do
    placed_set[pi] = true
  end
  local avail = {}
  for i = 1, #G.s2_pool do
    if not placed_set[i] then
      avail[#avail + 1] = i
    end
  end
  return avail
end
```

**Step 2: Verify**

Load in TIC-80. Same black screen, no errors. Functions exist but aren't called yet.

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: add utility functions — draw_wave, word_wrap, helpers"
```

---

## Task 3: Title Screen

**Files:**
- Modify: `return-signal.lua` — `draw_title()` and `update()` sections

**Goal:** Title screen renders per PRD section 4. Z advances to hub.

**Step 1: Implement draw_title**

```lua
function draw_title()
  cls(C_BG)
  -- Diamond
  print("\x04", 113, 42, C_OK)
  -- Title
  local title = "RETURN SIGNAL"
  local tw = #title * 6
  print(title, math.floor((SW - tw) / 2), 54, C_WHITE)
  -- Subtitle
  local sub = "a signal from earth"
  local subw = #sub * 6
  print(sub, math.floor((SW - subw) / 2), 66, C_TXT)
  -- Blinking prompt
  if math.floor(G.t / BLINK_RATE) % 2 == 0 then
    local prompt = "[Z to begin]"
    local pw = #prompt * 6
    print(prompt, math.floor((SW - pw) / 2), 86, C_DIM)
  end
end
```

Note: `\x04` is the diamond character in TIC-80's font. If it doesn't render as a diamond, use a simple `*` or draw a small diamond with `pix()` calls:
```lua
-- Alternative diamond drawing (4px diamond shape)
local dx, dy = 116, 44
pix(dx, dy-2, C_OK)
pix(dx-1, dy-1, C_OK) pix(dx, dy-1, C_OK) pix(dx+1, dy-1, C_OK)
pix(dx-2, dy, C_OK) pix(dx-1, dy, C_OK) pix(dx, dy, C_OK) pix(dx+1, dy, C_OK) pix(dx+2, dy, C_OK)
pix(dx-1, dy+1, C_OK) pix(dx, dy+1, C_OK) pix(dx+1, dy+1, C_OK)
pix(dx, dy+2, C_OK)
```

**Step 2: Implement update for title state**

In the `update()` function:

```lua
function update()
  if G.state == "title" then
    update_title()
  elseif G.state == "hub" then
    update_hub()
  elseif G.state == "stage1" then
    update_stage1()
  elseif G.state == "stage2" then
    update_stage2()
  elseif G.state == "vela_log" then
    update_vela_log()
  end
end

function update_title()
  if btnp(4) then  -- Z
    G.state = "hub"
    G.hub_cur = 1
  end
end
```

Also add stub functions so the game doesn't crash:

```lua
function update_hub() end
function update_stage1() end
function update_stage2() end
function update_vela_log() end
```

**Step 3: Verify**

Load in TIC-80. Title screen shows: diamond, "RETURN SIGNAL", "a signal from earth", blinking "[Z to begin]". Press Z — screen goes black (hub stub). No crash.

**Step 4: Commit**

```bash
git add return-signal.lua
git commit -m "feat: title screen with blinking prompt, Z advances to hub"
```

---

## Task 4: Hub Screen — Drawing

**Files:**
- Modify: `return-signal.lua` — `draw_hub()` section

**Goal:** Hub renders 8 TX entries per PRD section 7. Correct colors, statuses, garbled blocks for locked.

**Step 1: Implement draw_hub**

```lua
function draw_hub()
  cls(C_BG)
  -- Header: y 0-11
  draw_header("VELA // SIGNAL LOG", fmt_time(G.t))
  -- Divider: y 12
  draw_divider(12)

  -- Transmission list: y 13-122, 8 entries at 13px each
  for i = 1, 8 do
    local ey = 13 + (i - 1) * HUB_ENTRY_H
    if ey + HUB_ENTRY_H > 123 then break end

    local tx = TRANSMISSIONS[i]
    local status, col = tx_status(i)
    local is_cur = (G.hub_cur == i and is_selectable(i))

    -- Cursor highlight background
    if is_cur then
      rect(0, ey, SW, HUB_ENTRY_H, C_BG2)
    end

    -- Build entry text
    local prefix = is_cur and "> " or "  "
    local body
    if G.decoded[i] then
      -- Decoded: show first seq_frag line
      body = tx.id .. "  " .. tx.seq[1]
    elseif is_available(i) then
      -- Available: show origin
      body = tx.id .. "  ORIGIN: " .. tx.origin
    else
      -- Locked: garbled blocks
      local garble_lens = {14, 12, 16, 13, 15, 11, 14, 12}
      body = tx.id .. "  " .. string.rep("\x08", garble_lens[i] or 12)
    end

    local display_col = col
    if is_cur then display_col = C_CUR end

    print(prefix .. body, 2, ey + 3, display_col)

    -- Right-align status tag
    local sw = #status * 6
    print(status, SW - sw - 4, ey + 3, display_col)
  end

  -- Divider: y 123
  draw_divider(123)
  -- Hint bar: y 124-135
  draw_hint_bar("Z: OPEN", 124)
end
```

Note on garbled blocks: TIC-80's char `\x08` should render as a block. If not, use `string.rep("#", n)` as fallback or the unicode block char approach. Test and adjust.

**Step 2: Verify**

Load in TIC-80. Press Z on title. Hub shows:
- Header with "VELA // SIGNAL LOG" and elapsed time
- TX-001, TX-002, TX-003 as [AVAILABLE] with origins
- TX-004 through TX-008 as [LOCKED] with garbled text
- Cursor on TX-001 (yellow highlight)
- "Z: OPEN" at bottom

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: hub screen rendering — entries, statuses, garbled locks"
```

---

## Task 5: Hub Screen — Navigation and Selection

**Files:**
- Modify: `return-signal.lua` — `update_hub()` function

**Goal:** Cursor wraps among selectable entries. Z on available TX enters Stage 1. Cursor skips locked entries.

**Step 1: Implement update_hub**

```lua
function update_hub()
  -- Navigate: Up/Down wraps among selectable entries
  if btnp(0) then  -- Up
    G.hub_cur = next_selectable(G.hub_cur, -1)
  end
  if btnp(1) then  -- Down
    G.hub_cur = next_selectable(G.hub_cur, 1)
  end

  -- Select: Z enters Stage 1
  if btnp(4) then  -- Z
    local idx = G.hub_cur
    if is_available(idx) and not G.decoded[idx] then
      G.tx_idx = idx
      init_stage1(idx)
      G.state = "stage1"
      play_sfx(6)
    end
  end
end
```

**Step 2: Verify**

Load in TIC-80. Title → Z → Hub. Up/Down moves cursor among TX-001/002/003 only (skips locked). Cursor wraps (003→001, 001→003). Z on TX-001 → black screen (stage1 stub). No crash.

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: hub navigation — cursor wraps selectables, Z enters stage1"
```

---

## Task 6: Stage 1 — Waveform Drawing

**Files:**
- Modify: `return-signal.lua` — `draw_stage1()` function

**Goal:** Target waveform renders with known segments in white, gaps as dashed centerlines with bracket markers, fragment row shows shuffled fragments with mini-wave previews.

**Step 1: Implement draw_stage1**

```lua
function draw_stage1()
  local tx = TRANSMISSIONS[G.tx_idx]
  local gap_ranges = compute_gap_ranges(tx)
  cls(C_BG)

  -- Header: y 0-9
  rect(0, 0, SW, 10, C_BG2)
  print("VELA // " .. tx.id .. " // RECONSTRUCT", 4, 2, C_HFNT)
  draw_divider(10)

  -- Waveform area: y 11-79 (C_BG already from cls)
  -- Shake offset for error feedback
  local sox = 0
  if G.s1_shake_t > 0 then
    sox = (G.s1_shake_t % 2 == 0) and 2 or -2
  end

  -- Draw target waveform (known segments only)
  for i = 0, WAVE_W - 2 do
    local px = WAVE_X0 + i
    local px1 = px + 1
    local in_gap_cur = gap_at_x(px, gap_ranges)
    local in_gap_nxt = gap_at_x(px1, gap_ranges)
    if not in_gap_cur and not in_gap_nxt then
      local y1 = WCY + math.floor(
        math.sin(i * tx.target_freq) * tx.target_amp +
        math.sin(i * tx.target_freq * 2) * tx.target_amp * 0.4)
      local y2 = WCY + math.floor(
        math.sin((i + 1) * tx.target_freq) * tx.target_amp +
        math.sin((i + 1) * tx.target_freq * 2) * tx.target_amp * 0.4)
      line(px, y1, px1, y2, C_WHITE)
    end
  end

  -- Draw gap regions
  for gi, g in ipairs(gap_ranges) do
    if G.s1_placed[gi] then
      -- Placed fragment: render its wave in gap
      local fi = G.s1_placed[gi]
      local frag = tx.frags[fi]
      local col = C_OK
      -- Flash animation on stage complete
      if G.s1_flash_t > 0 then
        col = (math.floor(G.s1_flash_t / 4) % 2 == 0) and C_OK or C_WHITE
      end
      draw_wave(g.x0 + sox, WCY, FRAG_W, frag.amp, frag.freq, col)
    else
      -- Empty gap: dashed centerline + brackets
      for x = g.x0, g.x1 do
        if x % 4 < 2 then
          pix(x, WCY, C_DIM)
        end
      end
      -- Bracket markers at gap edges
      for y = WCY - 6, WCY + 6 do
        pix(g.x0, y, C_BDR)
        pix(g.x1, y, C_BDR)
      end
    end
    -- Gap cursor highlight
    if G.s1_mode == "gaps" and G.s1_gap_cur == gi then
      rectb(g.x0 - 1, WCY - 14, FRAG_W + 2, 28, C_CUR)
    end
  end

  -- Divider: y 80
  draw_divider(80)

  -- Fragment row: y 81-120 (C_BG2 fill)
  rect(0, 81, SW, 40, C_BG2)
  local nf = #tx.frags
  local bw = frag_box_w(nf)
  local frag_y = 81 + math.floor((40 - FRAG_H) / 2)

  for di = 1, nf do
    local fi = G.s1_order[di]
    local fx = 4 + (di - 1) * (bw + FRAG_GAP)
    local frag = tx.frags[fi]

    -- Check if this fragment is placed somewhere or held
    local is_placed = false
    for _, pfi in pairs(G.s1_placed) do
      if pfi == fi then is_placed = true; break end
    end
    local is_held = (G.s1_held == fi)

    if is_placed or is_held then
      -- Dim empty box
      rectb(fx, frag_y, bw, FRAG_H, C_DIM)
      if is_held then
        -- Show "held" indicator
        print("^", fx + math.floor(bw / 2) - 3, frag_y + 9, C_SEL)
      end
    else
      -- Determine box color
      local box_col = C_TXT
      if frag.gap == nil then box_col = C_DIM end  -- decoy
      local is_cursor = (G.s1_mode == "frags" and G.s1_cursor == di)
      if is_cursor then box_col = C_CUR end

      -- Draw box border
      rectb(fx, frag_y, bw, FRAG_H, box_col)

      -- Draw mini wave inside box
      local wave_col = box_col
      local mcy = frag_y + math.floor(FRAG_H / 2)
      draw_wave(fx + 1, mcy, bw - 2, frag.amp * 0.7, frag.freq, wave_col)
    end
  end

  -- Divider: y 121
  draw_divider(121)

  -- Status bar: y 122-135
  rect(0, 122, SW, 14, C_BG2)
  local hint
  if G.s1_flash_t > 0 then
    hint = "SIGNAL RECONSTRUCTED"
  elseif G.s1_mode == "gaps" and G.s1_held then
    hint = "L/R: GAP  Z: PLACE  X: CANCEL"
  elseif G.s1_mode == "gaps" then
    hint = "L/R: GAP  Z: LIFT  X/DN: BACK"
  else
    hint = "L/R: SELECT  Z: PICK UP  UP: GAPS"
  end
  print(hint, 4, 125, C_HFNT)
end
```

**Step 2: Verify**

Load in TIC-80. Title → Z → Hub → Z on TX-001. Stage 1 shows:
- Header with "VELA // TX-001 // RECONSTRUCT"
- White waveform with 2 gaps (dashed centerlines, brackets)
- 4 fragment boxes at bottom with mini wave previews
- Status bar with hints

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: stage 1 waveform rendering — target wave, gaps, fragment row"
```

---

## Task 7: Stage 1 — Interaction

**Files:**
- Modify: `return-signal.lua` — `update_stage1()` function

**Goal:** Full pick/place loop: browse fragments, hold, navigate gaps, place. Correct = green snap-in. Incorrect = shake + drop. All correct = flash + auto-advance to Stage 2.

**Step 1: Implement update_stage1**

```lua
function update_stage1()
  local tx = TRANSMISSIONS[G.tx_idx]

  -- Tick down timers
  if G.s1_shake_t > 0 then G.s1_shake_t = G.s1_shake_t - 1 end

  -- Stage complete: flash then advance
  if G.s1_flash_t > 0 then
    G.s1_flash_t = G.s1_flash_t - 1
    if G.s1_flash_t <= 0 then
      init_stage2(G.tx_idx)
      G.state = "stage2"
    end
    return
  end

  local nf = #tx.frags
  local ng = #tx.gap_pos

  if G.s1_mode == "frags" then
    -- Fragment row navigation
    if btnp(2) then  -- Left
      G.s1_cursor = G.s1_cursor - 1
      if G.s1_cursor < 1 then G.s1_cursor = nf end
    end
    if btnp(3) then  -- Right
      G.s1_cursor = G.s1_cursor + 1
      if G.s1_cursor > nf then G.s1_cursor = 1 end
    end
    if btnp(0) then  -- Up: switch to gap browsing (no held)
      G.s1_mode = "gaps"
      G.s1_gap_cur = 1
    end
    if btnp(4) then  -- Z: pick up fragment
      local fi = G.s1_order[G.s1_cursor]
      -- Check fragment isn't already placed
      local already_placed = false
      for _, pfi in pairs(G.s1_placed) do
        if pfi == fi then already_placed = true; break end
      end
      if not already_placed and G.s1_held == nil then
        G.s1_held = fi
        G.s1_mode = "gaps"
        G.s1_gap_cur = 1
        play_sfx(6)
      end
    end

  elseif G.s1_mode == "gaps" then
    -- Gap navigation
    if btnp(2) then  -- Left
      G.s1_gap_cur = G.s1_gap_cur - 1
      if G.s1_gap_cur < 1 then G.s1_gap_cur = ng end
    end
    if btnp(3) then  -- Right
      G.s1_gap_cur = G.s1_gap_cur + 1
      if G.s1_gap_cur > ng then G.s1_gap_cur = 1 end
    end
    if btnp(1) or btnp(5) then  -- Down or X: cancel back to frags
      if G.s1_held then
        G.s1_held = nil  -- drop held fragment
      end
      G.s1_mode = "frags"
    end
    if btnp(4) then  -- Z
      local gi = G.s1_gap_cur
      if G.s1_held then
        -- Holding fragment: try to place
        if not G.s1_placed[gi] then
          local fi = G.s1_held
          local frag = tx.frags[fi]
          if frag.gap == gi then
            -- CORRECT placement
            G.s1_placed[gi] = fi
            G.s1_held = nil
            play_sfx(1)
            -- Check if all gaps filled
            local all_done = true
            for ggi = 1, ng do
              if not G.s1_placed[ggi] then all_done = false; break end
            end
            if all_done then
              G.s1_flash_t = FLASH_DUR
              play_sfx(3)
            else
              G.s1_mode = "frags"
            end
          else
            -- WRONG placement: shake, drop fragment
            G.s1_shake_t = SHAKE_DUR
            G.s1_held = nil
            G.s1_mode = "frags"
            play_sfx(2)
          end
        end
      else
        -- Not holding: pick up from filled gap
        if G.s1_placed[gi] then
          G.s1_held = G.s1_placed[gi]
          G.s1_placed[gi] = nil
          play_sfx(6)
        end
      end
    end
  end
end
```

**Step 2: Verify**

Load in TIC-80. Title → Z → Hub → Z on TX-001.
- Left/Right navigates fragment boxes (yellow cursor border)
- Z on fragment → cursor moves to gap area (yellow gap border)
- Navigate gaps with Left/Right
- Z on gap: correct fragment → green wave fills gap, returns to fragment row
- Z on gap: wrong fragment → shake, fragment drops, back to row
- Up in fragment row → gap browsing (no held); Z on filled gap lifts it
- All gaps correct → 16-frame green/white flash → auto-advance to Stage 2 (black screen)

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: stage 1 interaction — pick, place, correct/incorrect feedback, completion"
```

---

## Task 8: Stage 2 — Rendering

**Files:**
- Modify: `return-signal.lua` — `draw_stage2()` function

**Goal:** Slot area and fragment pool render correctly per PRD sections 9.1-9.3. Text wraps. Cursor highlights. Error flash on wrong slots.

**Step 1: Implement draw_stage2**

```lua
function draw_stage2()
  local tx = TRANSMISSIONS[G.tx_idx]
  cls(C_BG)

  -- Header: y 0-9
  rect(0, 0, SW, 10, C_BG2)
  print("VELA // " .. tx.id .. " // SEQUENCE", 4, 2, C_HFNT)
  draw_divider(10)

  -- Typewriter phase: different rendering
  if G.s2_phase == "typewriter" or G.s2_phase == "done" then
    draw_s2_typewriter()
    return
  end

  -- Slot area: y 11-67 (C_BG2 fill)
  rect(0, 11, SW, 57, C_BG2)
  local ns = #tx.seq  -- number of correct slots needed
  local rows, per_row = slot_layout(ns)

  local slot_i = 0
  for r = 0, rows - 1 do
    local cols = per_row
    -- For 5 slots: row 1 has 2 columns
    if ns == 5 and r == 1 then cols = 2 end
    local sw = math.floor(236 / cols) - 1
    local ox = math.floor((SW - cols * (sw + 1)) / 2)
    local ry = 12 + r * (SLOT_H + 2)

    for c = 0, cols - 1 do
      slot_i = slot_i + 1
      if slot_i > ns then break end
      local sx = ox + c * (sw + 1)

      -- Border color
      local bc = C_BDR
      if G.s2_row == 0 and G.s2_col == slot_i then bc = C_CUR end
      -- Error flash overrides
      if G.s2_err_t > 0 and G.s2_err_sl[slot_i] then bc = C_ERR end

      rectb(sx, ry, sw, SLOT_H, bc)

      -- Slot number top-left
      print(tostring(slot_i), sx + 2, ry + 2, C_DIM)

      -- Slot content
      if G.s2_slots[slot_i] then
        local pi = G.s2_slots[slot_i]
        local text = G.s2_pool[pi].text
        local max_c = math.floor(sw / 6) - 1
        local l1, l2 = word_wrap(text, max_c)
        print(l1, sx + 2, ry + 5, C_TXT)
        if l2 ~= "" then
          print(l2, sx + 2, ry + 14, C_TXT)
        end
      end
    end
  end

  -- Divider: y 68
  draw_divider(68)

  -- Fragment pool: y 69-126 (C_BG fill, already from cls)
  local avail = s2_available_pool()
  local pool_cols = 4
  local pw = math.floor(236 / pool_cols) - 1
  local pox = math.floor((SW - pool_cols * (pw + 1)) / 2)

  for di, pi in ipairs(avail) do
    local r = math.floor((di - 1) / pool_cols)
    local c = (di - 1) % pool_cols
    local px = pox + c * (pw + 1)
    local py = 70 + r * (SLOT_H + 2)

    -- Border color
    local bc = C_BDR
    if G.s2_row == 1 and G.s2_col == di then bc = C_CUR end
    if G.s2_held == pi then bc = C_SEL end

    rectb(px, py, pw, SLOT_H, bc)

    -- Text
    local text = G.s2_pool[pi].text
    local max_c = math.floor(pw / 6) - 1
    local l1, l2 = word_wrap(text, max_c)
    local tc = C_TXT
    if G.s2_held == pi then tc = C_SEL end
    if G.s2_pool[pi].orig_idx == nil then tc = C_DIM end  -- decoy dimmed
    print(l1, px + 2, py + 5, tc)
    if l2 ~= "" then
      print(l2, px + 2, py + 14, tc)
    end
  end

  -- Divider: y 127
  draw_divider(127)

  -- Status bar: y 128-135
  rect(0, 128, SW, 8, C_BG2)
  local hint
  if G.s2_row == 1 then
    hint = "U/D: AREA  L/R: SELECT  Z: PICK"
  else
    hint = "U/D: AREA  L/R: SLOT  Z: PLACE  X: CLEAR"
  end
  print(hint, 4, 130, C_HFNT)
end

function draw_s2_typewriter()
  -- Full screen text reveal
  rect(0, 11, SW, 116, C_BG)
  local revealed = string.sub(G.s2_tw_text, 1, G.s2_tw_pos)
  -- Word wrap to screen width
  local max_c = math.floor(228 / 6) - 1
  -- Split by // for multi-line display
  local y = 20
  local words = {}
  for w in revealed:gmatch("%S+") do words[#words + 1] = w end
  local cur_line = ""
  for _, w in ipairs(words) do
    local candidate = cur_line == "" and w or (cur_line .. " " .. w)
    if #candidate <= max_c then
      cur_line = candidate
    else
      print(cur_line, 6, y, C_WHITE)
      y = y + 10
      cur_line = w
    end
  end
  if cur_line ~= "" then
    print(cur_line, 6, y, C_WHITE)
  end

  if G.s2_phase == "done" then
    print("Z: CONTINUE", SW - 11 * 6 - 4, SH - 10, C_HFNT)
  end
end
```

**Step 2: Verify**

To test rendering, temporarily set `G.state = "stage2"` and call `init_stage2(1)` at startup. Verify:
- 3 numbered slots in a single row (TX-001 has 3 seq frags)
- 3 text fragments in the pool area
- Cursor highlighting works visually

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: stage 2 rendering — slots, pool, text wrapping, error flash"
```

---

## Task 9: Stage 2 — Interaction

**Files:**
- Modify: `return-signal.lua` — `update_stage2()` function

**Goal:** Full select/place/submit/feedback loop. Toggle select in pool, place in slots, clear with X. Explicit Z submit when all filled. Wrong = error flash on wrong slots. Correct = typewriter reveal.

**Step 1: Implement update_stage2**

```lua
function update_stage2()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq

  -- Tick down error flash timer
  if G.s2_err_t > 0 then
    G.s2_err_t = G.s2_err_t - 1
    if G.s2_err_t <= 0 then G.s2_err_sl = {} end
  end

  -- Typewriter phase
  if G.s2_phase == "typewriter" then
    G.s2_tw_t = G.s2_tw_t + 1
    if G.s2_tw_t % TW_SPEED == 0 and G.s2_tw_pos < #G.s2_tw_text then
      G.s2_tw_pos = G.s2_tw_pos + 1
    end
    if G.s2_tw_pos >= #G.s2_tw_text then
      G.s2_pause_t = G.s2_pause_t + 1
      if G.s2_pause_t >= VL_PAUSE then
        G.s2_phase = "done"
      end
    end
    return
  end

  -- Done phase: Z to VELA log
  if G.s2_phase == "done" then
    if btnp(4) then
      init_vela_log(G.tx_idx)
      G.state = "vela_log"
    end
    return
  end

  -- Place phase: normal interaction
  local avail = s2_available_pool()

  -- Clamp pool cursor to available range
  if G.s2_row == 1 and G.s2_col > #avail then
    G.s2_col = math.max(1, #avail)
  end

  -- Up/Down: switch between slot area and pool
  if btnp(0) then  -- Up
    if G.s2_row == 1 then
      G.s2_row = 0
      G.s2_col = 1
    end
  end
  if btnp(1) then  -- Down
    if G.s2_row == 0 then
      G.s2_row = 1
      G.s2_col = 1
    end
  end

  if G.s2_row == 1 then
    -- Pool area
    local n = #avail
    if n > 0 then
      if btnp(2) then  -- Left
        G.s2_col = G.s2_col - 1
        if G.s2_col < 1 then G.s2_col = n end
      end
      if btnp(3) then  -- Right
        G.s2_col = G.s2_col + 1
        if G.s2_col > n then G.s2_col = 1 end
      end
      if btnp(4) then  -- Z: toggle select
        if G.s2_col <= n then
          local pi = avail[G.s2_col]
          if G.s2_held == pi then
            -- Deselect same fragment
            G.s2_held = nil
          else
            -- Select fragment
            G.s2_held = pi
            play_sfx(6)
          end
        end
      end
    end
    if btnp(5) then  -- X: deselect
      G.s2_held = nil
    end

  elseif G.s2_row == 0 then
    -- Slot area
    if btnp(2) then  -- Left
      G.s2_col = G.s2_col - 1
      if G.s2_col < 1 then G.s2_col = ns end
    end
    if btnp(3) then  -- Right
      G.s2_col = G.s2_col + 1
      if G.s2_col > ns then G.s2_col = 1 end
    end
    if btnp(4) then  -- Z
      local si = G.s2_col
      if G.s2_held then
        -- Place held fragment in slot (if empty)
        if not G.s2_slots[si] then
          G.s2_slots[si] = G.s2_held
          G.s2_held = nil
          play_sfx(1)
        end
      elseif G.s2_slots[si] then
        -- Pick up from filled slot
        G.s2_held = G.s2_slots[si]
        G.s2_slots[si] = nil
        play_sfx(6)
      else
        -- All filled, nothing held: submit
        local all_filled = true
        for i = 1, ns do
          if not G.s2_slots[i] then all_filled = false; break end
        end
        if all_filled then
          check_s2_solution()
        end
      end
    end
    if btnp(5) then  -- X
      local si = G.s2_col
      if G.s2_held then
        -- Deselect
        G.s2_held = nil
      elseif G.s2_slots[si] then
        -- Clear slot, return fragment to pool
        G.s2_slots[si] = nil
        play_sfx(6)
      end
    end
  end
end

function check_s2_solution()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq
  local all_correct = true
  local wrong = {}

  for si = 1, ns do
    local pi = G.s2_slots[si]
    local expected = tx.seq_sol[si]
    local pool_entry = G.s2_pool[pi]
    if pool_entry.orig_idx ~= expected then
      all_correct = false
      wrong[si] = true
    end
  end

  if all_correct then
    -- Build assembled message: fragments joined with //
    local parts = {}
    for si = 1, ns do
      local pi = G.s2_slots[si]
      parts[#parts + 1] = G.s2_pool[pi].text
    end
    G.s2_tw_text = table.concat(parts, " // ")
    G.s2_tw_pos = 0
    G.s2_tw_t = 0
    G.s2_pause_t = 0
    G.s2_phase = "typewriter"
    play_sfx(4)
  else
    -- Flash wrong slots
    G.s2_err_t = ERR_FLASH
    G.s2_err_sl = wrong
    play_sfx(2)
  end
end
```

**Step 2: Verify**

Full Stage 2 test for TX-001:
- Up/Down switches between slots and pool
- Z in pool selects fragment (yellow), Z again deselects (toggle)
- Navigate to slots, Z places. Fragment disappears from pool.
- X on filled slot clears it (fragment returns to pool)
- Z on filled slot (nothing held) picks up into hand
- Fill all 3 slots correctly (1,2,3 in order) → Z submits → typewriter reveal
- Fill slots in wrong order → Z submits → red flash on wrong slots, player fixes
- After typewriter: 60-frame pause → "Z: CONTINUE" appears → Z goes to black (vela stub)

**Step 3: Commit**

```bash
git add return-signal.lua
git commit -m "feat: stage 2 interaction — select, place, submit, error flash, typewriter"
```

---

## Task 10: VELA Log Screen

**Files:**
- Modify: `return-signal.lua` — `draw_vela_log()` and `update_vela_log()` functions

**Goal:** VELA log renders per PRD section 10. Typewriter line-by-line reveal. Z advances lines. After last line, Z returns to hub with decoded status.

**Step 1: Implement draw_vela_log**

```lua
function draw_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]
  cls(C_BG)

  -- Header: y 0-9
  rect(0, 0, SW, 10, C_BG2)
  print("VELA // INTERNAL LOG // " .. tx.id, 4, 2, C_HFNT)
  draw_divider(10)

  -- Log text area: y 11-118
  for i = 1, G.vl_line do
    if i <= #tx.vela then
      local text = tx.vela[i]
      if text ~= "" then
        print(text, 8, 14 + (i - 1) * 12, C_WHITE)
      end
    end
  end

  -- Divider: y 119
  draw_divider(119)

  -- Footer: y 120-135
  rect(0, 120, SW, 16, C_BG2)
  if G.vl_done then
    local prompt = "Z: CONTINUE"
    local pw = #prompt * 6
    print(prompt, SW - pw - 4, SH - 10, C_DIM)
  end
end
```

**Step 2: Implement update_vela_log**

```lua
function update_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]

  if G.vl_done then
    if btnp(4) then  -- Z: return to hub
      G.decoded[G.tx_idx] = true
      G.state = "hub"
    end
    return
  end

  G.vl_timer = G.vl_timer + 1

  if G.vl_line == 0 then
    -- Reveal first line immediately
    G.vl_line = 1
    G.vl_timer = 0
  elseif G.vl_line < #tx.vela then
    -- Auto-reveal on timer or Z to advance
    if btnp(4) or G.vl_timer >= VL_LINE_DUR then
      G.vl_line = G.vl_line + 1
      G.vl_timer = 0
    end
  else
    -- All lines revealed
    G.vl_done = true
  end
end
```

**Step 3: Verify**

Full VELA log test:
- Header shows "VELA // INTERNAL LOG // TX-001"
- Lines appear one at a time (every 40 frames or on Z press)
- "signal recovered." → "content noted." → "no action required."
- After all lines: "Z: CONTINUE" appears bottom right
- Z returns to hub. TX-001 now shows as [DECODED] in green with first seq frag text.

**Step 4: Commit**

```bash
git add return-signal.lua
git commit -m "feat: VELA log — typewriter line reveal, Z to dismiss, decoded status"
```

---

## Task 11: End-to-End Integration and Polish

**Files:**
- Modify: `return-signal.lua` — verify all transitions, fix edge cases

**Goal:** Full loop works: title → hub → TX-001 stage 1 → stage 2 → VELA log → hub (decoded). No crashes on any valid input sequence.

**Step 1: Verify complete flow**

Run through the entire flow in TIC-80:

1. Title screen → Z → Hub
2. Hub: TX-001 [AVAILABLE], TX-002/003 [AVAILABLE], rest [LOCKED]
3. Z on TX-001 → Stage 1: waveform with 2 gaps, 4 fragments
4. Solve Stage 1: place correct fragments in gaps → flash → auto-advance
5. Stage 2: 3 slots, 3 fragments in pool
6. Solve Stage 2: place in correct order → Z to submit → typewriter → Z: CONTINUE
7. VELA log: 3 lines reveal → Z: CONTINUE
8. Hub: TX-001 now [DECODED] in C_OK, shows first seq frag text

**Step 2: Edge case checks**

Test each of these:
- Press X on title screen (nothing should happen)
- Navigate hub cursor rapidly (wraps correctly among 1-3)
- Stage 1: pick up fragment, press X (returns to row, fragment available again)
- Stage 1: place all fragments wrong repeatedly (no crash, shake each time)
- Stage 1: pick up from filled gap (lift works)
- Stage 2: select fragment, select same again (deselects — toggle)
- Stage 2: place all wrong, submit (red flash on wrong slots, can fix)
- Stage 2: clear slot with X (fragment returns to pool)
- Stage 2: spam Z during typewriter (no crash, no skip)
- VELA log: press Z to advance lines faster (works)
- Return to hub after decode: TX-001 shows decoded

**Step 3: Fix any issues found**

Fix any bugs or rendering issues discovered during testing. Common issues:
- Pool cursor out of bounds after placing fragments
- Garbled block character not rendering (use fallback)
- Text overflow in slot boxes
- Fragment wave clipping outside box bounds

**Step 4: Commit**

```bash
git add return-signal.lua
git commit -m "feat: end-to-end integration — full TX-001 flow verified, edge cases fixed"
```

---

## Task 12: CLAUDE.md and Final Cleanup

**Files:**
- Create/update: `CLAUDE.md`
- Delete: any stale files

**Step 1: Update CLAUDE.md**

Update the existing `CLAUDE.md` to reflect the actual implemented architecture.

**Step 2: Clean up**

- Remove any stale test code or temporary debug lines
- Ensure all comments are accurate
- Verify file loads cleanly in TIC-80 one final time

**Step 3: Commit**

```bash
git add CLAUDE.md return-signal.lua
git commit -m "docs: update CLAUDE.md for Phase 1 implementation"
```

---

## Summary of Commits

| Task | Commit Message |
|------|---------------|
| 1 | `feat: scaffold constants, all 8 TX data, state table, main loop` |
| 2 | `feat: add utility functions — draw_wave, word_wrap, helpers` |
| 3 | `feat: title screen with blinking prompt, Z advances to hub` |
| 4 | `feat: hub screen rendering — entries, statuses, garbled locks` |
| 5 | `feat: hub navigation — cursor wraps selectables, Z enters stage1` |
| 6 | `feat: stage 1 waveform rendering — target wave, gaps, fragment row` |
| 7 | `feat: stage 1 interaction — pick, place, correct/incorrect feedback, completion` |
| 8 | `feat: stage 2 rendering — slots, pool, text wrapping, error flash` |
| 9 | `feat: stage 2 interaction — select, place, submit, error flash, typewriter` |
| 10 | `feat: VELA log — typewriter line reveal, Z to dismiss, decoded status` |
| 11 | `feat: end-to-end integration — full TX-001 flow verified, edge cases fixed` |
| 12 | `docs: update CLAUDE.md for Phase 1 implementation` |
