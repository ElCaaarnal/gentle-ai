# Gentle-AI README memory proof: two different agents, one memory.
#
# Regenerate with:
#   vhs docs/assets/brand/memory-demo.tape
#
# WHAT THIS PROVES: the headline claim. OpenCode is told a decision and saves
# it. OpenCode is closed on camera, back to a shell prompt. A second OpenCode
# session is opened with an empty context, asked about the decision, and
# retrieves it — the TUI shows the engram tool calls doing the work in both
# halves.
#
# An earlier version used Pi for the second half, which was stronger: no model
# can carry a conversation across two separate products. It was dropped because
# Pi took over 20s to boot and its model repeatedly passed malformed parameters
# to the engram tools, putting error dumps on screen. Worth revisiting.
#
# WORKING COPY LOCATION: the fixture is versioned at docs/demo/todo-app, but the
# take runs against a throwaway copy under /tmp. That is deliberate and not just
# tidiness: OpenCode prints the absolute working directory in its status bar, so
# a copy under $HOME puts the operator's username in the last frame of a
# published recording.
#
# CONTAINMENT — READ THIS BEFORE RUNNING: recording writes to the operator's
# real Engram store. ENGRAM_DATA_DIR does NOT isolate it: the CLI honours it,
# but the MCP server the agent spawns does not, so agent-written memories land
# in ~/.engram regardless. What is contained is the project name: everything
# lands under `todo-app`, and the setup below deletes that project
# before each take so the save on camera is the one recalled. To clean up
# afterwards: engram delete project todo-app --hard
#
# REQUIRES: authenticated `opencode` and `pi`.

Output docs/assets/brand/memory-demo.gif

Require opencode

Set Shell "bash"
Set FontSize 20
Set Framerate 24
Set Width 1400
Set Height 640
Set Padding 20
Set Margin 20
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 30ms
Set PlaybackSpeed 3
Set WaitTimeout 120s

# --- Materialise the fixture, never shown ------------------------------------
Hide
Type "export PS1='$ '; DEMO=/tmp/gentle-ai-demo/todo-app"
Enter
Type "rm -rf $DEMO && mkdir -p $(dirname $DEMO) && cp -R docs/demo/todo-app $DEMO && cd $DEMO"
Enter
Type "git init -q && git add -A && git -c user.email=demo@local -c user.name=demo commit -qm 'checkout service'"
Enter
Type "engram delete project todo-app --hard >/dev/null 2>&1; clear"
Enter
Sleep 1s
Show

# --- Agent one: OpenCode is told a decision, and saves it --------------------
Type "opencode"
Enter
# Anchor on the ready prompt rather than a fixed sleep: boot time varies with
# how many MCP servers and skills have to load.
Wait+Screen@120s /MCP/
Sleep 2s
Type "I want to build a todo-list app. What technologies could I use?"
Sleep 600ms
Enter
# The answer itself does not matter and is never waited on. What matters is
# closing the session properly below: the orchestrator's protocol persists the
# session on close, which is the product behaving as designed rather than the
# recording forcing an artificial save.
Sleep 40s

Type "Thanks, that sounds great. Let's continue in a new session."
Sleep 600ms
Enter
# Anchor on the tool-call line the TUI prints, never on the model's prose: the
# wording changes between runs and a missed wait burns a full take. This line
# is also the thing worth filming.
Wait+Screen@120s /engram_mem/
Sleep 8s

# --- Close it. The conversation is gone. ------------------------------------
Type "/exit"
Sleep 400ms
Enter
Sleep 2s

# Reset the terminal before handing over. OpenCode leaves the alternate screen
# on exit and Pi renders blank if it starts into that state; the clear also
# wipes the previous agent's transcript, which suits the hand-off.
Hide
Type "clear"
Enter
Sleep 4s
Show

# --- Session two: new process, empty context --------------------------------
Type "opencode"
Enter
Wait+Screen@120s /MCP/
Sleep 2s

# "Where did we leave off" is the phrasing the orchestrator's protocol routes to
# mem_context, which reads recent session history directly. Do not reword this
# into a search-style question: engram's search defaults to match_mode "all",
# so a natural phrasing that shares no tokens with the stored record returns
# nothing at all and the agent reports that nothing was saved.
Type "Where did we leave off here?"
Sleep 600ms
Enter
Wait+Screen@120s /engram_mem_context/
# mem_context lands early; the orchestrator then keeps working — a follow-up
# memory search and often a look at the repository state — before it answers.
# Give it room: cutting here leaves the recording ending on "Writing command…".
Sleep 55s
