#!/bin/bash
# Evidence harvest for SDS.OSV1-USE1.7, part 1 of 2: the setup episode.
# Runs as root because it installs packages. Everything else in this module
# is harvested as an ordinary user by harvest.sh.
#
# AUTHORING PREPARATION, NOT A LEARNER STEP: the box used for authoring
# already had tmux installed, so this script removes it first to produce a
# genuine installation transcript. A learner starting from a fresh Ubuntu
# 24.04 image runs only the "apt-get install" part.
#
# Run it as:
#   tr -d '\r' < evidence/harvest-setup.sh | MSYS_NO_PATHCONV=1 wsl -u root -- \
#     env TERM=dumb bash -c 'cat > /root/hs.sh; bash /root/hs.sh > /root/ts.txt 2>&1'
#   MSYS_NO_PATHCONV=1 wsl -u root -- cat /root/ts.txt > evidence/transcript-setup.txt
set -u
export DEBIAN_FRONTEND=noninteractive
TMPO=/root/.harvest-out

sec() { echo; echo "===== $* ====="; echo; }
blks() {
  echo "\$ $1"
  eval "$1" > "$TMPO" 2>&1
  local rc=$?
  cat "$TMPO"
  echo "[exit $rc]"
}

sec "BASELINE IDENTITY"
blks 'cat /etc/os-release | head -3'
blks 'uname -r'
blks 'id'

sec "AUTHORING PREPARATION: remove the pre-installed tmux"
blks 'apt-get remove -y tmux'
blks 'command -v tmux || echo "tmux: not on PATH"'

sec "STATE BEFORE THE LEARNER STEP"
blks 'command -v tmux screen || echo "neither tmux nor screen is installed"'
blks 'apt-cache policy tmux | head -3'
blks 'apt-cache policy screen | head -3'

sec "LEARNER STEP 1: refresh the package index"
blks 'apt-get update'

sec "LEARNER STEP 2: install the two multiplexers"
blks 'apt-get install -y tmux screen'

sec "LEARNER STEP 3: verify the installation"
blks 'tmux -V'
blks 'screen --version'
blks 'command -v tmux screen'

sec "RESTORE ANYTHING THE REMOVAL PULLED OUT"
blks 'apt-get install -y ubuntu-wsl'
blks 'dpkg -l tmux screen | tail -3'

sec "MANUAL PAGES SHIPPED WITH THE PACKAGES"
blks 'ls -l /usr/share/man/man1/tmux.1.gz /usr/share/man/man1/screen.1.gz'

sec "SOURCE QUOTATIONS CHECKED AGAINST THE SHIPPED MANUALS"
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | grep -n -m1 -A3 "is a terminal multiplexer"'
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | grep -n -m1 -A2 "Each session is persistent"'
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | grep -n -m1 -A2 "a session is displayed on screen"'
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | grep -n -m1 -A1 "Once all sessions are"'
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | sed -n "129,137p"'
blks 'MANWIDTH=78 man tmux 2>/dev/null | col -bx | grep -n -m1 -A2 "^ *d *Detach"'
blks 'MANWIDTH=78 man screen 2>/dev/null | col -bx | grep -n -m1 -A5 "full-screen window manager"'
blks 'MANWIDTH=78 man screen 2>/dev/null | col -bx | grep -n -m1 -A4 "detach.*screen session"'

sec "HARVEST COMPLETE"
blks 'date -u +%Y-%m-%dT%H:%M:%SZ'
rm -f "$TMPO"
