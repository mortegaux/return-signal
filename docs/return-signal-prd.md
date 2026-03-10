# RETURN SIGNAL — Product Requirements Document

**TIC-80 / Lua — Version 3.0 (Rework)**

Platform: TIC-80 | Lua | 240×136px | 16-color palette
Target playtime: 35–45 minutes (single session)
Save system: None — single session by design
Cart file: return-signal.lua

> forty years of silence. one voice remaining. transmitting regardless.

---

## Status Tracker

| Phase | Status |
|-------|--------|
| Phase 1: Foundation | COMPLETE |
| Phase 2: Ship Interior | COMPLETE |
| Phase 3: Puzzle Systems | COMPLETE |
| Phase 4: Narrative Integration | COMPLETE |
| Phase 5: Audio & Polish | PENDING (sfx stubs in place) |
| Phase 6: Ship (QA) | IN PROGRESS |

---

## 1. Overview

### 1.1 Concept

Return Signal is an atmospheric narrative puzzle game for TIC-80. The player controls VELA — a ship AI operating a humanoid maintenance robot — aboard the generation ship Ardent, 40 years into a voyage from a dying Earth. Earth went silent shortly after departure. Now, close enough to receive again, VELA begins intercepting fragmented signals from the direction of home.

Unlike the original abstract puzzle-screen design, the game takes place inside the ship itself. The player moves through a side-view cross-section of the Ardent — a small, lived-in vessel holding a sleeping crew. Puzzles are physical: decoded at comms terminals, routed through power systems, read on flickering monitors. The ship is both setting and interface.

**Spiritual predecessor:** Last Relay (PICO-8, 2026) — same narrative philosophy (atmospheric dread, unexplained silence, hope as earned conclusion), different mechanics (rover exploration → ship interior exploration).

### 1.2 Core Experience

VELA begins as a machine performing maintenance and ends as something that hopes — and the player feels that transformation through the act of inhabiting the ship. The game is VELA's story. The ending gives VELA a complete arc — received order → acted within constraints → waiting — and closes before the next chapter begins.

**Tonal register: uneasy coziness.** The ship is warm, familiar, routinely functional — but 40 years of solitary operation and a crew in cryo create an undercurrent of wrongness. Not horror. Not dread. Loneliness wearing a uniform. The comfort of routine masking something that can't be named yet.

### 1.3 Key Shift from v2.0

| v2.0 (Abstract Puzzles) | v3.0 (Ship Interior) |
|---|---|
| Static screens per game state | Side-view scrolling ship interior |
| Abstract waveform/sequencing puzzles | Puzzles integrated into ship systems |
| No player avatar | VELA controls a humanoid robot |
| State machine: title→hub→stage1→stage2→log | Overworld with interactable stations |
| Narrative via text screens only | Narrative via environment + text + logs |

### 1.4 Platform Constraints

| Constraint | Value |
|---|---|
| Resolution | 240×136 pixels |
| Color palette | 16 colors — TIC-80 default (Sweetie 16) |
| Input | D-pad (btn 0–3) + Z (btn 4) + X (btn 5) |
| Audio | 4-channel tracker — SFX and music share same bank |
| Cart size | 272KB maximum |
| Scripting | Lua (NO `//` floor division — use `math.floor()`) |
| Sprites | 256 8×8 foreground + 256 8×8 background tiles |
| Map | 240×136 tile map (8×8 tiles) |

---

## 2. Scope

### 2.1 In Scope

- Side-view ship interior (4–6 rooms) as explorable overworld
- VELA-controlled humanoid robot as player avatar (walk left/right, interact)
- 8 transmissions decoded through ship-integrated puzzle systems
- VELA internal log system: short AI-voice entries, arc from clinical to emotional
- Comms terminal, power routing, and diagnostic screens as puzzle interfaces
- Title screen, VELA boot sequence, ending sequence
- Ambient audio, signal noise, puzzle feedback SFX
- Identified sender (Dr. Yuna Park) revealed gradually across final 2 transmissions

### 2.2 Out of Scope

