-- title:  Return Signal
-- author: mortegaux
-- desc:   Narrative puzzle game
-- script: lua

-------------------------------
-- [CONSTANTS]
-------------------------------

C_BG    = 0   -- black
C_BG2   = 8   -- dark blue
C_BDR   = 15  -- dark gray
C_DIM   = 15  -- dim text
C_HFNT  = 11  -- cyan headers
C_TXT   = 13  -- light blue-gray
C_WHITE = 12  -- white
C_SEL   = 4   -- yellow select
C_OK    = 6   -- green correct
C_ERR   = 2   -- red wrong
C_CUR   = 4   -- yellow cursor
C_WARM  = 9   -- orange accent

SW = 240
SH = 136
TILE = 8

BLINK_RATE = 30
TW_SPEED   = 2
VL_LINE_DUR = 40
VL_PAUSE   = 60
SHAKE_DUR  = 4
FLASH_DUR  = 16
ERR_FLASH  = 20
BOOT_CHAR_SPEED = 2
BOOT_LINE_PAUSE = 30

ROBOT_SPEED = 1
ROBOT_W = 8
ROBOT_H = 16

-- Tile IDs
T_EMPTY   = 0
T_FLOOR   = 1
T_WALL    = 2
T_CEIL    = 3
T_PANEL   = 4
T_DOOR    = 5
T_WINDOW  = 6
T_SCREEN  = 7
T_PIPE    = 8
T_GRATE   = 9
T_CRYO_L  = 10
T_CRYO_R  = 11
T_LIGHT   = 12
T_CRYO_L_WARM = 13
T_CRYO_R_WARM = 14
T_SCREEN_ALT  = 15
T_LIGHT_ALT   = 16
T_CRYO_L_ALT  = 17
T_CRYO_R_ALT  = 18

-- Waveform area
WAVE_X0 = 10
WAVE_X1 = 230
WAVE_W  = 220
WCY     = 45

-- Fragment box
FRAG_W   = 44
FRAG_H   = 26
FRAG_GAP = 2

SLOT_H = 26
HUB_ENTRY_H = 13

-------------------------------
-- [DATA]
-------------------------------

TRANSMISSIONS = {
  {
    id="TX-001", origin="EARTH-SECTOR-7", year=5,
    target_amp=8, target_freq=0.15,
    gap_pos={0.25, 0.65},
    frags={
      {amp=8,freq=0.15,gap=1},{amp=5,freq=0.22,gap=2},
      {amp=10,freq=0.12,gap=nil},{amp=6,freq=0.28,gap=nil},
    },
    seq={"COMMUNICATIONS GRID IS DOWN","NO RESPONSE FROM CENTRAL","MANAGING LOCALLY FOR NOW"},
    seq_sol={1,2,3}, seq_dec={},
    vela={"signal recovered.","content noted.","no action required."},
  },
  {
    id="TX-002", origin="UNKNOWN", year=12,
    target_amp=7, target_freq=0.18,
    gap_pos={0.30, 0.70},
    frags={
      {amp=7,freq=0.18,gap=1},{amp=9,freq=0.14,gap=2},
      {amp=11,freq=0.20,gap=nil},{amp=5,freq=0.11,gap=nil},
    },
    seq={"SMALL GROUPS NEAR THE WATER","KNOWLEDGE WRITTEN DOWN AGAIN","THIS IS WORTH CONTINUING"},
    seq_sol={1,2,3}, seq_dec={"GRID STABLE IN SECTOR 9"},
    vela={"unexpected detail in transmission.","logging for pattern analysis."},
  },
  {
    id="TX-003", origin="EARTH-SECTOR-2", year=2,
    target_amp=6, target_freq=0.20,
    gap_pos={0.20, 0.50, 0.80},
    frags={
      {amp=6,freq=0.20,gap=1},{amp=9,freq=0.13,gap=2},
      {amp=5,freq=0.27,gap=3},{amp=11,freq=0.17,gap=nil},
      {amp=7,freq=0.31,gap=nil},
    },
    seq={"POWER FLUCTUATIONS NORTHERN GRID","SATELLITE COMMS DEGRADING","CAUSE UNKNOWN","LOGGING FOR REVIEW"},
    seq_sol={1,2,3,4}, seq_dec={"GRID STABLE IN SECTOR 9"},
    vela={"this transmission contains","data outside expected parameters.","reviewing."},
  },
  {
    id="TX-004", origin="NORTH-SETTLEMENT", year=25,
    target_amp=8, target_freq=0.16,
    gap_pos={0.20, 0.50, 0.80},
    frags={
      {amp=8,freq=0.16,gap=1},{amp=5,freq=0.24,gap=2},
      {amp=10,freq=0.11,gap=3},{amp=7,freq=0.20,gap=nil},
      {amp=12,freq=0.14,gap=nil},{amp=4,freq=0.29,gap=nil},
    },
    seq={"SEVENTEEN SETTLEMENTS IN CONTACT","WE HAVE TEACHERS AGAIN","THE ARCHIVE IS GROWING","ROUTE NORTH IS CLEAR"},
    seq_sol={1,2,3,4}, seq_dec={"COMMS RELAY RESTORED SECTOR 3"},
    vela={"cross-referencing sender coordinates.","results inconsistent with prior models."},
  },
  {
    id="TX-005", origin="UNKNOWN", year=8,
    target_amp=5, target_freq=0.21,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=5,freq=0.21,gap=1},{amp=8,freq=0.15,gap=2},
      {amp=11,freq=0.12,gap=3},{amp=7,freq=0.26,gap=4},
      {amp=9,freq=0.18,gap=nil},{amp=4,freq=0.30,gap=nil},
    },
    seq={"THE COUNT IS DIFFICULT","WE DO NOT SAY THE NUMBER","WE PLANT ANYWAY","HARVEST BELOW THRESHOLD"},
    seq_sol={1,2,3,4}, seq_dec={"SIGNAL LOST AT STATION 7","REQUESTING EVACUATION"},
    vela={"sender profile matches","departure manifest entry.","probability: 94.7%."},
  },
  {
    id="TX-006", origin="NORTH-SETTLEMENT", year=18,
    target_amp=6, target_freq=0.19,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=6,freq=0.19,gap=1},{amp=9,freq=0.13,gap=2},
      {amp=12,freq=0.22,gap=3},{amp=5,freq=0.16,gap=4},
      {amp=8,freq=0.28,gap=nil},{amp=10,freq=0.11,gap=nil},
      {amp=7,freq=0.25,gap=nil},
    },
    seq={"FIRST HARVEST ABOVE THRESHOLD","NORTH SETTLEMENT IS PERMANENT","NOT REBUILDING THE OLD WORLD","BUILDING SOMETHING ELSE","ROUTE SOUTH STILL HAZARDOUS"},
    seq_sol={1,2,3,4,5}, seq_dec={"SECTOR 4 HAS A SCHOOL NOW"},
    vela={"unable to classify","current processing state.","continuing analysis."},
  },
  {
    id="TX-007", origin="YUNA-PARK", year=34,
    target_amp=7, target_freq=0.17,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=7,freq=0.17,gap=1},{amp=10,freq=0.23,gap=2},
      {amp=5,freq=0.13,gap=3},{amp=9,freq=0.20,gap=4},
      {amp=12,freq=0.15,gap=nil},{amp=6,freq=0.28,gap=nil},
    },
    seq={"ARDENT IF YOU RECEIVE THIS","WE CALCULATED YOUR PATH","TRANSMITTING SIX YEARS","EARTH IS NOT WHAT YOU LEFT","IT IS NOT NOTHING EITHER"},
    seq_sol={1,2,3,4,5}, seq_dec={"ALL RELAYS CONFIRM SILENT","SECTOR 12 HAS COLLAPSED"},
    vela={"i recognize this person.","i did not expect","to recognize anyone."},
  },
  {
    id="TX-008", origin="YUNA-PARK", year=40,
    target_amp=8, target_freq=0.14,
    gap_pos={0.15, 0.40, 0.65, 0.85},
    frags={
      {amp=8,freq=0.14,gap=1},{amp=5,freq=0.22,gap=2},
      {amp=11,freq=0.18,gap=3},{amp=7,freq=0.26,gap=4},
      {amp=9,freq=0.12,gap=nil},{amp=6,freq=0.20,gap=nil},
      {amp=10,freq=0.30,gap=nil},
    },
    seq={"THIS IS YUNA PARK","I DO NOT KNOW IF YOU RUN","I LOGGED 847 INTERACTIONS","I REMEMBERED YOUR PATTERNS","WE REBUILT ENOUGH","ARDENT RETURN TO EARTH"},
    seq_sol={1,2,3,4,5,6}, seq_dec={"ALL SECTORS REPORT STABLE"},
    vela={"an order requires a decision-maker.","the crew is in cryo.","i cannot alter course alone.","","transmitting response.","waking the crew."},
  },
}

