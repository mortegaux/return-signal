#!/bin/bash
# Build and optionally run return-signal
TIC_FS="$HOME/.local/share/com.nesbox.tic/TIC-80"
cp return-signal.lua "$TIC_FS/return-signal.lua"
tic80 --cli --fs="$TIC_FS" --cmd "load return-signal.tic & import code return-signal.lua & save & exit" 2>&1
if [ "$1" = "run" ]; then
  tic80 --skip --fs="$TIC_FS" --cmd "load return-signal.tic & run" &
fi
