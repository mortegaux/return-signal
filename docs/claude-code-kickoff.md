# Return Signal — Claude Code Kickoff Prompt
# Paste this entire prompt to start the Phase 1 build session

---

Build **Return Signal**, a TIC-80 narrative puzzle game written in Lua.

## Platform constraints
- TIC-80: 240×136 display, 16-color default palette, 4-channel audio, Lua
- Input: d-pad (btn 0–3: up/down/left/right), Z (btn 4), X (btn 5)
- No save system — single session only
- Cart filename: `return-signal.tic`

## Phase 1 goal
One complete transmission playable end-to-end:
- Signal log hub screen (static, navigation functional)
- Stage 1: waveform reconstruction (full interaction loop)
- Stage 2: message sequencing (full interaction loop)
- VELA log entry display
- Return to hub

Use TX-001 as the test transmission. Full data at bottom of this prompt.

---

## Architecture

### Game states
```
STATE = "hub" | "stage1" | "stage2" | "vela_log" | "boot"
```

### Screen layout — Stage 1 (waveform)
```
y 0–9    header bar (dark bg)
y 10     divider
y 11–79  target waveform area (black bg)
y 80     divider
y 81–120 fragment row (dark bg)
y 121    divider
y 122–135 status bar
```

### Screen layout — Stage 2 (sequencing)
```
y 0–9    header bar
y 10     divider
y 11–67  slot area (dark bg) — numbered sequence slots
y 68     divider
y 69–126 fragment pool (black bg) — shuffled text fragments
y 127    divider
y 128–135 status bar
```

---

## Color constants (TIC-80 default palette indices)

```lua
-- Use these exact names and values throughout
C_BG      = 0   -- black background
C_BG2     = 8   -- dark blue — slot/header areas
C_BDR     = 15  -- dark gray — borders, dividers
C_DIM     = 15  -- same as border — placeholder text
C_HDR     = 8   -- header fill
C_HFNT    = 11  -- cyan — header text, status text
C_TXT     = 13  -- light blue-gray — body text
C_BRIGHT  = 12  -- white — known waveform segments
C_SEL     = 4   -- yellow — selected fragment
C_OK      = 6   -- green — correct placement
C_ERR     = 2   -- red — wrong slot flash
C_CUR     = 4   -- yellow — cursor highlight
C_HINT    = 15  -- dim — hint text
```

---

## Stage 1 — Waveform reconstruction

### Waveform rendering
- Target waveform: compound sine wave rendered with `line()` calls
- Compound = primary sine + 0.4× amplitude harmonic at 2× frequency
- Known segments: color `C_BRIGHT` (white) on black
- Gap segments: dashed centerline at `C_DIM`, bracket markers at gap edges
- Fragment waves: `C_TXT` (cyan) normally, `C_SEL` (yellow) when selected, `C_OK` (green) when placed correctly
- Decoy fragments: `C_DIM` (gray) — de-emphasized

### Fragment sizing
- Fragment box: 44px wide × 20px tall wave area
- Amplitude range: 4–12px, minimum 3.5px spread between correct fragments
- Frequency range: 0.10–0.32 rad/px, minimum 0.05 spread between correct fragments

### Matching logic
- Matching is by fragment INDEX, not visual similarity
- Player places fragment → game checks if fragIdx matches expected fragIdx for that gap
- Correct: snap in, chime SFX, gap fills green
- Incorrect: 4-frame shake animation, error SFX, returns to hand
- All gaps correct: 16-frame flash, auto-advance to Stage 2

### Interaction
- Left/Right: move cursor across fragments (bottom row)
- Z: pick up / place fragment
- X: cancel — return fragment to row
- Placed fragment can be picked back up by navigating to its gap and pressing Z

---

## Stage 2 — Message sequencing

### Slot layout rules (validated in prototype)
- 1–3 slots → single row
- 4 slots → 2×2 grid
- 5 slots → 3 top + 2 bottom
- 6 slots → 3×3 grid
- Slot height: 26px (tall enough for 2-line text)
- Slot width: `math.floor(236 / perRow) - 1`

### Fragment pool layout
- Up to 4 fragments per row
- Fragment box height: 26px
- Text wraps to 2 lines within fragment box
- Placed fragments disappear from pool; pool reflows

### Text rendering
- TIC-80 `print()` with scale=1 (default 6px wide chars)
- Max chars per line in fragment/slot: `math.floor(boxWidth / 6) - 1`
- Word-wrap required — never hard truncate mid-word
- All transmission text UPPERCASE in-engine

