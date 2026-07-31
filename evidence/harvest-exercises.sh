#!/bin/bash
# Evidence harvest for SDS.OSV1-USE1.7, part 3 of 3: the model answers of the
# exercises and of the hands-on task, executed with the session and file
# names the episodes actually ask for. Kept separate from harvest.sh so that
# a late change to an exercise does not force a re-run of the 52 captured
# screens.
#
# Runs as the ORDINARY user. Same invocation as harvest.sh:
#   tr -d '\r' < evidence/harvest-exercises.sh | MSYS_NO_PATHCONV=1 wsl -- \
#     env TERM=dumb bash -c 'cat > ~/he.sh; bash ~/he.sh > ~/te.txt 2>&1'
#   MSYS_NO_PATHCONV=1 wsl -- bash -c 'cat ~/te.txt' > evidence/transcript-exercises.txt
unset COLUMNS LINES TMUX TMUX_PANE
set -u

W="$HOME/use17"
TMPO="$HOME/.harvest-out"

sec()  { echo; echo "===== $* ====="; echo; }
blks() {
  echo "\$ $1"
  eval "$1" > "$TMPO" 2>&1
  local rc=$?
  sed -e 's/[[:space:]]*$//' "$TMPO"
  echo "[exit $rc]"
}

rm -rf "$W"; mkdir -p "$W"; cd "$W" || exit 1
tmux kill-server 2>/dev/null
printf '%s\n' '#!/bin/bash' '# prints one line per second until it is stopped' 'i=0' 'while true; do' '  i=$((i+1))' '  printf "%s tick %d\n" "$(date +%H:%M:%S)" "$i"' '  sleep 1' 'done' > ticker.sh
chmod +x ticker.sh

sec "EPISODE 3 CHECKPOINT - list-windows on the layout built in the guided practice"
blks 'tmux new-session -d -s layout -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux split-window -h -t layout:0'
blks 'tmux new-window -t layout -n notes -c "$HOME/use17"'
blks 'tmux list-windows -t layout'
blks 'tmux kill-session -t layout'

sec "EX1 - a session that proves itself"
blks 'tmux new-session -d -s harvest -c "$HOME/use17" "$HOME/use17/ticker.sh > $HOME/use17/harvest.log 2>&1"'
blks 'tmux ls'
blks 'sleep 5; wc -l < harvest.log'
blks 'sleep 5; wc -l < harvest.log'
blks 'tmux kill-session -t harvest; tmux ls'
blks 'sleep 2; wc -l < harvest.log; pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"'

sec "EX2 - a layout for a real task"
blks 'tmux new-session -d -s monitor -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux rename-window -t monitor:0 logs'
blks 'tmux split-window -h -t monitor:logs'
blks 'tmux new-window -t monitor -n notes -c "$HOME/use17"'
blks 'tmux list-windows -t monitor'
blks 'tmux list-panes -a -t monitor'
blks 'tmux ls'
blks 'tmux kill-session -t monitor; tmux ls'

sec "EX3 - finish an edit across a disconnection"
blks 'printf "input = data.csv\nworkdir = /scratch\n" > settings.conf; cat settings.conf'
blks 'tmux new-session -d -s remote -x 80 -y 24 -c "$HOME/use17" "nano settings.conf"'
blks 'sleep 2; tmux send-keys -t remote Down End Enter; sleep 1; tmux send-keys -t remote -l "threads = 4"; sleep 1; tmux ls'
echo "--- the buffer is unwritten and the client is detached: this is step 3 ---"
blks 'md5sum settings.conf'
blks 'wc -l < settings.conf'
blks 'grep -c "threads = 4" settings.conf || echo "(grep found nothing, exit 1)"'
echo "--- step 4: write with Ctrl+O Enter, leave with Ctrl+X ---"
blks 'tmux send-keys -t remote C-o; sleep 1; tmux send-keys -t remote Enter; sleep 1; tmux send-keys -t remote C-x; sleep 2; tmux ls'
echo "--- step 5 ---"
blks 'cat settings.conf'
blks 'md5sum settings.conf'
blks 'wc -l < settings.conf'
blks 'grep -c "threads = 4" settings.conf'

sec "HX1 - the hands-on task, executed end to end"
blks 'tmux new-session -d -s run -x 80 -y 24 -c "$HOME/use17"'
blks 'tmux rename-window -t run:0 job'
blks 'tmux send-keys -t run:job "$HOME/use17/ticker.sh > $HOME/use17/job.log 2>&1" Enter; sleep 3; wc -l < job.log'
blks 'tmux new-window -t run -n notes -c "$HOME/use17"'
blks 'tmux send-keys -t run:notes "nano handover.txt" Enter; sleep 2; tmux send-keys -t run:notes -l "the job was started at 10:00"; sleep 1'
blks 'tmux list-windows -t run'
echo "--- detached: nothing is drawing the session ---"
blks 'tmux ls'
blks 'ls handover.txt 2>&1'
blks 'sleep 5; wc -l < job.log'
echo "--- reattach, write the note, stop the job ---"
blks 'tmux send-keys -t run:notes C-o; sleep 1; tmux send-keys -t run:notes Enter; sleep 1; tmux send-keys -t run:notes C-x; sleep 1; cat handover.txt'
blks 'md5sum handover.txt'
blks 'wc -l < handover.txt'
blks 'tmux send-keys -t run:job C-c; sleep 1; wc -l < job.log'
blks 'sleep 3; wc -l < job.log'
blks 'tmux kill-session -t run; sleep 1; tmux ls'
blks 'pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"'

sec "CLEANUP"
blks 'tmux kill-server 2>/dev/null; tmux ls'
blks 'cd ~ && rm -rf ~/use17 && ls -d ~/use17 2>&1'
rm -f "$TMPO"

sec "HARVEST COMPLETE"
date -u +%Y-%m-%dT%H:%M:%SZ
