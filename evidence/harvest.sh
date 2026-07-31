#!/bin/bash
# Evidence harvest for SDS.OSV1-USE1.7, part 2 of 2: everything the episodes
# show. Runs as the ORDINARY user, because nothing in this module needs
# privileges once the packages from harvest-setup.sh are installed.
#
# HOW THE INTERACTIVE SCREENS ARE PRODUCED
# The subject of this module is also the harvesting tool, so the two are kept
# apart by socket name:
#   * the OUTER server (tmux -L harvest -f /dev/null) is the authoring
#     harness. It holds one session, "cap", whose single pane is fixed at
#     80x24 with the status line switched off. That pane plays the part of
#     the learner's terminal window, and its contents are what
#     "capture-pane -p" writes into this transcript.
#   * the INNER server is the learner's, on the default socket
#     (/tmp/tmux-<uid>/default). Every tmux command shown in an episode runs
#     there, so "tmux ls" inside a captured screen lists only the sessions
#     the episode created.
# The pane shell inherits $TMUX from the outer server; it is unset in the
# pane before anything else, otherwise the inner tmux refuses to nest.
#
# Run it as:
#   tr -d '\r' < evidence/harvest.sh | MSYS_NO_PATHCONV=1 wsl -- \
#     env TERM=dumb bash -c 'cat > ~/h.sh; bash ~/h.sh > ~/t.txt 2>&1'
#   MSYS_NO_PATHCONV=1 wsl -- cat ~/t.txt > evidence/transcript.txt
#
# unset COLUMNS LINES is required: ncurses programs prefer those variables
# over the pty size, and a value inherited from the invoking shell makes nano
# and vim draw wider than the 80-column pane.
unset COLUMNS LINES TMUX TMUX_PANE
set -u

W="$HOME/use17"
OUT="tmux -L harvest -f /dev/null"
TMPO="$HOME/.harvest-out"

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
# capt captures a named window of the harness session, which is how the two
# clients of one session are shown side by side in the transcript.
capt() {
  echo
  echo "----- SCREEN $1: $3 -----"
  $OUT capture-pane -p -t "$2" | sed -e 's/[[:space:]]*$//'
  echo "----- END SCREEN $1 -----"
  echo
}
run()     { $OUT send-keys -t cap -l "$1"; $OUT send-keys -t cap Enter; sleep "${2:-1}"; }
key()     { $OUT send-keys -t cap "$1"; sleep "${2:-1}"; }
lit()     { $OUT send-keys -t cap -l "$1"; sleep "${2:-0.5}"; }
pfx_key() { $OUT send-keys -t cap C-b; sleep 0.4; $OUT send-keys -t cap "$1"; sleep "${2:-1.2}"; }
pfx_lit() { $OUT send-keys -t cap C-b; sleep 0.4; $OUT send-keys -t cap -l "$1"; sleep "${2:-1.2}"; }

# ---------------------------------------------------------------- PART 0 ---
sec "PART 0 - BASELINE"
blks 'cat /etc/os-release | head -1'
blks 'uname -r'
blks 'id -un; id -u'
blks 'tmux -V'
blks 'screen --version'
blks 'ls -l ~/.tmux.conf /etc/tmux.conf 2>&1 | sed -e "s/^/  /"'
blks 'tmux -f /dev/null start-server \; show-options -g prefix \; show-options -g default-terminal \; show-options -g status \; kill-server'

rm -rf "$W"
blks 'mkdir -p ~/use17 && cd ~/use17 && pwd'
cd "$W" || exit 1

# ---------------------------------------------------------------- PART 1 ---
sec "PART 1 - WHY A MULTIPLEXER: A COMMAND THAT OUTLIVES ITS TERMINAL"

echo "--- the fixture: a command that keeps writing until it is stopped ---"
printf '%s\n' '#!/bin/bash' '# prints one line per second until it is stopped' 'i=0' 'while true; do' '  i=$((i+1))' '  printf "%s tick %d\n" "$(date +%H:%M:%S)" "$i"' '  sleep 1' 'done' > ticker.sh
chmod +x ticker.sh
blks 'cat ticker.sh'
blks 'ls -l ticker.sh'

