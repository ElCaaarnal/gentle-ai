// Command brandassets generates the README brand SVG assets.
//
// It writes six files into docs/assets/brand/, a dark and a light variant of
// each:
//
//	features-{dark,light}.svg   the four value-proposition cards
//	agents-{dark,light}.svg     the supported agents, as pills in two tiers
//	divider-{dark,light}.svg    the section rule
//
// The README serves them through <picture> with prefers-color-scheme, so both
// variants of a pair must keep the same dimensions.
//
// Usage, from the repository root:
//
//	go run ./internal/brandassets
//
// It is not part of the build or of CI. Run it after editing the copy or the
// supported-agent lists below, then commit the regenerated SVGs. TestAssets in
// this package fails when the committed files drift from what it produces.
//
// Two rules worth keeping:
//
//  1. Colours come from the "Gentleman Cute" theme in
//     internal/components/theme/inject.go. Never sample them from the raster
//     banner: the banner's glow reads as a far more saturated pink than the
//     brand's actual accent.
//
//  2. Always rasterise and look at the result before committing. Clipped
//     borders and miscomputed canvas heights are invisible in the XML:
//
//     brew install resvg
//     resvg docs/assets/brand/features-dark.svg /tmp/check.png
package main

import (
	"fmt"
	"math"
	"os"
	"path/filepath"
	"strconv"
	"strings"
)

// palette holds one colour scheme. The dark variant quotes the theme tokens
// directly; the light variant is derived, because the repository defines no
// light theme.
type palette struct {
	name    string
	bg      string // backgroundPanel
	card    string // backgroundElement
	stroke  string // border
	stroke2 string // secondary
	accent  string // primary / accent
	title   string // text
	body    string // textMuted
	muted   string // subtle
	glow    bool
}

var dark = palette{
	name:    "dark",
	bg:      "#1A1218",
	card:    "#241822",
	stroke:  "#342230",
	stroke2: "#D7A0B8",
	accent:  "#F095C8",
	title:   "#F6EFF3",
	body:    "#A78E9B",
	muted:   "#76616B",
	glow:    true,
}

// The same hue family, darkened for contrast on white.
var light = palette{
	name:    "light",
	bg:      "#FFFFFF",
	card:    "#FCF5F9",
	stroke:  "#EBD5E2",
	stroke2: "#C97FA6",
	accent:  "#B93A78",
	title:   "#1A1218",
	body:    "#6B5460",
	muted:   "#96808C",
	glow:    false,
}

// GitHub renders these through <img>, which cannot load web fonts. Both stacks
// must resolve to something present on macOS, Linux and Windows.
const (
	fontStack = "-apple-system,BlinkMacSystemFont,'Segoe UI',Helvetica,Arial,sans-serif"
	monoStack = "'SF Mono',SFMono-Regular,Menlo,Consolas,'Liberation Mono',monospace"
)

// num formats a coordinate without a trailing ".0", so the markup carries
// "570" rather than "570.0".
func num(v float64) string {
	return strconv.FormatFloat(v, 'f', -1, 64)
}

// num1 formats a coordinate to a single decimal place.
func num1(v float64) string {
	return strconv.FormatFloat(math.Round(v*10)/10, 'f', -1, 64)
}

func defs(p palette) string {
	glow := ""
	if p.glow {
		glow = `
    <filter id="glow" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="3.2" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
    <filter id="softglow" x="-60%" y="-60%" width="220%" height="220%">
      <feGaussianBlur stdDeviation="1.4" result="b"/>
      <feMerge><feMergeNode in="b"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>`
	}
	return fmt.Sprintf(`  <defs>
    <linearGradient id="rule" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%%" stop-color="%[1]s" stop-opacity="0"/>
      <stop offset="50%%" stop-color="%[1]s" stop-opacity="1"/>
      <stop offset="100%%" stop-color="%[1]s" stop-opacity="0"/>
    </linearGradient>
    <linearGradient id="cardfill" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%%" stop-color="%[2]s"/>
      <stop offset="100%%" stop-color="%[3]s"/>
    </linearGradient>%[4]s
  </defs>`, p.accent, p.card, p.bg, glow)
}

// fx returns the glow filter attribute, or nothing on the light variant.
func fx(p palette, soft bool) string {
	if !p.glow {
		return ""
	}
	if soft {
		return ` filter="url(#softglow)"`
	}
	return ` filter="url(#glow)"`
}

