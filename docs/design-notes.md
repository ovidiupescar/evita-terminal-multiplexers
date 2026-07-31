# Design notes: SDS.OSV1-USE1.7 "Terminal multiplexers"

Written before any episode text, in the order the authoring skill
requires: learner model, official outcomes, assessments, then the episodes
that bridge between the checks. These notes are authoring material and are
not part of the built site.

## Learner model

Role: a researcher, engineer or student who has an account on a shared
Linux machine or an HPC login node and reaches it over SSH from a laptop.

Prior knowledge assumed:

- A shell prompt, `cd`, `ls`, relative and absolute paths (SDS.OSV1-USE1.3).
- Opening a file in nano or Vim, typing, writing and leaving
  (SDS.OSV1-USE1.6). This module reuses both editors and teaches neither.
- Running a command that takes time and watching its output scroll.

Not assumed:

- Job control (`&`, `jobs`, `fg`, `bg`, `nohup`). SDS.OSV1-USE1.8 teaches
  it. This module names `nohup` once, as the different technique it is, and
  does not use it.
- Batch schedulers. Slurm appears only in the instructor guide's note about
  what belongs in a batch job rather than in a login-node session.
- Any tmux configuration. The module runs on stock defaults with no
  `~/.tmux.conf`, which is what a learner meets on a machine they do not
  administer.

Hardware and access: one disposable Ubuntu 24.04 machine with an ordinary
user account. No root beyond the two package installs in the setup episode,
no cluster account, no network service.

Language: English is a second language for a large part of the audience.
Key names are written out (Ctrl+B, then d) rather than in the compressed
`C-b d` form used by the tmux manual, and the compressed form is introduced
once so the manual stays readable.

Barriers observed in this population:

- The first tmux session is entered by typing one word and left by a key
  combination that nothing on screen advertises. A learner who does not
  know Ctrl+B d ends the session with `exit` and concludes that nothing was
  gained.
- The prefix key collides with editor and shell bindings, which makes the
  first editing session inside tmux feel broken rather than different.
- Scrollback stops behaving like the terminal's scrollback, and the mouse
  wheel does something unexpected.

## Documented misconceptions

Each distractor in `questions.yaml` maps to one of these.

- **M1** A multiplexer is a way to split the screen; the value is layout.
- **M2** The session belongs to the terminal window or to the SSH
  connection, so closing either ends it.
- **M3** Detaching stops the running command, the way Ctrl+Z does.
- **M4** `exit` in the last pane detaches, the way Ctrl+B d does.
- **M5** Sessions survive a reboot of the host, because they are "saved".
- **M6** The prefix key reaches the program in the pane, so Ctrl+B w is the
  editor's binding.
- **M7** Running `tmux` inside a session is how you return to it, and
  produces another view of the same session.
- **M8** A second client cannot attach, or attaching from a second terminal
  takes the session away from the first.
- **M9** A multiplexer protects an unwritten editor buffer: killing the
  session is safe because tmux "has" the text.
- **M10** Scrollback inside a pane is the terminal's scrollback, so the
  mouse wheel and Shift+PageUp reach the history.
- **M11** `screen` and `tmux` are the same program under two names, with
  the same keys.
- **M12** A detached session is paused; output stops until somebody
  attaches.

## Boundary with the neighbouring modules

- **SDS.OSV1-USE1.6 (CLI file editors)** teaches opening, writing and
  saving in nano and Vim. This module assumes that skill and adds one
  thing: the editor is running inside a session that the learner can leave
  and come back to. No nano or Vim command is taught here for its own sake;
  Episode 4 links back for the editor itself.
- **SDS.OSV1-USE1.8 (background processes and signaling)** teaches Ctrl+C,
  Ctrl+Z, `jobs` and `kill`. Episode 2 has to distinguish detaching from
  stopping, so it names Ctrl+Z once and points forward rather than teaching
  job control.
- **SDS.OSV1-USE1.3 (UNIX file system tree)** supplies the reading of
  `/tmp/tmux-1000/default` as a socket in a volatile directory, which
  Episode 2 uses when it explains why a reboot leaves nothing behind.

## Outcome to episode map

| Outcome | Episodes | Certifying evidence |
|---|---|---|
| O1 give examples for use cases | 2, 3 | ex1, ex2, q1–q3, hx1 |
| O2 review editing files using a multiplexer | 4 | ex3, q4, q5, hx1 |

Episode 1 carries no outcome: it installs the two packages and creates the
working directory.

## Episode outline

### Episode 1: setup (`use17-1-setup.md`)