echo
echo "--- CASE A: the command runs on a pseudo-terminal that is then destroyed."
echo "--- script(1) holds the pseudo-terminal, which stands in for the terminal"
echo "--- an SSH connection provides. Destroying it delivers the same SIGHUP a"
echo "--- dropped connection delivers."
blks 'setsid script -q -c "$HOME/use17/ticker.sh > $HOME/use17/plain.log 2>&1" /dev/null < /dev/null > /dev/null 2>&1 & echo "harness pid $!" > "$HOME/.use17-apid"; sleep 4; cat "$HOME/.use17-apid"'
APID=$(sed -e 's/[^0-9]//g' "$HOME/.use17-apid")
blks "pstree -p $APID"
blks 'cat plain.log; echo "-- $(wc -l < plain.log) lines"'
blks "kill $APID"
blks 'sleep 3; cat plain.log; echo "-- $(wc -l < plain.log) lines"'
blks 'pgrep -af ticker.sh || echo "no ticker.sh process is running"'

echo
echo "--- CASE B: the same command inside a tmux session with no client attached."
blks 'tmux kill-server 2>/dev/null; tmux new-session -d -s work -x 80 -y 24 -c "$HOME/use17" "$HOME/use17/ticker.sh > $HOME/use17/tmux.log 2>&1"; sleep 4; cat tmux.log; echo "-- $(wc -l < tmux.log) lines"'
blks 'tmux ls'
blks 'pgrep -af "bash .*ticker.sh"'
blks 'sleep 4; cat tmux.log; echo "-- $(wc -l < tmux.log) lines"'
blks 'tmux kill-session -t work; sleep 1; pgrep -af ticker.sh || echo "no ticker.sh process is running"'

# ---------------------------------------------------------------- PART 2 ---
sec "PART 2 - THE MODEL: SERVER, SESSION, CLIENT"
blks 'tmux kill-server 2>/dev/null; tmux ls'
blks 'tmux new-session -d -s demo -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux ls'
blks 'ls -l /tmp/tmux-$(id -u)/'
blks 'pgrep -a tmux'
blks 'tmux display -p -t demo "server pid #{pid}, session #{session_name}, pane pid #{pane_pid}"'
blks 'pstree -p $(tmux display -p -t demo "#{pid}")'
blks 'COLUMNS=100 LINES=40 ps -o pid,ppid,tty,stat,comm,args -p $(tmux display -p -t demo "#{pid}")'
blks 'COLUMNS=100 LINES=40 ps -o pid,ppid,tty,stat,comm,args -p $(tmux display -p -t demo "#{pane_pid}")'
blks 'tmux list-windows -t demo'
blks 'tmux list-panes -t demo'
blks 'tmux display -p -t demo "#{session_name} #{window_width}x#{window_height} #{pane_pid}"'
blks 'tmux attach -t nosuch'
blks 'tmux kill-server; sleep 1; tmux ls'
blks 'ls -l /tmp/tmux-$(id -u)/ 2>&1'

# ---------------------------------------------------------------- PART 3 ---
sec "PART 3 - SCREENS: THE SESSION LIFECYCLE (EPISODE 2)"
$OUT kill-server 2>/dev/null
sleep 0.5
$OUT new-session -d -s cap -x 80 -y 24 -c "$W"
$OUT set -g status off
$OUT set -g prefix C-q
sleep 1
blks "$OUT display -p -t cap '#{pane_width}x#{pane_height}'"
run 'unset TMUX TMUX_PANE; clear' 1
cap "E2-01" "the shell in the working directory, before any multiplexer is started"

run 'tmux new -s demo' 2
cap "E2-02" "a new session called demo: the status line names it"

run './ticker.sh' 4
cap "E2-03" "the ticker running inside the session"

pfx_key d 1.5
cap "E2-04" "after Ctrl+B d: the client has detached and the shell is back"

run 'tmux ls' 1
cap "E2-05" "tmux ls lists the session that is still there"

sleep 6
run 'tmux attach -t demo' 2
cap "E2-06" "after tmux attach: the tick numbers advanced while nobody was attached"

