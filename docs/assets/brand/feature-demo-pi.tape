# Gentle-AI README feature-work proof, recorded through Pi.
#
# Regenerate with:
#   vhs docs/assets/brand/feature-demo-pi.tape
#
# The fixture is copied to a new /tmp directory before every take. Pi changes
# only that copy; the source fixture and this repository remain untouched.
#
# REQUIRES: authenticated `pi`, `node`, `npm`, and `gentle-ai` on PATH.

Output docs/assets/brand/feature-demo-pi.gif

Require pi
Require node
Require npm
Require gentle-ai

Set Shell "bash"
Set FontSize 12
Set Framerate 12
Set Width 1400
Set Height 1000
Set Padding 20
Set Margin 20
Set BorderRadius 10
Set WindowBar Colorful
Set Theme "Catppuccin Mocha"
Set TypingSpeed 20ms
Set PlaybackSpeed 6
Set WaitTimeout 180s

# Keep the operator's Pi banner configuration private and make the cold boot
# compact enough to avoid Pi's known clipped-startup frame. The setup is hidden:
# no local path or username can enter the published recording.
Hide
Type "export PS1='$ '; set -o ignoreeof; REPO=$PWD; DEMO_ROOT=$(mktemp -d /tmp/gentle-ai-feature-demo.XXXXXX); DEMO=$DEMO_ROOT/todo-app"
Enter
Type "export GENTLE_PI_CONFIG_HOME=$DEMO_ROOT/piconf; mkdir -p $GENTLE_PI_CONFIG_HOME"
Enter
Type `printf '%s' '{"showRose":false,"showTextLogo":false,"color":"pink"}' > $GENTLE_PI_CONFIG_HOME/banner.json`
Enter
# Copy first, then guard the git setup by the known fixture suffix. A failed copy
# cannot initialize or commit the repository being recorded from.
Type "cp -R $REPO/docs/demo/todo-app $DEMO && cd $DEMO"
Enter
Type `case "$PWD" in */gentle-ai-feature-demo.*/todo-app) git init -q && git add -A && git -c user.email=demo@local -c user.name=demo commit -qm 'todo app baseline' ;; *) echo REFUSING ;; esac`
Enter
Type "npm run verify >/dev/null && clear"
Enter
Sleep 3s
Show

# Pi's cold boot is deliberately hidden. Its startup listing can be taller than
# the terminal viewport; after the first prompt, the conversation restores a
# stable visible state for state-based anchors.
Hide
# Fullscreen mode keeps the transcript pinned to its latest output. Regular
# mode can leave long delegated results below the terminal's visible frame.
Type "pi --tui-mode fullscreen"
Enter
Sleep 60s
Type "Add a completed count to this todo app. Calculate it in the model, render Completed: 1 without changing the existing list wording, and update the tests. Use your normal Gentle AI workflow and run npm run verify."
Sleep 600ms
Enter
Sleep 10s
Show

# These are rendered runtime states, not terms from the request: the verifier's
# Node test result and Pi's idle composer. The visible interval contains todo
# progress and the exploration, bounded implementation, and verification cards.
# Pi writes its required session summary only after implementation and delegated
# verification have finished. It is a more stable completion anchor than model
# prose, whose exact wording can vary between takes.
Wait+Screen@600s /session summary/
Sleep 20s