// ---------------------------------------------------------------------- icons
// Each icon draws into a 42x42 box at (x, y).

type iconFunc func(p palette, x, y float64) string

func iconMemory(p palette, x, y float64) string {
	return fmt.Sprintf(`<g transform="translate(%s,%s)" fill="none" stroke-width="2" stroke-linecap="round"%s>
      <path d="M9 21 L29 11 M9 21 L29 31" stroke="%s"/>
      <circle cx="9" cy="21" r="5" stroke="%[5]s"/>
      <circle cx="30" cy="10" r="4" stroke="%[5]s"/>
      <circle cx="30" cy="32" r="4" stroke="%[5]s"/>
    </g>`, num(x), num(y), fx(p, false), p.stroke2, p.accent)
}

func iconRoute(p palette, x, y float64) string {
	return fmt.Sprintf(`<g transform="translate(%s,%s)" fill="none" stroke-width="2" stroke-linecap="round"%s>
      <path d="M5 21 H16 C22 21 22 9 28 9 H36" stroke="%[4]s"/>
      <path d="M16 21 C22 21 22 33 28 33 H36" stroke="%[5]s"/>
      <circle cx="5" cy="21" r="2.5" fill="%[4]s" stroke="none"/>
      <circle cx="37" cy="9" r="2.5" fill="%[4]s" stroke="none"/>
      <circle cx="37" cy="33" r="2.5" fill="%[5]s" stroke="none"/>
    </g>`, num(x), num(y), fx(p, false), p.accent, p.stroke2)
}

func iconProof(p palette, x, y float64) string {
	return fmt.Sprintf(`<g transform="translate(%s,%s)" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"%s>
      <path d="M21 4 L35 10 V22 C35 30 28 36 21 39 C14 36 7 30 7 22 V10 Z" stroke="%s"/>
      <path d="M15 21 L19.5 25.5 L28 16" stroke="%s"/>
    </g>`, num(x), num(y), fx(p, false), p.stroke2, p.accent)
}

func iconHub(p palette, x, y float64) string {
	var spokes strings.Builder
	for i := 0; i < 6; i++ {
		ang := float64(i)*60 - 90
		rad := ang * math.Pi / 180
		x1, y1 := 21+8*math.Cos(rad), 21+8*math.Sin(rad)
		x2, y2 := 21+15*math.Cos(rad), 21+15*math.Sin(rad)
		cx, cy := 21+18*math.Cos(rad), 21+18*math.Sin(rad)
		fmt.Fprintf(&spokes, `<path d="M%s %s L%s %s" stroke="%s"/>`,
			num1(x1), num1(y1), num1(x2), num1(y2), p.stroke2)
		fmt.Fprintf(&spokes, `<circle cx="%s" cy="%s" r="2.6" fill="%s" stroke="none"/>`,
			num1(cx), num1(cy), p.accent)
	}
	return fmt.Sprintf(`<g transform="translate(%s,%s)" fill="none" stroke-width="2" stroke-linecap="round"%s>
      %s
      <circle cx="21" cy="21" r="6.5" stroke="%s"/>
    </g>`, num(x), num(y), fx(p, false), spokes.String(), p.accent)
}

// ------------------------------------------------------------------- features

// card is one value-proposition tile. Body lines are wrapped by hand: SVG has
// no automatic text flow, and the renderer cannot measure a font it may not
// have. Keep each line under about 42 characters so it fits the card.
type card struct {
	icon  iconFunc
	title string
	lines []string
}

var cards = []card{
	{iconMemory, "It remembers", []string{
		"Decisions, bug fixes and context survive",
		"restarts. Your agent stops starting",
		"from zero every morning.",
	}},
	{iconRoute, "It knows when to slow down", []string{
		"Small change? It just does it. Ambiguous",
		"feature? It plans first. Size alone never",
		"forces ceremony.",
	}},
	{iconProof, "It proves its work", []string{
		"Optional review freezes your exact bytes",
		"and derives evidence independently.",
		"No more taking its word for it.",
	}},
	{iconHub, "It speaks your agent's language", []string{
		"16 runtimes, each configured through its",
		"own native features — not a lowest-",
		"common-denominator wrapper.",
	}},
}

