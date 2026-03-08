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
-- [DRAW] Title (stub)
-------------------------------

function draw_title()
  cls(C_BG)
end

-------------------------------
-- [DRAW] Hub (stub)
-------------------------------

function draw_hub()
  cls(C_BG)
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
-- [UPDATE] Dispatcher
-------------------------------

function update()
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
