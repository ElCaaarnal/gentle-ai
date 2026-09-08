# Gentle-AI README hero recording.
#
# Regenerate with:
#   vhs docs/assets/brand/tui-demo.tape
#
# SAFETY: the run is sandboxed to a throwaway HOME (/tmp/gentle-ai-demo), set
# inside a Hide block so it never appears on screen. The install executes for
# real — that is where the motion comes from — but writes only inside that
# directory. Nothing touches the operator's own agent configs.
#
# ROBUSTNESS: every screen is entered through `Wait+Screen`, not a guessed
# Sleep. If a screen does not appear, the render fails loudly instead of
# silently drifting one screen out of sync.
#
# FRAMING: the frame is sized for the ~26-row screens (agent picker, install
# plan, summary). System Detection is taller and passes by clipped on purpose;
# sizing for it would leave every other screen mostly empty.
#
# DETERMINISM: the sandbox is seeded with a single ~/.claude directory, so
# detection reports exactly one configured agent and the picker pre-selects
# only Claude Code (preselectedAgents -> agentsToManage, internal/tui/model.go).
# That pins the optional picker chain to exactly: Claude models -> Strict TDD
# -> Community Tools. Note there is no SDD Mode screen here: it is gated on the
# OpenCode agent (shouldShowSDDModeScreen, model.go:4878). Seeding a second
# agent directory would insert extra screens (Codex/Kiro pickers, SDD mode,
# OpenCode plugins) and desynchronise every step below.

Output docs/assets/brand/tui-demo.gif

Require gentle-ai

Set Shell "bash"
Set FontSize 22
Set Width 1280
Set Height 760
Set Padding 20
Set Margin 20
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 40ms
Set WaitTimeout 30s

# --- Sandbox, never shown ---------------------------------------------------
Hide
Type "export HOME=/tmp/gentle-ai-demo; rm -rf /tmp/gentle-ai-demo; mkdir -p /tmp/gentle-ai-demo/.claude; cd /tmp/gentle-ai-demo; clear"
Enter
Sleep 1s
Show

# --- Launch -----------------------------------------------------------------
Type "gentle-ai"
Sleep 300ms
Enter

Wait+Screen /Start installation/
Sleep 1200ms
Enter

# --- System Detection: "Continue" is row 0 ----------------------------------
# This screen is ~40 rows (OS, tools, dependencies, 16 agent configs) and does
# not fit the frame, so its title scrolls off the top. Anchor the wait to the
# last config row, which stays visible above the actions. It reads as a fast
# system scan rather than a list anyone is meant to finish reading.
Wait+Screen /hermes/
Sleep 700ms
Enter

# --- Select AI Agents: Claude Code arrives pre-checked ----------------------
# Do NOT press Space here. agentsToManage (model.go:4749) falls back to the
# whole catalogue when no agent config is detected, so on a bare HOME all
# sixteen rows arrive checked and a Space on row 0 would UNCHECK Claude Code —
# which silently drops the Claude model picker from the chain below. The seeded
# .claude directory is what pins the selection to exactly one agent.
#
# Reach "Continue" with two wrap-around Ups (model.go:1773, issue #150) rather
# than sixteen Downs.
Wait+Screen /Select AI Agents/
Sleep 1200ms
Up
Sleep 250ms
Up
Sleep 500ms
Enter

# --- Choose your Persona: gentleman is row 0 --------------------------------
Wait+Screen /Choose your Persona/
Sleep 900ms
Enter

# --- Select Ecosystem Preset: "Dev Stack + Polish" is row 0 -----------------
Wait+Screen /Select Ecosystem Preset/
Sleep 1s
Enter

# --- Claude Model Assignments: "Balanced" is row 0 --------------------------
Wait+Screen /Claude Model Assignments/
Sleep 900ms
Enter

# --- Strict TDD Mode: "Enable" is row 0 -------------------------------------
Wait+Screen /STRICT TDD MODE/
Sleep 800ms
Enter

# --- Community Tools: one tool renders 2 rows, "Continue" is row 2 ----------
Wait+Screen /Community Tools/
Sleep 700ms
Down 2
Sleep 400ms
Enter

# --- Install Plan: "Continue" is row 0 --------------------------------------
# Anchored to the section header, not the "Install Plan" title: the component
# list pushes the title off the top of the frame. Same reason the waits below
# use bottom-of-screen help text instead of titles.
Wait+Screen /Components to install/
Sleep 1400ms
Enter

# --- Review and Confirm: "Install" is row 0 ---------------------------------
Wait+Screen /enter: install/
Sleep 1600ms
Enter

# --- The payoff: progress running, then the summary landing -----------------
# No wait on the "Installing" title (it clips once the log panel grows). Let the
# progress run on camera, then sync on the summary, which is what the whole
# recording is building towards. Generous timeout: this is a real install.
Sleep 3s

# The install runs for real here: 15 steps, each landing in the log panel. That
# footage is the point of the recording, so let it play. The Installing screen
# then parks on a prompt and needs one Enter to hand over to the summary.
Wait+Screen@180s /Press Enter to continue/
Sleep 2s
Enter

Wait+Screen /Configured agents/
Sleep 4s
