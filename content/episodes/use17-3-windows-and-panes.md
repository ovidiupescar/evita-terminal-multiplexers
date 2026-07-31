# Windows and panes: several views in one connection

The second reason to run a multiplexer has nothing to do with dropped
connections. One SSH connection gives you one screen, and the work needs
three: the job's output, a shell to check things in, and the file you are
editing. A session holds **windows**, a window holds **panes**, and both are
reached with the same prefix key from Episode 2.

:::{objectives}
- Split a window into panes and move between them.
- Open, name and switch between windows in one session.
- Read scrollback inside a pane with copy mode.
- Give the use cases that this layout answers, and recognise `screen` as the
  same model with different keys.
:::

:::{instructor-note}
- 10 min worked, 8 min guided, 7 min independent
- The keystrokes are the whole difficulty. Learners lose the prefix
  constantly at first; say out loud "Ctrl+B, let go, then the key" for the
  first few
- `Ctrl+B ,` pre-fills the current window name and appends what you type.
  Learners who do not clear it end up with `bashnotes`. This is in the
  worked example on purpose
- Adaptation: the `screen` section can be dropped for cohorts whose target
  system carries tmux; keep it for anyone heading to an unfamiliar cluster
:::

## Entry check

:::::{discussion}
You are watching a log with `tail -f` in your only terminal, and you need to
run `wc -l` on the same file. Name two ways to do that without a
multiplexer, and one cost of each.

::::{solution}
:class: dropdown

Stop the `tail`, run the command, start `tail` again: you lose the lines
that arrived in between. Or open a second SSH connection: you now have two
connections to manage, two working directories to set up, and both die
independently. A window with two panes costs neither.

::::
:::::

## Worked example: two panes in one window

:::{demo}

**Step 1. Start a session for the layout.**

```console
$ tmux new -s layout
```

```text
trainee@trainvm:~/use17$
[layout] 0:bash*                                       "trainvm" 10:05 31-Jul-26
```

**Step 2. Split it side by side: Ctrl+B then %.**

```text
trainee@trainvm:~/use17$                 │trainee@trainvm:~/use17$
                                        │
[layout] 0:bash*                                       "trainvm" 10:05 31-Jul-26
```

The vertical line is the pane border. Both panes hold a shell, both start in
the directory the window was in, and the cursor is in the new one on the
right.

**Step 3. Give the right pane a job.**

```text
trainee@trainvm:~/use17$                 │trainee@trainvm:~/use17$ tail -f ~/use17
                                        │/build.log
                                        │10:05:02 tick 1
                                        │10:05:03 tick 2
                                        │10:05:04 tick 3
                                        │10:05:05 tick 4
                                        │10:05:06 tick 5
                                        │10:05:07 tick 6
                                        │10:05:08 tick 7
                                        │10:05:09 tick 8
                                        │10:05:10 tick 9
[layout] 0:tail*                                       "trainvm" 10:05 31-Jul-26
```

The window name in the status line changed from `bash` to `tail`: by default
tmux names a window after the command running in the active pane.

**Step 4. Move to the other pane: Ctrl+B then o.**

```text
trainee@trainvm:~/use17$ wc -l ~/use17/bu│trainee@trainvm:~/use17$ tail -f ~/use17
ild.log                                 │/build.log
11 /home/trainee/use17/build.log         │10:05:02 tick 1
trainee@trainvm:~/use17$                 │10:05:03 tick 2
                                        │10:05:04 tick 3
                                        │10:05:05 tick 4
                                        │10:05:06 tick 5
                                        │10:05:07 tick 6
                                        │10:05:08 tick 7
                                        │10:05:09 tick 8
                                        │10:05:10 tick 9
                                        │10:05:11 tick 10
                                        │10:05:12 tick 11
                                        │10:05:13 tick 12
[layout] 0:bash*                                       "trainvm" 10:05 31-Jul-26
```

The left pane answered a question while the right pane kept reading. That is
the use case: two things at once, in one connection, in one directory.

`Ctrl+B o` cycles. `Ctrl+B` and an arrow key goes in a direction, which is
easier once there are more than two panes.

**Step 5. Split again, top and bottom: Ctrl+B then "**.

```text
trainee@trainvm:~/use17$ wc -l ~/use17/bu│trainee@trainvm:~/use17$ tail -f ~/use17
ild.log                                 │/build.log
11 /home/trainee/use17/build.log         │10:05:02 tick 1
trainee@trainvm:~/use17$                 │10:05:03 tick 2
                                        │10:05:04 tick 3
                                        │10:05:05 tick 4
                                        │10:05:06 tick 5
                                        │10:05:07 tick 6
                                        │10:05:08 tick 7
                                        │10:05:09 tick 8
                                        │10:05:10 tick 9
────────────────────────────────────────┤10:05:11 tick 10
trainee@trainvm:~/use17$ date; uptime    │10:05:12 tick 11
Fri Jul 31 10:05:15 EEST 2026           │10:05:13 tick 12
 10:05:15 up 1 min,  1 user,  load avera│10:05:14 tick 13
ge: 0.03, 0.01, 0.00                    │10:05:15 tick 14
trainee@trainvm:~/use17$                 │10:05:16 tick 15
                                        │10:05:17 tick 16
[layout] 0:bash*                                       "trainvm" 10:05 31-Jul-26
```

