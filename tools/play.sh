#!/bin/sh
# Run the game headless with a scripted input file (see tools/emu/play.lua).
#   tools/play.sh script.txt [out_dir]    -> out_dir/a7800/NNNN.png, out_dir/play.txt
# ROM=... picks the cartridge (default build/output/astrowing.a78),
# A7800=... the emulator (default ../../a7800/mame64, the a7800 fork).
ROOT=$(cd "$(dirname "$0")/.." && pwd)
A7800=${A7800:-$ROOT/../../a7800/mame64}
SCRIPT=$(cd "$(dirname "$1")" && pwd)/$(basename "$1")
OUT=${2:-$ROOT/build/play}
ROMFILE=${ROM:-$ROOT/build/output/astrowing.a78}
ROMFILE=$(cd "$(dirname "$ROMFILE")" && pwd)/$(basename "$ROMFILE")
rm -rf "$OUT"; mkdir -p "$OUT"; OUT=$(cd "$OUT" && pwd)
cd "$(dirname "$A7800")"
PLAY_SCRIPT="$SCRIPT" PLAY_OUT="$OUT/play.txt" "$A7800" ${MACHINE:-a7800} -cart "$ROMFILE" \
  -video none -sound none -nothrottle -seconds_to_run 600 -snapshot_directory "$OUT" \
  -autoboot_script "$ROOT/tools/emu/play.lua" -skip_gameinfo -nomouse > "$OUT/emu.log" 2>&1
cat "$OUT/play.txt"
