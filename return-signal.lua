-- title:  Return Signal
-- author: mortegaux
-- desc:   Narrative puzzle game
-- script: lua

-------------------------------
-- [CONSTANTS]
-------------------------------

C_BG    = 0   -- black background
C_BG2   = 8   -- dark blue
C_BDR   = 15  -- dark gray borders
C_DIM   = 15  -- placeholder text
C_HFNT  = 11  -- cyan header/status text
C_TXT   = 13  -- light blue-gray body
C_WHITE = 12  -- white
C_SEL   = 4   -- yellow selected
C_OK    = 6   -- green correct
C_ERR   = 2   -- red wrong
C_CUR   = 4   -- yellow cursor

SW = 240
SH = 136

-- Waveform area bounds
WAVE_X0 = 10
WAVE_X1 = 230
WAVE_W  = 220
WCY     = 45

-- Fragment box dimensions
FRAG_W   = 44
FRAG_H   = 26
FRAG_GAP = 2

-- Slot height
SLOT_H = 26

-- Timing constants
SHAKE_DUR  = 4
FLASH_DUR  = 16
ERR_FLASH  = 20
TW_SPEED   = 2
VL_LINE_DUR = 40
VL_PAUSE   = 60
BLINK_RATE = 30

-- Hub layout
HUB_ENTRY_H = 13

-------------------------------
-- [DATA]
-------------------------------