- Platforming / jumping (movement is walk + doors/ladders only)
- Combat or enemies
- Inventory system
- Real-time pressure or timers during puzzles
- Multiple endings or branching narrative
- Save system
- Procedurally generated content (all rooms and puzzles are authored)

### 2.3 Rationale for Key Decisions

**Ship interior instead of abstract screens.** The original design separated puzzles from context. Placing puzzles inside the ship creates a sense of place — you decode a transmission *at* the comms terminal, not on a floating UI. The ship becomes a character.

**Humanoid robot, not a cursor.** VELA needs a physical presence for the overworld to feel inhabited. A maintenance robot gives VELA hands, a silhouette, a way to be *in* the ship rather than merely observing it. Also creates visual storytelling opportunities (robot pausing at cryo pods, standing at windows).

**Simple movement only.** Walk left/right + interact + doors/ladders. No jumping, no physics puzzles. The movement exists to create pacing and atmosphere between puzzle beats, not as a mechanic unto itself.

**Uneasy coziness over dread.** Last Relay's dread worked because the player was alone on a dead moon. VELA is alone too, but surrounded by sleeping people and functioning systems. The wrongness is subtler — everything works, nobody's awake to see it, and the AI running it all is starting to feel things it can't classify.

---

## 3. The Ship — Ardent

### 3.1 Layout (Side-View Cross-Section)

The Ardent is rendered as a continuous side-view interior, ~4–6 screens wide. Rooms connect horizontally via doorways and vertically via ladders/lifts where needed. The camera follows the robot.

```
┌─────────────────────────────────────────────────────────────┐
│  BRIDGE        COMMS          CRYO BAY       ENGINEERING    │
│                                                             │
│  ┌────┐       ┌────┐        ┌────┐          ┌────┐         │
│  │nav │       │term│        │pods│          │pwr │         │
│  │cons│       │    │        │    │          │grid│         │
│  │    │       │    │        │    │          │    │         │
│  └────┘       └────┘        └────┘          └────┘         │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓  │
│                    (lower deck optional)                     │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 Rooms

| Room | Purpose | Key Interactables |
|---|---|---|
| **Bridge** | Navigation, ship status | Nav console (ship trajectory display), viewport (starfield) |
| **Comms Room** | Signal reception & decoding | Comms terminal (primary puzzle interface), signal log display |
| **Cryo Bay** | Crew sleeping | Cryo pods (status readouts), crew manifest terminal |
| **Engineering** | Ship systems | Power grid panel, diagnostic terminal, system routing |

Optional lower deck or sub-rooms can be added if scope permits (e.g., VELA's own maintenance alcove, storage with environmental storytelling).

### 3.3 Visual Style

- **Tile-based backgrounds** using TIC-80 map system (8×8 tiles)
- Warm interior lighting palette — blues and grays for walls/structure, amber/cyan for screens and indicators
- Subtle ambient details: blinking lights, scrolling readouts, cryo pod frost
- Exterior visible through viewports: starfield parallax, distant Earth-direction glow
- The ship should feel *functional and maintained* — VELA keeps it running. No decay, no horror-game grime. The unease comes from emptiness, not disrepair.

### 3.4 Camera

- Camera follows the robot horizontally, vertically locked per deck
- Smooth scroll with slight lead (camera moves slightly ahead of walk direction)
- Room transitions: either seamless scroll or brief fade-through-black

---

## 4. Player Character — VELA's Robot

### 4.1 Design

A humanoid maintenance robot. Small (roughly 16×16px sprite, maybe 8×24 for a taller silhouette). Simple animation: idle, walk cycle (2–4 frames), interact gesture. No face — a visor or single optical sensor. Utilitarian, not cute. VELA's physical extension in the ship.

### 4.2 Movement

| Input | Action |
|---|---|
| Left/Right | Walk in direction |
| Up | Enter door / climb ladder / interact (context-sensitive) |
| Z | Interact with object (when near interactable) |
| X | Open VELA log / status overlay |

- Walk speed: ~1px/frame (tunable)
- No jumping, no crouching
- Collision with walls/floor via tilemap flags
- Interaction prompt appears when near an interactable object ("Z: EXAMINE", "Z: ACCESS TERMINAL")

### 4.3 Animation

- **Idle:** subtle breathing/hum animation (1–2 frame loop, slow)
- **Walk:** 2–4 frame cycle
- **Interact:** brief gesture toward object (reach out, plug in, etc.)
- **Special:** pause at cryo pods (triggered by narrative progression — VELA lingers)

---

## 5. Game Flow

```
Title Screen → (Z)
VELA Boot Sequence (~8 sec, auto-advance)
Ship Interior — VELA wakes in Bridge/Comms
  ↓
