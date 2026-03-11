# Return Signal — Gameplay Improvements Design

**Date:** 2026-03-11
**Approach:** Bottom-Up (Foundation First)
**Priorities:** Feel/polish → Player experience → Atmosphere/narrative

---

## Summary

Five phases of gameplay improvements to transform Return Signal from functional prototype to polished experience. Puzzles are mechanically sound and unchanged. All work layers on top of existing systems.

---

## Phase 1: Sprites & Animation

### Robot Sprite (8x16, 1 tile wide × 2 tiles tall)
Current robot is `ROBOT_W=8, ROBOT_H=16` (1×2 tiles). Keep this footprint.

- Humanoid maintenance bot — no face, single visor/optical sensor
- 5 sprite images total across 4 animation states:
  - Idle frame A (default)
  - Idle frame B (breathing variant — subtle visor flicker or chest shift)
  - Walk frame A
  - Walk frame B
  - Interact frame (arm-reach gesture)
- Idle: toggle A↔B at ~30 frame interval
- Walk: toggle A↔B at ~8 frames per step, tied to `walk_t`
- Interact: single frame on Z press near object, held for 12 frames
- Direction: horizontal flip via `spr()` flip flag
- Each frame = 2 sprite tiles (top half + bottom half) = 10 tiles total for robot

### Sprite Index Allocation

| Index Range | Usage | Count |
|-------------|-------|-------|
| 1–12 | Map tiles (T_FLOOR through T_LIGHT, matching existing tile IDs) | 12 |
| 13–14 | T_CRYO_L_WARM, T_CRYO_R_WARM (clear glass variants for Phase 5) | 2 |
| 15–16 | Ambient anim: T_SCREEN alt frame, T_LIGHT alt frame | 2 |
| 17–18 | Ambient anim: T_CRYO_L alt frame, T_CRYO_R alt frame | 2 |
| 32–41 | Robot frames: 5 frames × 2 tiles each (top/bottom) | 10 |
| 48–51 | Environmental detail sprites (mug, tool marks, scuff marks, signal indicator) | 4 |
| **Total** | | **32 of 256** |

Plenty of headroom for future sprite needs.

### Tile Art (8x8, all 13 tile types)
Replace programmatic colored blocks with authored pixel art:

| Tile | Art Direction |
|------|--------------|
| T_FLOOR | Metal plating with rivet detail |
| T_WALL | Hull panel lines |
| T_CEIL | Structural beam pattern |
| T_PANEL | Upper wall paneling |
| T_DOOR | Sliding door seam |
| T_WINDOW | Dark blue with star dots |
| T_SCREEN | Green/cyan terminal glow |
| T_PIPE | Industrial conduit |
| T_GRATE | Crosshatch pattern |
| T_CRYO_L/R | Frosted glass with faint figure silhouette |
| T_LIGHT | Amber ceiling fixture |

### Ambient Sprite Animations
- Ceiling lights: 2-frame flicker, occasional random timing
- Screens: 2-frame scan line scroll
- Cryo pods: slow frost shimmer, 2-frame, long interval

All sprites in `<TILES>` section. Current `rect()`/`pix()` drawing replaced with `spr()` calls.

---

## Phase 2: Audio

### SFX Slots (TIC-80 SFX bank, up to 64 slots)

Aligns with PRD Section 11 audio map, extended with additional events:

| Slot | Event | Design |
|------|-------|--------|
| 0 | Ambient ship hum | Low drone, slightly detuned (looped on dedicated channel) |
| 1 | Footstep | Soft metallic tap, alternating pitch L/R |
| 2 | Door open/close | Pneumatic hiss, short |
| 3 | Terminal access | Electronic chirp, ascending |
| 4 | Correct puzzle action | Soft chime |
| 5 | Incorrect puzzle action | Low descending buzz |
| 6 | Transmission decoded | 3-note ascending resolution |
| 7 | Typewriter tick | Soft click, 1 frame |
| 8 | Static noise burst | White noise hit, 1–2 frames |
| 9 | Cryo pod hum | Deep resonant tone (late game) |
| 10 | Terminal exit | Descending chirp |
| 11 | VELA log line appear | Soft tone |
| 12 | Boot sequence character | Faint terminal blip |
| 13 | Interaction prompt appear | Subtle ping |
| 14 | Fragment pick/place | Click/snap |

**Note:** SFX slots ≠ audio channels. TIC-80 has 4 channels (0–3). `sfx(slot, note, duration, channel)` plays a slot on a channel.

### Channel Assignment

| Channel | Usage |
|---------|-------|
| 0 | Ambient drone (continuous, lowest priority) |
| 1 | Footsteps, door transitions |
| 2 | Puzzle feedback (correct/incorrect/fragment) |
| 3 | UI/narrative (typewriter, VELA log, terminal chirps) |

### Ambient Drone
- Plays SFX slot 0 on channel 0, re-triggered via timer in `TIC()` to loop
- Per-room pitch variation via `sfx()` note parameter: engineering lower, cryo deeper
- No ducking — drone simply shares its channel with nothing else. Other SFX use channels 1–3.
- Starts after boot sequence completes

### Integration
- Update existing `play_sfx()` calls to use correct slot IDs (current code already calls play_sfx with IDs — remap to match table above)
- Footsteps: trigger on walk cycle frame change (~every 8 frames while moving)
- Add new `sfx()` calls at door transitions, terminal enter/exit, prompt appear

---

## Phase 3: Screen Transitions & Visual Feedback

### Room Transitions
- Fade-through-black on door boundaries
- 8 frames fade out → swap room/position → 8 frames fade in
- `G.fade` counter checked in `TIC()`, input skipped during fade

