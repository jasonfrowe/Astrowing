#!/usr/bin/env python3
"""Build the game's manual: docs/manual/manual.html -> PDFs.

    .venv/bin/python tools/make_manual.py            # sprites and PDFs
    .venv/bin/python tools/make_manual.py --shots    # screenshots too (runs
                                                     # the emulator: a minute)

The manual is a 16-page pocket booklet in the style of the old Atari
manuals (the same layout as Atari Gamma Force's), laid out in
docs/manual/manual.html (edit the text there) and printed by Chrome at
5 x 7 inches and 4 x 6.5 inches (docs/manual/*.pdf). 16 pages: a multiple of
4, for a folded, stapled booklet.

Images in docs/manual/img: screenshots from the emulator (tools/play.sh, the
built ROM, RAM poked to set each scene up), the sprites drawn from
src/graphics in their in-game colours at the 7800's pixel shape (a 160A
pixel is twice as wide as tall), and the cover art from coverart/.
"""

import argparse
import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
MAN = ROOT / "docs" / "manual"
IMG = MAN / "img"
GFX = ROOT / "src" / "graphics"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

NTSC = json.loads((ROOT / "tools" / "a7800_ntsc_palette.json").read_text())["rgb"]


def rgb(code):
    return tuple(NTSC[code])


# The game's palettes (set_palettes / init_boss in src/astrowing.bas)
P1 = [0xC2, 0xC6, 0xCA]        # player bullets, energy orb
P2 = [0x04, 0x08, 0x0C]        # asteroid
P3 = [0xB4, 0x46, 0x1C]        # enemy fighters
P5 = [0x34, 0x86, 0x0A]        # your ship, hearts
P6 = [0x46, 0x96, 0x0A]        # guardians (boss palette), arrows
P6E = [0x42, 0x46, 0x4A]       # enemy bullets
P7 = [0xC8, 0x46, 0x1C]        # relics

# ---------------------------------------------------------------------------
# Screenshots. RAM used to set scenes up (see docs/MEMORY_MAP.md):
#   $25A4 current_level, $2548 fighters left, $2549 shield, $254B lives,
#   $01A6 score (BCD), $25B0 boss x,y  $25B6 boss x_hi,y_hi, $25B2 boss hp,
#   $2550 asteroid x,y,vx,vy,life,x_hi,y_hi, $25F4 orb x,y,x_hi,y_hi,on.

START = ["300 press P1 Button 1", "306 release P1 Button 1",
         "340 press P1 Button 1", "346 release P1 Button 1"]


def keep_shield(a, b):
    return [f"{f} poke 2549 64" for f in range(a, b, 20)]


def boss_scene(level, x=0x40, y=0x18, until=760):
    s = START + [f"330 poke 25a4 {level:02x}", "330 poke 2548 00", "360 press P1 Button 1"]
    s += [f"{f} poke 25b0 {x:02x} {y:02x}\n{f} poke 25b6 01 01" for f in range(420, until, 3)]
    return s + keep_shield(360, until)


def kill_boss():
    s = START + ["330 poke 2548 00", "360 press P1 Button 1", "400 poke 25b2 06"]
    s += [f"{f} poke 25b0 48 10\n{f} poke 25b6 01 01" for f in range(400, 470, 2)]
    return s + ["470 release P1 Button 1"]


def game_over(level=3):
    return START + [f"330 poke 25a4 {level:02x}", "400 poke 01a6 01 23 40",
                    "400 poke 254b 01", "401 poke 2549 00"]


def victory():
    s = START + ["330 poke 25a4 06", "330 poke 2548 00", "360 press P1 Button 1",
                 "400 poke 25b2 02", "400 poke 01a6 05 43 21"]
    s += [f"{f} poke 25b0 40 10\n{f} poke 25b6 01 01" for f in range(400, 470, 2)]
    return s + ["470 release P1 Button 1", "600 press P1 Button 1", "606 release P1 Button 1"]