Note what a narrow pane does to output: `load average` wrapped mid-word.
Panes are terminals, and a 40-column terminal wraps at 40 columns. Keep the
pane that has to stay readable wide.

**Step 6. Ask which pane is which: Ctrl+B then q.**

tmux writes a large number into each pane for a moment. Those numbers are
the pane indexes that `Ctrl+B q <number>` jumps to.

:::

## Guided practice: windows

A window is a whole screen inside the session. Use windows for separate
tasks and panes for views of one task.

:::{type-along}

1. **Ctrl+B c** opens a new window. The status line now lists both, and the
   star moves to the new one:

   ```text
   [layout] 0:bash- 1:bash*                               "trainvm" 10:05 31-Jul-26
   ```

   The dash marks the window you were in before.

2. **Ctrl+B ,** renames the current window. tmux offers the current name
   with the cursor at the end of it:

   ```text
   (rename-window) bash
   ```

   Typing now appends to `bash`. Press **Ctrl+U** first to clear the line,
   then type the new name and press Enter:

   ```text
   [layout] 0:bash- 1:notes*                              "trainvm" 10:05 31-Jul-26
   ```

3. **Ctrl+B n** goes to the next window, **Ctrl+B p** to the previous one,
   and **Ctrl+B 0** to window 0 by its index.

4. **Ctrl+B w** lists the windows in a chooser you move through with the
   arrow keys. Enter selects, Escape leaves it.

Checkpoint: `tmux list-windows` prints the same information as text.

```console
$ tmux list-windows -t layout
0: bash- (2 panes) [80x24] [layout 8205,80x24,0,0{40x24,0,0,0,39x24,41,0,1}] @0
1: notes* (1 panes) [80x24] [layout b25f,80x24,0,0,2] @1 (active)
```

:::

## Reading what scrolled past

