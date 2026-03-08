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
  cls(C_BG)
end

-------------------------------
-- [DRAW] Stage 2 (stub)
-------------------------------

function draw_stage2()
  cls(C_BG)
end

-------------------------------
-- [DRAW] VELA Log (stub)
-------------------------------

function draw_vela_log()
  cls(C_BG)
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
end

-------------------------------
-- [UPDATE] Stage 2 (stub)
-------------------------------

function update_stage2()
end

-------------------------------
-- [UPDATE] VELA Log (stub)
-------------------------------

function update_vela_log()
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
