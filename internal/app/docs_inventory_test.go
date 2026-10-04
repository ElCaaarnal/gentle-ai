package app_test

import (
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"testing"
)

// componentPackages returns the directories under internal/components that
// contain Go files, i.e. the component packages.
func componentPackages(t *testing.T) map[string]bool {
	t.Helper()
	root := filepath.Join("..", "components")
	entries, err := os.ReadDir(root)
	if err != nil {
		t.Fatalf("read %s: %v", root, err)
	}
	packages := map[string]bool{}
	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}
		goFiles, err := filepath.Glob(filepath.Join(root, entry.Name(), "*.go"))
		if err != nil {
			t.Fatal(err)
		}
		if len(goFiles) > 0 {
			packages[entry.Name()] = true
		}
	}
	return packages
}

// architectureComponentTree returns the packages listed under `  components/`
// in the docs/architecture.md tree: the leading `name/` fields of each deeper
// indented line, stopping at the next sibling of components/.
func architectureComponentTree(t *testing.T, content string) []string {
	t.Helper()
	dirField := regexp.MustCompile(`^[a-z][a-z0-9]*/$`)
	var names []string
	inTree := false
	for _, line := range strings.Split(content, "\n") {
		if !inTree {
			inTree = strings.HasPrefix(line, "  components/")
			continue
		}
		if !strings.HasPrefix(line, "    ") {
			break
		}
		for _, field := range strings.Fields(line) {
			if !dirField.MatchString(field) {
				break
			}
			names = append(names, strings.TrimSuffix(field, "/"))
		}
	}
	if !inTree {
		t.Fatal("docs/architecture.md: `  components/` tree entry not found")
	}
	return names
}

func diffPackages(listed []string, actual map[string]bool, checkMissing bool) (missing, invented []string) {
	seen := map[string]bool{}
	for _, name := range listed {
		seen[name] = true
		if !actual[name] {
			invented = append(invented, name)
		}
	}
	if checkMissing {
		for name := range actual {
			if !seen[name] {
				missing = append(missing, name)
			}
		}
	}
	sort.Strings(missing)
	sort.Strings(invented)
	return missing, invented
}

func TestComponentTreesMatchPackages(t *testing.T) {
	actual := componentPackages(t)

	read := func(name string) string {
		content, err := os.ReadFile(filepath.Join("..", "..", name))
		if err != nil {
			t.Fatalf("read %s: %v", name, err)
		}
		return string(content)
	}

	// docs/architecture.md carries the full package tree: compare 1:1.
	missing, invented := diffPackages(architectureComponentTree(t, read("docs/architecture.md")), actual, true)
	if len(missing) > 0 || len(invented) > 0 {
		t.Errorf("docs/architecture.md components tree drifted from internal/components\nmissing: %v\ninvented: %v", missing, invented)
	}

	// docs/codebase/repository-map.md is an ownership table that names only
	// selected component packages, so every package it names must exist.
	pathRef := regexp.MustCompile("`internal/components/([^/`]+)/")
	var referenced []string
	for _, match := range pathRef.FindAllStringSubmatch(read("docs/codebase/repository-map.md"), -1) {
		referenced = append(referenced, match[1])
	}
	if _, invented := diffPackages(referenced, actual, false); len(invented) > 0 {
		t.Errorf("docs/codebase/repository-map.md names packages missing from internal/components\ninvented: %v", invented)
	}
}

func TestArchitectureComponentTreeParsesOnlyComponents(t *testing.T) {
	content := "internal/\n  catalog/                 Registry (agents, skills/)\n  components/              Per-component logic\n" +
		"    engram/  skills/\n    filemerge/             Marker-based install/inject merging\n  skillregistry/           Refresh\n    nested/\n"
	listed := architectureComponentTree(t, content)
	if got := strings.Join(listed, ","); got != "engram,skills,filemerge" {
		t.Fatalf("architectureComponentTree = %q, want %q", got, "engram,skills,filemerge")
	}
	missing, invented := diffPackages(listed, map[string]bool{"engram": true, "skills": true, "uninstall": true}, true)
	if strings.Join(missing, ",") != "uninstall" || strings.Join(invented, ",") != "filemerge" {
		t.Fatalf("diffPackages missing=%v invented=%v, want [uninstall] [filemerge]", missing, invented)
	}
}