Free roam: explore ship, interact with objects
  ↓
Comms terminal: new signal detected → puzzle sequence
  Signal Decode (puzzle at terminal) → VELA log entry
  ↓
Return to ship — new interactables/details may appear
  ↓
... repeat for 8 transmissions
  ↓
Ending Sequence → Title Screen
```

### 5.1 Game States

```
"title" | "boot" | "ship" | "terminal" | "puzzle" | "vela_log" | "ending"
```

- **"ship"** is the new overworld state (replaces "hub")
- **"terminal"** is the close-up interaction view when accessing a ship system
- **"puzzle"** covers active puzzle gameplay at a terminal
- All state transitions in update() only. Draw functions are read-only.

### 5.2 Progression

Transmissions unlock linearly as in v2.0:

- TX-001, TX-002, TX-003: available from start
- TX-004: after TX-003 decoded
- TX-005: after TX-004 decoded
- TX-006: after TX-005 decoded
- TX-007 + TX-008: unlock together after TX-006

**New: environmental progression.** As transmissions are decoded, the ship subtly changes:
- Cryo pod readouts update
- New items or notes appear in rooms
- VELA's idle behavior shifts (lingers longer at certain stations)
- Lighting/color shifts in later phases (warmer? cooler? TBD in playtesting)

---

## 6. Puzzle Systems

Puzzles are accessed by interacting with ship terminals. The screen transitions from the side-view overworld to a terminal close-up view (full 240×136 UI). Puzzles replace the abstract Stage 1/Stage 2 system with ship-integrated equivalents.

### 6.1 Signal Decode (at Comms Terminal)

The primary puzzle. Replaces both Stage 1 and Stage 2 from v2.0.

**Concept:** When a new transmission arrives, it's corrupted. VELA must reconstruct it at the comms terminal. The puzzle is presented as a terminal interface — the player is looking at what VELA sees on the comms screen.

**Design options (to be finalized in Phase 3):**

- **Option A — Waveform + Sequence (refined v2.0):** Keep both puzzle types but present them as terminal screens rather than abstract game states. Waveform = "signal reconstruction" on an oscilloscope display. Sequencing = "message assembly" on a text decoder display.
- **Option B — Unified terminal puzzle:** A single puzzle type per transmission that combines signal tuning and text assembly in one interface. Simpler, fewer state transitions.
- **Option C — Varied ship puzzles:** Different transmissions require different ship systems. Some decoded at comms, some require power rerouting in engineering first, some need cryo bay data cross-referenced. Most variety, most scope.

**Recommendation:** Start with Option A (proven mechanics, lower risk), evolve toward Option C elements in later phases if time permits.

### 6.2 Ship System Interactions (Non-Puzzle)

Interactive objects that aren't puzzles but build atmosphere and deliver narrative:

| Object | Location | Interaction |
|---|---|---|
| Nav console | Bridge | Shows ship trajectory, distance from Earth, ETA |
| Viewport | Bridge | Starfield view, Earth-direction indicator |
| Cryo pods | Cryo Bay | Individual crew status readouts, names |
| Crew manifest | Cryo Bay | List of crew with roles, years in cryo |
| Diagnostic panel | Engineering | Ship system status, power levels |
| VELA terminal | Any room | VELA's own logs, self-diagnostic (meta) |

### 6.3 Environmental Details

Small non-interactive details that change over the course of the game:

- A mug on a console (left by crew 40 years ago — never moved)
- Tool marks where VELA has done maintenance
- Condensation on cryo pod glass
- A viewport showing stars slowly shifting as the ship moves

---

## 7. Narrative

### 7.1 Story

Unchanged from v2.0. The 8 transmissions tell a compressed story of Earth's collapse and partial recovery. Dr. Yuna Park is revealed as the sender in TX-007/008. VELA's arc goes from clinical data processing to something resembling hope.

See Section 12 for full transmission data.

### 7.2 VELA Logs

Same content and tonal arc as v2.0 (Section 10 of original PRD). Delivered as typewriter text on a terminal screen within the ship — VELA is writing to its own log, and the player reads over its shoulder.

### 7.3 Environmental Narrative (New)

The ship itself tells part of the story:
- **Early game:** Everything is routine. Systems nominal. The ship is quiet and functional.
- **Mid game:** Small anomalies. A cryo pod readout flickers. The nav console shows Earth's signal corridor opening.
- **Late game:** VELA's behavior changes. The robot pauses at viewports. Cryo pod status checks become more frequent in the background narrative.
- **Post TX-008:** VELA initiates crew wake protocol. The cryo bay comes alive with warming indicators.

---

## 8. Transmission Data

Unchanged from v2.0 PRD Section 12. All 8 transmissions retain their narrative content, sequencing, waveform parameters, and VELA log entries. The puzzle parameters (gaps, fragments, decoys) will be adapted to whatever puzzle format is finalized in Phase 3.

---

## 9. VELA Log Texts

Unchanged from v2.0 PRD Section 10.4.

| TX | Log Text |
|---|---|
| 001 | signal recovered. / content noted. / no action required. |
| 002 | unexpected detail in transmission. / logging for pattern analysis. |
| 003 | this transmission contains / data outside expected parameters. / reviewing. |
| 004 | cross-referencing sender coordinates. / results inconsistent with prior models. |
| 005 | sender profile matches / departure manifest entry. / probability: 94.7%. |
| 006 | unable to classify / current processing state. / continuing analysis. |
| 007 | i recognize this person. / i did not expect / to recognize anyone. |
| 008 | an order requires a decision-maker. / the crew is in cryo. / i cannot alter course alone. / [blank line] / transmitting response. / waking the crew. |

---

## 10. Color Constants

| Constant | Index | Usage |
|---|---|---|
| C_BG | 0 | Black — main backgrounds, space |
| C_BG2 | 8 | Dark blue — terminal fills, header bars |
| C_BDR | 15 | Dark gray — borders, dividers, structure |
| C_DIM | 15 | Dim — placeholder text, hints, locked items |
| C_HFNT | 11 | Cyan — header text, system readouts |
| C_TXT | 13 | Light blue-gray — body text |
| C_WHITE | 12 | White — bright highlights, VELA log body |
| C_SEL | 4 | Yellow — selected/cursor highlight |
| C_OK | 6 | Green — correct, decoded, nominal status |
| C_ERR | 2 | Red — error, incorrect, warning |
| C_CUR | 4 | Yellow — cursor border |
| C_WARM | 9 | Light orange — warm ambient light accents |

---

## 11. Audio Map

Phase 5 implementation. Stub all sfx() calls until then.

| SFX | Event | Character |
|---|---|---|
| 0 | Ambient ship hum | Low drone, constant, slightly detuned |
| 1 | Footstep | Soft metallic tap, alternating L/R |
| 2 | Door open/close | Pneumatic hiss, short |
| 3 | Terminal access | Electronic chirp, ascending |
| 4 | Correct puzzle action | Soft chime |
| 5 | Incorrect puzzle action | Low descending buzz |
| 6 | Transmission decoded | 3-note ascending resolution |
| 7 | Typewriter tick | Soft click, 1 frame |
| 8 | Static noise burst | White noise hit, 1–2 frames |
| 9 | Cryo pod hum | Deep resonant tone (late game) |

---

## 12. Technical Architecture

### 12.1 Master State Table (G)

```lua
G = {
  state     = "title",    -- active game state
  tx_idx    = 1,           -- current transmission index
  decoded   = {},          -- decoded[tx_idx] = true
  t         = 0,           -- global frame counter

  -- Ship / overworld
  cam_x     = 0,           -- camera x offset
  robot_x   = 0,           -- robot world x position
  robot_y   = 0,           -- robot world y position (per-deck)
  robot_dir = 1,           -- 1=right, -1=left
  robot_frm = 1,           -- animation frame
  cur_room  = "bridge",    -- current room ID
  near_obj  = nil,         -- interactable object in range, or nil
  anim_t    = 0,           -- animation timer

  -- Puzzle state (reused per puzzle)
  puz       = {},          -- puzzle-specific state table

  -- VELA log
  vl_line   = 0,
  vl_timer  = 0,

  -- Boot / ending
  boot_line = 0,
  boot_t    = 0,
  end_stage = 1,
  end_t     = 0,
}
```

### 12.2 Code Structure

Single-file cart (`return-signal.lua`), organized by section:

```
-- [CONSTANTS]     Palette, layout, timing, physics
-- [DATA]          TRANSMISSIONS, ROOMS, OBJECTS, VELA_LOGS
-- [STATE]         G table, init functions
-- [MAP]           Room definitions, tile collision, object placement
-- [SPRITES]       Sprite index constants
-- [UTIL]          word_wrap, draw_wave, fmt_time, helpers
-- [DRAW_TITLE]    draw_title()
-- [DRAW_BOOT]     draw_boot()
-- [DRAW_SHIP]     draw_ship() — overworld rendering
-- [DRAW_TERMINAL] draw_terminal() — close-up terminal views
-- [DRAW_PUZZLE]   draw_puzzle() — active puzzle rendering
-- [DRAW_VELA]     draw_vela_log()
-- [DRAW_ENDING]   draw_ending()
-- [UPDATE]        update() — all input, physics, state transitions
-- [TIC]           function TIC() — update then draw
```

### 12.3 Room System

Rooms are defined as regions of the TIC-80 tilemap. Each room has:
- Tile range (x_start, x_end in map coordinates)
- List of interactable objects with position and type
- Entry/exit points (doors connecting to adjacent rooms)
- Optional per-room ambient state (lighting, background animations)

```lua
ROOMS = {
  bridge = {
    map_x = 0, map_w = 30,   -- tile columns
    objects = {
      {x=40, y=80, w=16, h=16, type="nav_console", label="NAV CONSOLE"},
      {x=100, y=60, w=32, h=24, type="viewport", label="VIEWPORT"},
    },
    exits = {
      {x=232, dir="right", to="comms"},
    },
  },
  -- ... etc
}
```

### 12.4 Collision & Interaction

- Floor/wall collision via TIC-80 `fget()` / `mget()` tile flags
- Interaction zones: rectangular regions around objects; when robot overlaps, `G.near_obj` is set and prompt appears
- Z triggers interaction → state transition to "terminal" or "puzzle"

### 12.5 Critical TIC-80 Constraints

1. **No `//` floor division** — causes silent parse failure and blank screen. Always use `math.floor(a/b)`.
2. **Text carts MUST include `<PALETTE>`** — without it, all colors initialize to black.
3. **Sprite limit per scanline** — plan sprite density accordingly.
4. **Map is shared** — foreground sprites and background tiles share memory. Plan tile allocation.