key C-c 1
run 'tmux' 1.5
cap "E2-07" "starting tmux inside a session is refused"

run 'exit' 1.5
cap "E2-08" "exit in the last pane ends the session"

run 'tmux ls' 1
cap "E2-09" "with the session gone, no server is running"

run 'tmux attach -t demo' 1
cap "E2-10" "attaching a session that no longer exists"

run 'clear' 0.5

echo "--- two clients drawing one session at the same time ---"
blks 'tmux kill-server 2>/dev/null; tmux new-session -d -s pair -x 80 -y 24 -c "$HOME/use17"; tmux ls'
run 'tmux attach -t pair' 2
blks 'tmux list-clients -t pair'
$OUT new-window -t cap: -c "$W"
sleep 1
run 'unset TMUX TMUX_PANE; clear' 1
run 'tmux attach -t pair' 2
blks 'tmux list-clients -F "#{client_tty} #{client_width}x#{client_height} #{client_session}"'
run 'echo this line was typed in the second client' 1.5
capt "E2-11" "cap:1" "the second client, where the command was typed"
capt "E2-12" "cap:0" "the first client, drawing the same session at the same time"
pfx_key d 1.5
$OUT kill-window -t cap:1
sleep 1
cap "E2-13" "the first client after the second one detached"
run 'tmux kill-server' 1.5
run 'tmux ls' 1.2
cap "E2-14" "the session ends when it is killed, not when a client leaves"
run 'clear' 0.5

# ---------------------------------------------------------------- PART 4 ---
sec "PART 4 - SCREENS: WINDOWS AND PANES (EPISODE 3)"
blks 'nohup ./ticker.sh > ~/use17/build.log 2>&1 & echo "background writer pid $!" > "$HOME/.use17-bpid"; sleep 2; cat "$HOME/.use17-bpid"'
BPID=$(sed -e 's/[^0-9]//g' "$HOME/.use17-bpid")

run 'tmux new -s layout' 2
cap "E3-01" "a session with one window and one pane"

pfx_lit '%' 1.5
cap "E3-02" "Ctrl+B % splits the window into two panes side by side"

run 'tail -f ~/use17/build.log' 3
cap "E3-03" "the right pane follows the log while the left pane stays free"

pfx_key o 1.2
run 'wc -l ~/use17/build.log' 1.2
cap "E3-04" "Ctrl+B o moves to the other pane, which still has a prompt"

pfx_lit '"' 1.5
run 'date; uptime' 1.5
cap "E3-05" 'Ctrl+B " splits the current pane top and bottom'

pfx_key q 1.5
cap "E3-06" "Ctrl+B q shows the number of each pane"

sleep 1
pfx_key c 1.5
cap "E3-07" "Ctrl+B c opens a second window; the status line lists both"

pfx_lit ',' 1.2
cap "E3-08" "Ctrl+B , offers the current name for editing"
key C-u 0.5
lit 'notes'
key Enter 1.2
cap "E3-08b" "Ctrl+U clears the offered name before the new one is typed"

pfx_key n 1.2
cap "E3-09" "Ctrl+B n moves to the next window"

run 'seq 1 60' 1.5
pfx_lit '[' 1.2
key PPage 1.2
cap "E3-10" "Ctrl+B [ enters copy mode; the indicator counts the lines above"

key q 1.2
cap "E3-11" "q leaves copy mode"

pfx_key x 1.2
cap "E3-12" "Ctrl+B x asks before it kills the pane"

lit 'y' 1.5
cap "E3-13" "the pane is gone and the remaining pane fills the window"

pfx_key d 1.5
run 'tmux ls' 1.2
cap "E3-14" "the session with its two windows is still there after detaching"

run 'tmux kill-session -t layout; tmux ls' 1.2
cap "E3-15" "killing the session by name ends it"

blks "kill $BPID 2>/dev/null; sleep 1; pgrep -af 'bash .*ticker.sh' || echo 'no ticker.sh process is running'"
run 'clear' 0.5

