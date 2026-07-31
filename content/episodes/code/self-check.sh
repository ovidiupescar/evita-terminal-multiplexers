#!/bin/bash
# Self-check for SDS.OSV1-USE1.7.
#
# Each exercise in this module states its success criteria as observable
# state. This script asks the machine whether that state is there, so a
# self-paced learner gets an answer instead of an opinion.
#
# Usage:
#   ./self-check.sh ex1        while the harvest session is detached and running
#   ./self-check.sh ex2        after the monitor layout is built
#   ./self-check.sh ex3        after the settings.conf edit is finished
#   ./self-check.sh hx1-open   while the run session is detached, before the write
#   ./self-check.sh hx1-final  after the note is written and the job stopped
#   ./self-check.sh cleanup    after the cleanup section of Episode 4
#
# Exit status 0 means every criterion of that step is met.
set -u
W="${USE17_DIR:-$HOME/use17}"
fails=0

ok()   { printf 'PASS  %s\n' "$1"; }
bad()  { printf 'FAIL  %s\n' "$1"; fails=$((fails+1)); }
check(){ if [ "$1" = 0 ]; then ok "$2"; else bad "$2${3:+ -- $3}"; fi; }

has_session() { tmux has-session -t "=$1" 2>/dev/null; }

lines() { [ -f "$1" ] && wc -l < "$1" || echo 0; }

case "${1:-}" in
ex1)
  has_session harvest; check $? "a session named harvest exists"
  a=$(lines "$W/harvest.log")
  printf '      harvest.log has %s lines, waiting five seconds\n' "$a"
  sleep 5
  b=$(lines "$W/harvest.log")
  printf '      harvest.log has %s lines now\n' "$b"
  [ "$b" -gt "$a" ]; check $? "harvest.log grew while nothing was attached" "it did not grow"
  [ "$(tmux list-clients 2>/dev/null | wc -l)" -eq 0 ]
  check $? "no client is attached" "detach with Ctrl+B d before running this check"
  ;;
ex2)
  has_session monitor; check $? "a session named monitor exists"
  w=$(tmux list-windows -t monitor 2>/dev/null)
  printf '%s\n' "$w" | grep -qE '^[0-9]+: logs[-*]? \(2 panes\)'
  check $? "window logs holds two panes"
  printf '%s\n' "$w" | grep -qE '^[0-9]+: notes[-*]? \(1 panes\)'
  check $? "window notes holds one pane"
  n=$(tmux list-panes -a -t monitor 2>/dev/null | wc -l)
  [ "$n" -eq 3 ]; check $? "the session holds three panes in total" "found $n"
  ;;
ex3)
  [ -f "$W/settings.conf" ]; check $? "settings.conf exists"
  n=$(lines "$W/settings.conf")
  [ "$n" -eq 3 ]; check $? "settings.conf holds three lines" "found $n"
  [ "$(grep -c '^threads = 4$' "$W/settings.conf" 2>/dev/null)" -eq 1 ]
  check $? "the line threads = 4 is on disk exactly once"
  ! has_session remote; check $? "no session named remote is left"
  ;;
hx1-open)
  has_session run; check $? "a session named run exists"
  w=$(tmux list-windows -t run 2>/dev/null)
  printf '%s\n' "$w" | grep -q ': job'; check $? "a window named job exists"
  printf '%s\n' "$w" | grep -q ': notes'; check $? "a window named notes exists"
  a=$(lines "$W/job.log")
  printf '      job.log has %s lines, waiting five seconds\n' "$a"
  sleep 5
  b=$(lines "$W/job.log")
  printf '      job.log has %s lines now\n' "$b"
  [ "$b" -gt "$a" ]; check $? "job.log grew while nothing was attached"
  [ ! -f "$W/handover.txt" ]
  check $? "handover.txt is not on disk yet" "it exists, so the buffer was written already"
  ;;
hx1-final)
  [ -f "$W/handover.txt" ]; check $? "handover.txt is on disk"
  [ "$(lines "$W/handover.txt")" -ge 1 ]; check $? "handover.txt holds at least one line"
  a=$(lines "$W/job.log")
  sleep 3
  [ "$(lines "$W/job.log")" -eq "$a" ]
  check $? "job.log stopped growing, so the job was stopped"
  ! has_session run; check $? "no session named run is left"
  ;;
cleanup)
  ! tmux ls > /dev/null 2>&1; check $? "no tmux server is running"
  ! screen -ls 2>/dev/null | grep -q '^\s*[0-9]'
  check $? "no screen session is left"
  [ ! -d "$W" ]; check $? "the working directory is gone" "$W still exists"
  ! pgrep -af 'bash .*ticker.sh' > /dev/null 2>&1
  check $? "no ticker process is left running"
  ;;
*)
  printf 'usage: %s ex1|ex2|ex3|hx1-open|hx1-final|cleanup\n' "${0##*/}" >&2
  exit 2
  ;;
esac

echo
if [ "$fails" -eq 0 ]; then
  echo "All criteria met."
else
  printf '%s criterion/criteria not met.\n' "$fails"
fi
exit "$fails"