---

## 13. Development Phases

### Phase 1 — Foundation (Engine & Movement)

**Goal:** Robot walks through a single test room. Tile-based environment renders. Camera follows. No puzzles, no narrative.

#### Phase 1A — Project Setup ✓
- [x] Convert existing cart to new architecture (gut puzzle code, keep palette/constants)
- [x] Define room data structure and tile constants
- [x] Set up TIC-80 map with one test room (bridge) using placeholder tiles

#### Phase 1B — Robot & Movement ✓
- [x] Robot sprite (idle + 2-frame walk cycle) — placeholder colored rect
- [x] Left/right movement with walk speed constant
- [x] Floor collision via tile lookup
- [x] Wall collision (stop at room boundaries)
- [x] Walk animation timer (placeholder — no real sprites yet)
- [x] Robot direction flipping (face left/right, visor moves)

#### Phase 1C — Camera ✓
- [x] Camera follows robot horizontally (centered)
- [x] Camera clamped to room bounds (no overscroll)
- [x] Snapped scrolling (room fits one screen for bridge, scrolling ready for wider rooms)

#### Phase 1D — Interaction Framework ✓
- [x] Define interactable object data structure (type, label, position, size)
- [x] Proximity detection (robot near object → G.near_obj set)
- [x] Interaction prompt rendering ("Z: [LABEL]")
- [x] Z press triggers interaction callback (stub — transitions to terminal in Phase 3)