# ---------------------------------------------------------------- PART 5 ---
sec "PART 5 - THE SAME MODEL IN GNU SCREEN (EPISODE 3)"
blks 'screen -ls'
blks 'screen -dmS jobs bash'
blks 'screen -ls'
blks 'ls -l /run/screen/S-$(id -un)/'

run 'screen -r jobs' 2
cap "E3-16" "a screen session has no status line by default"

run 'echo this shell runs inside screen' 1.2
cap "E3-17" "a command in the screen session"

key C-a 0.4
key d 1.5
cap "E3-18" "Ctrl+A d detaches a screen session"

run 'screen -ls' 1.2
cap "E3-19" "screen -ls lists the detached session"

run 'screen -X -S jobs quit; screen -ls' 1.5
cap "E3-20" "screen -X quit ends the session"

run 'clear' 0.5

# ---------------------------------------------------------------- PART 6 ---
sec "PART 6 - SCREENS: EDITING A FILE INSIDE A SESSION (EPISODE 4)"
printf 'run the preprocessing step\ncheck the output size\n' > "$W/notes.txt"
printf 'alpha\nbeta\ngamma\n' > "$W/report.txt"
blks 'cat notes.txt'
blks 'md5sum notes.txt'
blks 'cat report.txt'
blks 'md5sum report.txt'
blks 'rm -f ~/.viminfo; ls -a ~ | grep viminfo || echo "no ~/.viminfo"'

run 'tmux new -s edit' 2
cap "E4-01" "a session for the editing work"

run 'nano notes.txt' 2
cap "E4-02" "nano opened inside the session; the tmux status line is still there"

key Down 0.4
key End 0.4
key Enter 0.4
lit 'archive the log directory' 0.8
cap "E4-03" "a third line typed; the title bar marks the buffer as changed"

pfx_key d 1.5
cap "E4-04" "detaching while nano is still running and the buffer is unwritten"

blks 'cat notes.txt'
blks 'md5sum notes.txt'
blks 'tmux ls'

run 'tmux attach -t edit' 2
cap "E4-05" "reattaching returns the same nano screen with the same buffer"

pfx_lit 'w' 1.5
cap "E4-06" "Ctrl+B w is taken by tmux, which shows its window list instead of nano's search"

key Escape 1.2
cap "E4-07" "Escape leaves the window list and nano is back"

key C-o 0.8
key Enter 1.2
cap "E4-08" "Ctrl+O then Enter writes the buffer to notes.txt"

key C-x 1.5
cap "E4-09" "Ctrl+X leaves nano"

blks 'cat notes.txt'
blks 'md5sum notes.txt'
blks 'wc -l notes.txt'

run 'cat -v' 1.2
key C-b 0.4
key C-b 1.2
cap "E4-10" "Ctrl+B twice: the terminal echoes the one literal Ctrl+B that reached the pane"

key Enter 1
cap "E4-11" "cat -v prints the byte it received, so the second Ctrl+B arrived at the program"

key C-c 1.2
run 'clear' 0.8

echo "--- the staged failure: the session is killed with an unwritten buffer ---"
run 'vim report.txt' 2
cap "E4-12" "vim in the pane, before any change"

lit 'o' 0.6
lit 'delta' 0.8
cap "E4-13" "a fourth line typed in insert mode and not written"

blks 'tmux kill-session -t edit'
sleep 2
cap "E4-14" "the pane is back at the shell: killing the session ended vim with it"

blks 'ls -a'
blks 'cat report.txt'
blks 'md5sum report.txt'
blks 'ls -l .report.txt.swp'

run 'vim -r report.txt' 2.5
cap "E4-15" "vim -r reads the swap file and reports what it recovered"

key Enter 1.5
cap "E4-16" "the recovered buffer holds the line that was never written"

lit ':q!' 0.4
key Enter 1.5
run 'rm -f .report.txt.swp; ls -a' 1.2
cap "E4-17" "the swap file removed after the recovery"

run 'clear' 0.5

# ---------------------------------------------------------------- PART 7 ---
sec "PART 7 - MODEL ANSWERS FOR THE EXERCISES"

