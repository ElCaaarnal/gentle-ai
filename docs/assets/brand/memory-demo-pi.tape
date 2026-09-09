# Gentle-AI README memory proof, recorded through Pi.
#
# Regenerate with:
#   vhs docs/assets/brand/memory-demo-pi.tape
#
# Same script as memory-demo.tape, different runtime, with one deliberate
# difference: the save is requested explicitly.
#
# memory-demo.tape closes its session with "Thanks, that sounds great. Let's
# continue in a new session." and OpenCode's orchestrator persists the session
# on its own. Pi does not: given that exact message it makes no engram call at
# all and replies "in the new session, mention the chosen stack" — asking the
# user to repeat themselves, which is the failure this project exists to
# remove. Until Pi honours the session-close protocol, this recording has to
# ask for the save in so many words. Do not read this tape as evidence that Pi
# persists automatically; it does not.
#
# WHY THE QUESTION IS WORDED THIS WAY: "where did we leave off" routes to
# mem_context, which reads session history. Do not reword it into a search-style
# question. Pi's model reliably passes match_mode="hybrid" to mem_search, which
# engram rejects with a ten-line schema dump on screen, and engram's search also
# defaults to requiring every query token to match. mem_context touches neither.
#
# PI'S BOOT IS NOT FILMED, and that is not a style choice. Pi draws its startup
# listing and the whole transcript as ONE frame; rows past the terminal's last
# row are clipped away, input box included, and nothing recovers them. Anchoring
# on the visible boot was tried at length and cannot work: the state it waits
# for never arrives. The boot therefore runs inside Hide on a fixed sleep (Pi
# starts in ~30s, measured), and every anchor after it waits on the
# conversation, which is the only thing this GIF is about.
#
# A side effect worth knowing: the dev-binary override warning no longer appears
# on camera, because the setup points GENTLE_PI_CONFIG_HOME at a scratch banner
# config. Whether that warning belongs in the README was the owner's call when
# the boot was visible; it is simply absent now.
#
# Wait+Screen does not resolve while output is hidden, so nothing inside a Hide
# block can anchor — those waits are deliberate fixed sleeps.
#
# CONTAINMENT: recording writes to the operator's real Engram store.
# ENGRAM_DATA_DIR does not isolate it: the CLI honours it, the MCP server the
# agent spawns does not. What is contained is the project name — everything
# lands under `todo-app`, and the setup deletes that project before each take so
# the save on camera is the one recalled. Clean up afterwards with:
#   engram delete project todo-app --hard
#
# REQUIRES: an authenticated `pi`.

Output docs/assets/brand/memory-demo-pi.gif

Require pi
Require engram

Set Shell "bash"
Set FontSize 12
Set Framerate 12
# HEIGHT IS A CORRECTNESS SETTING, NOT A LOOK: Pi renders one frame of about
# 41 rows on a cold project (welcome grid, Context, Skills, Prompts,
# Extensions, Themes, then the input box). Rows past the terminal's height are
# not pushed below the fold — they are CLIPPED AND GONE, input box included,
# and no sleep, anchor or keystroke brings them back. Measured: FontSize 16 at
# Height 700 gives 31 rows, so rows =~ (height - 30) / (fontsize * 1.35).
# Keep enough height for the whole frame or the take cannot succeed.
Set Width 1400
Set Height 1000
Set Padding 20
Set Margin 20
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 30ms
Set PlaybackSpeed 3
Set WaitTimeout 120s

# --- Fixture and a clean project, never shown --------------------------------
Hide
# set -o ignoreeof is what keeps this recording alive. Closing Pi needs Ctrl+D,
# but the EOF reaches the shell too, and a bash shell answers EOF with logout —
# the terminal dies mid-take and every later keystroke fails with "use of
# closed network connection". With ignoreeof the shell shrugs the EOF off and
# session two still has somewhere to run.
# REPO is captured before anything can cd away from it, and the copy below uses
# it as an absolute path. A relative "docs/demo/todo-app" here is a trap: if the
# copy fails the && chain stops, `cd $DEMO` never runs, and the git commands on
# the next line execute in THIS repository instead of the fixture — which is
# exactly how two "todo app" commits once landed on a real branch.
Type "export PS1='$ '; set -o ignoreeof; REPO=$PWD; DEMO=/tmp/gentle-ai-demo-pi/todo-app"
Enter
# Why the whole startup fits on camera now, and why it must: Pi's boot prints
# Context, Skills, Prompts, Extensions and Themes, and gentle-pi's banner adds
# an ASCII logo on top. At FontSize 20 that is ~40 rows in a ~24-row terminal.
# The overflow is the whole bug: the terminal ends parked on the dump's head
# with the input box below the fold, so no Wait+Screen can ever match and the
# take dies. Nothing to wait for — the final state is wrong. So make it fit:
# FontSize 16 buys the rows, and this scratch banner config drops the logo.
# GENTLE_PI_CONFIG_HOME keeps that off the operator's real config.
Type "export GENTLE_PI_CONFIG_HOME=/tmp/gentle-ai-demo-pi/piconf; mkdir -p $GENTLE_PI_CONFIG_HOME"
Enter
Type `printf '%s' '{"showRose":false,"showTextLogo":false,"color":"pink"}' > $GENTLE_PI_CONFIG_HOME/banner.json`
Enter
Type "rm -rf $DEMO && mkdir -p $(dirname $DEMO) && cp -R $REPO/docs/demo/todo-app $DEMO && cd $DEMO"
Enter
# Guarded so `git add -A` can only ever run inside the fixture. Matched on the
# path suffix because macOS resolves /tmp to /private/tmp, so comparing $PWD
# against $DEMO directly would never hold. If this ever prints REFUSING, the
# copy above failed — fix that rather than removing the guard.
Type `case "$PWD" in */gentle-ai-demo-pi/todo-app) git init -q && git add -A && git -c user.email=demo@local -c user.name=demo commit -qm 'todo app' ;; *) echo REFUSING ;; esac`
Enter
# Refresh the skill registry before the take, so Pi boots against a settled
# resource set instead of paying for the refresh while the camera waits.
Type "gentle-ai skill-registry refresh >/dev/null 2>&1"
Enter
# Wipe the demo project so the save filmed below is the one recalled later.
Type "engram delete project todo-app --hard >/dev/null 2>&1; clear"
Enter
Sleep 20s
Show

