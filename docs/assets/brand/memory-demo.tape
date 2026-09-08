# Gentle-AI README memory proof.
#
# Regenerate with:
#   vhs docs/assets/brand/memory-demo.tape
#
# WHAT THIS PROVES: the headline claim. An agent is told a decision, that
# session ends, and a brand new session with an empty context answers a
# question about it correctly. `claude -p` starts a fresh session per
# invocation, so the second call genuinely carries no conversation history —
# the only channel between the two is Engram.
#
# SELF-VERIFYING, AND THE SCREEN CLEAR IS LOad-BEARING: the second wait matches
# /Postgres/, which after the clear can only have come from the model's answer.
# If memory were not working the reply cannot contain it, the wait times out,
# and the render fails instead of quietly producing a recording that lies.
# Do not drop the clear and do not name the database in the second prompt: a
# Wait pattern that also appears in the typed command matches the echoed
# prompt immediately and every response gets typed over before it arrives.
#
# ISOLATION: ENGRAM_PROJECT pins every write to a throwaway demo project, kept
# away from real project memories, and the setup drops it before each take so
# the save on camera is the one being recalled.
#
# REQUIRES: an authenticated `claude` CLI. Unlike tui-demo.tape this cannot run
# against a sandboxed HOME, because it needs real agent credentials.

Output docs/assets/brand/memory-demo.gif

Require claude
Require engram

Set Shell "bash"
Set FontSize 22
Set Width 1280
Set Height 520
Set Padding 20
Set Margin 20
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 30ms
Set PlaybackSpeed 2.5

# --- Setup, never shown ------------------------------------------------------
Hide
Type "export ENGRAM_PROJECT=gentle-ai-readme-demo; export PS1='$ '; mkdir -p /tmp/gentle-ai-memory-demo; cd /tmp/gentle-ai-memory-demo"
Enter
Type "engram delete project gentle-ai-readme-demo --hard >/dev/null 2>&1; clear"
Enter
Sleep 1s
Show

# --- Session one: tell the agent something -----------------------------------
Type "claude -p 'We chose Postgres over MongoDB because we need multi-row transactions. Save that decision. Reply in one short line.'"
Sleep 400ms
Enter
# Time-based, not pattern-based: any confirmation word worth waiting for would
# also appear in the instruction above and match instantly. Measured ~12s; the
# margin covers a slower reply. The one-line reply instruction is not cosmetic:
# an unconstrained answer runs to eight lines and names the demo project key
# and observation id, which do not belong in a published recording.
Sleep 26s
Sleep 3s

# --- The beat that makes the point land --------------------------------------
# Wiping the screen is both the narrative break and the thing that makes the
# wait below trustworthy.
Hide
Type "clear"
Enter
Show
Type "# that session is over. new session, empty context, no history."
Enter
Sleep 2s

# --- Session two: it remembers -----------------------------------------------
Type "claude -p 'What database did we choose, and why? Answer in one short sentence.'"
Sleep 400ms
Enter
Wait+Screen@120s /Postgres/
Sleep 5s