The mouse wheel does not scroll a pane's history on a stock configuration.
**Ctrl+B [** enters copy mode, where the arrow keys, PageUp and PageDown
move through the scrollback and an indicator in the corner counts your
position:

```text
────────────────────────────────────────┤10:05:21 tick 20
42                       10:05:27 [9/55]│10:05:22 tick 21
43                                      │10:05:23 tick 22
44                                      │10:05:24 tick 23
45                                      │10:05:25 tick 24
46                                      │10:05:26 tick 25
47                                      │10:05:27 tick 26
[layout] 0:[tmux]* 1:notes-                            "trainvm" 10:05 31-Jul-26
```

`[9/55]` means nine lines above the bottom, out of 55 in the history. The
window name shows `[tmux]` while copy mode is active, which is the signal
that the pane is not accepting keys for the program any more. Press **q** to
leave.

## When it breaks

### Closing a pane

**Ctrl+B x** asks first, replacing the status line with a prompt:

```text
kill-pane 1? (y/n)
```

Answer `y` and the pane is gone; the remaining pane takes the whole window.
Answer `n` and nothing happens. The same thing happens without the prompt
when the shell in a pane exits.

### The last pane, and the last window

Closing the last pane of a window closes the window. Closing the last window
of a session ends the session, exactly as `exit` did in Episode 2. The status
line is the check: as long as it lists a window, the session is there.

A detached session keeps its whole layout:

```text
trainee@trainvm:~/use17$ tmux new -s layout
[detached (from session layout)]
trainee@trainvm:~/use17$ tmux ls
layout: 2 windows (created Fri Jul 31 10:05:04 2026)
```

and `tmux kill-session -t layout` ends it with its windows and panes
together.

## The same model in GNU Screen

`screen` is older than tmux and is installed on systems that do not carry
tmux. The model is the same, and the keys are not: its prefix is **Ctrl+A**.

```console
$ screen -ls
No Sockets found in /run/screen/S-trainee.

$ screen -dmS jobs bash
$ screen -ls
There is a screen on:
	989.jobs	(07/31/26 10:05:41)	(Detached)
1 Socket in /run/screen/S-trainee.
```

`screen -dmS jobs bash` is `tmux new-session -d -s jobs` in the other
dialect. Attach it with `screen -r jobs`, and the screen has no status line
at all:

```text
trainee@trainvm:~/use17$ echo this shell runs inside screen
this shell runs inside screen
trainee@trainvm:~/use17$
```

Detach with **Ctrl+A d**:

```text
trainee@trainvm:~/use17$ screen -r jobs
[detached from 989.jobs]
trainee@trainvm:~/use17$ screen -ls
There is a screen on:
        989.jobs        (07/31/26 10:05:41)     (Detached)
1 Socket in /run/screen/S-trainee.
```

and end it from outside with `screen -X -S jobs quit`:

```text
trainee@trainvm:~/use17$ screen -X -S jobs quit; screen -ls
No Sockets found in /run/screen/S-trainee.
```

The number in `989.jobs` is the process id of that session, so it differs
every time. What to carry away: if a machine has no tmux, the same three
operations exist under different names, and the detach key is Ctrl+A d.

| Operation | tmux | screen |
|---|---|---|
| Start a named session | `tmux new -s name` | `screen -S name` |
| Start it detached | `tmux new -s name -d` | `screen -dmS name` |
| List | `tmux ls` | `screen -ls` |
| Reattach | `tmux attach -t name` | `screen -r name` |
| Detach from inside | Ctrl+B d | Ctrl+A d |
| Kill from outside | `tmux kill-session -t name` | `screen -X -S name quit` |
| New window | Ctrl+B c | Ctrl+A c |
| Next window | Ctrl+B n | Ctrl+A n |

## Independent task

:::::{exercise}
**A layout for a real task.**

You are running a preprocessing job on a remote machine and you want, in one
connection: the job's log as it grows, a shell in the same directory for
checking file sizes, and a separate window for the notes you are taking.

Build a session called `monitor` with:

1. a window named `logs` holding two panes;
2. a second window named `notes` holding one pane;
3. the session detached at the end, so that `tmux ls` lists it.

Success criteria: `tmux list-windows -t monitor` shows exactly two windows
with those names and those pane counts, and `tmux list-panes -a -t monitor`
shows three panes in total. Then state, in one sentence per view, which use
case each of the three panes serves.

::::{solution}
:class: dropdown

Interactively: `tmux new -s monitor`, then `Ctrl+B ,` `Ctrl+U` `logs`
Enter, then `Ctrl+B %`, then `Ctrl+B c`, then `Ctrl+B ,` `Ctrl+U` `notes`
Enter, then `Ctrl+B d`.

The same thing from the shell, which is also how the criteria are checked:

```console
$ tmux new-session -d -s monitor -c "$HOME/use17"
$ tmux rename-window -t monitor:0 logs
$ tmux split-window -h -t monitor:logs
$ tmux new-window -t monitor -n notes
$ tmux list-windows -t monitor
0: logs- (2 panes) [80x24] [layout 8205,80x24,0,0{40x24,0,0,0,39x24,41,0,1}] @0
1: notes* (1 panes) [80x24] [layout b25f,80x24,0,0,2] @1 (active)
$ tmux list-panes -a -t monitor
monitor:0.0: [40x24] [history 0/2000, 960 bytes] %0
monitor:0.1: [39x24] [history 0/2000, 960 bytes] %1 (active)
monitor:1.0: [80x24] [history 0/2000, 960 bytes] %2 (active)
$ tmux ls
monitor: 2 windows (created Fri Jul 31 10:19:40 2026)
$ tmux kill-session -t monitor; tmux ls
no server running on /tmp/tmux-1000/default
```

The two panes of `logs` are one task seen twice: the log arriving, and a
shell to ask questions about the files it names. The `notes` window is a
different task, which is why it is a window and not a third pane: you switch
to it, you do not watch it.

::::
:::::

## Retrieval check

:::::{discussion}
1. You press Ctrl+B then a letter and something unexpected happens. What did
   tmux do with the letter?
2. What is the difference between closing a pane and detaching?
3. `screen -ls` prints `No Sockets found`. What does that tell you, and
   what would the tmux equivalent have printed?

::::{solution}
:class: dropdown

1. It read it as a command key. Every key that follows the prefix is tmux's,
   not the program's, until the command is complete.
2. Closing a pane ends the shell in it and destroys it; when it was the last
   pane, the window and possibly the session go too. Detaching destroys
   nothing: the client leaves and everything keeps running.
3. That no screen session of yours exists on this machine. tmux would have
   said `no server running on /tmp/tmux-1000/default`.

::::
:::::

:::{keypoints}
- A session holds windows; a window holds panes. Panes are views of one
  task, windows are separate tasks.
- `Ctrl+B %` and `Ctrl+B "` split, `Ctrl+B o` and the arrow keys move,
  `Ctrl+B c` opens a window, `Ctrl+B ,` renames it after `Ctrl+U` clears the
  offered name.
- `Ctrl+B [` enters copy mode for scrollback, `q` leaves it.
- A pane is a terminal of its own width, so narrow panes wrap output.
- `screen` is the same model with Ctrl+A as its prefix, and it is what you
  find when a machine has no tmux.
:::

:::{seealso}
- `man tmux`, section DEFAULT KEY BINDINGS, for the full table.
- `man screen`, section DEFAULT KEY BINDINGS, for the Ctrl+A equivalents.
- {doc}`use17-4-editing-in-a-session` puts an editor in one of these panes.
:::
