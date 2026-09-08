package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

const committedDir = "../../docs/assets/brand"

// TestCommittedAssetsMatchGenerator fails when a committed SVG drifts from what
// the generator produces, which happens when someone edits the markup by hand
// instead of editing this package and regenerating.
func TestCommittedAssetsMatchGenerator(t *testing.T) {
	for name, want := range assets() {
		t.Run(name, func(t *testing.T) {
			got, err := os.ReadFile(filepath.Join(committedDir, name))
			if err != nil {
				t.Fatalf("read committed asset: %v", err)
			}
			if string(got) != want {
				t.Errorf("%s is stale; run `go run ./internal/brandassets` and commit the result", name)
			}
		})
	}
}

// TestAssetPairsShareDimensions guards the <picture> contract in the README:
// the reader's colour scheme selects between the two variants, so a pair whose
// canvases differ would reflow the page when the scheme changes.
func TestAssetPairsShareDimensions(t *testing.T) {
	generated := assets()
	for _, base := range []string{"features", "agents", "divider"} {
		t.Run(base, func(t *testing.T) {
			darkHead := headerOf(t, generated[base+"-dark.svg"])
			lightHead := headerOf(t, generated[base+"-light.svg"])
			if darkHead != lightHead {
				t.Errorf("variant canvases differ:\n dark: %s\nlight: %s", darkHead, lightHead)
			}
		})
	}
}

// headerOf extracts the width/height/viewBox attributes from the opening tag.
func headerOf(t *testing.T, svg string) string {
	t.Helper()
	end := strings.IndexByte(svg, '>')
	if end < 0 {
		t.Fatal("asset has no opening tag")
	}
	open := svg[:end]
	var parts []string
	for _, attr := range []string{`width="`, `height="`, `viewBox="`} {
		i := strings.Index(open, attr)
		if i < 0 {
			t.Fatalf("opening tag is missing %s", attr)
		}
		rest := open[i+len(attr):]
		parts = append(parts, attr+rest[:strings.IndexByte(rest, '"')])
	}
	return strings.Join(parts, " ")
}

// TestAgentCountMatchesFeatureCopy keeps the number quoted in the feature card
// honest: the copy claims a runtime count that the agent lists must support.
func TestAgentCountMatchesFeatureCopy(t *testing.T) {
	total := len(fullDelegation) + len(soloAgent)
	claim := strings.Contains(cards[3].lines[0], "16 runtimes")
	if total != 16 || !claim {
		t.Errorf("agent lists hold %d entries but the feature card claims 16; update both together", total)
	}
}

// TestRunWritesEveryAsset covers the write path against a scratch directory.
func TestRunWritesEveryAsset(t *testing.T) {
	dir := t.TempDir()
	if err := run(dir); err != nil {
		t.Fatalf("run: %v", err)
	}
	for name := range assets() {
		if _, err := os.Stat(filepath.Join(dir, name)); err != nil {
			t.Errorf("run did not write %s: %v", name, err)
		}
	}
}