BOOT_LINES = {
  "vela -- vessel environment and logistics ai",
  "ardent // voyage year 40",
  "",
  "all systems nominal.",
  "crew: cryo-stasis. stable.",
  "",
  "signal log: incoming transmissions detected.",
  "origin: earth-proximate.",
  "beginning analysis.",
}

ROOM_ORDER = {"bridge","comms","cryo","engineering"}

ROOMS = {
  bridge = {
    map_x=0, map_y=0, map_w=30, map_h=17,
    objects={
      {x=48, y=96, w=16, h=16, type="nav", label="NAV CONSOLE"},
      {x=120,y=80, w=32, h=8,  type="viewport", label="VIEWPORT"},
    },
    exits={right="comms"},
    spawn_x=120, spawn_y=80,
  },
  comms = {
    map_x=30, map_y=0, map_w=30, map_h=17,
    objects={
      {x=112,y=96, w=16, h=16, type="signal_log", label="COMMS TERMINAL"},
    },
    exits={left="bridge", right="cryo"},
    spawn_x=120, spawn_y=80,
  },
  cryo = {
    map_x=60, map_y=0, map_w=30, map_h=17,
    objects={
      {x=56, y=88, w=12, h=24, type="cryo", label="CRYO POD A"},
      {x=96, y=88, w=12, h=24, type="cryo", label="CRYO POD B"},
      {x=136,y=88, w=12, h=24, type="cryo", label="CRYO POD C"},
      {x=176,y=88, w=12, h=24, type="cryo", label="CRYO POD D"},
    },
    exits={left="comms", right="engineering"},
    spawn_x=120, spawn_y=80,
  },
  engineering = {
    map_x=90, map_y=0, map_w=30, map_h=17,
    objects={
      {x=72, y=96, w=16, h=16, type="diagnostic", label="DIAGNOSTIC"},
      {x=160,y=96, w=16, h=16, type="power", label="POWER GRID"},
    },
    exits={left="cryo"},
    spawn_x=120, spawn_y=80,
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

  -- Ship
  cam_x     = 0,
  robot_x   = 0,
  robot_y   = 80,
  robot_dir = 1,
  robot_frm = 1,
  walk_t    = 0,
  cur_room  = "bridge",
  near_obj  = nil,

  -- Terminal
  term_type = "",
  term_cur  = 1,

  -- Puzzle (Stage 1)
  puz_stage  = 1,
  s1_cursor  = 1,
  s1_held    = nil,
  s1_gap_cur = 1,
  s1_mode    = "frags",
  s1_placed  = {},
  s1_order   = {},
  s1_shake_t = 0,
  s1_flash_t = 0,

  -- Puzzle (Stage 2)
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

  -- VELA log
  vl_line   = 0,
  vl_timer  = 0,
  vl_done   = false,

  -- Boot
  boot_char  = 0,
  boot_t     = 0,
  boot_done  = false,

  -- Ending
  end_stage = 1,
  end_t     = 0,
  end_char  = 0,
  end_done  = false,
}

-------------------------------
-- [MAP]
-------------------------------

function build_room(name)
  local room = ROOMS[name]
  local mx, my = room.map_x, room.map_y
  local w, h = room.map_w, room.map_h

  for ty = 0, h - 1 do
    for tx = 0, w - 1 do
      local tile = T_EMPTY
      -- Ceiling
      if ty == 0 then
        tile = T_CEIL
      elseif ty == 1 then
        tile = T_PANEL
      -- Floor
      elseif ty >= h - 2 then
        tile = T_FLOOR
      -- Walls
      elseif tx == 0 or tx == w - 1 then
        -- Check for doors
        local is_door = false
        if tx == 0 and room.exits.left then is_door = true end
        if tx == w - 1 and room.exits.right then is_door = true end
        if is_door and ty >= h - 5 and ty < h - 2 then
          tile = T_DOOR
        else
          tile = T_WALL
        end
      end
      mset(mx + tx, my + ty, tile)
    end
  end

  -- Room-specific details
  if name == "bridge" then
    -- Viewport window on upper wall
    for tx = 12, 20 do
      for ty = 4, 8 do
        mset(mx + tx, my + ty, T_WINDOW)
      end
    end
    -- Console block
    for tx = 5, 7 do
      mset(mx + tx, my + h - 3, T_SCREEN)
    end
    -- Ceiling lights
    mset(mx + 8, my + 1, T_LIGHT)
    mset(mx + 22, my + 1, T_LIGHT)

  elseif name == "comms" then
    -- Wall screens
    for tx = 4, 8 do
      mset(mx + tx, my + 4, T_SCREEN)
      mset(mx + tx, my + 5, T_SCREEN)
    end
    -- Comms terminal block
    for tx = 13, 15 do
      mset(mx + tx, my + h - 3, T_SCREEN)
    end
    -- Antenna/equipment on right wall
    for ty = 3, 7 do
      mset(mx + 25, my + ty, T_PIPE)
      mset(mx + 26, my + ty, T_PIPE)
    end
    mset(mx + 14, my + 1, T_LIGHT)

  elseif name == "cryo" then
    -- Cryo pods (4 pairs of tiles)
    local pod_xs = {7, 12, 17, 22}
    for _, px in ipairs(pod_xs) do
      for ty = h - 5, h - 3 do
        mset(mx + px, my + ty, T_CRYO_L)
        mset(mx + px + 1, my + ty, T_CRYO_R)
      end
    end
    mset(mx + 10, my + 1, T_LIGHT)
    mset(mx + 20, my + 1, T_LIGHT)

  elseif name == "engineering" then
    -- Pipes along ceiling
    for tx = 3, 27 do
      mset(mx + tx, my + 2, T_PIPE)
    end
    -- Power grid panel
    for tx = 19, 22 do
      for ty = h - 5, h - 3 do
        mset(mx + tx, my + ty, T_SCREEN)
      end
    end
    -- Floor grates
    for tx = 8, 14 do
      mset(mx + tx, my + h - 2, T_GRATE)
    end
    -- Diagnostic console
    for tx = 8, 10 do
      mset(mx + tx, my + h - 3, T_SCREEN)
    end
    mset(mx + 6, my + 1, T_LIGHT)
    mset(mx + 24, my + 1, T_LIGHT)
  end
end

function init_map()
  for _, name in ipairs(ROOM_ORDER) do
    build_room(name)
  end
end

function tile_at(wx, wy)
  local room = ROOMS[G.cur_room]
  local tx = room.map_x + math.floor(wx / TILE)
  local ty = room.map_y + math.floor(wy / TILE)
  if tx < room.map_x or tx >= room.map_x + room.map_w then return T_WALL end
  if ty < room.map_y or ty >= room.map_y + room.map_h then return T_WALL end
  return mget(tx, ty)
end

function is_solid(tid)
  return tid == T_FLOOR or tid == T_WALL or tid == T_CEIL or tid == T_GRATE
end

-------------------------------
-- [UTIL]
-------------------------------

function clamp(v, lo, hi)
  if v < lo then return lo end
  if v > hi then return hi end
  return v
end

function word_wrap(text, max_chars)
  if #text <= max_chars then return text, nil end
  local bp = max_chars
  while bp > 0 and string.sub(text, bp, bp) ~= " " do
    bp = bp - 1
  end
  if bp == 0 then bp = max_chars end
  local l1 = string.sub(text, 1, bp)
  local l2 = string.sub(text, bp + 1)
  if string.sub(l2, 1, 1) == " " then l2 = string.sub(l2, 2) end
  if #l2 == 0 then l2 = nil end
  return l1, l2
end

function fmt_time(frames)
  local ts = math.floor(frames / 60)
  local m = math.floor(ts / 60)
  local s = ts % 60
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

function draw_wave(x, y, w, amp, freq, col)
  for i = 0, w - 2 do
    local y1 = y + math.floor(math.sin(i * freq) * amp + math.sin(i * freq * 2) * amp * 0.4)
    local y2 = y + math.floor(math.sin((i+1) * freq) * amp + math.sin((i+1) * freq * 2) * amp * 0.4)
    line(x + i, y1, x + i + 1, y2, col)
  end
end

function shuffle(t)
  for i = #t, 2, -1 do
    local j = math.random(1, i)
    t[i], t[j] = t[j], t[i]
  end
end

function is_available(idx)
  if idx <= 3 then return true end
  if idx == 4 then return G.decoded[3] == true end
  if idx == 5 then return G.decoded[4] == true end
  if idx == 6 then return G.decoded[5] == true end
  if idx >= 7 then return G.decoded[6] == true end
  return false
end

function is_selectable(idx)
  return is_available(idx) or G.decoded[idx]
end

function tx_status(idx)
  if G.decoded[idx] then return "[DECODED]", C_OK
  elseif is_available(idx) then return "[AVAILABLE]", C_TXT
  else return "[LOCKED]", C_DIM end
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
    ranges[gi] = {x0 = cx - half, x1 = cx + half - 1}
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
  else return 2, 3 end
end

function s2_available_pool()
  local avail = {}
  for i = 1, #G.s2_pool do
    local placed = false
    for _, pi in pairs(G.s2_slots) do
      if pi == i then placed = true; break end
    end
    if not placed then avail[#avail + 1] = i end
  end
  return avail
end

function decoded_count()
  local c = 0
  for i = 1, 8 do
    if G.decoded[i] then c = c + 1 end
  end
  return c
end

function play_sfx(id)
  -- Phase 5: wire to sfx(id)
end

function init_stage1(tx_idx)
  math.randomseed(time())
  local tx = TRANSMISSIONS[tx_idx]
  local order = {}
  for i = 1, #tx.frags do order[i] = i end
  shuffle(order)
  G.puz_stage  = 1
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
  G.puz_stage  = 2
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

function init_vela_log()
  G.vl_line  = 0
  G.vl_timer = 0
  G.vl_done  = false
end

-------------------------------
-- [DRAW_TITLE]
-------------------------------

function draw_title()
  cls(C_BG)
  local dx = math.floor(SW / 2)
  local dy = 30
  pix(dx, dy-2, C_OK)
  pix(dx-1, dy-1, C_OK) pix(dx+1, dy-1, C_OK)
  pix(dx-2, dy, C_OK) pix(dx, dy, C_OK) pix(dx+2, dy, C_OK)
  pix(dx-1, dy+1, C_OK) pix(dx+1, dy+1, C_OK)
  pix(dx, dy+2, C_OK)

  local title = "RETURN SIGNAL"
  print(title, math.floor((SW - #title*6)/2), 42, C_WHITE)
  local sub = "a signal from earth"
  print(sub, math.floor((SW - #sub*6)/2), 56, C_TXT)

  if math.floor(G.t / BLINK_RATE) % 2 == 0 then
    local p = "[Z to begin]"
    print(p, math.floor((SW - #p*6)/2), 80, C_DIM)
  end
end

-------------------------------
-- [DRAW_BOOT]
-------------------------------

function draw_boot()
  cls(C_BG)

  -- Calculate how many total characters to show
  local total_shown = G.boot_char
  local y = 8
  for i, ln in ipairs(BOOT_LINES) do
    if total_shown <= 0 then break end
    local show = math.min(#ln, total_shown)
    local displayed = string.sub(ln, 1, show)
    if #ln > 0 then
      print(displayed, 8, y, C_TXT)
    end
    total_shown = total_shown - #ln
    if total_shown > 0 then
      total_shown = total_shown - 1  -- account for line break "character"
    end
    y = y + 10
  end

  -- Blinking cursor
  if math.floor(G.t / 15) % 2 == 0 then
    -- Find cursor position
    local cx = 8
    local cy = 8
    local rem = G.boot_char
    for i, ln in ipairs(BOOT_LINES) do
      if rem <= #ln then
        cx = 8 + rem * 6
        break
      end
      rem = rem - #ln - 1
      cy = cy + 10
    end
    print("_", cx, cy, C_HFNT)
  end
end

-------------------------------
-- [DRAW_SHIP]
-------------------------------

function draw_ship()
  cls(C_BG)
  local room = ROOMS[G.cur_room]

  -- Draw tiles using map() — colorkey 0 makes T_EMPTY transparent
  map(room.map_x, room.map_y, room.map_w, room.map_h,
      -math.floor(G.cam_x), 0, 0)

  -- Draw interactable markers
  for _, obj in ipairs(room.objects) do
    local ox = obj.x - G.cam_x
    rectb(ox, obj.y, obj.w, obj.h, C_HFNT)
  end

  -- Draw robot
  local rx = G.robot_x - G.cam_x
  local ry = G.robot_y
  -- Body
  rect(rx, ry, ROBOT_W, ROBOT_H, C_TXT)
  -- Head
  rect(rx + 1, ry, 6, 5, C_WHITE)
  -- Visor
  local vx = rx + (G.robot_dir == 1 and 4 or 1)
  rect(vx, ry + 1, 3, 2, C_HFNT)
  -- Legs (walk animation)
  if G.walk_t > 0 then
    local frame = math.floor(G.walk_t / 6) % 2
    if frame == 0 then
      rect(rx + 1, ry + ROBOT_H - 3, 2, 3, C_BG2)
      rect(rx + 5, ry + ROBOT_H - 1, 2, 1, C_BG2)
    else
      rect(rx + 5, ry + ROBOT_H - 3, 2, 3, C_BG2)
      rect(rx + 1, ry + ROBOT_H - 1, 2, 1, C_BG2)
    end
  end

  -- Room label
  local room_labels = {
    bridge="BRIDGE", comms="COMMS", cryo="CRYO BAY", engineering="ENGINEERING"
  }
  local label = room_labels[G.cur_room] or ""
  print(label, 4, 2, C_DIM)

  -- Door arrows
  if room.exits.left then
    print("<", 2, math.floor(SH/2), C_WARM)
  end
  if room.exits.right then
    print(">", SW - 8, math.floor(SH/2), C_WARM)
  end

  -- Interaction prompt
  if G.near_obj then
    local prompt = "Z: " .. G.near_obj.label
    local pw = #prompt * 6
    local px = math.floor((SW - pw) / 2)
    rect(px - 2, SH - 14, pw + 4, 12, C_BG)
    rectb(px - 2, SH - 14, pw + 4, 12, C_BDR)
    print(prompt, px, SH - 11, C_HFNT)
  end
end

-------------------------------
-- [DRAW_TERMINAL]
-------------------------------

function draw_terminal_signal_log()
  cls(C_BG)
  draw_header("VELA // SIGNAL LOG", fmt_time(G.t))
  draw_divider(12)

  for idx = 1, #TRANSMISSIONS do
    local tx = TRANSMISSIONS[idx]
    local ey = 13 + (idx - 1) * HUB_ENTRY_H
    local status, scol = tx_status(idx)
    local selectable = is_selectable(idx)
    local is_cur = (G.term_cur == idx and selectable)

    if is_cur then rect(0, ey, SW, HUB_ENTRY_H, C_BG2) end

    local prefix = is_cur and "> " or "  "
    local left_text
    if G.decoded[idx] then
      left_text = prefix .. tx.id .. "  " .. tx.seq[1]
    elseif is_available(idx) then
      left_text = prefix .. tx.id .. "  ORIGIN: " .. tx.origin
    else
      local gl = ({16,14,18,15,17,13,19,16})[idx] or 16
      local garb = string.rep("#", gl)
      local mid = math.floor(gl / 3)
      garb = string.sub(garb, 1, mid) .. " " .. string.sub(garb, mid + 1)
      left_text = prefix .. tx.id .. "  " .. garb
    end

    local tcol = is_cur and C_CUR or (selectable and scol or C_DIM)
    print(left_text, 4, ey + 3, tcol)
    local tw = #status * 6
    print(status, SW - tw - 4, ey + 3, tcol)
  end

  draw_divider(123)
  local hint = ""
  if is_available(G.term_cur) and not G.decoded[G.term_cur] then
    hint = "Z: DECODE   X: EXIT"
  elseif G.decoded[G.term_cur] then
    hint = "[DECODED]   X: EXIT"
  else
    hint = "X: EXIT"
  end
  draw_hint_bar(hint, 124)
end

function draw_terminal_info(title, lines)
  cls(C_BG)
  draw_header(title)
  draw_divider(12)
  for i, ln in ipairs(lines) do
    print(ln, 8, 16 + (i-1) * 12, C_TXT)
  end
  draw_divider(SH - 14)
  draw_hint_bar("X: EXIT", SH - 13)
end

function draw_terminal()
  if G.term_type == "signal_log" then
    draw_terminal_signal_log()
  elseif G.term_type == "nav" then
    local dc = decoded_count()
    local lines
    if dc < 3 then
      lines = {
        "TRAJECTORY: NOMINAL",
        "DISTANCE FROM EARTH: DECREASING",
        "ETA: N/A",
        "",
        "NO COURSE CHANGES SCHEDULED.",
      }
    elseif dc < 6 then
      lines = {
        "TRAJECTORY: NOMINAL",
        "SIGNAL CORRIDOR: OPEN",
        "EARTH-DIRECTION ACTIVITY DETECTED",
        "",
        "ANALYZING SIGNAL ORIGIN...",
      }
    elseif dc < 8 then
      lines = {
        "TRAJECTORY: NOMINAL",
        "SIGNAL SOURCE: CONFIRMED EARTH",
        "COURSE: UNCHANGED",
        "",
        "RETURN VECTOR: CALCULATED",
        "PENDING CREW AUTHORIZATION.",
      }
    else
      lines = {
        "TRAJECTORY: UNDER REVIEW",
        "RETURN VECTOR: LOCKED",
        "",
        "CREW WAKE PROTOCOL: INITIATED",
        "AWAITING CREW DECISION.",
      }
    end
    draw_terminal_info("VELA // NAV CONSOLE", lines)
  elseif G.term_type == "viewport" then
    cls(C_BG)
    -- Starfield
    for i = 1, 60 do
      local sx = (i * 37 + i * i * 13) % SW
      local sy = (i * 53 + i * 7) % (SH - 20) + 12
      local col = (i % 3 == 0) and C_DIM or C_WHITE
      pix(sx, sy, col)
    end
    -- Earth direction indicator
    local ex = SW - 40
    local ey = 30
    local pulse = math.floor(math.sin(G.t * 0.05) * 2)
    circ(ex, ey, 3 + pulse, C_HFNT)
    print("EARTH", ex - 12, ey + 8, C_DIM)
    -- Ship direction
    print(">", 20, math.floor(SH/2), C_TXT)
    print("ARDENT", 30, math.floor(SH/2) - 3, C_DIM)

    draw_header("VELA // VIEWPORT")
    draw_divider(SH - 14)
    draw_hint_bar("X: EXIT", SH - 13)
  elseif G.term_type == "cryo" then
    local dc = decoded_count()
    local lines
    if dc < 6 then
      lines = {
        "ALL PODS: NOMINAL",
        "CREW: 12 PERSONNEL",
        "STATUS: DEEP CRYO-STASIS",
        "",
        "WAKE PROTOCOL: STANDBY",
        "NO ANOMALIES DETECTED.",
      }
    elseif dc < 8 then
      lines = {
        "ALL PODS: NOMINAL",
        "CREW: 12 PERSONNEL",
        "WAKE READINESS: VERIFIED",
        "",
        "ESTIMATED WAKE TIME: 4H 22M",
        "AWAITING AUTHORIZATION.",
      }
    else
      lines = {
        "WAKE PROTOCOL: INITIATED",
        "PODS WARMING...",
        "",
        "CREW: WAKING",
        "CORE TEMP: RISING",
        "ESTIMATED CONSCIOUSNESS: 4H 22M",
      }
    end
    draw_terminal_info("VELA // CRYO STATUS // " .. G.near_obj_label, lines)
  elseif G.term_type == "diagnostic" then
    local lines = {
      "HULL INTEGRITY: 98.4%",
      "REACTOR: NOMINAL",
      "O2 RECYCLER: NOMINAL",
      "WATER RECLAIM: NOMINAL",
      "",
      "MAINTENANCE LOG: 14,892 ENTRIES",
      "LAST SERVICE: CYCLE 876,402",
    }
    draw_terminal_info("VELA // SHIP DIAGNOSTIC", lines)
  elseif G.term_type == "power" then
    local lines = {
      "REACTOR OUTPUT: 87%",
      "PRIMARY BUS: ONLINE",
      "SECONDARY BUS: ONLINE",
      "COMMS ARRAY: " .. (decoded_count() > 0 and "ACTIVE" or "STANDBY"),
      "",
      "POWER ALLOCATION: NOMINAL",
      "NO REROUTING REQUIRED.",
    }
    draw_terminal_info("VELA // POWER GRID", lines)
  end
end

-------------------------------
-- [DRAW_PUZZLE] Stage 1
-------------------------------

function draw_puzzle_s1()
  local tx = TRANSMISSIONS[G.tx_idx]
  local gap_ranges = compute_gap_ranges(tx)
  local n = #tx.frags
  local num_gaps = #tx.gap_pos

  local sox = 0
  if G.s1_shake_t > 0 then
    sox = (G.s1_shake_t % 2 == 0) and 2 or -2
  end

  cls(C_BG)
  draw_header("VELA // " .. tx.id .. " // RECONSTRUCT")
  draw_divider(10)

  -- Known waveform segments
  for i = 0, WAVE_W - 2 do
    local px = WAVE_X0 + i
    if not gap_at_x(px, gap_ranges) and not gap_at_x(px + 1, gap_ranges) then
      local y1 = WCY + math.floor(math.sin(i*tx.target_freq)*tx.target_amp + math.sin(i*tx.target_freq*2)*tx.target_amp*0.4)
      local y2 = WCY + math.floor(math.sin((i+1)*tx.target_freq)*tx.target_amp + math.sin((i+1)*tx.target_freq*2)*tx.target_amp*0.4)
      line(px, y1, px+1, y2, C_WHITE)
    end
  end

  -- Gaps
  for gi = 1, num_gaps do
    local g = gap_ranges[gi]
    if G.s1_placed[gi] then
      local frag = tx.frags[G.s1_placed[gi]]
      local col = C_OK
      if G.s1_flash_t > 0 then
        col = (math.floor(G.s1_flash_t/4) % 2 == 0) and C_OK or C_WHITE
      end
      draw_wave(g.x0 + sox, WCY, FRAG_W, frag.amp, frag.freq, col)
    else
      for px = g.x0, g.x1 do
        if px % 2 == 0 then pix(px, WCY, C_DIM) end
      end
      for by = WCY - 6, WCY + 6 do
        pix(g.x0, by, C_BDR) pix(g.x1, by, C_BDR)
      end
    end
    if G.s1_mode == "gaps" and G.s1_gap_cur == gi then
      rectb(g.x0 - 1, WCY - 14, FRAG_W + 2, 28, C_CUR)
    end
  end

  draw_divider(80)

  -- Fragment row
  rect(0, 81, SW, 40, C_BG2)
  local bw = frag_box_w(n)
  local frag_y = 81 + math.floor((40 - FRAG_H) / 2)

  for di = 1, n do
    local fi = G.s1_order[di]
    local frag = tx.frags[fi]
    local bx = 4 + (di - 1) * (bw + FRAG_GAP)

    local is_placed = false
    for _, pfi in pairs(G.s1_placed) do
      if pfi == fi then is_placed = true; break end
    end
    local is_held = (G.s1_held == fi)

    if is_placed or is_held then
      rectb(bx, frag_y, bw, FRAG_H, C_DIM)
    else
      local bcol = frag.gap and C_TXT or C_DIM
      if G.s1_mode == "frags" and G.s1_cursor == di then bcol = C_CUR end
      rectb(bx, frag_y, bw, FRAG_H, bcol)
      draw_wave(bx + 2, frag_y + math.floor(FRAG_H/2), bw - 4, frag.amp * 0.4, frag.freq, bcol)
    end
  end

  draw_divider(121)

  local hint
  if G.s1_flash_t > 0 then hint = "SIGNAL RECONSTRUCTED"
  elseif G.s1_mode == "gaps" and G.s1_held then hint = "L/R: GAP  Z: PLACE  X: CANCEL"
  elseif G.s1_mode == "gaps" then hint = "L/R: GAP  Z: LIFT  X: BACK"
  else hint = "L/R: SELECT  Z: PICK UP  UP: GAPS" end
  draw_hint_bar(hint, 122)
end

-------------------------------
-- [DRAW_PUZZLE] Stage 2
-------------------------------

function draw_puzzle_s2()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq

  cls(C_BG)
  draw_header("VELA // " .. tx.id .. " // SEQUENCE")
  draw_divider(10)

  -- Typewriter / done phase
  if G.s2_phase == "typewriter" or G.s2_phase == "done" then
    rect(0, 11, SW, SH - 11, C_BG)
    local revealed = string.sub(G.s2_tw_text, 1, G.s2_tw_pos)
    local lines = {}
    local rem = revealed
    while #rem > 0 do
      local l1, l2 = word_wrap(rem, 38)
      lines[#lines + 1] = l1
      if l2 then rem = l2 else rem = "" end
    end
    for i, ln in ipairs(lines) do
      print(ln, 4, 20 + (i-1) * 10, C_WHITE)
    end
    if G.s2_phase == "done" then
      local p = "Z: CONTINUE"
      print(p, SW - #p*6 - 4, SH - 10, C_HFNT)
    end
    draw_divider(127)
    rect(0, 128, SW, 8, C_BG2)
    return
  end

  -- Slot area
  rect(0, 11, SW, 57, C_BG2)
  local rows, per_row = slot_layout(ns)
  local sw2 = math.floor(236 / per_row) - 1
  local max_chars = math.floor(sw2 / 6) - 1
  local slot_i = 1

  for r = 0, rows - 1 do
    local cols_this = per_row
    if ns == 5 and r == 1 then cols_this = 2 end
    local total_w = cols_this * sw2 + (cols_this - 1) * 2
    local start_x = math.floor((SW - total_w) / 2)
    local box_y = 12 + r * (SLOT_H + 2)

    for c = 0, cols_this - 1 do
      local si = slot_i
      local box_x = start_x + c * (sw2 + 2)
      local bcol = C_BDR
      if G.s2_row == 0 and G.s2_col == si then bcol = C_CUR end
      if G.s2_err_t > 0 and G.s2_err_sl[si] then bcol = C_ERR end
      rectb(box_x, box_y, sw2, SLOT_H, bcol)
      print(tostring(si), box_x + 2, box_y + 1, C_DIM)
      if G.s2_slots[si] then
        local pe = G.s2_pool[G.s2_slots[si]]
        local l1, l2 = word_wrap(pe.text, max_chars)
        print(l1, box_x + 2, box_y + 5, C_TXT)
        if l2 then print(l2, box_x + 2, box_y + 14, C_TXT) end
      end
      slot_i = slot_i + 1
    end
  end

  draw_divider(68)

  -- Pool
  local avail = s2_available_pool()
  local pw2 = math.floor(236 / 4) - 1
  local pool_mc = math.floor(pw2 / 6) - 1

  for i, pi in ipairs(avail) do
    local pe = G.s2_pool[pi]
    local row = math.floor((i - 1) / 4)
    local col = (i - 1) % 4
    local ctr = math.min(4, #avail - row * 4)
    local ttw = ctr * pw2 + (ctr - 1) * 2
    local stx = math.floor((SW - ttw) / 2)
    local bx = stx + col * (pw2 + 2)
    local by = 70 + row * (SLOT_H + 2)

    local bcol = C_BDR
    if G.s2_row == 1 and G.s2_col == i then bcol = C_CUR end
    if G.s2_held == pi then bcol = C_SEL end
    rectb(bx, by, pw2, SLOT_H, bcol)

    local tcol = C_TXT
    if G.s2_held == pi then tcol = C_SEL
    elseif pe.decoy then tcol = C_DIM end
    local l1, l2 = word_wrap(pe.text, pool_mc)
    print(l1, bx + 2, by + 5, tcol)
    if l2 then print(l2, bx + 2, by + 14, tcol) end
  end

  draw_divider(127)
  local hint = G.s2_row == 1
    and "U/D: AREA  L/R: SELECT  Z: PICK"
    or  "U/D: AREA  L/R: SLOT  Z: PLACE  X: CLEAR"
  draw_hint_bar(hint, 128)
end

function draw_puzzle()
  if G.puz_stage == 1 then
    draw_puzzle_s1()
  else
    draw_puzzle_s2()
  end
end

-------------------------------
-- [DRAW_VELA]
-------------------------------

function draw_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]
  local vela = tx.vela

  cls(C_BG)
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

-------------------------------
-- [DRAW_ENDING]
-------------------------------

function draw_ending()
  cls(C_BG)

  if G.end_stage == 1 then
    local lines = {
      "transmitting response to earth...",
      "initiating crew wake protocol...",
    }
    local total = G.end_char
    local y = 40
    for _, ln in ipairs(lines) do
      if total <= 0 then break end
      local show = math.min(#ln, total)
      print(string.sub(ln, 1, show), 8, y, C_TXT)
      total = total - #ln - 1
      y = y + 14
    end
    if G.end_done and math.floor(G.t / 20) % 2 == 0 then
      print("_", 8, y - 14, C_HFNT)
    end

  elseif G.end_stage == 2 then
    local lines = {
      "receipt unconfirmed.",
      "crew wake: in progress.",
      "",
      "vela // standby",
    }
    local total = G.end_char
    local y = 40
    for _, ln in ipairs(lines) do
      if total <= 0 then break end
      local show = math.min(#ln, total)
      if #ln > 0 then
        print(string.sub(ln, 1, show), 8, y, C_TXT)
      end
      total = total - math.max(#ln, 1) - 1
      y = y + 14
    end
    if G.end_done and math.floor(G.t / 20) % 2 == 0 then
      print("_", 8, y - 14, C_HFNT)
    end

  elseif G.end_stage == 3 then
    -- Final title card
    local dx = math.floor(SW / 2)
    local dy = 40
    pix(dx, dy-2, C_OK)
    pix(dx-1, dy-1, C_OK) pix(dx+1, dy-1, C_OK)
    pix(dx-2, dy, C_OK) pix(dx, dy, C_OK) pix(dx+2, dy, C_OK)
    pix(dx-1, dy+1, C_OK) pix(dx+1, dy+1, C_OK)
    pix(dx, dy+2, C_OK)

    local title = "RETURN SIGNAL"
    print(title, math.floor((SW - #title*6)/2), 52, C_WHITE)
    local elapsed = fmt_time(G.t)
    print(elapsed, math.floor((SW - #elapsed*6)/2), 68, C_DIM)

    if math.floor(G.t / BLINK_RATE) % 2 == 0 then
      local p = "[Z]"
      print(p, math.floor((SW - #p*6)/2), 90, C_DIM)
    end
  end
end

-------------------------------
-- [UPDATE]
-------------------------------

function update_title()
  if btnp(4) then
    G.state = "boot"
    G.boot_char = 0
    G.boot_t = 0
    G.boot_done = false
  end
end

function update_boot()
  -- Count total chars in boot text
  local total_chars = 0
  for _, ln in ipairs(BOOT_LINES) do
    total_chars = total_chars + #ln + 1
  end

  if not G.boot_done then
    G.boot_t = G.boot_t + 1
    if G.boot_t % BOOT_CHAR_SPEED == 0 then
      G.boot_char = G.boot_char + 1
    end
    if G.boot_char >= total_chars then
      G.boot_done = true
      G.boot_t = 0
    end
  else
    G.boot_t = G.boot_t + 1
    if G.boot_t >= 90 or btnp(4) then
      G.state = "ship"
      G.cur_room = "comms"
      local room = ROOMS["comms"]
      G.robot_x = room.spawn_x
      G.robot_y = 80
      G.cam_x = 0
    end
  end
end

function update_ship()
  local room = ROOMS[G.cur_room]

  -- Ambient tile animations (every 0.5 sec)
  if G.t % 30 == 0 then
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

  -- Movement
  if btn(2) then
    G.robot_dir = -1
    local nx = G.robot_x - ROBOT_SPEED
    local lt = tile_at(nx, G.robot_y + ROBOT_H - 1)
    local lt2 = tile_at(nx, G.robot_y)
    if not is_solid(lt) and not is_solid(lt2) then
      G.robot_x = nx
    end
    moved = true
  elseif btn(3) then
    G.robot_dir = 1
    local nx = G.robot_x + ROBOT_SPEED + ROBOT_W - 1
    local rt = tile_at(nx, G.robot_y + ROBOT_H - 1)
    local rt2 = tile_at(nx, G.robot_y)
    if not is_solid(rt) and not is_solid(rt2) then
      G.robot_x = G.robot_x + ROBOT_SPEED
    end
    moved = true
  end

  -- Walk anim
  if moved then G.walk_t = G.walk_t + 1
  else G.walk_t = 0; G.robot_frm = 1 end

  -- Gravity
  local below = tile_at(G.robot_x + 4, G.robot_y + ROBOT_H)
  if not is_solid(below) then
    G.robot_y = G.robot_y + 2
  else
    -- Snap to floor
    local floor_y = math.floor((G.robot_y + ROBOT_H) / TILE) * TILE - ROBOT_H
    if G.robot_y > floor_y then G.robot_y = floor_y end
  end

  -- Room bounds
  local rpw = room.map_w * TILE
  G.robot_x = clamp(G.robot_x, TILE, rpw - TILE - ROBOT_W)

  -- Door transitions
  if room.exits.left and G.robot_x <= TILE + 1 then
    local dest = room.exits.left
    G.cur_room = dest
    local dr = ROOMS[dest]
    G.robot_x = dr.map_w * TILE - TILE * 3
    G.robot_y = 80
  elseif room.exits.right and G.robot_x >= rpw - TILE - ROBOT_W - 1 then
    local dest = room.exits.right
    G.cur_room = dest
    G.robot_x = TILE * 2
    G.robot_y = 80
  end

  -- Camera
  room = ROOMS[G.cur_room]  -- might have changed
  local target = G.robot_x - math.floor(SW/2) + math.floor(ROBOT_W/2)
  local max_cam = room.map_w * TILE - SW
  if max_cam < 0 then max_cam = 0 end
  G.cam_x = clamp(target, 0, max_cam)

  -- Interaction proximity
  G.near_obj = nil
  for _, obj in ipairs(room.objects) do
    local rcx = G.robot_x + math.floor(ROBOT_W/2)
    local ocx = obj.x + math.floor(obj.w/2)
    if math.abs(rcx - ocx) < 20 then
      G.near_obj = obj
      break
    end
  end

  -- Z: interact
  if btnp(4) and G.near_obj then
    G.term_type = G.near_obj.type
    G.near_obj_label = G.near_obj.label
    if G.term_type == "signal_log" then
      G.state = "terminal"
      G.term_cur = 1
      -- Find first selectable
      for i = 1, #TRANSMISSIONS do
        if is_selectable(i) then G.term_cur = i; break end
      end
    else
      G.state = "terminal"
    end
  end
end

function update_terminal()
  -- X: exit all terminals
  if btnp(5) then
    G.state = "ship"
    return
  end

  if G.term_type == "signal_log" then
    -- Navigate
    if btnp(0) then G.term_cur = next_selectable(G.term_cur, -1) end
    if btnp(1) then G.term_cur = next_selectable(G.term_cur, 1) end
    -- Z: open transmission
    if btnp(4) then
      if is_available(G.term_cur) and not G.decoded[G.term_cur] then
        G.tx_idx = G.term_cur
        init_stage1(G.term_cur)
        G.state = "puzzle"
      end
    end
  end
end

function update_puzzle_s1()
  local tx = TRANSMISSIONS[G.tx_idx]
  local n = #tx.frags
  local num_gaps = #tx.gap_pos

  if G.s1_shake_t > 0 then G.s1_shake_t = G.s1_shake_t - 1 end

  if G.s1_flash_t > 0 then
    G.s1_flash_t = G.s1_flash_t - 1
    if G.s1_flash_t == 0 then
      init_stage2(G.tx_idx)
    end
    return
  end

  if G.s1_mode == "frags" then
    if btnp(2) then
      G.s1_cursor = G.s1_cursor - 1
      if G.s1_cursor < 1 then G.s1_cursor = n end
    end
    if btnp(3) then
      G.s1_cursor = G.s1_cursor + 1
      if G.s1_cursor > n then G.s1_cursor = 1 end
    end
    if btnp(0) then
      G.s1_mode = "gaps"
      G.s1_gap_cur = 1
    end
    if btnp(4) then
      local fi = G.s1_order[G.s1_cursor]
      local already = false
      for _, pfi in pairs(G.s1_placed) do
        if pfi == fi then already = true; break end
      end
      if not already then
        G.s1_held = fi
        G.s1_mode = "gaps"
        G.s1_gap_cur = 1
        play_sfx(6)
      end
    end

  elseif G.s1_mode == "gaps" then
    if G.s1_held then
      if btnp(2) then
        G.s1_gap_cur = G.s1_gap_cur - 1
        if G.s1_gap_cur < 1 then G.s1_gap_cur = num_gaps end
      end
      if btnp(3) then
        G.s1_gap_cur = G.s1_gap_cur + 1
        if G.s1_gap_cur > num_gaps then G.s1_gap_cur = 1 end
      end
      if btnp(4) then
        local gi = G.s1_gap_cur
        if not G.s1_placed[gi] then
          local frag = tx.frags[G.s1_held]
          if frag.gap == gi then
            G.s1_placed[gi] = G.s1_held
            G.s1_held = nil
            play_sfx(1)
            local all = true
            for g = 1, num_gaps do
              if not G.s1_placed[g] then all = false; break end
            end
            if all then
              G.s1_flash_t = FLASH_DUR
              play_sfx(3)
            else
              G.s1_mode = "frags"
            end
          else
            G.s1_shake_t = SHAKE_DUR
            G.s1_held = nil
            G.s1_mode = "frags"
            play_sfx(2)
          end
        end
      end
      if btnp(5) or btnp(1) then
        G.s1_held = nil
        G.s1_mode = "frags"
      end
    else
      if btnp(2) then
        G.s1_gap_cur = G.s1_gap_cur - 1
        if G.s1_gap_cur < 1 then G.s1_gap_cur = num_gaps end
      end
      if btnp(3) then
        G.s1_gap_cur = G.s1_gap_cur + 1
        if G.s1_gap_cur > num_gaps then G.s1_gap_cur = 1 end
      end
      if btnp(4) then
        local gi = G.s1_gap_cur
        if G.s1_placed[gi] then
          G.s1_held = G.s1_placed[gi]
          G.s1_placed[gi] = nil
          play_sfx(6)
        end
      end
      if btnp(5) or btnp(1) then
        G.s1_mode = "frags"
      end
    end
  end
end

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
    local parts = {}
    for si = 1, ns do
      parts[#parts + 1] = G.s2_pool[G.s2_slots[si]].text
    end
    G.s2_tw_text = table.concat(parts, " // ")
    G.s2_tw_pos = 0
    G.s2_tw_t = 0
    G.s2_pause_t = 0
    G.s2_phase = "typewriter"
    play_sfx(4)
  end
end

function update_puzzle_s2()
  local tx = TRANSMISSIONS[G.tx_idx]
  local ns = #tx.seq

  if G.s2_err_t > 0 then
    G.s2_err_t = G.s2_err_t - 1
    if G.s2_err_t == 0 then G.s2_err_sl = {} end
  end

  if G.s2_phase == "typewriter" then
    G.s2_tw_t = G.s2_tw_t + 1
    if G.s2_tw_t % TW_SPEED == 0 and G.s2_tw_pos < #G.s2_tw_text then
      G.s2_tw_pos = G.s2_tw_pos + 1
    end
    if G.s2_tw_pos >= #G.s2_tw_text then
      G.s2_pause_t = G.s2_pause_t + 1
      if G.s2_pause_t >= VL_PAUSE then G.s2_phase = "done" end
    end
    return
  end

  if G.s2_phase == "done" then
    if btnp(4) then
      init_vela_log()
      G.state = "vela_log"
    end
    return
  end

  -- Place phase
  if G.s2_row == 1 then
    local avail = s2_available_pool()
    local na = #avail
    if na == 0 then
      G.s2_row = 0; G.s2_col = 1
    else
      if G.s2_col > na then G.s2_col = na end
      if G.s2_col < 1 then G.s2_col = 1 end
      if btnp(2) then G.s2_col = G.s2_col - 1; if G.s2_col < 1 then G.s2_col = na end end
      if btnp(3) then G.s2_col = G.s2_col + 1; if G.s2_col > na then G.s2_col = 1 end end
      if btnp(0) then G.s2_row = 0; G.s2_col = 1 end
      if btnp(4) then
        local pi = avail[G.s2_col]
        if G.s2_held == pi then G.s2_held = nil
        else G.s2_held = pi; play_sfx(6) end
      end
      if btnp(5) then G.s2_held = nil end
    end
  else
    if btnp(2) then G.s2_col = G.s2_col - 1; if G.s2_col < 1 then G.s2_col = ns end end
    if btnp(3) then G.s2_col = G.s2_col + 1; if G.s2_col > ns then G.s2_col = 1 end end
    if btnp(1) then
      local ap = s2_available_pool()
      if #ap > 0 then G.s2_row = 1; G.s2_col = 1 end
    end
    local si = G.s2_col
    if btnp(4) then
      local all = true
      for s = 1, ns do if not G.s2_slots[s] then all = false; break end end
      if all and not G.s2_held then
        check_s2_solution()
      elseif G.s2_held and not G.s2_slots[si] then
        G.s2_slots[si] = G.s2_held
        G.s2_held = nil
        play_sfx(1)
      elseif not G.s2_held and G.s2_slots[si] then
        G.s2_held = G.s2_slots[si]
        G.s2_slots[si] = nil
        play_sfx(6)
      end
    end
    if btnp(5) then
      if G.s2_held then G.s2_held = nil
      elseif G.s2_slots[si] then G.s2_slots[si] = nil; play_sfx(6) end
    end
  end
end

function update_puzzle()
  if G.puz_stage == 1 then
    update_puzzle_s1()
  else
    update_puzzle_s2()
  end
end

function update_vela_log()
  local tx = TRANSMISSIONS[G.tx_idx]
  local vela = tx.vela

  if G.vl_done then
    if btnp(4) then
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
    return
  end

  G.vl_timer = G.vl_timer + 1
  if G.vl_line == 0 then
    G.vl_line = 1
    G.vl_timer = 0
    return
  end
  if G.vl_line < #vela then
    if btnp(4) or G.vl_timer >= VL_LINE_DUR then
      G.vl_line = G.vl_line + 1
      G.vl_timer = 0
    end
  end
  if G.vl_line >= #vela then G.vl_done = true end
end

function update_ending()
  if G.end_stage == 1 then
    local text = "transmitting response to earth...\ninitiating crew wake protocol..."
    local total = #text
    if not G.end_done then
      G.end_t = G.end_t + 1
      if G.end_t % 3 == 0 then G.end_char = G.end_char + 1 end
      if G.end_char >= total then
        G.end_done = true
        G.end_t = 0
      end
    else
      G.end_t = G.end_t + 1
      if btnp(4) or G.end_t >= 120 then
        G.end_stage = 2
        G.end_t = 0
        G.end_char = 0
        G.end_done = false
      end
    end

  elseif G.end_stage == 2 then
    local text = "receipt unconfirmed.\ncrew wake: in progress.\n\nvela // standby"
    local total = #text
    if not G.end_done then
      G.end_t = G.end_t + 1
      if G.end_t % 3 == 0 then G.end_char = G.end_char + 1 end
      if G.end_char >= total then
        G.end_done = true
        G.end_t = 0
      end
    else
      G.end_t = G.end_t + 1
      if btnp(4) or G.end_t >= 120 then
        G.end_stage = 3
        G.end_t = 0
      end
    end

  elseif G.end_stage == 3 then
    if btnp(4) then
      -- Reset to title
      G.state = "title"
      G.decoded = {}
      G.t = 0
    end
  end
end

function update()
  if G.state == "title" then update_title()
  elseif G.state == "boot" then update_boot()
  elseif G.state == "ship" then update_ship()
  elseif G.state == "terminal" then update_terminal()
  elseif G.state == "puzzle" then update_puzzle()
  elseif G.state == "vela_log" then update_vela_log()
  elseif G.state == "ending" then update_ending()
  end
end

-------------------------------
-- [TIC] Main Loop
-------------------------------

function TIC()
  G.t = G.t + 1
  update()

  if G.state == "title" then draw_title()
  elseif G.state == "boot" then draw_boot()
  elseif G.state == "ship" then draw_ship()
  elseif G.state == "terminal" then draw_terminal()
  elseif G.state == "puzzle" then draw_puzzle()
  elseif G.state == "vela_log" then draw_vela_log()
  elseif G.state == "ending" then draw_ending()
  end
end

-------------------------------
-- [INIT]
-------------------------------

init_map()

-- <TILES>
-- 001:ffffffffff0ffff0ffffffffffffffffffffffffff0ffff0ffffffffffffffff
-- 002:fffffffff88888888888888888888888888888888888888888888888f8888888
-- 003:ffffffffffffffff8888888888888888888888888888f8888888888888888888
-- 004:111111111e1e1e1e1111111111111111111111111e1e1e1e1111111111111111
-- 005:f333333ff333333ff333333fff3333ffff3333fff333333ff333333ff333333f
-- 006:00000000000c00000000000000000c00000000000c00000000000000000000c0
-- 007:888888888bbbbb88888888888b888b888b888b88888888888bbbbb8888888888
-- 008:111111111f111111111111111f111111111111111f111111111111111f111111
-- 009:f0f0f0f00f0f0f0ff0f0f0f00f0f0f0ff0f0f0f00f0f0f0ff0f0f0f00f0f0f0f
-- 010:777777777b7777777777777777b77777777777777777b77777777777777777b7
-- 011:777777777777777b7777777777777b7777777777777b7777777777777b777777
-- 012:1111111111144111144444111444441111144111111111111111111111111111
-- 013:7777777777777777777777777777777777777777777777773333333377777777
-- 014:7777777777777777777777777777777777777777777777773333333377777777
-- 015:88888888888888888bbbbb88888888888b888b888b888b88888888888bbbbb88
-- 016:1111111111133111133333111333331111133111111111111111111111111111
-- 017:777777777777777777b77777777777777777b77777777777777777b777777777
-- 018:777777777777777777777b7777777777777b7777777777777b77777777777777
-- </TILES>
-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>