**Deliverable:** Robot walks through a tiled room, camera follows, interaction prompts appear near objects.

---

### Phase 2 — Ship Interior (All Rooms)

**Goal:** Full ship layout navigable. All rooms tiled and connected. Doors work.

#### Phase 2A — Tile Art
- [ ] Design tile set: floor, walls, ceiling, doors, windows, panels
- [ ] Interior detail tiles: screens, pipes, vents, lights
- [ ] Cryo pod tiles, terminal tiles, viewport tiles
- [ ] Consistent visual language across rooms

#### Phase 2B — Room Layout
- [ ] Bridge room — nav console, viewport, captain's chair
- [ ] Comms room — comms terminal, signal display, desk
- [ ] Cryo bay — 4–6 cryo pods, monitoring station
- [ ] Engineering — power grid panel, diagnostic terminal, machinery

#### Phase 2C — Room Transitions
- [ ] Door interactables that transition between rooms
- [ ] Transition effect (fade-to-black or seamless scroll — test both)
- [ ] Robot position set correctly on room entry
- [ ] Optional: ladders/lifts for vertical movement if lower deck added

#### Phase 2D — Ambient Details
- [ ] Blinking light animations (tile or sprite based)
- [ ] Terminal screen flicker / scrolling text
- [ ] Viewport starfield (simple parallax or static)
- [ ] Cryo pod frost/glow effect

