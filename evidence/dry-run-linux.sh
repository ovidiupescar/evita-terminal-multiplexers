#!/bin/bash
# Linux dry run for SDS.OSV1-USE1.7, run on the local-linux path rather than
# the WSL2 one the original evidence used. Its purpose is to raise the
# local-linux environment from "supported" to "verified": it re-executes the
# spine of every episode on a real Ubuntu 24.04 virtual machine with a stock
# distribution kernel and systemd as PID 1, and it captures the evidence for
# quiz question 4.
#
# Runs as the ORDINARY user inside the guest. Same two-socket technique as
# evidence/harvest.sh: the OUTER server (-L dryrun) is the harness and its
# single 80x24 pane plays the learner's terminal; the INNER server is the
# learner's, on the default socket.
unset COLUMNS LINES TMUX TMUX_PANE
set -u

W="$HOME/use17-linux"
OUT="tmux -L dryrun -f /dev/null"
TMPO="$HOME/.dryrun-out"

sec()  { echo; echo "===== $* ====="; echo; }
blks() {
  echo "\$ $1"
  eval "$1" > "$TMPO" 2>&1
  local rc=$?
  sed -e 's/[[:space:]]*$//' "$TMPO"
  echo "[exit $rc]"
}
cap() {
  echo
  echo "----- SCREEN $1: $2 -----"
  $OUT capture-pane -p -t cap | sed -e 's/[[:space:]]*$//'
  echo "----- END SCREEN $1 -----"
  echo
}
run()     { $OUT send-keys -t cap -l "$1"; $OUT send-keys -t cap Enter; sleep "${2:-1}"; }
key()     { $OUT send-keys -t cap "$1"; sleep "${2:-1}"; }
lit()     { $OUT send-keys -t cap -l "$1"; sleep "${2:-0.5}"; }
pfx_key() { $OUT send-keys -t cap C-b; sleep 0.4; $OUT send-keys -t cap "$1"; sleep "${2:-1.2}"; }
pfx_lit() { $OUT send-keys -t cap C-b; sleep 0.4; $OUT send-keys -t cap -l "$1"; sleep "${2:-1.2}"; }

# --------------------------------------------------------------- PART 0 ---
sec "PART 0 - WHICH MACHINE THIS IS"
blks 'grep PRETTY_NAME /etc/os-release'
blks 'uname -r'
blks 'ps -p 1 -o comm='
blks 'systemd-detect-virt'
blks 'id -un'
blks 'tmux -V'
blks 'screen --version | head -1'
blks 'nano --version | head -1'
blks 'dpkg-query -W -f "\${binary:Package} \${Version}\n" tmux screen nano vim'
blks 'ls -l ~/.tmux.conf /etc/tmux.conf 2>&1'

rm -rf "$W"; mkdir -p "$W"
blks 'mkdir -p ~/use17-linux && cd ~/use17-linux && pwd'
cd "$W" || exit 1

$OUT kill-server 2>/dev/null
tmux kill-server 2>/dev/null
sleep 1
$OUT new-session -d -s cap -x 80 -y 24
$OUT set-option -t cap status off
$OUT send-keys -t cap -l 'unset TMUX TMUX_PANE COLUMNS LINES; PS1="\u@\h:\w\$ "; clear'
$OUT send-keys -t cap Enter
sleep 1

# --------------------------------------------------------------- PART 1 ---
sec "PART 1 - EPISODE 2 SPINE: A SESSION THAT OUTLIVES ITS CLIENT"
run 'tmux new-session -d -s build'
run 'tmux ls'
cap L1-01 "a detached session exists on the Linux guest"

run 'tmux attach -t build' 1.5
run 'echo "work happens here" > ~/use17-linux/inside.txt'
cap L1-02 "attached, inside the session"

pfx_key 'd' 1.5
cap L1-03 "detached with Ctrl+B d, back in the outer shell"

run 'tmux ls'
run 'cat ~/use17-linux/inside.txt'
cap L1-04 "the session survived the detach and its work is on disk"

# --------------------------------------------------------------- PART 2 ---
sec "PART 2 - EPISODE 3 SPINE: WINDOWS AND PANES"
run 'tmux attach -t build' 1.5
pfx_lit '%' 1.5
cap L2-01 "Ctrl+B % split side by side"

