# Sessions that outlive the connection

A job on a login node takes forty minutes. The laptop that started it is on a
train. When the connection drops, what happens to the job? This episode
answers that with two runs of the same command, and then builds the model
that explains the difference: a **server** process on the remote machine
owns the **session**, and the terminal you look at is only a **client**.

:::{objectives}
- Give the use cases a terminal multiplexer answers, starting with a command
  that has to survive a dropped connection.
- Start, detach from, list, reattach and kill a named tmux session.
- Say what a session does not survive.
:::

:::{instructor-note}
- 10 min framing and experiment, 10 min worked example, 5 min guided, 10 min
  independent
- The experiment in "Two runs of one command" is the load-bearing evidence
  of the whole module. Run it live if you demonstrate; it takes 20 seconds
- Setup risk: a learner whose machine has a `~/.tmux.conf` has a different
  prefix key. The setup episode's verification block catches it
- Adaptation: learners who already use tmux daily can go straight to
  "When it breaks" and the independent task; the two-client section is the
  part they most often have not seen
:::

## Entry check

:::::{discussion}

1. You start a long command over SSH and close the laptop lid. Which
   process, on which machine, decides whether that command keeps running?
2. `nohup` also keeps a command alive after a disconnection. What can it
   not give you back at the next login?

::::{solution}
:class: dropdown

1. The command runs on the **remote** machine. What ends it is a signal
   delivered there when the terminal it is attached to disappears, not
   anything the laptop does.
2. Its output as a live screen, and the ability to type into it again.
   `nohup` protects one command and redirects its output to a file; it does
   not give you a terminal to return to.

::::
:::::

## Two runs of one command

The fixture is a script that prints one line per second until it is stopped.
Create it in the working directory from the setup episode:

```console
$ cd ~/use17
$ cat ticker.sh
#!/bin/bash
# prints one line per second until it is stopped
i=0
while true; do
  i=$((i+1))
  printf "%s tick %d\n" "$(date +%H:%M:%S)" "$i"
  sleep 1
done
$ chmod +x ticker.sh
```

### Case A: the terminal goes away

To lose a terminal without losing this one, run the ticker on a
pseudo-terminal of its own. `script` provides one; destroying `script` takes
that terminal away exactly as a dropped connection takes yours away.

```console
$ setsid script -q -c "$HOME/use17/ticker.sh > $HOME/use17/plain.log 2>&1" /dev/null < /dev/null > /dev/null 2>&1 &
$ pstree -p 312
script(312)---bash(314)---ticker.sh(315)---sleep(369)
$ cat plain.log; echo "-- $(wc -l < plain.log) lines"
10:04:05 tick 1
10:04:06 tick 2
10:04:07 tick 3
10:04:08 tick 4
-- 4 lines
```

Now destroy the terminal, wait, and look again:

```console
$ kill 312
$ sleep 3; cat plain.log; echo "-- $(wc -l < plain.log) lines"
10:04:05 tick 1
10:04:06 tick 2
10:04:07 tick 3
10:04:08 tick 4
10:04:09 tick 5
-- 5 lines
$ pgrep -af ticker.sh || echo "no ticker.sh process is running"
no ticker.sh process is running
```

Three seconds passed and the file gained nothing. The ticker is gone. When a
terminal disappears, the kernel sends **SIGHUP** to the processes attached
to it, and the default action for SIGHUP is to terminate. That is what a
dropped SSH connection does to the command you started.

### Case B: the same command inside a session

```console
$ tmux new-session -d -s work -c "$HOME/use17" "$HOME/use17/ticker.sh > $HOME/use17/tmux.log 2>&1"
$ sleep 4; cat tmux.log; echo "-- $(wc -l < tmux.log) lines"
10:04:12 tick 1
10:04:13 tick 2
10:04:14 tick 3
10:04:15 tick 4
10:04:16 tick 5
-- 5 lines
$ tmux ls
work: 1 windows (created Fri Jul 31 10:04:12 2026)
$ sleep 4; cat tmux.log; echo "-- $(wc -l < tmux.log) lines"
10:04:12 tick 1
10:04:13 tick 2
10:04:14 tick 3
10:04:15 tick 4
10:04:16 tick 5
10:04:17 tick 6
10:04:18 tick 7
10:04:19 tick 8
10:04:20 tick 9
-- 9 lines
```

No terminal is showing that session: `-d` started it detached and nothing
has attached since. The counter went from five to nine anyway. Stop it and
confirm the processes are gone:

```console
$ tmux kill-session -t work
$ pgrep -af ticker.sh || echo "no ticker.sh process is running"
no ticker.sh process is running
```

Same script, same machine, two different fates. The difference is who owns
the terminal the script is attached to.

## Server, session, client

tmux(1) states the arrangement:

> In tmux, a session is displayed on screen by a client and all sessions are
> managed by a single server. The server and each client are separate
> processes which communicate through a socket in /tmp.

Three things, and they can end at three different times:

| Part | What it is | Ends when |
|---|---|---|
| Server | One process per user, started by the first session | The last session is killed, or the machine stops |
| Session | A collection of terminals inside the server | You kill it, or the last shell in it exits |
| Client | The terminal you are looking at | You detach, or the connection drops |

The evidence is in the process table. Start a session and ask tmux for the
two process ids:

```console
$ tmux new-session -d -s demo -c "$HOME/use17"
$ tmux display -p -t demo "server pid #{pid}, session #{session_name}, pane pid #{pane_pid}"
server pid 445, session demo, pane pid 446
$ pstree -p $(tmux display -p -t demo "#{pid}")
tmux: server(445)---bash(446)
$ ps -o pid,ppid,tty,stat,comm,args -p $(tmux display -p -t demo "#{pid}")
    PID    PPID TT       STAT COMMAND         COMMAND
    445     261 ?        Ss   tmux: server    tmux new-session -d -s demo -x 80 -y 24 -c /home/trainee/use17
$ ps -o pid,ppid,tty,stat,comm,args -p $(tmux display -p -t demo "#{pane_pid}")
    PID    PPID TT       STAT COMMAND         COMMAND
    446     445 pts/2    Rs+  bash            -bash
```

Read the `TT` column. The shell in the session sits on `pts/2`, a terminal
the server created. The server itself has `?`: no terminal at all. That is
the whole trick. Your SSH connection can take its terminal away without
touching the terminal your commands are attached to.

The socket the clients connect through is a file:

```console
$ ls -l /tmp/tmux-$(id -u)/
total 0
srw-rw---- 1 trainee trainee 0 Jul 31 10:04 default
```

`1000` in that path is your numeric user id, and `default` is the socket
name. Sessions are memory inside the running server, not files under that
directory.

## Worked example: the session lifecycle

:::{demo}

**Step 1. Start a named session.**

```console
$ tmux new -s demo
```

The screen clears and a status line appears at the bottom:

```text
trainee@trainvm:~/use17$
[demo] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

`[demo]` is the session name, `0:bash` is window 0 running a shell, and the
star marks the current window. The shell inside is an ordinary shell in the
directory the session was created in.

**Step 2. Start something that keeps running.**

```text
trainee@trainvm:~/use17$ ./ticker.sh
10:04:26 tick 1
10:04:27 tick 2
10:04:28 tick 3
10:04:29 tick 4
[demo] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

**Step 3. Detach: press Ctrl+B, release both keys, then press d.**

Ctrl+B is the **prefix**. tmux takes it and reads the next key as a command
for itself. The client exits and reports why:

```text
trainee@trainvm:~/use17$ tmux new -s demo
[detached (from session demo)]
trainee@trainvm:~/use17$
```

You are back in the shell you started from. The status line is gone, because
the status line belongs to the client and there is no client any more.

**Step 4. Ask what is still there.**

```text
trainee@trainvm:~/use17$ tmux ls
demo: 1 windows (created Fri Jul 31 10:04:24 2026)
trainee@trainvm:~/use17$
```

**Step 5. Reattach and read the counter.**

```console
$ tmux attach -t demo
```

```text
trainee@trainvm:~/use17$ ./ticker.sh
10:04:26 tick 1
10:04:27 tick 2
10:04:28 tick 3
10:04:29 tick 4
10:04:30 tick 5
10:04:31 tick 6
10:04:32 tick 7
10:04:33 tick 8
10:04:34 tick 9
10:04:35 tick 10
10:04:36 tick 11
10:04:37 tick 12
10:04:38 tick 13
10:04:39 tick 14
10:04:40 tick 15
[demo] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

Tick 4 was the last line before the detach and tick 15 is on the screen now.
Nothing was watching in between and the script did not care.

:::

## Guided practice

:::{type-along}

Do the same with a session of your own, using a command that leaves a trace
you can check from outside.

1. `tmux new -s train`
2. In the session: `date > ~/use17/train.log; ./ticker.sh >> ~/use17/train.log`
3. Detach with Ctrl+B then d.
4. From the shell: `wc -l ~/use17/train.log`, wait five seconds, run it
   again. The number grows while you are detached.
5. `tmux attach -t train`, stop the ticker with Ctrl+C.
6. Detach again, then end the session by name: `tmux kill-session -t train`.
7. `tmux ls` reports `no server running on /tmp/tmux-1000/default`, because
   that was the only session.

Checkpoint after step 4: if the count does not grow, the ticker is not
running. Reattach and look at the pane rather than guessing.

:::

## One session, two clients

A session is not tied to one terminal. Attach the same session from a second
terminal and both draw it:

```console
$ tmux list-clients -F "#{client_tty} #{client_width}x#{client_height} #{client_session}"
/dev/pts/2 80x24 pair
/dev/pts/4 80x24 pair
```

A command typed in one appears in the other. This is the second client:

```text
trainee@trainvm:~/use17$ echo this line was typed in the second client
this line was typed in the second client
trainee@trainvm:~/use17$
[pair] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

and this is the first, captured at the same moment:

```text
trainee@trainvm:~/use17$ echo this line was typed in the second client
this line was typed in the second client
trainee@trainvm:~/use17$
[pair] 0:bash*                                         "trainvm" 10:04 31-Jul-26
```

Two people on the same login node, attached to the same session, see one
screen and can both type. That is the use case for walking a colleague
through a failure without sending screenshots.

## When it breaks

### The last shell exits and the session goes with it

Inside a session with one window and one pane, typing `exit` ends the shell.
The session has nothing left to hold, so it ends too, and the client reports
`[exited]` rather than `[detached]`:

```text
trainee@trainvm:~/use17$ tmux attach -t demo
[exited]
trainee@trainvm:~/use17$ tmux ls
no server running on /tmp/tmux-1000/default
trainee@trainvm:~/use17$ tmux attach -t demo
no sessions
```

Two different messages for two different states: `no server running on ...`
when nothing of yours is left at all, and `no sessions` when a server is
running but has no session by that name. Leave with **Ctrl+B d** when you
want the session to stay.

`tmux kill-server` from inside a session produces a third message,
`[server exited]`, and ends every session you have.

### Starting tmux inside tmux

```text
trainee@trainvm:~/use17$ tmux
sessions should be nested with care, unset $TMUX to force
trainee@trainvm:~/use17$
```

tmux sets `$TMUX` in every shell it starts, sees it, and declines. The
mistake behind it is treating `tmux` as the command that returns you to your
session. It is not: `tmux attach` is, and from inside a session you are
already there.

## Independent task

:::::{exercise}
**A session that proves itself.**

Build a session called `harvest` that keeps working while you are not
looking, and prove it from outside the session rather than from the screen.

Success criteria, all checked from a shell with no client attached:

1. `tmux ls` lists a session named `harvest`.
2. A file `~/use17/harvest.log` grows by at least five lines between two
   readings taken five seconds apart, while no client is attached.
3. After you kill the session by name, `tmux ls` reports no server, the log
   stops growing, and `pgrep -af "bash .*ticker.sh"` finds nothing.

Do not use `nohup` or a background job. The point is the session.

The first two criteria can be checked by the machine while the session is
still detached:

```console
$ bash episodes/code/self-check.sh ex1
PASS  a session named harvest exists
      harvest.log has 3 lines, waiting five seconds
      harvest.log has 7 lines now
PASS  harvest.log grew while nothing was attached
PASS  no client is attached

All criteria met.
```

::::{solution}
:class: dropdown

```console
$ tmux new-session -d -s harvest -c "$HOME/use17" "$HOME/use17/ticker.sh > $HOME/use17/harvest.log 2>&1"
$ tmux ls
harvest: 1 windows (created Fri Jul 31 10:19:28 2026)
$ sleep 5; wc -l < harvest.log
5
$ sleep 5; wc -l < harvest.log
10
$ tmux kill-session -t harvest; tmux ls
no server running on /tmp/tmux-1000/default
$ sleep 2; wc -l < harvest.log; pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"
10
no ticker.sh process is running
```

Five lines in the first interval, five more in the second, and the file
stops at ten the moment the session is killed. `-d` matters: it creates the
session without attaching, which is the state the criteria ask about.

::::
:::::

## Retrieval check

:::::{discussion}
Without scrolling back:

1. Your connection drops while a session is attached. Which of the three
   parts — server, session, client — ended?
2. You reboot the login node. Which of the three ended?
3. `tmux ls` answers `no sessions`. What is running, and what is not?

::::{solution}
:class: dropdown

1. Only the client. The server kept running and the session with it, which
   is why `tmux attach` gets your work back.
2. All three. The server is an ordinary process on that machine; a reboot
   ends it, and sessions are memory inside it, not files. Work that has to
   survive a reboot belongs in a batch job, or in a file on disk.
3. A server is running for your account, and it holds no session by the name
   you asked for. `no server running on ...` would mean the server itself is
   gone.

::::
:::::

:::{admonition} Take it further
:class: seealso

You have a long-running command, and the choice is between `nohup ./run.sh &`
and starting it inside a session. Both survive the disconnection. Write down
one thing each of them gives you that the other does not, then decide which
you would use for a run you expect to have to interrupt and inspect.
:::

:::{keypoints}
- A tmux server on the remote machine owns the session; the terminal you
  look at is a client that can leave and come back.
- A command loses its terminal when the connection drops and is terminated
  by SIGHUP; a command inside a session does not notice.
- `tmux new -s name`, Ctrl+B d, `tmux ls`, `tmux attach -t name`,
  `tmux kill-session -t name`.
- `exit` in the last pane ends the session; Ctrl+B d keeps it.
- A session survives a dropped connection, not a reboot.
:::

:::{seealso}
- `man tmux`, sections DESCRIPTION and DEFAULT KEY BINDINGS.
- `man 7 signal` for SIGHUP and its default action.
- {doc}`use17-3-windows-and-panes` for the second family of use cases:
  several views inside one connection.
:::