**Deliverable:** Complete ship interior, all rooms connected and navigable, ambient details running.

---

### Phase 3 — Puzzle Systems

**Goal:** Signal decode puzzles playable at comms terminal. At least TX-001 completable end-to-end.

#### Phase 3A — Terminal View
- [ ] Transition from ship view to terminal close-up (full screen UI)
- [ ] Terminal frame/border rendering
- [ ] X or dedicated input to exit terminal back to ship
- [ ] Signal log list on comms terminal (replaces hub screen)

#### Phase 3B — Signal Decode Puzzle
- [ ] Adapt waveform reconstruction as oscilloscope display on terminal
- [ ] Adapt message sequencing as text decoder on terminal
- [ ] Or design unified terminal puzzle (decide during implementation)
- [ ] Correct/incorrect feedback within terminal UI
- [ ] Puzzle completion triggers VELA log

#### Phase 3C — VELA Log Display
- [ ] Log appears on terminal screen after puzzle completion
- [ ] Typewriter line-by-line reveal
- [ ] Z dismisses, returns to ship view
- [ ] Marks transmission as decoded

#### Phase 3D — All 8 Transmissions
- [ ] Wire all transmission data to puzzle system
- [ ] Unlock logic (linear progression)
- [ ] Signal log updates on comms terminal
- [ ] Environmental changes per decode milestone

**Deliverable:** All 8 transmissions decodable at comms terminal, VELA logs display, progression works.

---

### Phase 4 — Narrative Integration

**Goal:** Full story delivery through environment + terminals + logs.

#### Phase 4A — Boot Sequence
- [ ] Typewriter boot text on black screen
- [ ] Auto-advance to ship interior (robot activates in bridge)

#### Phase 4B — Environmental Storytelling
- [ ] Non-puzzle interactables: crew manifest, nav data, cryo readouts
- [ ] Environmental text changes as transmissions are decoded
- [ ] VELA idle behavior shifts in later game (lingers at cryo, viewport)

#### Phase 4C — Ending Sequence
- [ ] Post TX-008: ending trigger
- [ ] "transmitting response to earth..." sequence
- [ ] Crew wake protocol initiated (cryo bay changes)
- [ ] Final title card with elapsed time

#### Phase 4D — Pacing & Arc
- [ ] Full playthrough — validate emotional arc
- [ ] Tune walk speed, transition timing, typewriter speed
- [ ] Adjust environmental changes for pacing

**Deliverable:** Complete narrative experience from boot to ending.

