# Install

Gentle-AI configures the AI coding agent already installed on your machine. It never installs an agent for you — if it cannot detect the runtime you selected, it refuses and prints the exact command you would run yourself.

## Prerequisites

| Requirement | Why |
| --- | --- |
| **Node.js 18+ and npm** | Required by `gentle-ai install` on every platform. It warns if either is missing and prints a distro-specific hint — it does not install them for you. |
| **Git 2.38+** | Used for project detection and review scoping. |
| **Go 1.25.10+** | Required on Windows, and anywhere you install from source. |
| **Your AI agent** | Already installed and on your `PATH`. |

Per-distro hints: [Quickstart — Prerequisites](quickstart.md#prerequisites).

## Step 1 — Install the binary

**macOS / Linux**

```bash
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash
```

**Windows (PowerShell)**

```powershell
go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@latest
```

> [!WARNING]
> **On Windows, install from source — this is the supported path.** Windows is a fully tested platform and the complete suite runs on its CI lane, but official Windows binary distribution and Scoop are unavailable. Windows installation and upgrades require Go 1.25.10+ and fail closed to source-install guidance; they never download an unsigned Gentle AI executable or execute a remote update script.

**Expected result:** `gentle-ai version` prints a version number.

## Step 2 — Configure your agents

```bash
gentle-ai
```

Select your agent(s), your components (or a preset), and your persona.

**Expected result:** Gentle-AI writes config files into each selected agent's global config directory — system prompts, skills, SDD agents, persona files and MCP entries. Your previous configs are snapshotted first.

## Step 3 — Verify

```bash
gentle-ai doctor
```

**Expected result:** a read-only health report covering tool binaries, `state.json`, Engram reachability and disk space. It also classifies broken managed paths — dangling ancestor symlinks, config symlink loops and unreadable managed files. Nothing is modified. Run this any time something looks wrong.

**You are now ready to use your agent normally.**

## Keeping it up to date

Refresh the binary and its managed agent assets **together**:

```bash
gentle-ai upgrade
gentle-ai sync
```

> [!IMPORTANT]
> `sync` is not optional after an upgrade. If you replace the `gentle-ai` binary by any means, run `gentle-ai sync` to refresh the managed assets it writes into your agents. See the [sync and upgrade reference](usage.md#sync).

**What `sync` writes:**

- **Claude Code review hooks.** `Stop` and `SessionStart` entries are written into `~/.claude/settings.json` as managed entries. They remind the agent to preflight a review once per session candidate, and stay silent when review mode is off or the worktree is clean. `uninstall` removes them and preserves every hook it does not own.
- **Pi system prompt cleanup.** Stale managed blocks left by older builds are stripped from `~/.pi/agent/APPEND_SYSTEM.md`. The file is preserved; only the blocks Gentle-AI wrote are removed.
- **Only the agents you selected.** `sync` derives its agent set from the agents recorded at install time, not from what it finds on disk. If you relied on `sync` writing into an agent you never selected, run `gentle-ai` and select it first.

### Backups

Every install, sync and upgrade automatically snapshots your config files. Backups are **compressed** (tar.gz), **deduplicated** (identical configs are not re-backed up) and **auto-pruned** (the 5 most recent are kept). Pin important backups via the TUI (<kbd>p</kbd> key) to protect them from pruning.

Restoring a snapshot: [Backup & Rollback Guide](rollback.md).

## Installing to one project instead of globally

By default, `gentle-ai install` writes agent-scoped files to each selected agent's **global** config directory. To keep the Gentleman stack isolated to a single project:

```bash
gentle-ai install --scope=workspace
```

Workspace scope covers agent-scoped files — system prompts, skills, SDD agents and persona files. Global-only integrations remain global by design.

## Alternative install methods

**Homebrew (macOS / Linux)**

```bash
brew tap gentleman-programming/tap
brew trust --formula gentleman-programming/tap/gentle-ai  # one-time, if Homebrew requires trust
brew install gentle-ai
```

To install several tools from this tap, run `brew trust gentleman-programming/tap` instead. That broader option trusts all current and future formulas, casks and external commands published in the tap.

**Scoop (Windows)** — temporarily unavailable while official Windows binary distribution is held for public-trust Authenticode signing. Use the Windows `go install` command above.

**Beta channel (tracks `main`)** — requires Go 1.25.10+:

```bash
# macOS / Linux
curl -fsSL https://raw.githubusercontent.com/Gentleman-Programming/gentle-ai/main/scripts/install.sh | bash -s -- --channel beta

# Windows (PowerShell)
$env:GENTLE_AI_CHANNEL="beta"; go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@main
```

To update a beta installation later, preserve the channel — both installers default to stable:

```bash
# macOS / Linux
GENTLE_AI_CHANNEL=beta gentle-ai upgrade

# Windows (PowerShell)
$env:GENTLE_AI_CHANNEL="beta"; gentle-ai upgrade
```

If a manual `go install ...@main` does not pick up recent commits because `proxy.golang.org` is stale, bypass it:

```bash
GOPROXY=direct go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@main
# PowerShell
$env:GOPROXY="direct"; go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@main
```

## Release channels and version policy

There are two current channels. Install `@latest` unless you are deliberately testing unreleased development code.

| Channel | Current | Install |
| --- | --- | --- |
| **Stable** | [`v2.6.0`](https://github.com/Gentleman-Programming/gentle-ai/releases/tag/v2.6.0) | `go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@latest` |
| **Development** | `main` | `go install github.com/gentleman-programming/gentle-ai/v2/cmd/gentle-ai@main` |

Verify with `gentle-ai version` after any of them.

Use `@main` only to test changes that are not part of a release. The managed installer tracks a channel's latest version and does not accept an arbitrary release pin — use `go install` when you need an exact version.

**About the `/v2` suffix:** Go requires it for major version 2 and above. Releases before `v2.0.0` use the unsuffixed import path.

**Stable `v2.6.0` publishes six archives under a signed checksum manifest:** four platform `.tar.gz` archives for macOS and Linux (amd64 and arm64), the provider-contract archive, and the release-provenance archive. `checksums.txt` covers all six and is authenticated by `checksums.txt.minisig`.

Receipt-Driven Development became the supported stable path in `v2.2.0`; the negotiated public review contract was published in `v2.1.6`.

Signature verification: [Release signing and key rotation](release-signing.md).

## Uninstall

```bash
gentle-ai uninstall
```

Removes Gentle-AI managed files. Hooks and config entries it does not own are preserved. Full command surface: [Usage](usage.md).
