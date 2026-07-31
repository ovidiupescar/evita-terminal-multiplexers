# Reference for learners

A lookup page for after the module. Version scope: tmux 3.4 and GNU Screen
4.09.01 as shipped in Ubuntu 24.04, stock configuration, ordinary user
account.

## Which tool for which problem

| The problem | The answer |
|---|---|
| A command must survive a dropped connection and stay interactive | Run it in a session; detach with Ctrl+B d |
| A command must survive a disconnection and you never need to type into it again | `nohup command &` and read the file it writes |
| The work must survive a reboot of the machine | Neither. Use a batch job, and write results to disk |
| One connection, several things to watch | Panes in one window |
| One connection, several separate tasks | Windows in one session |
| Two people looking at one screen | Both attach the same session |
| Reading output that has scrolled past | Copy mode, Ctrl+B [ |

## tmux from the shell

| Command | Effect |
|---|---|
| `tmux new -s name` | Create a session and attach to it |
| `tmux new-session -d -s name` | Create it without attaching |
| `tmux ls` | List sessions; exit status 1 and `no server running on ...` when there are none |
| `tmux attach -t name` | Attach to a session by name |
| `tmux kill-session -t name` | End one session |
| `tmux kill-server` | End every session of this account |
| `tmux list-windows -t name` | List the windows of a session with their pane counts |
| `tmux list-panes -a -t name` | List every pane with its size |
| `tmux list-clients` | List the terminals currently drawing a session |
| `tmux display -p "#{pid}"` | Print the process id of the server |
| `tmux -V` | Print the version |

## tmux keys, all after the prefix Ctrl+B

| Key | Effect |
|---|---|
| `d` | Detach this client; the session keeps running |
| `c` | New window |
| `,` | Rename the current window; Ctrl+U clears the offered name first |
| `n`, `p` | Next window, previous window |
| `0` … `9` | Go to the window with that index |
| `w` | Window and session chooser; Escape leaves it |
| `%` | Split the pane left and right |
| `"` | Split the pane top and bottom |
| `o` | Next pane |
| arrow keys | Move to the pane in that direction |
| `q` | Show the pane numbers |
| `x` | Kill the current pane, after a `(y/n)` prompt |
| `z` | Zoom the current pane to the whole window, and back |
| `[` | Copy mode, for scrollback; `q` leaves it |
| `Ctrl+B` | Send one literal Ctrl+B to the program in the pane |
| `?` | List every binding |

## GNU Screen, for systems without tmux

| Operation | tmux | screen |
|---|---|---|
| Create and attach | `tmux new -s name` | `screen -S name` |
| Create detached | `tmux new-session -d -s name` | `screen -dmS name` |
| List | `tmux ls` | `screen -ls` |
| Attach | `tmux attach -t name` | `screen -r name` |
| Detach from inside | Ctrl+B d | Ctrl+A d |
| Kill from outside | `tmux kill-session -t name` | `screen -X -S name quit` |
| New window | Ctrl+B c | Ctrl+A c |
| Next window | Ctrl+B n | Ctrl+A n |
| Scrollback | Ctrl+B [ | Ctrl+A Esc |

The prefix is the difference that bites: Ctrl+A in screen is also the
default "beginning of line" key of the shell, so inside screen it takes two
presses to reach it.

## Messages and what they mean

| Message | State |
|---|---|
| `[detached (from session name)]` | You left; the session is still running |
| `[exited]` | The last shell in the session ended, so the session ended |
| `[server exited]` | `kill-server` ended every session of this account |
| `no server running on /tmp/tmux-1000/default` | Nothing of yours is running; the number is your user id |
| `no sessions` | A server is running but has no session by that name |
| `sessions should be nested with care, unset $TMUX to force` | You ran `tmux` inside a session; you wanted `tmux attach`, or nothing |
| `can't find session: name` | A server is running and that name is not among its sessions |
| `kill-pane 1? (y/n)` | Ctrl+B x is waiting for confirmation |

## Reading the status line

```text
[demo] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

`[demo]` is the session. `0:bash` is window 0, named after the command
running in its active pane. The star marks the current window and a dash
marks the previous one. The right-hand side is the host name, the time and
the date.

## Checking your own work

An editor in a session tells you about its buffer. The file system tells you
about the file. Ask the file system:

```console
$ md5sum file
$ wc -l file
$ grep -c "the line you added" file
```

and after a module or a work session, ask whether anything was left running:

```console
$ tmux ls
$ screen -ls
$ pgrep -af tmux
```

## Glossary

**Server**: one process per user on the machine, holding every session of
that user. Started by the first session, ends with the last one.

**Session**: a named collection of windows inside the server. Survives a
dropped connection; does not survive a reboot.

**Client**: a terminal attached to a session and drawing it. A session can
have several clients or none.

**Window**: one full screen inside a session, listed in the status line.

**Pane**: a rectangle inside a window, with a terminal and a process of its
own.

**Prefix**: the key that tells tmux the next keystroke is for it. Ctrl+B by
default, Ctrl+A in screen.

**Detach**: disconnect the client and leave everything running.

**Copy mode**: the state entered with Ctrl+B [ where keys move through the
pane's scrollback instead of reaching the program.

**SIGHUP**: the signal delivered to processes when their terminal goes
away. Its default action is to terminate the process, which is what a
dropped connection does to a command that is not in a session.

**Socket**: the file under `/tmp/tmux-<uid>/` through which clients talk to
the server. It carries no session data.

## Reading materials for further learning

- `man tmux`: the whole manual, and in particular DESCRIPTION and DEFAULT
  KEY BINDINGS.
- `man screen`: the same for GNU Screen.
- `man 7 signal`: SIGHUP, SIGINT, SIGTSTP and their default actions.
  SDS.OSV1-USE1.8 covers signals as a topic.
- SDS.OSV1-USE1.6: the editors this module runs inside a session.