echo "--- ex1: a named session whose command keeps writing while detached ---"
blks 'tmux kill-server 2>/dev/null; tmux new-session -d -s ex1 -x 80 -y 24 -c "$HOME/use17" "$HOME/use17/ticker.sh > $HOME/use17/ex1.log 2>&1"'
blks 'tmux ls'
blks 'sleep 5; wc -l < ex1.log'
blks 'sleep 5; wc -l < ex1.log'
blks 'tmux kill-session -t ex1; tmux ls'
blks 'sleep 2; wc -l < ex1.log; pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"'

echo
echo "--- ex2: a two-window layout, read back with the tmux command interface ---"
blks 'tmux new-session -d -s ex2 -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux rename-window -t ex2:0 watch'
blks 'tmux split-window -h -t ex2:watch'
blks 'tmux new-window -t ex2 -n edit'
blks 'tmux list-windows -t ex2'
blks 'tmux list-panes -a -t ex2'
blks 'tmux kill-session -t ex2'

echo
echo "--- ex3: an edit that survives a detach, verified from outside the session ---"
blks 'printf "step one\nstep two\n" > plan.txt; md5sum plan.txt; wc -l plan.txt'
blks 'tmux new-session -d -s ex3 -x 80 -y 24 -c "$HOME/use17" "nano plan.txt"'
blks 'sleep 2; tmux send-keys -t ex3 Down End Enter; sleep 1; tmux send-keys -t ex3 -l "step three"; sleep 1; tmux ls'
blks 'md5sum plan.txt'
blks 'tmux send-keys -t ex3 C-o; sleep 1; tmux send-keys -t ex3 Enter; sleep 1; tmux send-keys -t ex3 C-x; sleep 1; tmux ls'
blks 'cat plan.txt'
blks 'md5sum plan.txt'
blks 'wc -l plan.txt'
blks 'tmux kill-server 2>/dev/null; tmux ls'

echo
echo "--- hx1: the hands-on task, executed end to end ---"
blks 'tmux new-session -d -s hx1 -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux rename-window -t hx1:0 run'
blks 'tmux send-keys -t hx1:run "$HOME/use17/ticker.sh > $HOME/use17/hx1.log 2>&1" Enter; sleep 3; wc -l < hx1.log'
blks 'tmux new-window -t hx1 -n edit -c "$HOME/use17"'
blks 'tmux send-keys -t hx1:edit "nano hx1-notes.txt" Enter; sleep 2; tmux send-keys -t hx1:edit -l "the run started"; sleep 1'
blks 'tmux list-windows -t hx1'
blks 'tmux detach-client -s hx1 2>/dev/null; tmux ls'
blks 'sleep 5; wc -l < hx1.log'
blks 'tmux send-keys -t hx1:edit C-o; sleep 1; tmux send-keys -t hx1:edit Enter; sleep 1; tmux send-keys -t hx1:edit C-x; sleep 1; cat hx1-notes.txt'
blks 'md5sum hx1-notes.txt'
blks 'tmux send-keys -t hx1:run C-c; sleep 1; tmux kill-session -t hx1; sleep 1; tmux ls'
blks 'pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"'

# ---------------------------------------------------------------- PART 8 ---
sec "PART 8 - CLEANUP AND VERIFICATION"
blks "pgrep -af 'bash .*ticker.sh' || echo 'no ticker.sh process is running'"
blks 'tmux kill-server 2>/dev/null; tmux ls'
blks 'screen -ls'
blks 'ls ~/use17'
blks 'cd ~ && rm -rf ~/use17 && ls -d ~/use17 2>&1'
# The harness server is torn down before the last two checks, so that what
# they report is the state a learner's box is left in and not an artefact of
# the way this transcript was produced.
$OUT kill-server 2>/dev/null
sleep 2
rm -f "/tmp/tmux-$(id -u)/harvest" "$HOME/.use17-apid" "$HOME/.use17-bpid"
blks 'ls -l /tmp/tmux-$(id -u)/ 2>&1'
blks 'pgrep -af "tmux|screen|ticker" || echo "no tmux, screen or ticker process is running"'
rm -f "$TMPO"

sec "HARVEST COMPLETE"
date -u +%Y-%m-%dT%H:%M:%SZ