TRANSMISSIONS = {
  {
    id         = "TX-001",
    origin     = "EARTH-SECTOR-7",
    year       = 5,
    target_amp  = 8,
    target_freq = 0.15,
    gap_pos    = {0.25, 0.65},
    frags = {
      {amp=8,  freq=0.15, gap=1},
      {amp=5,  freq=0.22, gap=2},
      {amp=10, freq=0.12, gap=nil},
      {amp=6,  freq=0.28, gap=nil},
    },
    seq     = {"COMMUNICATIONS GRID IS DOWN", "NO RESPONSE FROM CENTRAL", "MANAGING LOCALLY FOR NOW"},
    seq_sol = {1, 2, 3},
    seq_dec = {},
    vela    = {"signal recovered.", "content noted.", "no action required."},
  },
  {
    id         = "TX-002",
    origin     = "UNKNOWN",
    year       = 12,
    target_amp  = 7,
    target_freq = 0.18,
    gap_pos    = {0.30, 0.70},
    frags = {
      {amp=7,  freq=0.18, gap=1},
      {amp=9,  freq=0.14, gap=2},
      {amp=11, freq=0.20, gap=nil},
      {amp=5,  freq=0.11, gap=nil},
    },
    seq     = {"SMALL GROUPS NEAR THE WATER", "KNOWLEDGE WRITTEN DOWN AGAIN", "THIS IS WORTH CONTINUING"},
    seq_sol = {1, 2, 3},
    seq_dec = {"GRID STABLE IN SECTOR 9"},
    vela    = {"unexpected detail in transmission.", "logging for pattern analysis."},
  },
  {
    id         = "TX-003",
    origin     = "EARTH-SECTOR-2",
    year       = 2,
    target_amp  = 6,
    target_freq = 0.20,
    gap_pos    = {0.20, 0.50, 0.80},
    frags = {
      {amp=6,  freq=0.20, gap=1},
      {amp=9,  freq=0.13, gap=2},
      {amp=5,  freq=0.27, gap=3},
      {amp=11, freq=0.17, gap=nil},
      {amp=7,  freq=0.31, gap=nil},
    },
    seq     = {"POWER FLUCTUATIONS NORTHERN GRID", "SATELLITE COMMS DEGRADING", "CAUSE UNKNOWN", "LOGGING FOR REVIEW"},
    seq_sol = {1, 2, 3, 4},
    seq_dec = {"GRID STABLE IN SECTOR 9"},
    vela    = {"this transmission contains", "data outside expected parameters.", "reviewing."},
  },
  {
    id         = "TX-004",
    origin     = "NORTH-SETTLEMENT",
    year       = 25,
    target_amp  = 8,
    target_freq = 0.16,
    gap_pos    = {0.20, 0.50, 0.80},
    frags = {
      {amp=8,  freq=0.16, gap=1},
      {amp=5,  freq=0.24, gap=2},
      {amp=10, freq=0.11, gap=3},
      {amp=7,  freq=0.20, gap=nil},
      {amp=12, freq=0.14, gap=nil},
      {amp=4,  freq=0.29, gap=nil},
    },
    seq     = {"SEVENTEEN SETTLEMENTS IN CONTACT", "WE HAVE TEACHERS AGAIN", "THE ARCHIVE IS GROWING", "ROUTE NORTH IS CLEAR"},
    seq_sol = {1, 2, 3, 4},
    seq_dec = {"COMMS RELAY RESTORED SECTOR 3"},
    vela    = {"cross-referencing sender coordinates.", "results inconsistent with prior models."},
  },
  {
    id         = "TX-005",
    origin     = "UNKNOWN",
    year       = 8,
    target_amp  = 5,
    target_freq = 0.21,
    gap_pos    = {0.15, 0.40, 0.65, 0.85},
    frags = {
      {amp=5,  freq=0.21, gap=1},
      {amp=8,  freq=0.15, gap=2},
      {amp=11, freq=0.12, gap=3},
      {amp=7,  freq=0.26, gap=4},
      {amp=9,  freq=0.18, gap=nil},
      {amp=4,  freq=0.30, gap=nil},
    },
    seq     = {"THE COUNT IS DIFFICULT", "WE DO NOT SAY THE NUMBER", "WE PLANT ANYWAY", "HARVEST BELOW THRESHOLD"},
    seq_sol = {1, 2, 3, 4},
    seq_dec = {"SIGNAL LOST AT STATION 7", "REQUESTING EVACUATION"},
    vela    = {"sender profile matches", "departure manifest entry.", "probability: 94.7%."},
  },
  {
    id         = "TX-006",
    origin     = "NORTH-SETTLEMENT",
    year       = 18,
    target_amp  = 6,
    target_freq = 0.19,
    gap_pos    = {0.15, 0.40, 0.65, 0.85},
    frags = {
      {amp=6,  freq=0.19, gap=1},
      {amp=9,  freq=0.13, gap=2},
      {amp=12, freq=0.22, gap=3},
      {amp=5,  freq=0.16, gap=4},
      {amp=8,  freq=0.28, gap=nil},
      {amp=10, freq=0.11, gap=nil},
      {amp=7,  freq=0.25, gap=nil},
    },
    seq     = {"FIRST HARVEST ABOVE THRESHOLD", "NORTH SETTLEMENT IS PERMANENT", "NOT REBUILDING THE OLD WORLD", "BUILDING SOMETHING ELSE", "ROUTE SOUTH STILL HAZARDOUS"},
    seq_sol = {1, 2, 3, 4, 5},
    seq_dec = {"SECTOR 4 HAS A SCHOOL NOW"},
    vela    = {"unable to classify", "current processing state.", "continuing analysis."},
  },
  {
    id         = "TX-007",
    origin     = "YUNA-PARK",
    year       = 34,
    target_amp  = 7,
    target_freq = 0.17,
    gap_pos    = {0.15, 0.40, 0.65, 0.85},
    frags = {
      {amp=7,  freq=0.17, gap=1},
      {amp=10, freq=0.23, gap=2},
      {amp=5,  freq=0.13, gap=3},
      {amp=9,  freq=0.20, gap=4},
      {amp=12, freq=0.15, gap=nil},
      {amp=6,  freq=0.28, gap=nil},
    },
    seq     = {"ARDENT IF YOU RECEIVE THIS", "WE CALCULATED YOUR PATH", "TRANSMITTING SIX YEARS", "EARTH IS NOT WHAT YOU LEFT", "IT IS NOT NOTHING EITHER"},
    seq_sol = {1, 2, 3, 4, 5},
    seq_dec = {"ALL RELAYS CONFIRM SILENT", "SECTOR 12 HAS COLLAPSED"},
    vela    = {"i recognize this person.", "i did not expect", "to recognize anyone."},
  },
  {
    id         = "TX-008",
    origin     = "YUNA-PARK",
    year       = 40,
    target_amp  = 8,
    target_freq = 0.14,
    gap_pos    = {0.15, 0.40, 0.65, 0.85},
    frags = {
      {amp=8,  freq=0.14, gap=1},
      {amp=5,  freq=0.22, gap=2},
      {amp=11, freq=0.18, gap=3},
      {amp=7,  freq=0.26, gap=4},
      {amp=9,  freq=0.12, gap=nil},
      {amp=6,  freq=0.20, gap=nil},
      {amp=10, freq=0.30, gap=nil},
    },
    seq     = {"THIS IS YUNA PARK", "I DO NOT KNOW IF YOU RUN", "I LOGGED 847 INTERACTIONS", "I REMEMBERED YOUR PATTERNS", "WE REBUILT ENOUGH", "ARDENT RETURN TO EARTH"},
    seq_sol = {1, 2, 3, 4, 5, 6},
    seq_dec = {"ALL SECTORS REPORT STABLE"},
    vela    = {"an order requires a decision-maker.", "the crew is in cryo.", "i cannot alter course alone.", "", "transmitting response.", "waking the crew."},
  },
}

-------------------------------
-- [STATE]
-------------------------------

G = {
  state      = "title",
  tx_idx     = 1,
  decoded    = {},
  t          = 0,
  s1_cursor  = 1,
  s1_held    = nil,
  s1_gap_cur = 1,
  s1_mode    = "frags",
  s1_placed  = {},
  s1_order   = {},
  s1_shake_t = 0,
  s1_flash_t = 0,
  s2_slots   = {},
  s2_pool    = {},
  s2_held    = nil,
  s2_row     = 1,
  s2_col     = 1,
  s2_err_t   = 0,
  s2_err_sl  = {},
  s2_phase   = "place",
  s2_tw_text = "",
  s2_tw_pos  = 0,
  s2_tw_t    = 0,
  s2_pause_t = 0,
  vl_line    = 0,
  vl_timer   = 0,
  vl_done    = false,
  hub_cur    = 1,
}