Tabs per host OS, all four leading to the same Ubuntu 24.04 shell. Install
`tmux` and `screen` with apt. Verify with `tmux -V` and `screen --version`.
Create `~/use17`. State the disposable-environment note before the first
`sudo`. HPC note: on a login node the multiplexer is usually installed
already, so `which tmux` replaces the install.

### Episode 2: sessions that outlive the connection (`use17-2-sessions.md`)

Concept-then-procedure. Entry check on what happens to a running command
when its terminal goes away.

1. **Prediction**: a command is started in a shell; the shell's terminal is
   closed. Does the command continue?
2. **Contrasting evidence**: the same command started in a plain shell and
   in a tmux session, each with its terminal taken away. The plain one is
   gone, the tmux one is still running and still writing to its file. This
   is the evidence for the whole module and it is executed, not asserted.
3. **Model**: server, session, client. `tmux ls` read against `pstree` so
   the learner sees the server as a process that owns the shell.
4. **Worked example**: `tmux new -s demo`, run something, Ctrl+B d,
   `tmux ls`, `tmux attach -t demo`.
5. **Guided practice**: a named session of the learner's own with a
   different command in it, detached and reattached.
6. **When it breaks**: `exit` in the last pane ends the session (M4);
   `tmux attach` then reports no server. Second failure: `tmux` inside a
   session answers "sessions should be nested with care" (M7).
7. **Independent exercise ex1**: a changed context — start a session that
   writes timestamps to a file, detach, prove from outside the session that
   the file keeps growing, reattach, stop it, kill the session by name.
8. **Retrieval check rc1** and a transfer prompt about the reboot (M5).

### Episode 3: windows and panes (`use17-3-windows-and-panes.md`)

Procedure. One connection, several views: the second family of use cases.

1. **Worked example**: split a window with Ctrl+B % and Ctrl+B ", move
   between panes with Ctrl+B o and the arrow keys, watch a log in one pane
   while a command runs in the other.
2. **Guided practice**: a second window with Ctrl+B c, rename with
   Ctrl+B , , switch with Ctrl+B n and Ctrl+B 0.
3. Copy mode with Ctrl+B [ for scrollback (M10), left with q.
4. **When it breaks**: closing the last pane of a window closes the window;
   closing the last window ends the session.
5. **Independent exercise ex2**: build a two-pane, two-window layout for a
   described monitoring task and describe which use case each view serves.
6. **Retrieval check rc2**.

`screen` appears here as one short section: same session model, different
prefix (Ctrl+A), the fallback found on clusters that carry no tmux (M11).
It is executed, not described.

### Episode 4: editing a file inside a session (`use17-4-editing-in-a-session.md`)

Procedure, and the spine for O2.

1. **Worked example**: open a file in nano inside a session, type, detach
   with the buffer unwritten, reattach, finish, write, verify from outside
   the session with `cat` and a checksum.
2. **Guided practice**: the same cycle in Vim, including the prefix
   collision (M6) and how to send a literal Ctrl+B with Ctrl+B Ctrl+B.
3. **When it breaks**: the session is killed while the buffer is unwritten.
   The file on disk is unchanged; Vim's swap file is on disk and
   `vim -r` recovers (M9). This is the staged failure that carries q5.
4. **Independent exercise ex3**: a changed context — a file that must be
   edited across a simulated disconnect, with success criteria stated as
   the content on disk rather than the state of the screen.
5. **Retrieval check rc3**, transfer prompt, verified cleanup: kill the
   server, remove `~/use17`, verify both.

## Evidence plan

The harvest technique is the subject matter, so the two are kept apart by
socket name:

- The **outer** server (`tmux -L harvest -f /dev/null`) is the authoring
  tool. It holds a pane fixed at 80x24 whose contents are captured.
- The **inner** server is the learner's, on the default socket, so
  `tmux ls` inside the captured pane lists only the sessions the episode
  created.

Staged failures to harvest, each quoted in an episode:

1. A command started in a plain shell dies when its terminal goes away; the
   same command in a session does not.
2. `exit` in the last pane ends the session; `tmux attach` then reports no
   server on the socket.
3. `tmux` inside a session prints the nesting refusal.
4. `tmux kill-session` while Vim holds an unwritten buffer; the file is
   unchanged and the swap file is present; `vim -r` reports what it found.
5. Attaching a session that does not exist.

Volatile values (PIDs, socket paths carrying the uid, host name, dates)
are normalized through `masks.yaml`. Line counts, byte counts, checksums
and pane geometry are left as harvested, because they are the evidence.