# --- Session one -------------------------------------------------------------
# Pi's boot does not fit the viewport and never will: the welcome grid plus the
# Context/Skills/Prompts/Extensions/Themes listing runs past 40 rows. When it
# overflows, the terminal can end parked on the listing's head with the input
# box below the fold, and from there NO Wait+Screen can ever match — there is
# nothing left to wait for, the final state is simply wrong.
#
# So the boot is not filmed. Pi starts and takes the first message off camera;
# keystrokes reach it even while the camera cannot see them, and Pi's own
# output is what scrolls the view back down to a live prompt. The camera opens
# on the conversation, which is the only thing this GIF is about.
#
# Wait+Screen does not resolve inside Hide, so the boot below is a fixed sleep.
# Everything AFTER the first exchange is anchored normally, because by then the
# screen is healthy again.
Hide
Type "pi"
Enter
Sleep 60s
Type "I want to build a todo-list app. What technologies could I use? Answer in two sentences."
Sleep 600ms
Enter
Sleep 10s
Show

# The camera is open. Prove the screen really did scroll back to the live
# conversation: the question has to be visible before anything else is trusted.
Wait+Screen@120s /technologies could I use/
# The answer's content does not matter and is never waited on — closing the
# session properly below is what persists it. But its TIMING does: typing while
# Pi is still generating loses the message. The prompt placeholder only comes
# back when Pi is idle again, so that is the anchor. Never a fixed sleep here.
Sleep 20s
Wait+Screen@300s /type, or/
Sleep 2s

Type "Thanks, that sounds great. Save this to memory — we'll continue in a new session."
# Prove the input box received the keystrokes before submitting. Waiting on
# the echoed text fails the take in seconds instead of burning minutes on a
# wait for a reply to a message Pi never got.
Wait+Screen@60s /Save this to memory/
Sleep 600ms
Enter
# Anchor on the tool-call line Pi prints, never on the model's prose. Do NOT
# anchor on the raw tool name (engram_mem...): pi-pretty.ts renders engram
# calls as a brain glyph plus a verb, and the raw name never reaches the screen.
# Anchor on the result line instead, which is plain ASCII and appears only once
# the save actually landed — the whole point of this recording.
Wait+Screen@180s /saved #/
# The save is not the end of Pi's turn: the close protocol also writes a
# session summary, and Pi ignores input until that finishes. Wait for the
# prompt placeholder — idle — before sending /exit, or the command is swallowed
# and the session never closes. Same rule as before every other keystroke here:
# wait for a state, never for a clock.
Sleep 6s
Wait+Screen@300s /type, or/
Sleep 2s

# --- Close it. The conversation is gone. -------------------------------------
# Ctrl+D, not "/exit": typing a slash opens Pi's command palette, and from a
# tape the command lands as a plain message instead of closing anything — the
# take then waits forever on a session that never ended. Pi's own banner
# documents ctrl+d as exit, and it needs no palette.
# EXACTLY ONE Ctrl+D. The first closes Pi and hands the terminal back to the
# shell; a second one reaches that shell, where Ctrl+D means logout, and kills
# the terminal — every later command silently goes nowhere and the take waits
# forever on a session two that never started.
Ctrl+D
# On camera just long enough to see the session close.
Sleep 4s
Hide
# /exit is NOT instant: it runs Engram's session-close protocol and generates a
# summary, which takes tens of seconds. Give it real room. Anything typed
# before the shell prompt returns lands inside Pi as a message instead — that
# is what silently broke this take before. Off camera, so the wait is free.
Sleep 120s

# --- Session two: new process, empty context ---------------------------------
# Same reason as session one: the boot stays off camera, and the question goes
# in blind. The camera opens on the question already asked, so the recall lands
# in frame — which is the whole point of the GIF.
Type "clear"
Enter
Sleep 2s
Type "pi"
Enter
Sleep 60s
Type "Where did we leave off here?"
Sleep 600ms
Enter
Sleep 10s
Show

Wait+Screen@120s /did we leave off/
# Same reason as session one: match Pi's rendered engram line, not a tool name.
# Session two recalls rather than saves, so the verb differs; the brain glyph
# every engram call is prefixed with is what both have in common.
Wait+Screen@180s /\x{1F9E0}/
Sleep 55s