def play(level=1):
    s = START + [f"330 poke 25a4 {level:02x}", "360 press P1 Button 1"]
    for f in range(400, 1600, 160):
        s += [f"{f} press P1 Right", f"{f + 18} release P1 Right",
              f"{f + 60} press P1 Up", f"{f + 90} release P1 Up"]
    return s + keep_shield(360, 1600)


SHOTS = {
    # name: (script lines, frames to snap; the busiest frame is kept)
    "title": ([], range(400, 460, 6)),
    "play": (play(1) + ["900 poke 2550 18 40 00 00 01 01 01"], range(900, 1000, 4)),
    "hud": (boss_scene(3, until=700) + ["300 poke 01a6 00 48 50"], range(640, 700, 6)),
    "boss1": (boss_scene(1), range(700, 760, 6)),
    "boss2": (boss_scene(2), range(700, 760, 6)),
    "boss3": (boss_scene(3), range(700, 760, 6)),
    "boss4": (boss_scene(4), range(700, 760, 6)),
    "boss5": (boss_scene(5), range(700, 760, 6)),
    "boss6": (boss_scene(6), range(700, 760, 6)),
    "arrow": (boss_scene(2, until=600) + [f"{f} poke 25b0 80 50\n{f} poke 25b6 00 01"
                                          for f in range(600, 700, 3)], range(650, 700, 6)),
    "orb": (play(2) + ["900 poke 25f4 64 44 01 01 01", "900 poke 25fa ff",
                       "900 poke 2550 20 70 00 00 01 01 01"], range(904, 940, 4)),
    "reward": (kill_boss(), range(520, 560, 6)),
    "victory": (victory(), range(940, 1100, 8)),
    "gameover": (game_over(), range(660, 760, 6)),
    "hiscore": (game_over() + ["760 press P1 Button 1", "766 release P1 Button 1",
                               "800 press P1 Up", "806 release P1 Up"], range(840, 880, 8)),
}


def shots():
    with tempfile.TemporaryDirectory() as t:
        tmp = Path(t)
        for name, (lines, frames) in SHOTS.items():
            last = max(frames)
            lines = list(lines) + [f"{f} snap" for f in frames] + [f"{last + 10} exit"]
            lines.sort(key=lambda l: int(l.split()[0]))
            (tmp / f"{name}.txt").write_text("\n".join(lines) + "\n")
            subprocess.run([str(ROOT / "tools" / "play.sh"), str(tmp / f"{name}.txt"), str(tmp / name)],
                           check=True, stdout=subprocess.DEVNULL)
            ims = [Image.open(p).convert("RGB") for p in sorted((tmp / name / "a7800").glob("*.png"))]
            if not ims:
                raise SystemExit(f"no screenshots for {name}: see {tmp / name / 'emu.log'}")
            # of several frames, the one with the most drawn on it
            best = max(ims, key=lambda im: sum(c for c, _ in sorted(im.getcolors(1 << 20))[:-1]))
            best.save(IMG / f"{name}.png")
            print("shot", name, file=sys.stderr)


# ---------------------------------------------------------------------------
# Sprites from src/graphics (colour 0 transparent, 1-3 the palette's colours)

def sprite(name, pal, box=None):
    src = Image.open(GFX / f"{name}.png")
    if box:
        src = src.crop(box)
    out = Image.new("RGBA", src.size, (0, 0, 0, 0))
    for y in range(src.height):
        for x in range(src.width):
            i = src.getpixel((x, y))
            if i:
                out.putpixel((x, y), (*rgb(pal[i - 1]), 255))
    bb = out.getbbox()
    return out.crop(bb) if bb else out


def big(im, scale):
    """At the 7800's shape: each 160A pixel 2 wide, 1 tall, times scale."""
    return im.resize((im.width * 2 * scale, im.height * scale), Image.NEAREST)