pfx_lit '"' 1.5
cap L2-02 "Ctrl+B \" split top and bottom - the key is the double-quote character"

pfx_key 'q' 1.5
cap L2-03 "Ctrl+B q shows the pane numbers"
sleep 1

run 'tmux list-panes -t build'
cap L2-04 "three panes in this window"

# --------------------------------------------------------------- PART 3 ---
sec "PART 3 - EPISODE 4 SPINE: EDITING, DETACHING MID-EDIT, REATTACHING"
run 'nano ~/use17-linux/notes.txt' 2
lit 'a line typed before the disconnection'
sleep 1
cap L3-01 "nano with an unwritten buffer inside the session"

pfx_key 'd' 1.5
cap L3-02 "detached while nano still holds the unwritten buffer"

run 'tmux ls'
cap L3-03 "the session is still there, nano still running inside it"

run 'tmux attach -t build' 2
cap L3-04 "reattached: the buffer is exactly as it was left"

# --------------------------------------------------------------- PART 4 ---
sec "PART 4 - EVIDENCE FOR QUIZ QUESTION 4: WHICH KEYS TMUX TAKES"
echo "--- The learner wants nano's Where Is search, which is Ctrl+W."
echo "--- First the mistake the question describes: prefixing it with Ctrl+B."
pfx_key 'w' 1.5
cap L4-01 "Ctrl+B then w: tmux took w as its own command and showed the window list"

key 'q' 1.2
cap L4-02 "q leaves that list and returns to nano"

echo "--- Now the same key WITHOUT the prefix. Ctrl+W is not tmux's prefix,"
echo "--- so tmux does not intercept it and nano receives it."
key 'C-w' 1.5
cap L4-03 "Ctrl+W on its own: nano's Where Is prompt, no prefix involved"

key 'C-c' 1.2
cap L4-04 "Ctrl+C cancels the search prompt and gives the buffer back"

echo "--- And the doubled prefix, which is a different repair for a different"
echo "--- problem: it delivers a literal Ctrl+B to the program in the pane."
echo "--- A text capture cannot show a cursor, so the cursor column is read"
echo "--- from the learner's own tmux server before and after the keys."
key 'End' 2.0
blks 'tmux display-message -p -t build "cursor column at end of line: #{cursor_x}"'
key 'C-b' 0.4
key 'C-b' 1.5
blks 'tmux display-message -p -t build "cursor column after Ctrl+B Ctrl+B: #{cursor_x}"'
key 'C-b' 0.4
key 'C-b' 1.5
blks 'tmux display-message -p -t build "cursor column after a second doubled prefix: #{cursor_x}"'
cap L4-05 "the buffer is unchanged: the literal Ctrl+B reached nano as a cursor movement, not as a tmux command"

# --------------------------------------------------------------- PART 5 ---
sec "PART 5 - LEAVING NANO AND THE SESSION CLEANLY"
key 'C-x' 1.2
cap L5-01 "Ctrl+X asks whether to save the modified buffer"
key 'y' 1.2
key 'Enter' 1.5
cap L5-02 "saved under the offered name"

run 'cat ~/use17-linux/notes.txt'
cap L5-03 "the file on disk carries what was typed before the disconnection"

# --------------------------------------------------------------- PART 6 ---
sec "PART 6 - THE PORTABLE FALLBACK IS PRESENT HERE TOO"
run 'screen -dmS fallback; sleep 1; screen -ls'
cap L6-01 "GNU screen creates and lists a detached session on this machine"
run 'screen -S fallback -X quit; sleep 1; screen -ls'
cap L6-02 "and removes it"

# --------------------------------------------------------------- PART 7 ---
sec "PART 7 - CLEANUP, VERIFIED"
run 'tmux kill-server 2>/dev/null; sleep 1; tmux ls'
cap L7-01 "no tmux sessions remain"
$OUT kill-server 2>/dev/null
sleep 1

blks 'tmux ls 2>&1'
blks 'screen -ls 2>&1 | tail -2'
blks 'pgrep -c tmux; echo "(0 means no tmux process of this user is left)"'
blks 'ls ~/use17-linux'
blks 'rm -rf ~/use17-linux; ls ~/use17-linux 2>&1'
blks 'date -u +"linux dry run finished %Y-%m-%dT%H:%M:%SZ"'
