#!/bin/sh
# Build Astro Wing with the vendored 7800basic (tools/7800basic, a copy of
# the 7800basic the game has been built with; needs wasmtime on the PATH).
#
#   tools/build.sh   -> build/output/astrowing.a78 (and .bin)
#
# 7800basic writes its intermediate files next to the source, so the build
# runs in a copy of src/ under build/work and copies the results out. The
# music (src/music/music_data.asm) is committed; CMake regenerates it from
# the .vgm files when they change.
set -e
ROOT=$(cd "$(dirname "$0")/.." && pwd)
BASDIR="$ROOT/tools/7800basic"
WORK="$ROOT/build/work"
OUT="$ROOT/build/output"

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"
cp -R "$ROOT/src/." "$WORK/"

cd "$WORK"
rm -f astrowing.bas.a78 astrowing.bas.bin
bas7800dir="$BASDIR" PATH="$BASDIR:$PATH" sh "$BASDIR/7800basic.sh" astrowing.bas > build.log 2>&1 || true
if [ ! -f astrowing.bas.a78 ] || grep -q -i -E "Fatal assembly error|Compilation failed|unresolved" build.log; then
    grep -i -E -B2 -A2 "error|unresolved|failed" build.log | head -40
    echo "BUILD FAILED (full log: build/work/build.log)"
    exit 1
fi
cp astrowing.bas.a78 "$OUT/astrowing.a78"
cp astrowing.bas.bin "$OUT/astrowing.bin"
grep -E "bytes of ROM space left" build.log || true
echo "built build/output/astrowing.a78"
