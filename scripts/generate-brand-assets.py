#!/usr/bin/env python3
"""Generate the README brand SVG assets.

Writes six files into docs/assets/brand/, a dark and a light variant of each:

    features-{dark,light}.svg   the four value-proposition cards
    agents-{dark,light}.svg     the supported agents, as pills in two tiers
    divider-{dark,light}.svg    the section rule

The README serves them through <picture> with prefers-color-scheme, so both
variants of a pair must keep the same dimensions.

Usage (from anywhere; paths resolve against the repository):

    python3 scripts/generate-brand-assets.py

Requires only the Python 3 standard library. It is not part of the build or of
CI: run it by hand after editing the copy or the supported-agent lists below,
then commit the regenerated SVGs.

Two rules worth keeping:

1. Colours come from the "Gentleman Cute" theme in
   internal/components/theme/inject.go. Never sample them from the raster
   banner -- the banner's glow reads as a far more saturated pink than the
   brand's actual accent.
2. Always rasterise and look at the result before committing. Clipped borders
   and miscomputed canvas heights are invisible in the XML. For example:

       brew install resvg
       resvg docs/assets/brand/features-dark.svg /tmp/check.png
"""

from __future__ import annotations

import math
import pathlib

OUT = pathlib.Path(__file__).resolve().parent.parent / "docs" / "assets" / "brand"

# Authoritative palette -- internal/components/theme/inject.go, "Gentleman Cute".
DARK = dict(
    bg="#1A1218",       # backgroundPanel
    card="#241822",     # backgroundElement
    stroke="#342230",   # border
    stroke2="#D7A0B8",  # secondary
    accent="#F095C8",   # primary / accent
    accent2="#FFB1DD",  # borderActive / shimmer
    title="#F6EFF3",    # text
    body="#A78E9B",     # textMuted
    muted="#76616B",    # subtle
    glow=True,
    name="dark",
)

# Light variant: the same hue family, darkened for contrast on white. The repo
# defines no light theme, so these are derived rather than quoted.
LIGHT = dict(
    bg="#FFFFFF",
    card="#FCF5F9",
    stroke="#EBD5E2",
    stroke2="#C97FA6",
    accent="#B93A78",
    accent2="#9C2C63",
    title="#1A1218",
    body="#6B5460",
    muted="#96808C",
    glow=False,
    name="light",
)

# GitHub renders these through <img>, which cannot load web fonts. Both stacks
# must resolve to something present on macOS, Linux and Windows.
FONT = "-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif"
MONO = "'SF Mono',SFMono-Regular,Menlo,Consolas,'Liberation Mono',monospace"


def defs(p):
    glow = ""
    if p["glow"]:
        glow = """
    <filter id="glow" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="3.2" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="softglow" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="1.4" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>"""
    return f"""  <defs>
    <linearGradient id="rule" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="{p['accent']}" stop-opacity="0"/>
      <stop offset="50%" stop-color="{p['accent']}" stop-opacity="1"/>
      <stop offset="100%" stop-color="{p['accent']}" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="cardfill" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="{p['card']}"/>
      <stop offset="100%" stop-color="{p['bg']}"/>
    </linearGradient>{glow}
  </defs>"""


def fx(p, soft=False):
    """The glow filter attribute, or nothing on the light variant."""
    if not p["glow"]:
        return ""
    return ' filter="url(#softglow)"' if soft else ' filter="url(#glow)"'


# --------------------------------------------------------------------- icons
# Each icon draws into a 42x42 box at (x, y).


def icon_memory(p, x, y):
    a, s = p["accent"], p["stroke2"]
    return f"""<g transform="translate({x},{y})" fill="none" stroke-width="2" stroke-linecap="round"{fx(p)}>
      <path d="M9 21 L29 11 M9 21 L29 31" stroke="{s}"/>
      <circle cx="9" cy="21" r="5" stroke="{a}"/>
      <circle cx="30" cy="10" r="4" stroke="{a}"/>
      <circle cx="30" cy="32" r="4" stroke="{a}"/>
    </g>"""


def icon_route(p, x, y):
    a, s = p["accent"], p["stroke2"]
    return f"""<g transform="translate({x},{y})" fill="none" stroke-width="2" stroke-linecap="round"{fx(p)}>
      <path d="M5 21 H16 C22 21 22 9 28 9 H36" stroke="{a}"/>
      <path d="M16 21 C22 21 22 33 28 33 H36" stroke="{s}"/>
      <circle cx="5" cy="21" r="2.5" fill="{a}" stroke="none"/>
      <circle cx="37" cy="9" r="2.5" fill="{a}" stroke="none"/>
      <circle cx="37" cy="33" r="2.5" fill="{s}" stroke="none"/>
    </g>"""