func features(p palette) string {
	const (
		width      = 1200.0
		pad        = 16.0
		gap        = 26.0
		cardHeight = 246.0
	)
	cardWidth := (width - 2*pad - gap) / 2
	height := 2*cardHeight + gap + 2*pad

	var b strings.Builder
	fmt.Fprintf(&b, `<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %[1]s %[2]s" role="img" aria-label="What Gentle-AI gives your agent">`+"\n",
		num(width), num(height))
	b.WriteString(defs(p) + "\n")
	fmt.Fprintf(&b, `<rect width="%s" height="%s" fill="%s"/>`+"\n", num(width), num(height), p.bg)

	for i, c := range cards {
		x := pad + float64(i%2)*(cardWidth+gap)
		y := pad + float64(i/2)*(cardHeight+gap)
		fmt.Fprintf(&b, `<g transform="translate(%s,%s)">`+"\n", num(x), num(y))
		fmt.Fprintf(&b, `<rect x="1" y="1" width="%s" height="%s" rx="18" fill="url(#cardfill)" stroke="%s" stroke-width="1.5"/>`+"\n",
			num(cardWidth-2), num(cardHeight-2), p.stroke)
		// An accent stroke along the top edge only, following the corner radius.
		fmt.Fprintf(&b, `<path d="M19 1 H%s A18 18 0 0 1 %s 19" fill="none" stroke="%s" stroke-width="2.5" opacity="0.7" stroke-linecap="round"/>`+"\n",
			num(cardWidth-19), num(cardWidth-1), p.accent)
		fmt.Fprintf(&b, `<path d="M1 19 A18 18 0 0 1 19 1" fill="none" stroke="%s" stroke-width="2.5" opacity="0.7" stroke-linecap="round"/>`+"\n", p.accent)
		b.WriteString(c.icon(p, 42, 44) + "\n")
		fmt.Fprintf(&b, `<text x="104" y="74" font-family="%s" font-size="26" font-weight="700" fill="%s"%s>%s</text>`+"\n",
			fontStack, p.title, fx(p, true), c.title)
		for j, line := range c.lines {
			fmt.Fprintf(&b, `<text x="44" y="%s" font-family="%s" font-size="17.5" fill="%s">%s</text>`+"\n",
				num(134+float64(j)*29), fontStack, p.body, line)
		}
		b.WriteString("</g>\n")
	}
	b.WriteString("</svg>")
	return b.String()
}

// --------------------------------------------------------------------- agents
// Keep these in step with docs/agents.md, and with the agent count quoted in
// the fourth feature card above and in the README badge.

var fullDelegation = []string{
	"Claude Code", "OpenCode", "Cursor", "Codex", "Gemini CLI", "VS Code Copilot",
	"Kilo Code", "Kimi Code", "Kiro IDE", "Qwen Code", "Antigravity", "Pi", "Hermes",
}

var soloAgent = []string{"Windsurf", "OpenClaw", "Trae"}

type pill struct {
	name  string
	width float64
}

type pillRow struct {
	cells []pill
	width float64
}

// pillRows greedily wraps names into rows, estimating text width from glyph
// count because the generator cannot measure the reader's font.
func pillRows(names []string, maxWidth, fontSize float64) []pillRow {
	const (
		padX = 22.0
		gap  = 12.0
	)
	var rows []pillRow
	var cur []pill
	var curWidth float64
	for _, n := range names {
		w := math.Trunc(float64(len(n))*fontSize*0.56) + padX*2
		if len(cur) > 0 && curWidth+gap+w > maxWidth {
			rows = append(rows, pillRow{cells: cur, width: curWidth})
			cur, curWidth = nil, 0
		}
		if len(cur) > 0 {
			curWidth += gap
		}
		cur = append(cur, pill{name: n, width: w})
		curWidth += w
	}
	if len(cur) > 0 {
		rows = append(rows, pillRow{cells: cur, width: curWidth})
	}
	return rows
}