def row(ims, gap=3):
    w = sum(i.width for i in ims) + gap * (len(ims) - 1)
    out = Image.new("RGBA", (w, max(i.height for i in ims)), (0, 0, 0, 0))
    x = 0
    for i in ims:
        out.alpha_composite(i, (x, (out.height - i.height) // 2))
        x += i.width + gap
    return out


def glyph(k, pal):
    """Character k of the game's font (8 pixels wide cells, 16 rows)."""
    return sprite("unified_font", pal, (k * 8, 0, k * 8 + 8, 16))


def sprites():
    big(sprite("sprite_spaceship1", P5), 8).save(IMG / "sp_ship.png")
    big(row([sprite(f"sprite_spaceship{k}", P5) for k in (1, 3, 5, 7, 9, 13)], 4), 6).save(IMG / "sp_turns.png")
    big(sprite("fighter", P3), 8).save(IMG / "sp_fighter.png")
    big(sprite("blue_fighter", P3), 8).save(IMG / "sp_blue.png")
    big(sprite("asteroid_M_conv", P2), 4).save(IMG / "sp_asteroid.png")
    big(sprite("Energy", P1), 10).save(IMG / "sp_orb.png")
    big(sprite("bullet_conv", P6E), 10).save(IMG / "sp_ebullet.png")
    big(sprite("bullet_conv", P1), 10).save(IMG / "sp_pbullet.png")
    big(sprite("arrows_01", P6), 8).save(IMG / "sp_arrow.png")
    # the flagship, its four quarters together
    fl = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    for k, (x, y) in enumerate(((0, 0), (16, 0), (0, 16), (16, 16))):
        fl.alpha_composite(sprite_full(f"BossV2_0{k + 1}", P6), (x, y))
    big(fl, 5).save(IMG / "sp_flagship.png")
    # relics (font characters 46-50) and a heart (51)
    for k, name in enumerate(("relic1", "relic2", "relic3", "relic4", "relic5")):
        big(glyph(46 + k, P7), 8).save(IMG / f"sp_{name}.png")
    big(row([glyph(46 + k, P7) for k in range(5)], 4), 6).save(IMG / "sp_relics.png")
    big(glyph(51, P5), 8).save(IMG / "sp_heart.png")


def sprite_full(name, pal):
    """Like sprite(), without trimming (for putting pieces together)."""
    src = Image.open(GFX / f"{name}.png")
    out = Image.new("RGBA", src.size, (0, 0, 0, 0))
    for y in range(src.height):
        for x in range(src.width):
            i = src.getpixel((x, y))
            if i:
                out.putpixel((x, y), (*rgb(pal[i - 1]), 255))
    return out


def cover():
    im = Image.open(ROOT / "coverart" / "astrowing_boss_confrontation.png").convert("RGB")
    im.resize((900, 900), Image.LANCZOS).save(IMG / "cover.jpg", quality=90)


# ---------------------------------------------------------------------------
SIZES = {
    # name: page width, height (inches), base font size, page padding
    "5x7": ("5in", "7in", "9pt", "0.38in 0.4in 0.42in"),
    "4x6.5": ("4in", "6.5in", "7.6pt", "0.3in 0.3in 0.36in"),
}


def pdfs():
    html = (MAN / "manual.html").read_text()
    for name, (w, h, fs, pad) in SIZES.items():
        sized = re.sub(r"/\*SIZE\*/.*?/\*END\*/",
                       f"/*SIZE*/ --page-w: {w}; --page-h: {h}; --base: {fs}; --pad: {pad}; /*END*/",
                       html, flags=re.S)
        sized = re.sub(r"@page \{[^}]*\}", f"@page {{ size: {w} {h}; margin: 0; }}", sized)
        tmp = MAN / f".manual-{name}.html"
        tmp.write_text(sized)
        out = MAN / f"Astro_Wing_Manual_{name}.pdf"
        subprocess.run([CHROME, "--headless=new", "--disable-gpu", "--no-pdf-header-footer",
                        "--run-all-compositor-stages-before-draw", "--virtual-time-budget=4000",
                        f"--print-to-pdf={out}", tmp.as_uri()],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        tmp.unlink()
        print(out.relative_to(ROOT))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--shots", action="store_true", help="capture the screenshots (runs the emulator)")
    ap.add_argument("--no-pdf", action="store_true")
    args = ap.parse_args()
    IMG.mkdir(parents=True, exist_ok=True)
    if args.shots:
        shots()
    sprites()
    cover()
    if not args.no_pdf:
        pdfs()


if __name__ == "__main__":
    main()