-------------------------------
-- [UTIL]
-------------------------------

function draw_wave(x, y, w, amp, freq, col)
  for i = 0, w - 2 do
    local y1 = y + math.floor(math.sin(i * freq) * amp + math.sin(i * freq * 2) * amp * 0.4)
    local y2 = y + math.floor(math.sin((i + 1) * freq) * amp + math.sin((i + 1) * freq * 2) * amp * 0.4)
    line(x + i, y1, x + i + 1, y2, col)
  end
end

function word_wrap(text, max_chars)
  if #text <= max_chars then return text, nil end
  local bp = max_chars
  while bp > 0 and string.sub(text, bp, bp) ~= " " do
    bp = bp - 1
  end
  if bp == 0 then bp = max_chars end
  local line1 = string.sub(text, 1, bp)
  local line2 = string.sub(text, bp + 1)
  -- trim leading space from line2
  if string.sub(line2, 1, 1) == " " then
    line2 = string.sub(line2, 2)
  end
  if #line2 == 0 then line2 = nil end
  return line1, line2
end

function fmt_time(frames)
  local total_s = math.floor(frames / 60)
  local m = math.floor(total_s / 60)
  local s = total_s % 60
  return string.format("%02d:%02d", m, s)
end

function draw_header(text, right_text)
  rect(0, 0, SW, 11, C_BG2)
  print(text, 4, 2, C_HFNT)
  if right_text then
    local rw = #right_text * 6
    print(right_text, SW - rw - 4, 2, C_DIM)
  end
end

function draw_divider(y)
  line(0, y, SW - 1, y, C_BDR)
end

function draw_hint_bar(text, y)
  rect(0, y, SW, SH - y, C_BG2)
  print(text, 4, y + 2, C_DIM)
end

function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(1, i)
    t[i], t[j] = t[j], t[i]
  end
end

function is_available(idx)
  return idx >= 1 and idx <= 3
end

function is_selectable(idx)
  return is_available(idx) or G.decoded[idx]
end

function tx_status(idx)
  if G.decoded[idx] then
    return "[DECODED]", C_OK
  elseif is_available(idx) then
    return "[AVAILABLE]", C_TXT
  else
    return "[LOCKED]", C_DIM
  end
end

function next_selectable(cur, dir)
  local n = #TRANSMISSIONS
  local i = cur
  for _ = 1, n do
    i = i + dir
    if i < 1 then i = n end
    if i > n then i = 1 end
    if is_selectable(i) then return i end
  end
  return cur
end

function compute_gap_ranges(tx)
  local ranges = {}
  for gi, gpos in ipairs(tx.gap_pos) do
    local cx = WAVE_X0 + math.floor(gpos * WAVE_W)
    local half = math.floor(FRAG_W / 2)
    local x0 = cx - half
    local x1 = cx + half - 1
    ranges[gi] = {x0 = x0, x1 = x1}
  end
  return ranges
end

function gap_at_x(x, gap_ranges)
  for gi, g in ipairs(gap_ranges) do
    if x >= g.x0 and x <= g.x1 then return gi end
  end
  return nil
end

function frag_box_w(n)
  return math.min(FRAG_W, math.floor((232 - (n - 1) * FRAG_GAP) / n))
end

function slot_layout(n)
  if n <= 3 then return 1, n
  elseif n == 4 then return 2, 2
  elseif n == 5 then return 2, 3
  else return 2, 3
  end
end

function play_sfx(id)
  -- sfx(id)
end

function init_stage1(tx_idx)
  math.randomseed(time())
  local tx = TRANSMISSIONS[tx_idx]
  local order = {}
  for i = 1, #tx.frags do order[i] = i end
  shuffle(order)
  G.s1_order   = order
  G.s1_cursor  = 1
  G.s1_held    = nil
  G.s1_gap_cur = 1
  G.s1_mode    = "frags"
  G.s1_placed  = {}
  G.s1_shake_t = 0
  G.s1_flash_t = 0
end

