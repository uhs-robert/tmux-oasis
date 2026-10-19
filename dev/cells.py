#!/usr/bin/env python3
"""Parse lines from `tmux capture-pane -e -p` into cells, and print or compare them.

usage:
  cells.py dump FILE              print each line as runs of same-styled cells
  cells.py diff REF WORK [LABEL]  exit 1 and print the differing cells, if any

Colours are kept as tmux names them ("#rrggbb", "colourN", "default") so they
can be compared without a palette. Non-ASCII glyphs print as U+XXXX because
private-use glyphs tend to vanish from terminals and agent output.
"""
import re
import sys
import unicodedata
from collections import namedtuple

Cell = namedtuple("Cell", "glyph fg bg bold")

FULL_BLOCK = "█"
# Second column of a double-width glyph
WIDE_FILLER = ""
MAX_REPORTED_CELLS = 40

sgr_pattern = re.compile(r"(\x1b\[[0-9;:]*m)")


def extended_colour(codes, i):
    """Reads a 38/48 colour starting at codes[i]; returns (colour, codes consumed)."""
    if i + 1 < len(codes) and codes[i + 1] == 2 and i + 4 < len(codes):
        red, green, blue = codes[i + 2:i + 5]
        return "#%02x%02x%02x" % (red, green, blue), 5
    if i + 2 < len(codes) and codes[i + 1] == 5:
        return "colour%d" % codes[i + 2], 3
    return None, len(codes) - i


def parse_line(line):
    cells = []
    fg, bg, bold, reverse = "default", "default", False, False
    for part in sgr_pattern.split(line):
        if part.startswith("\x1b["):
            codes = [int(c) if c else 0 for c in re.split("[;:]", part[2:-1])]
            i = 0
            while i < len(codes):
                code = codes[i]
                consumed = 1
                if code == 0:
                    fg, bg, bold, reverse = "default", "default", False, False
                elif code == 1:
                    bold = True
                elif code == 22:
                    bold = False
                elif code == 7:
                    reverse = True
                elif code == 27:
                    reverse = False
                elif code in (38, 48):
                    colour, consumed = extended_colour(codes, i)
                    if colour and code == 38:
                        fg = colour
                    elif colour:
                        bg = colour
                elif code == 39:
                    fg = "default"
                elif code == 49:
                    bg = "default"
                elif 30 <= code <= 37:
                    fg = "colour%d" % (code - 30)
                elif 90 <= code <= 97:
                    fg = "colour%d" % (code - 90 + 8)
                elif 40 <= code <= 47:
                    bg = "colour%d" % (code - 40)
                elif 100 <= code <= 107:
                    bg = "colour%d" % (code - 100 + 8)
                i += consumed
            continue
        for glyph in part:
            shown_fg, shown_bg = (bg, fg) if reverse else (fg, bg)
            cells.append(Cell(glyph, shown_fg, shown_bg, bold))
            if unicodedata.east_asian_width(glyph) in ("W", "F"):
                cells.append(Cell(WIDE_FILLER, shown_fg, shown_bg, bold))
    return cells


def read_lines(path):
    with open(path, encoding="utf-8") as source:
        return source.read().rstrip("\n").split("\n")


def glyph_text(glyph):
    if glyph == WIDE_FILLER:
        return ""
    if " " <= glyph <= "~":
        return glyph
    return "<U+%04X>" % ord(glyph)


def style_text(cell):
    return "fg=%s bg=%s%s" % (cell.fg, cell.bg, " bold" if cell.bold else "")


def dump(path):
    for line in read_lines(path):
        cells = parse_line(line)
        start = 0
        while start < len(cells):
            end = start
            while end + 1 < len(cells) and cells[end + 1][1:] == cells[start][1:]:
                end += 1
            text = "".join(glyph_text(c.glyph) for c in cells[start:end + 1])
            print("%3d-%-3d %-40s \"%s\"" % (start, end, style_text(cells[start]), text))
            start = end + 1


def appearance(cell):
    """What a cell looks like: a space and a full block fill it with one colour."""
    if cell.glyph == " ":
        return ("fill", cell.bg)
    if cell.glyph == FULL_BLOCK:
        return ("fill", cell.fg)
    return cell


def cell_text(cell):
    if cell is None:
        return "(none)"
    return "%-10s %s" % (glyph_text(cell.glyph) or "(wide)", style_text(cell))


def diff(ref_path, work_path, label):
    ref_lines, work_lines = read_lines(ref_path), read_lines(work_path)
    differences = []
    for row in range(max(len(ref_lines), len(work_lines))):
        ref_cells = parse_line(ref_lines[row]) if row < len(ref_lines) else []
        work_cells = parse_line(work_lines[row]) if row < len(work_lines) else []
        for column in range(max(len(ref_cells), len(work_cells))):
            ref_cell = ref_cells[column] if column < len(ref_cells) else None
            work_cell = work_cells[column] if column < len(work_cells) else None
            if ref_cell is None or work_cell is None or appearance(ref_cell) != appearance(work_cell):
                differences.append((column, ref_cell, work_cell))
    if not differences:
        return 0
    print("%s: %d cells differ" % (label, len(differences)))
    for column, ref_cell, work_cell in differences[:MAX_REPORTED_CELLS]:
        print("  col %3d  ref  %s" % (column, cell_text(ref_cell)))
        print("           work %s" % cell_text(work_cell))
    if len(differences) > MAX_REPORTED_CELLS:
        print("  ... %d more" % (len(differences) - MAX_REPORTED_CELLS))
    return 1


def main(args):
    if len(args) == 2 and args[0] == "dump":
        dump(args[1])
        return 0
    if len(args) in (3, 4) and args[0] == "diff":
        label = args[3] if len(args) == 4 else "bar"
        return diff(args[1], args[2], label)
    sys.stderr.write(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