func agents(p palette) string {
	const (
		width      = 1200.0
		maxWidth   = 1090.0
		pad        = 26.0
		fontSize   = 17.0
		pillHeight = 42.0
		gap        = 12.0
	)
	rowsFull := pillRows(fullDelegation, maxWidth, fontSize)
	rowsSolo := pillRows(soloAgent, maxWidth, fontSize)

	var body strings.Builder
	block := func(y float64, label, sub string, rows []pillRow, dim bool) float64 {
		accent := p.accent
		if dim {
			accent = p.stroke2
		}
		fmt.Fprintf(&body, `<text x="%s" y="%s" text-anchor="middle" font-family="%s" font-size="13" letter-spacing="3.2" font-weight="700" fill="%s"%s>%s</text>`+"\n",
			num(width/2), num(y), monoStack, accent, fx(p, true), label)
		fmt.Fprintf(&body, `<text x="%s" y="%s" text-anchor="middle" font-family="%s" font-size="14" fill="%s">%s</text>`+"\n",
			num(width/2), num(y+23), fontStack, p.muted, sub)

		rowY := y + 46
		for _, row := range rows {
			x := (width - row.width) / 2
			for _, cell := range row.cells {
				fmt.Fprintf(&body, `<rect x="%s" y="%s" width="%s" height="%s" rx="%s" fill="%s" stroke="%s" stroke-width="1.5"/>`+"\n",
					num1(x), num(rowY), num(cell.width), num(pillHeight), num(pillHeight/2), p.card, p.stroke)
				fmt.Fprintf(&body, `<circle cx="%s" cy="%s" r="3" fill="%s"%s/>`+"\n",
					num1(x+17), num(rowY+pillHeight/2), accent, fx(p, true))
				// Nudged right of centre to balance the leading dot.
				fmt.Fprintf(&body, `<text x="%s" y="%s" text-anchor="middle" font-family="%s" font-size="%s" fill="%s">%s</text>`+"\n",
					num1(x+cell.width/2+8), num(rowY+pillHeight/2+6), fontStack, num(fontSize), p.title, cell.name)
				x += cell.width + gap
			}
			rowY += pillHeight + 13
		}
		return rowY
	}

	y := block(pad+18, "FULL DELEGATION", "hands work to focused sub-agents", rowsFull, false)
	fmt.Fprintf(&body, `<rect x="%s" y="%s" width="520" height="1.5" fill="url(#rule)"/>`+"\n",
		num(width/2-260), num(y+12))
	y = block(y+58, "SOLO-AGENT", "runs everything in one conversation", rowsSolo, true)

	// Derive the canvas height from the laid-out content, never from a formula:
	// a wrong guess silently clips the last row.
	height := math.Trunc(y - 13 + pad)

	var b strings.Builder
	fmt.Fprintf(&b, `<svg xmlns="http://www.w3.org/2000/svg" width="%s" height="%s" viewBox="0 0 %[1]s %[2]s" role="img" aria-label="Supported AI coding agents">`+"\n",
		num(width), num(height))
	b.WriteString(defs(p) + "\n")
	fmt.Fprintf(&b, `<rect width="%s" height="%s" fill="%s"/>`+"\n", num(width), num(height), p.bg)
	b.WriteString(body.String())
	b.WriteString("</svg>")
	return b.String()
}

// -------------------------------------------------------------------- divider

func divider(p palette) string {
	const (
		width  = 1200.0
		height = 28.0
	)
	return fmt.Sprintf(`<svg xmlns="http://www.w3.org/2000/svg" width="%[1]s" height="%[2]s" viewBox="0 0 %[1]s %[2]s" role="presentation">
%[3]s
  <rect x="0" y="%[4]s" width="%[1]s" height="1.5" fill="url(#rule)"/>
  <g%[5]s>
    <circle cx="%[6]s" cy="%[7]s" r="4.5" fill="%[8]s"/>
    <circle cx="%[9]s" cy="%[7]s" r="2" fill="%[8]s" opacity="0.6"/>
    <circle cx="%[10]s" cy="%[7]s" r="2" fill="%[8]s" opacity="0.6"/>
  </g>
</svg>`,
		num(width), num(height), defs(p), num(height/2-0.75), fx(p, true),
		num(width/2), num(height/2), p.accent, num(width/2-34), num(width/2+34))
}

// ----------------------------------------------------------------------- main

// assets returns every file the generator owns, keyed by base name.
func assets() map[string]string {
	out := make(map[string]string, 6)
	for _, p := range []palette{dark, light} {
		out["features-"+p.name+".svg"] = features(p)
		out["agents-"+p.name+".svg"] = agents(p)
		out["divider-"+p.name+".svg"] = divider(p)
	}
	return out
}

func main() {
	if err := run("docs/assets/brand"); err != nil {
		fmt.Fprintln(os.Stderr, "brandassets:", err)
		os.Exit(1)
	}
}

func run(dir string) error {
	if err := os.MkdirAll(dir, 0o755); err != nil {
		return err
	}
	for name, content := range assets() {
		path := filepath.Join(dir, name)
		if err := os.WriteFile(path, []byte(content), 0o644); err != nil {
			return err
		}
		fmt.Println("wrote", path)
	}
	return nil
}