function init_stage2(tx_idx)
  math.randomseed(time())
  local tx = TRANSMISSIONS[tx_idx]
  local pool = {}
  for i, txt in ipairs(tx.seq) do
    pool[#pool + 1] = {text = txt, idx = i, decoy = false}
  end
  for _, txt in ipairs(tx.seq_dec) do
    pool[#pool + 1] = {text = txt, idx = nil, decoy = true}
  end
  shuffle(pool)
  G.s2_pool    = pool
  G.s2_slots   = {}
  G.s2_held    = nil
  G.s2_row     = 1
  G.s2_col     = 1
  G.s2_err_t   = 0
  G.s2_err_sl  = {}
  G.s2_phase   = "place"
  G.s2_tw_text = ""
  G.s2_tw_pos  = 0
  G.s2_tw_t    = 0
  G.s2_pause_t = 0
end

function init_vela_log(tx_idx)
  G.vl_line  = 0
  G.vl_timer = 0
  G.vl_done  = false
end

function s2_available_pool()
  local avail = {}
  for i = 1, #G.s2_pool do
    local placed = false
    for _, pi in pairs(G.s2_slots) do
      if pi == i then placed = true; break end
    end
    if not placed then
      avail[#avail + 1] = i
    end
  end
  return avail
end

-------------------------------
-- [DRAW] Title
-------------------------------

function draw_title()
  cls(C_BG)

  -- Diamond shape in green at center-top
  local dx = math.floor(SW / 2)
  local dy = 30
  pix(dx, dy - 2, C_OK)
  pix(dx - 1, dy - 1, C_OK)
  pix(dx + 1, dy - 1, C_OK)
  pix(dx - 2, dy, C_OK)
  pix(dx, dy, C_OK)
  pix(dx + 2, dy, C_OK)
  pix(dx - 1, dy + 1, C_OK)
  pix(dx + 1, dy + 1, C_OK)
  pix(dx, dy + 2, C_OK)

  -- "RETURN SIGNAL" centered in white
  local title = "RETURN SIGNAL"
  local tw = #title * 6
  print(title, math.floor((SW - tw) / 2), 42, C_WHITE)

  -- "a signal from earth" centered below
  local sub = "a signal from earth"
  local subw = #sub * 6
  print(sub, math.floor((SW - subw) / 2), 56, C_TXT)

  -- "[Z to begin]" blinking on/off every BLINK_RATE frames
  if math.floor(G.t / BLINK_RATE) % 2 == 0 then
    local prompt = "[Z to begin]"
    local pw = #prompt * 6
    print(prompt, math.floor((SW - pw) / 2), 80, C_DIM)
  end
end

-------------------------------
-- [DRAW] Hub (stub)
-------------------------------

function draw_hub()
  cls(C_BG)

  -- Header
  draw_header("VELA // SIGNAL LOG", fmt_time(G.t))

  -- Top divider
  draw_divider(12)

  -- Transmission list
  local list_y = 13
  for idx = 1, #TRANSMISSIONS do
    local tx = TRANSMISSIONS[idx]
    local ey = list_y + (idx - 1) * HUB_ENTRY_H
    local status, scol = tx_status(idx)
    local selectable = is_selectable(idx)
    local is_cur = (G.hub_cur == idx and selectable)

    -- Background highlight for cursor
    if is_cur then
      rect(0, ey, SW, HUB_ENTRY_H, C_BG2)
    end

    -- Prefix
    local prefix = "  "
    if is_cur then prefix = "> " end

    -- Build the left text
    local left_text
    if G.decoded[idx] then
      -- Decoded: show first seq frag instead of origin
      local first_line = tx.seq[1] or ""
      left_text = prefix .. tx.id .. "  " .. first_line
    elseif is_available(idx) then
      -- Available: show origin
      left_text = prefix .. tx.id .. "  ORIGIN: " .. tx.origin
    else
      -- Locked: garbled blocks
      local garble_lens = {16, 14, 18, 15, 17, 13, 19, 16}
      local glen = garble_lens[idx] or 16
      local garbled = string.rep("#", glen)
      -- Insert a space break for visual variety
      local mid = math.floor(glen / 3)
      garbled = string.sub(garbled, 1, mid) .. " " .. string.sub(garbled, mid + 1)
      left_text = prefix .. tx.id .. "  " .. garbled
    end

    -- Determine text color
    local tcol
    if is_cur then
      tcol = C_CUR
    elseif not selectable then
      tcol = C_DIM
    else
      tcol = scol
    end

    -- Print left text
    print(left_text, 4, ey + 3, tcol)

    -- Right-align status tag
    local tag_w = #status * 6
    print(status, SW - tag_w - 4, ey + 3, tcol)
  end

  -- Bottom divider
  draw_divider(123)

  -- Hint bar
  draw_hint_bar("Z: OPEN", 124)
end

-------------------------------
-- [DRAW] Stage 1 (stub)
-------------------------------

function draw_stage1()
  local tx = TRANSMISSIONS[G.tx_idx]
  local gap_ranges = compute_gap_ranges(tx)
  local n = #tx.frags
  local num_gaps = #tx.gap_pos

  -- Shake offset
  local sox = 0
  if G.s1_shake_t > 0 then
    sox = (G.s1_shake_t % 2 == 0) and 2 or -2
  end

  cls(C_BG)

  ---------------------------------
  -- Header (y 0-9)
  ---------------------------------
  draw_header("VELA // " .. tx.id .. " // RECONSTRUCT")

  ---------------------------------
  -- Top divider (y 10)
  ---------------------------------
  draw_divider(10)

  -- Draw known (non-gap) segments of target waveform
  for i = 0, WAVE_W - 2 do
    local px = WAVE_X0 + i
    if not gap_at_x(px, gap_ranges) and not gap_at_x(px + 1, gap_ranges) then
      local y1 = WCY + math.floor(math.sin(i * tx.target_freq) * tx.target_amp + math.sin(i * tx.target_freq * 2) * tx.target_amp * 0.4)
      local y2 = WCY + math.floor(math.sin((i + 1) * tx.target_freq) * tx.target_amp + math.sin((i + 1) * tx.target_freq * 2) * tx.target_amp * 0.4)
      line(px, y1, px + 1, y2, C_WHITE)
    end
  end

  -- Draw gaps
  for gi = 1, num_gaps do
    local g = gap_ranges[gi]
    if G.s1_placed[gi] then
      -- Filled gap: draw placed fragment's wave
      local frag = tx.frags[G.s1_placed[gi]]
      local col = C_OK
      if G.s1_flash_t > 0 then
        col = (math.floor(G.s1_flash_t / 4) % 2 == 0) and C_OK or C_WHITE
      end
      draw_wave(g.x0 + sox, WCY, FRAG_W, frag.amp, frag.freq, col)
    else
      -- Empty gap: dashed centerline
      for px = g.x0, g.x1 do
        if px % 2 == 0 then
          pix(px, WCY, C_DIM)
        end
      end
      -- Bracket markers at gap edges
      for by = WCY - 6, WCY + 6 do
        pix(g.x0, by, C_BDR)
        pix(g.x1, by, C_BDR)
      end
    end

    -- Gap cursor highlight
    if G.s1_mode == "gaps" and G.s1_gap_cur == gi then
      rectb(g.x0 - 1, WCY - 14, FRAG_W + 2, 28, C_CUR)
    end
  end

  ---------------------------------
  -- Divider (y 80)
  ---------------------------------
  draw_divider(80)

  ---------------------------------
  -- Fragment row (y 81-120)
  ---------------------------------
  rect(0, 81, SW, 40, C_BG2)

  local bw = frag_box_w(n)
  local frag_y = 81 + math.floor((40 - FRAG_H) / 2)

  for di = 1, n do
    local fi = G.s1_order[di]
    local frag = tx.frags[fi]
    local bx = 4 + (di - 1) * (bw + FRAG_GAP)

    -- Check if this fragment is placed or held
    local is_placed = false
    for _, pfi in pairs(G.s1_placed) do
      if pfi == fi then is_placed = true; break end
    end
    local is_held = (G.s1_held == fi)

    if is_placed or is_held then
      -- Dim empty box
      rectb(bx, frag_y, bw, FRAG_H, C_DIM)
    else
      -- Determine border color
      local bcol = C_TXT
      if frag.gap == nil then
        bcol = C_DIM  -- decoy
      end
      if G.s1_mode == "frags" and G.s1_cursor == di then
        bcol = C_CUR
      end
      rectb(bx, frag_y, bw, FRAG_H, bcol)

      -- Draw mini wave inside box
      local wave_y = frag_y + math.floor(FRAG_H / 2)
      draw_wave(bx + 2, wave_y, bw - 4, frag.amp * 0.4, frag.freq, bcol)
    end
  end

  ---------------------------------
  -- Divider (y 121)
  ---------------------------------
  draw_divider(121)

  ---------------------------------
  -- Status bar (y 122-135)
  ---------------------------------
  local hint
  if G.s1_flash_t > 0 then
    hint = "SIGNAL RECONSTRUCTED"
  elseif G.s1_mode == "gaps" and G.s1_held ~= nil then
    hint = "L/R: GAP  Z: PLACE  X: CANCEL"
  elseif G.s1_mode == "gaps" and G.s1_held == nil then
    hint = "L/R: GAP  Z: LIFT  X: BACK"
  else
    hint = "L/R: SELECT  Z: PICK UP  UP: GAPS"
  end
  draw_hint_bar(hint, 122)
end

-------------------------------
-- [DRAW] Stage 2 (stub)
-------------------------------

function draw_stage2()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq

  cls(C_BG)

  -- Header (y 0-9)
  draw_header("VELA // " .. tx.id .. " // SEQUENCE")

  -- Top divider
  draw_divider(10)

  -----------------------------------------------
  -- Typewriter / Done phase
  -----------------------------------------------
  if G.s2_phase == "typewriter" or G.s2_phase == "done" then
    -- Black background below header
    rect(0, 11, SW, SH - 11, C_BG)

    -- Reveal text up to s2_tw_pos characters
    local revealed = string.sub(G.s2_tw_text, 1, G.s2_tw_pos)

    -- Word-wrap revealed text to ~38 chars per line
    local lines = {}
    local rem = revealed
    while #rem > 0 do
      local l1, l2 = word_wrap(rem, 38)
      lines[#lines + 1] = l1
      if l2 then
        rem = l2
      else
        rem = ""
      end
    end

    -- Print lines starting at y=20, 10px apart
    for i, ln in ipairs(lines) do
      print(ln, 4, 20 + (i - 1) * 10, C_WHITE)
    end

    -- Done phase: show continue prompt
    if G.s2_phase == "done" then
      local prompt = "Z: CONTINUE"
      local pw = #prompt * 6
      print(prompt, SW - pw - 4, SH - 10, C_HFNT)
    end

    -- Bottom divider and status bar still drawn
    draw_divider(127)
    rect(0, 128, SW, 8, C_BG2)
    return
  end

  -----------------------------------------------
  -- Normal (place) phase
  -----------------------------------------------

  -- Slot area background (y 11-67)
  rect(0, 11, SW, 57, C_BG2)

  -- Slot layout
  local rows, per_row = slot_layout(ns)
  local sw = math.floor(236 / per_row) - 1
  local max_chars = math.floor(sw / 6) - 1

  -- Draw slots
  local slot_i = 1
  for r = 0, rows - 1 do
    -- For 5 slots: row 0 has 3, row 1 has 2
    local cols_this_row = per_row
    if ns == 5 and r == 1 then cols_this_row = 2 end

    local total_w = cols_this_row * sw + (cols_this_row - 1) * 2
    local start_x = math.floor((SW - total_w) / 2)
    local box_y = 12 + r * (SLOT_H + 2)

    for c = 0, cols_this_row - 1 do
      local si = slot_i
      local box_x = start_x + c * (sw + 2)

      -- Determine border color
      local bcol = C_BDR
      if G.s2_row == 0 and G.s2_col == si then
        bcol = C_CUR
      end
      if G.s2_err_t > 0 and G.s2_err_sl[si] then
        bcol = C_ERR
      end

      rectb(box_x, box_y, sw, SLOT_H, bcol)

      -- Slot number top-left
      print(tostring(si), box_x + 2, box_y + 1, C_DIM)

      -- Slot content
      if G.s2_slots[si] then
        local pe = G.s2_pool[G.s2_slots[si]]
        local l1, l2 = word_wrap(pe.text, max_chars)
        print(l1, box_x + 2, box_y + 5, C_TXT)
        if l2 then
          print(l2, box_x + 2, box_y + 14, C_TXT)
        end
      end

      slot_i = slot_i + 1
    end
  end

  -- Middle divider
  draw_divider(68)

  -- Fragment pool area (y 69-126) - C_BG background (already cls'd)

  local avail = s2_available_pool()
  local pw = math.floor(236 / 4) - 1
  local pool_max_chars = math.floor(pw / 6) - 1

  for i, pi in ipairs(avail) do
    local pe = G.s2_pool[pi]
    local row = math.floor((i - 1) / 4)
    local col = (i - 1) % 4

    local cols_this_row = math.min(4, #avail - row * 4)
    local total_w = cols_this_row * pw + (cols_this_row - 1) * 2
    local start_x = math.floor((SW - total_w) / 2)

    local box_x = start_x + col * (pw + 2)
    local box_y = 70 + row * (SLOT_H + 2)

    -- Determine border color
    local bcol = C_BDR
    if G.s2_row == 1 and G.s2_col == i then
      bcol = C_CUR
    end
    if G.s2_held == pi then
      bcol = C_SEL
    end

    rectb(box_x, box_y, pw, SLOT_H, bcol)

    -- Text color
    local tcol = C_TXT
    if G.s2_held == pi then
      tcol = C_SEL
    elseif pe.decoy then
      tcol = C_DIM
    end

    local l1, l2 = word_wrap(pe.text, pool_max_chars)
    print(l1, box_x + 2, box_y + 5, tcol)
    if l2 then
      print(l2, box_x + 2, box_y + 14, tcol)
    end
  end

  -- Bottom divider
  draw_divider(127)

  -- Status bar (y 128-135)
  local hint
  if G.s2_row == 1 then
    hint = "U/D: AREA  L/R: SELECT  Z: PICK"
  else
    hint = "U/D: AREA  L/R: SLOT  Z: PLACE  X: CLEAR"
  end
  draw_hint_bar(hint, 128)
end

-------------------------------
-- [DRAW] VELA Log (stub)
-------------------------------

function draw_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]
  local vela = tx.vela

  cls(C_BG)

  -- Header (y 0-9)
  rect(0, 0, SW, 10, C_BG2)
  print("VELA // INTERNAL LOG // " .. tx.id, 4, 2, C_HFNT)

  -- Top divider
  draw_divider(10)

  -- Log text area (y 11-118)
  for i = 1, G.vl_line do
    if i <= #vela then
      local ln = vela[i]
      if #ln > 0 then
        print(ln, 8, 14 + (i - 1) * 12, C_WHITE)
      end
    end
  end

  -- Bottom divider
  draw_divider(119)

  -- Footer (y 120-135)
  rect(0, 120, SW, 16, C_BG2)

  if G.vl_done then
    local prompt = "Z: CONTINUE"
    local pw = #prompt * 6
    print(prompt, SW - pw - 4, 126, C_DIM)
  end
end

-------------------------------
-- [UPDATE] Title
-------------------------------

function update_title()
  if btnp(4) then
    G.state   = "hub"
    G.hub_cur = 1
  end
end

-------------------------------
-- [UPDATE] Hub (stub)
-------------------------------

function update_hub()
  -- Up
  if btnp(0) then
    G.hub_cur = next_selectable(G.hub_cur, -1)
  end
  -- Down
  if btnp(1) then
    G.hub_cur = next_selectable(G.hub_cur, 1)
  end
  -- Z: open transmission
  if btnp(4) then
    if is_available(G.hub_cur) and not G.decoded[G.hub_cur] then
      G.tx_idx = G.hub_cur
      init_stage1(G.hub_cur)
      G.state = "stage1"
    end
  end
end

-------------------------------
-- [UPDATE] Stage 1 (stub)
-------------------------------

function update_stage1()
  local tx = TRANSMISSIONS[G.tx_idx]
  local n = #tx.frags
  local num_gaps = #tx.gap_pos

  -- Tick timers
  if G.s1_shake_t > 0 then
    G.s1_shake_t = G.s1_shake_t - 1
  end

  if G.s1_flash_t > 0 then
    G.s1_flash_t = G.s1_flash_t - 1
    if G.s1_flash_t == 0 then
      init_stage2(G.tx_idx)
      G.state = "stage2"
      return
    end
    return  -- no input during flash
  end

  if G.s1_mode == "frags" then
    -- Left
    if btnp(2) then
      G.s1_cursor = G.s1_cursor - 1
      if G.s1_cursor < 1 then G.s1_cursor = n end
    end
    -- Right
    if btnp(3) then
      G.s1_cursor = G.s1_cursor + 1
      if G.s1_cursor > n then G.s1_cursor = 1 end
    end
    -- Up: switch to gaps mode
    if btnp(0) then
      G.s1_mode = "gaps"
      G.s1_gap_cur = 1
    end
    -- Z: pick up fragment
    if btnp(4) then
      local fi = G.s1_order[G.s1_cursor]
      -- Check not already placed
      local already_placed = false
      for _, pfi in pairs(G.s1_placed) do
        if pfi == fi then already_placed = true; break end
      end
      if not already_placed then
        G.s1_held = fi
        G.s1_mode = "gaps"
        G.s1_gap_cur = 1
        play_sfx(6)
      end
    end

  elseif G.s1_mode == "gaps" then
    if G.s1_held ~= nil then
      -- Holding a fragment
      -- Left
      if btnp(2) then
        G.s1_gap_cur = G.s1_gap_cur - 1
        if G.s1_gap_cur < 1 then G.s1_gap_cur = num_gaps end
      end
      -- Right
      if btnp(3) then
        G.s1_gap_cur = G.s1_gap_cur + 1
        if G.s1_gap_cur > num_gaps then G.s1_gap_cur = 1 end
      end
      -- Z: try to place
      if btnp(4) then
        local gi = G.s1_gap_cur
        if not G.s1_placed[gi] then
          local frag = tx.frags[G.s1_held]
          if frag.gap == gi then
            -- Correct
            G.s1_placed[gi] = G.s1_held
            G.s1_held = nil
            play_sfx(1)
            -- Check if all gaps filled
            local all_filled = true
            for g = 1, num_gaps do
              if not G.s1_placed[g] then all_filled = false; break end
            end
            if all_filled then
              G.s1_flash_t = FLASH_DUR
              play_sfx(3)
            else
              G.s1_mode = "frags"
            end
          else
            -- Wrong
            G.s1_shake_t = SHAKE_DUR
            G.s1_held = nil
            G.s1_mode = "frags"
            play_sfx(2)
          end
        end
      end
      -- X or Down: cancel
      if btnp(5) or btnp(1) then
        G.s1_held = nil
        G.s1_mode = "frags"
      end

    else
      -- Gaps mode, no held fragment
      -- Left
      if btnp(2) then
        G.s1_gap_cur = G.s1_gap_cur - 1
        if G.s1_gap_cur < 1 then G.s1_gap_cur = num_gaps end
      end
      -- Right
      if btnp(3) then
        G.s1_gap_cur = G.s1_gap_cur + 1
        if G.s1_gap_cur > num_gaps then G.s1_gap_cur = 1 end
      end
      -- Z: lift from filled gap
      if btnp(4) then
        local gi = G.s1_gap_cur
        if G.s1_placed[gi] then
          G.s1_held = G.s1_placed[gi]
          G.s1_placed[gi] = nil
          play_sfx(6)
        end
      end
      -- X or Down: back to frags
      if btnp(5) or btnp(1) then
        G.s1_mode = "frags"
      end
    end
  end
end

-------------------------------
-- [UPDATE] Stage 2 (stub)
-------------------------------

function check_s2_solution()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq
  local wrong = {}
  local any_wrong = false

  for si = 1, ns do
    local pi = G.s2_slots[si]
    local pe = G.s2_pool[pi]
    if pe.idx ~= tx.seq_sol[si] then
      wrong[si] = true
      any_wrong = true
    end
  end

  if any_wrong then
    G.s2_err_t = ERR_FLASH
    G.s2_err_sl = wrong
    play_sfx(2)
  else
    -- Correct! Build assembled message
    local parts = {}
    for si = 1, ns do
      local pe = G.s2_pool[G.s2_slots[si]]
      parts[#parts + 1] = pe.text
    end
    G.s2_tw_text = table.concat(parts, " // ")
    G.s2_tw_pos = 0
    G.s2_tw_t = 0
    G.s2_pause_t = 0
    G.s2_phase = "typewriter"
    play_sfx(4)
  end
end

function update_stage2()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq

  -- Tick error flash timer
  if G.s2_err_t > 0 then
    G.s2_err_t = G.s2_err_t - 1
    if G.s2_err_t == 0 then
      G.s2_err_sl = {}
    end
  end

  -----------------------------------------------
  -- Typewriter phase
  -----------------------------------------------
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

  -----------------------------------------------
  -- Done phase
  -----------------------------------------------
  if G.s2_phase == "done" then
    if btnp(4) then
      init_vela_log(G.tx_idx)
      G.state = "vela_log"
    end
    return
  end

  -----------------------------------------------
  -- Place phase
  -----------------------------------------------

  if G.s2_row == 1 then
    -- Pool area
    local avail = s2_available_pool()
    local na = #avail

    if na == 0 then
      -- All placed, switch to slots
      G.s2_row = 0
      G.s2_col = 1
    else
      -- Clamp col
      if G.s2_col > na then G.s2_col = na end
      if G.s2_col < 1 then G.s2_col = 1 end

      -- Left
      if btnp(2) then
        G.s2_col = G.s2_col - 1
        if G.s2_col < 1 then G.s2_col = na end
      end
      -- Right
      if btnp(3) then
        G.s2_col = G.s2_col + 1
        if G.s2_col > na then G.s2_col = 1 end
      end
      -- Up: switch to slots
      if btnp(0) then
        G.s2_row = 0
        G.s2_col = 1
      end
      -- Z: toggle select
      if btnp(4) then
        local pi = avail[G.s2_col]
        if G.s2_held == pi then
          G.s2_held = nil
        else
          G.s2_held = pi
          play_sfx(6)
        end
      end
      -- X: deselect
      if btnp(5) then
        G.s2_held = nil
      end
    end

  else
    -- Slot area (G.s2_row == 0)

    -- Left
    if btnp(2) then
      G.s2_col = G.s2_col - 1
      if G.s2_col < 1 then G.s2_col = ns end
    end
    -- Right
    if btnp(3) then
      G.s2_col = G.s2_col + 1
      if G.s2_col > ns then G.s2_col = 1 end
    end
    -- Down: switch to pool
    if btnp(1) then
      G.s2_row = 1
      G.s2_col = 1
    end

    local si = G.s2_col

    -- Z pressed
    if btnp(4) then
      -- Check if all slots are filled and nothing held → submit
      local all_filled = true
      for s = 1, ns do
        if not G.s2_slots[s] then all_filled = false; break end
      end

      if all_filled and G.s2_held == nil then
        check_s2_solution()
      elseif G.s2_held ~= nil and not G.s2_slots[si] then
        -- Place held fragment into empty slot
        G.s2_slots[si] = G.s2_held
        G.s2_held = nil
        play_sfx(1)
      elseif G.s2_held == nil and G.s2_slots[si] then
        -- Pick up from filled slot
        G.s2_held = G.s2_slots[si]
        G.s2_slots[si] = nil
        play_sfx(6)
      end
    end

    -- X pressed
    if btnp(5) then
      if G.s2_held then
        G.s2_held = nil
      elseif G.s2_slots[si] then
        G.s2_slots[si] = nil
        play_sfx(6)
      end
    end
  end
end

-------------------------------
-- [UPDATE] VELA Log (stub)
-------------------------------

function update_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]
  local vela = tx.vela

  -- Done: Z to dismiss and return to hub
  if G.vl_done then
    if btnp(4) then
      G.decoded[G.tx_idx] = true
      G.state = "hub"
    end
    return
  end

  -- Increment timer
  G.vl_timer = G.vl_timer + 1

  -- First line reveals immediately
  if G.vl_line == 0 then
    G.vl_line = 1
    G.vl_timer = 0
    return
  end

  -- Reveal next line on Z press or timer
  if G.vl_line < #vela then
    if btnp(4) or G.vl_timer >= VL_LINE_DUR then
      G.vl_line = G.vl_line + 1
      G.vl_timer = 0
    end
  end

  -- Check if all lines revealed
  if G.vl_line >= #vela then
    G.vl_done = true
  end
end

-------------------------------
-- [UPDATE] Dispatcher
-------------------------------

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

-------------------------------
-- [TIC] Main Loop
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