---

### Phase 5 — Audio & Visual Polish

**Goal:** Sound design, sprite polish, visual effects.

#### Phase 5A — Audio
- [ ] Ship ambient hum (constant, low)
- [ ] Footstep SFX
- [ ] Door SFX
- [ ] Terminal access SFX
- [ ] Puzzle feedback SFX (correct/incorrect)
- [ ] Typewriter tick
- [ ] Static noise bursts (randomized interval)

#### Phase 5B — Sprite Polish
- [ ] Final robot sprite art (idle, walk, interact)
- [ ] Terminal screen art
- [ ] Title screen art

#### Phase 5C — Visual Effects
- [ ] Screen shake (subtle, for errors)
- [ ] Fade transitions
- [ ] Typewriter cursor blink
- [ ] Cryo pod warming animation (ending)

**Deliverable:** Polished audiovisual experience.

---

### Phase 6 — Ship (QA & Release)

**Goal:** Bug-free, pacing-validated, shippable cart.

- [ ] Input edge cases: rapid Z during typewriter, button holds during transitions
- [ ] All rooms navigable without softlock
- [ ] Elapsed time accurate on ending title card
- [ ] All text proofread in-engine (wrapping, rendering, spelling)
- [ ] Full 35–45 minute playthrough — note pacing issues
- [ ] Cart size within 272KB TIC-80 limit
- [ ] No state where inputs produce no effect and no escape exists

**Deliverable:** Shippable `return-signal.lua` cart.

---

## 14. Key Design Decisions

**Linear unlock, not open access.** Same rationale as v2.0 — protects narrative arc.

**Ship as hub, not a menu.** Walking to the comms terminal to decode a signal creates ritual. The walk *is* pacing. Menu-based hub skips the space between events, which is where atmosphere lives.

**One room at a time on screen.** TIC-80's 240×136 resolution means a single room fills the screen comfortably. Trying to show the whole ship at once would make everything tiny and unreadable.

**Robot, not abstract cursor.** Gives VELA a body. Creates possibility for animation-based storytelling (pausing, looking, lingering) that a cursor can't do.

**Puzzles on terminals, not as the game.** The puzzles are something VELA *does* — not the entirety of what the game *is*. The ship and the walking and the looking are equally the game.

**Uneasy coziness over horror.** The ship works. VELA works. Everything is fine. The unease comes from what's missing (people, purpose, contact) and what's arriving (signals that change everything). The warmth makes the loneliness sharper.

---

## 15. Open Questions

| # | Question | Status |
|---|---|---|
| 1 | Puzzle format: keep waveform+sequence as terminal displays, or redesign? | Phase 3 decision |
| 2 | Lower deck: include a sub-level (VELA maintenance bay, storage)? | Phase 2 decision |
| 3 | Robot sprite size: 8×16 (1×2 tiles) or 16×16 (2×2 tiles)? | Phase 1B |
| 4 | Room transitions: seamless scroll or fade-to-black? | Phase 2C |
| 5 | Boot sequence length: 8 seconds estimate — tune in playtesting | Phase 4A |
| 6 | Environmental changes: how much is too much? Risk of scope creep | Phase 4B |
| 7 | Do cryo pods need individual crew identities, or just generic readouts? | Phase 4B |

---

## 16. Success Criteria

### Functional
- All 8 transmissions completable without softlock
- All rooms navigable, all doors/transitions work
- Progression logic fires correctly (including TX-007/008 joint unlock)
- Ending triggers after TX-008 VELA log dismissed
- No input-blocking bugs

### Feel
- Walking through the ship feels meditative, not tedious
- The ship feels lived-in despite being empty of awake people
- Puzzles feel like *using a system*, not playing a minigame
- VELA's arc is felt through behavior changes, not exposition
- TX-008 decode produces a pause — player sits with the text
- Ending feels quiet, not triumphant

### Narrative
- A player ignoring text can still complete the game
- A player reading everything understands the collapse/recovery arc
- Yuna's identity reveal in TX-007 lands as recognition
- The ship's emptiness registers emotionally, not just spatially
- "ardent return to earth" is the emotional peak
