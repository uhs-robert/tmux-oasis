#!/usr/bin/env python3
"""Draw lines from `tmux capture-pane -e -p` to a PNG with a Nerd Font.

usage: ansi_to_png.py IN.ansi OUT.png [--scale N] [--only-last N]

The font is JetBrainsMono Nerd Font Mono, looked up in the usual font folders.
OASIS_FONT and OASIS_FONT_BOLD point at other .ttf files instead.
"""
import glob
import os
import sys

from cells import WIDE_FILLER, parse_line, read_lines

try:
    from PIL import Image, ImageDraw, ImageFont
except ImportError:
    sys.exit("ansi_to_png: Pillow is missing; install it with `python3 -m pip install Pillow`")

FONT_FILES = {
    "regular": "JetBrainsMonoNerdFontMono-Regular.ttf",
    "bold": "JetBrainsMonoNerdFontMono-Bold.ttf",
}
FONT_DIRS = [
    "/usr/share/fonts",
    "/usr/local/share/fonts",
    "~/.local/share/fonts",
    "~/.fonts",
    "~/Library/Fonts",
    "/Library/Fonts",
    "/opt/homebrew/share/fonts",
]
FONT_ENV = {"regular": "OASIS_FONT", "bold": "OASIS_FONT_BOLD"}

ANSI_16 = [
    (0, 0, 0), (205, 49, 49), (13, 188, 121), (229, 229, 16),
    (36, 114, 200), (188, 63, 188), (17, 168, 205), (229, 229, 229),
    (102, 102, 102), (241, 76, 76), (35, 209, 139), (245, 245, 67),
    (59, 142, 234), (214, 112, 214), (41, 184, 219), (255, 255, 255),
]
DEFAULT_COLOURS = {"fg": (220, 220, 220), "bg": (16, 16, 16)}


def find_font(weight):
    override = os.environ.get(FONT_ENV[weight])
    if override:
        if not os.path.isfile(override):
            sys.exit("ansi_to_png: %s=%s is not a file" % (FONT_ENV[weight], override))
        return override
    for folder in FONT_DIRS:
        matches = glob.glob(os.path.join(os.path.expanduser(folder), "**", FONT_FILES[weight]), recursive=True)
        if matches:
            return matches[0]
    return None


def load_fonts(size):
    regular_path = find_font("regular")
    if not regular_path:
        sys.exit(
            "ansi_to_png: %s not found in %s.\nInstall JetBrainsMono Nerd Font, or set %s (and %s) to a .ttf file."
            % (FONT_FILES["regular"], ", ".join(FONT_DIRS), FONT_ENV["regular"], FONT_ENV["bold"])
        )
    bold_path = find_font("bold") or regular_path
    return ImageFont.truetype(regular_path, size), ImageFont.truetype(bold_path, size)


def colour_256(n):
    if n < 16:
        return ANSI_16[n]
    if n < 232:
        n -= 16
        steps = [0, 95, 135, 175, 215, 255]
        return (steps[n // 36], steps[(n // 6) % 6], steps[n % 6])
    level = 8 + (n - 232) * 10
    return (level, level, level)


def rgb(colour, role):
    if colour.startswith("#"):
        return tuple(int(colour[i:i + 2], 16) for i in (1, 3, 5))
    if colour.startswith("colour"):
        return colour_256(int(colour[len("colour"):]))
    return DEFAULT_COLOURS[role]


def take_option(args, name, default):
    if name not in args:
        return default
    i = args.index(name)
    value = int(args[i + 1])
    del args[i:i + 2]
    return value


def main(args):
    scale = take_option(args, "--scale", 2)
    only_last = take_option(args, "--only-last", 0)
    if len(args) != 2:
        sys.exit(__doc__)
    source_path, out_path = args
    lines = read_lines(source_path)
    if only_last:
        lines = lines[-only_last:]
    rows = [parse_line(line) for line in lines]

    regular, bold = load_fonts(16 * scale)
    cell_width = round(regular.getlength("M"))
    ascent, descent = regular.getmetrics()
    cell_height = ascent + descent
    columns = max((len(row) for row in rows), default=1)
    image = Image.new("RGB", (columns * cell_width, len(rows) * cell_height), DEFAULT_COLOURS["bg"])
    draw = ImageDraw.Draw(image)
    for y, row in enumerate(rows):
        for x, cell in enumerate(row):
            box = (x * cell_width, y * cell_height, (x + 1) * cell_width, (y + 1) * cell_height)
            draw.rectangle(box, fill=rgb(cell.bg, "bg"))
            if cell.glyph.strip() and cell.glyph != WIDE_FILLER:
                font = bold if cell.bold else regular
                draw.text(box[:2], cell.glyph, font=font, fill=rgb(cell.fg, "fg"))
    image.save(out_path)


if __name__ == "__main__":
    main(sys.argv[1:])