### Terminal Transitions
- Enter: scanlines draw top-to-bottom over ~12 frames
- Exit: reverse collapse effect
- Replaces instant state swap

### Puzzle Feedback
- S1 correct: green pulse on gap region
- S1 incorrect: red border flash (adds to existing shake)
- S2 correct: wave ripple across text before typewriter
- S2 incorrect: static noise overlay on wrong slots (adds to existing red flash)

### Interaction Prompt
- Floating prompt above robot when `near_obj` set
- Drawn at `robot_y - 10` clamped to minimum y=2 (prevents clipping off top of screen)
- 4-frame fade in via `G.prompt_fade` counter (0→4), gentle 1px sine bob
- Uses object's existing `label` field for text (e.g. "Z: COMMS TERMINAL") — no type-verb mapping needed
- When `G.near_obj` changes from nil, reset `G.prompt_fade = 0` to trigger fade-in

### Camera Smoothing
- Replace snap with lerp: `cam_x = math.floor(cam_x + (target - cam_x) * 0.15)`
- `math.floor()` required — TIC-80 renders at integer pixels; float cam_x causes tile shimmer
- Robot leads, camera follows with drift

### HUD
- Decoded count "3/8" in top-right corner during ship state, dim text
- Room name fades in on entry, fades out after 60 frames

---

## Phase 4: Player Onboarding & Difficulty Curve

### First-Time Hints
All tracked via `G.hints_shown = {}`, each hint ID shown once:

| Trigger | Text | Duration |
|---------|------|----------|
| First ship entry after boot | "signal detected on comms array. routing to terminal." | 120 frames |
| First approach to comms terminal | Prompt pulses brighter | Until interaction |
| First signal log entry | "incoming signal — select to decode" with TX-001 highlight | Until selection |
| First Stage 1 | "match fragments to gaps in the waveform" | 180 frames, fade |
| First Stage 2 | "arrange fragments in sequence" | 180 frames, fade |

### Visual Difficulty Reinforcement
- Later transmissions: more static/noise on waveform display
- More visual clutter on terminal screen for higher TX numbers
- Data already scales (gaps: 2→4, fragments: 3→6, decoys increase) — visuals match

### Puzzle Exit Safety
- X during puzzle sets `G.puz_confirm = true` (flag, not a new game state)
- While `G.puz_confirm == true`: draw "ABORT DECODE? Z:YES X:NO" overlay, skip puzzle input
- Z confirms: reset puzzle state, set transmission back to available (not decoded), return to terminal (`G.state = "terminal"`)
- X cancels: set `G.puz_confirm = false`, resume puzzle
- Works identically in Stage 1 and Stage 2 — both abort to terminal

### Replay Decoded Transmissions
- Decoded TX in signal log shows "Z: READ LOG" prompt instead of being unselectable
- Z on decoded entry → new `G.state = "vela_log"` with `G.replay = true`
- Replay mode shows: assembled message (all `tx.seq` fragments joined with " // ") on first screen, Z advances to VELA log lines, Z again returns to terminal
- Same draw path as existing `draw_vela_log()` but prefixed with the decoded message text
- `G.replay` flag prevents `decoded[]` from being set again on dismiss

---

## Phase 5: Environmental Storytelling & Atmosphere

### Ship State Progression

| Decoded | Changes |
|---------|---------|
| 0 | Baseline — nominal, quiet, routine |
| 1–2 | Comms screens show faint signal indicator |
| 3–4 | Nav console: "SIGNAL CORRIDOR DETECTED". One cryo pod readout flickers (rare 2-frame glitch) |
| 5–6 | Comms screens cycle new data. Viewport tiles: faint Earth-direction glow. Robot idle pauses longer |
| 7–8 | Cryo bay: amber warming indicators on pods. Engineering: increased power draw on screens. Robot idle: occasionally turns toward nearest cryo pod |
| All 8 | Cryo bay lights warm. Pod frost → clear glass (swap T_CRYO_L/R → T_CRYO_L_WARM/T_CRYO_R_WARM tile IDs, indices 13–14). Ship hum pitch shifts upward |

### Implementation
- `decoded_count()` helper returns count of decoded entries
- Tile-based changes (cryo pod warm variants, signal indicators): call `rebuild_room()` after each transmission decode — re-runs `build_room()` for current room with decoded count, swapping tile IDs where thresholds are met
- Draw-based changes (flickering, glow overlays, text on screens): branched in `draw_ship()` on `decoded_count()` — these are visual overlays, not tile identity changes
- Robot contextual idle in `update_ship()`: when `walk_t == 0` and `G.t % 300 == 0`, trigger behavior based on decoded count (look at pod, look at viewport)
- Ambient hum pitch adjusted per threshold via `sfx()` note parameter
- New tile constants: `T_CRYO_L_WARM = 13`, `T_CRYO_R_WARM = 14` added to constants section

### Static Environmental Details (always present)
- Comms room: mug sprite on console edge
- Bridge: tool marks near nav console
- Engineering: scuff marks on floor near grates

---

## Phase Dependencies

```
Phase 1 (Sprites) ──→ Phase 2 (Audio) ──→ Phase 3 (Transitions/Feedback)
    │                      │                          │
    │                      │                          ▼
    │                      │                Phase 4 (Onboarding/UX)
    │                      │                          │
    ▼                      ▼                          ▼
    └──────────────────────┴───────→ Phase 5 (Atmosphere)
```

Phases are sequential. Phase 5 has hard dependencies on Phase 1 (tile art for swaps, environmental detail sprites) and Phase 2 (ambient drone for pitch shifts). These are satisfied by the sequential ordering.