def icon_proof(p, x, y):
    a, s = p["accent"], p["stroke2"]
    return f"""<g transform="translate({x},{y})" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"{fx(p)}>
      <path d="M21 4 L35 10 V22 C35 30 28 36 21 39 C14 36 7 30 7 22 V10 Z" stroke="{s}"/>
      <path d="M15 21 L19.5 25.5 L28 16" stroke="{a}"/>
    </g>"""


def icon_hub(p, x, y):
    a, s = p["accent"], p["stroke2"]
    spokes = ""
    for i in range(6):
        ang = math.radians(i * 60 - 90)
        x1, y1 = 21 + 8 * math.cos(ang), 21 + 8 * math.sin(ang)
        x2, y2 = 21 + 15 * math.cos(ang), 21 + 15 * math.sin(ang)
        cx, cy = 21 + 18 * math.cos(ang), 21 + 18 * math.sin(ang)
        spokes += f'<path d="M{x1:.1f} {y1:.1f} L{x2:.1f} {y2:.1f}" stroke="{s}"/>'
        spokes += f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="2.6" fill="{a}" stroke="none"/>'
    return f"""<g transform="translate({x},{y})" fill="none" stroke-width="2" stroke-linecap="round"{fx(p)}>
      {spokes}
      <circle cx="21" cy="21" r="6.5" stroke="{a}"/>
    </g>"""


# ------------------------------------------------------------------ features
# Body lines are wrapped by hand: SVG has no automatic text flow, and the
# renderer cannot measure a font it may not have. Keep each line under about
# 42 characters so it fits the card.
CARDS = [
    (
        icon_memory,
        "It remembers",
        [
            "Decisions, bug fixes and context survive",
            "restarts. Your agent stops starting",
            "from zero every morning.",
        ],
    ),
    (
        icon_route,
        "It knows when to slow down",
        [
            "Small change? It just does it. Ambiguous",
            "feature? It plans first. Size alone never",
            "forces ceremony.",
        ],
    ),
    (
        icon_proof,
        "It proves its work",
        [
            "Optional review freezes your exact bytes",
            "and derives evidence independently.",
            "No more taking its word for it.",
        ],
    ),
    (
        icon_hub,
        "It speaks your agent's language",
        [
            "16 runtimes, each configured through its",
            "own native features — not a lowest-",
            "common-denominator wrapper.",
        ],
    ),
]