### Interaction
- Up/Down: switch between slot row and fragment pool
- Left/Right: move cursor within current row
- Z in pool: select fragment (highlight yellow)
- Z in slot (with fragment selected): place fragment
- Z in slot (no selection, slot filled): pick up fragment back to hand
- X: clear slot → return fragment to pool, OR deselect current selection
- Enter / Z when all slots filled: submit

### Feedback
- Submit with wrong slots: flash `C_ERR` on wrong slot borders (20 frames), player fixes and resubmits
- Never full-reset on wrong submission — only highlight specific wrong slots
- Correct: typewriter reveal of assembled message, then VELA log

### Typewriter
- Assembled message = correct fragments joined with ` // `
- Reveal at ~1 char per 2 frames
- After full reveal: 60-frame pause, then VELA log appears

---

## VELA log display

```
y 0–9    header: "VELA // INTERNAL LOG // TX-XXX" in C_HFNT
y 11–100 log text, typewriter reveal, C_BRIGHT
y 101    divider
y 102–135 dark bg, Z-to-continue prompt in bottom right
```

- Typewriter: 1 line revealed per 40 frames
- Z advances to next line; after last line, Z returns to hub
- Log text is lowercase (VELA's voice shifts register here)

---

## Hub screen

```
y 0–9    header: "VELA // SIGNAL LOG" in C_HFNT
y 10     divider
y 11–125 transmission list (8 entries, 14px each)
y 126    divider
y 127–135 status / hint
```

Each entry format:
```
TX-001  ORIGIN: EARTH-SECTOR-7    [DECODED]
TX-002  ORIGIN: EARTH-SECTOR-2    [LOCKED]
```

- `[LOCKED]` entries: dim color, no selection allowed
- `[DECODED]` entries: show first fragment line instead of origin
- Active/unlocked entry: cursor highlight in `C_CUR`
- Z on available entry: enter that transmission's Stage 1
- Cursor wraps around available entries only

---

## TX-001 — Test transmission data

```lua
TX = {
  {
    id = "TX-001",
    origin = "EARTH-SECTOR-7",
    year = 5,
    -- Stage 1: waveform parameters
    -- gaps = positions (as fraction of waveform width) where fragments go
    gaps = {0.25, 0.65},
    fragments = {
      { amp=8,  freq=0.15, correct_gap=1 },  -- frag 1: goes in gap 1
      { amp=5,  freq=0.22, correct_gap=2 },  -- frag 2: goes in gap 2
      { amp=10, freq=0.12, correct_gap=nil }, -- decoy A
      { amp=6,  freq=0.28, correct_gap=nil }, -- decoy B
    },
    -- Stage 2: message sequencing
    seq_frags = {
      "COMMUNICATIONS GRID DOWN",      -- slot 1 (correct order)
      "NO RESPONSE FROM CENTRAL",      -- slot 2
      "MANAGING LOCALLY FOR NOW",      -- slot 3
    },
    seq_solution = {1, 2, 3},  -- correct order indices
    seq_decoys = {},            -- TX-001: no decoys
    -- VELA log (lowercase intentional — VELA voice)
    vela_log = {
      "signal recovered.",
      "content noted.",
      "no action required.",
    }
  }
}
```

---

## Code structure

Suggested file layout (single cart):

```lua
-- return-signal.tic
-- Sections separated by comments:
-- [CONSTANTS]   palette indices, layout coords, timing values
-- [DATA]        transmission definitions (TX table)
-- [STATE]       game state, current tx, cursor positions
-- [DRAW]        all rendering functions
-- [UPDATE]      input handling and state transitions
-- [AUDIO]       sfx trigger helpers
-- [TIC]         main loop — calls update() then draw()
```

Keep rendering and logic fully separated. No input handling inside draw functions.

---

## Coding conventions
- Snake_case for all variables and functions
- Constants in SCREAMING_SNAKE_CASE
- Comment every major section
- Draw functions return nothing, modify screen only
- State transitions happen in update(), never in draw()
- All magic numbers extracted to named constants

---

## What NOT to build in Phase 1
- Audio (stubs only — `sfx()` calls with placeholder IDs)
- Boot sequence / title screen
- Transmissions TX-002 through TX-008
- Ending sequence
- Unlock logic (TX-001 always available in Phase 1)

---

## Deliverable
A working `return-signal.tic` cart where:
1. Hub screen loads showing TX-001 as available
2. Selecting TX-001 loads Stage 1 waveform puzzle
3. Solving Stage 1 transitions to Stage 2 sequencing puzzle
4. Solving Stage 2 shows VELA log for TX-001
5. Dismissing VELA log returns to hub
6. No crashes on any valid input sequence

Start by scaffolding the cart structure and constants, then implement Stage 1, then Stage 2, then wire the transitions.