def features(p):
    W, PAD, GAP, CH = 1200, 16, 26, 246
    CW = (W - 2 * PAD - GAP) / 2
    H = 2 * CH + GAP + 2 * PAD
    label = "What Gentle-AI gives your agent"
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="{label}">',
        defs(p),
        f'<rect width="{W}" height="{H}" fill="{p["bg"]}"/>',
    ]
    for i, (icon, title, lines) in enumerate(CARDS):
        cx = PAD + (i % 2) * (CW + GAP)
        cy = PAD + (i // 2) * (CH + GAP)
        out.append(f'<g transform="translate({cx},{cy})">')
        out.append(
            f'<rect x="1" y="1" width="{CW - 2}" height="{CH - 2}" rx="18" '
            f'fill="url(#cardfill)" stroke="{p["stroke"]}" stroke-width="1.5"/>'
        )
        # An accent stroke along the top edge only, following the corner radius.
        out.append(
            f'<path d="M19 1 H{CW - 19} A18 18 0 0 1 {CW - 1} 19" fill="none" '
            f'stroke="{p["accent"]}" stroke-width="2.5" opacity="0.7" stroke-linecap="round"/>'
        )
        out.append(
            f'<path d="M1 19 A18 18 0 0 1 19 1" fill="none" '
            f'stroke="{p["accent"]}" stroke-width="2.5" opacity="0.7" stroke-linecap="round"/>'
        )
        out.append(icon(p, 42, 44))
        out.append(
            f'<text x="104" y="74" font-family="{FONT}" font-size="26" font-weight="700" '
            f'fill="{p["title"]}"{fx(p, soft=True)}>{title}</text>'
        )
        for j, line in enumerate(lines):
            out.append(
                f'<text x="44" y="{134 + j * 29}" font-family="{FONT}" '
                f'font-size="17.5" fill="{p["body"]}">{line}</text>'
            )
        out.append("</g>")
    out.append("</svg>")
    return "\n".join(out)


# -------------------------------------------------------------------- agents
# Keep these in step with docs/agents.md, and with the agent count quoted in
# the fourth feature card above and in the README badge.
FULL = [
    "Claude Code",
    "OpenCode",
    "Cursor",
    "Codex",
    "Gemini CLI",
    "VS Code Copilot",
    "Kilo Code",
    "Kimi Code",
    "Kiro IDE",
    "Qwen Code",
    "Antigravity",
    "Pi",
    "Hermes",
]
SOLO = ["Windsurf", "OpenClaw", "Trae"]


def pill_rows(names, max_w, fs=17, pad=22, gap=12):
    """Greedily wrap names into rows, estimating text width from glyph count."""
    rows, cur, cw = [], [], 0
    for n in names:
        w = int(len(n) * fs * 0.56) + pad * 2
        if cur and cw + gap + w > max_w:
            rows.append((cur, cw))
            cur, cw = [], 0
        cur.append((n, w))
        cw += w + (gap if cur[:-1] else 0)
    if cur:
        rows.append((cur, cw))
    return rows


def agents(p):
    W, MAXW, PAD = 1200, 1090, 26
    fs, ph, gap = 17, 42, 12
    rows_full = pill_rows(FULL, MAXW, fs)
    rows_solo = pill_rows(SOLO, MAXW, fs)
    body, y = [], PAD + 18

    def block(y, label, sub, rows, dim=False):
        acc = p["stroke2"] if dim else p["accent"]
        o = [
            f'<text x="{W / 2}" y="{y}" text-anchor="middle" font-family="{MONO}" '
            f'font-size="13" letter-spacing="3.2" font-weight="700" fill="{acc}"'
            f'{fx(p, soft=True)}>{label}</text>',
            f'<text x="{W / 2}" y="{y + 23}" text-anchor="middle" font-family="{FONT}" '
            f'font-size="14" fill="{p["muted"]}">{sub}</text>',
        ]
        yy = y + 46
        for cells, cw in rows:
            x = (W - cw) / 2
            for n, w in cells:
                o.append(
                    f'<rect x="{x:.1f}" y="{yy}" width="{w}" height="{ph}" rx="{ph / 2}" '
                    f'fill="{p["card"]}" stroke="{p["stroke"]}" stroke-width="1.5"/>'
                )
                o.append(
                    f'<circle cx="{x + 17:.1f}" cy="{yy + ph / 2}" r="3" fill="{acc}"'
                    f'{fx(p, soft=True)}/>'
                )
                # Nudged right of centre to balance the leading dot.
                o.append(
                    f'<text x="{x + w / 2 + 8:.1f}" y="{yy + ph / 2 + 6}" text-anchor="middle" '
                    f'font-family="{FONT}" font-size="{fs}" fill="{p["title"]}">{n}</text>'
                )
                x += w + gap
            yy += ph + 13
        return o, yy

    o, y = block(y, "FULL DELEGATION", "hands work to focused sub-agents", rows_full)
    body += o
    body.append(f'<rect x="{W / 2 - 260}" y="{y + 12}" width="520" height="1.5" fill="url(#rule)"/>')
    o, y = block(y + 58, "SOLO-AGENT", "runs everything in one conversation", rows_solo, dim=True)
    body += o

    # Derive the canvas height from the laid-out content, never from a formula:
    # a wrong guess silently clips the last row.
    H = int(y - 13 + PAD)
    label = "Supported AI coding agents"
    head = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="img" aria-label="{label}">',
        defs(p),
        f'<rect width="{W}" height="{H}" fill="{p["bg"]}"/>',
    ]
    return "\n".join(head + body + ["</svg>"])


# ------------------------------------------------------------------- divider
def divider(p):
    W, H = 1200, 28
    return f"""<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}" role="presentation">
{defs(p)}
  <rect x="0" y="{H / 2 - 0.75}" width="{W}" height="1.5" fill="url(#rule)"/>
  <g{fx(p, soft=True)}>
    <circle cx="{W / 2}" cy="{H / 2}" r="4.5" fill="{p['accent']}"/>
    <circle cx="{W / 2 - 34}" cy="{H / 2}" r="2" fill="{p['accent']}" opacity="0.6"/>
    <circle cx="{W / 2 + 34}" cy="{H / 2}" r="2" fill="{p['accent']}" opacity="0.6"/>
  </g>
</svg>"""


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for palette in (DARK, LIGHT):
        variant = palette["name"]
        for name, render in (("features", features), ("agents", agents), ("divider", divider)):
            path = OUT / f"{name}-{variant}.svg"
            path.write_text(render(palette))
            print(f"wrote {path.relative_to(OUT.parent.parent.parent)}")


if __name__ == "__main__":
    main()
