# Quiz

Summative assessment. Questions 1 to 5 are multiple choice; question 6 is a
hands-on task in your own environment. Attempt each one before opening its
solution.

:::{instructor-note}
20 min for questions 1 to 5, 25 min for question 6. For supervised
assessment, distribute questions 1 to 5 without this page; the dropdown
solutions suit self-paced use. Question 6 needs nothing but a shell with
tmux and one editor, so it works on a login node as well as on a virtual
machine. Mark question 6 against the rubric rather than against the learner
having chosen the same names as the model answer.
:::

## Question 1

A preprocessing script takes forty minutes and is started over SSH on a
cluster login node from a laptop that suspends when its lid closes. A
colleague suggests starting it inside tmux. Which statement names what tmux
changes about that run?

- **a)** the script runs under a tmux server process on the login node, so
  closing the laptop removes the client that was displaying the session and
  leaves the script running
- **b)** tmux sends traffic through the connection at short intervals, so
  the connection to the login node stays open while the laptop is suspended
- **c)** tmux records the output of the script in a file on the login node
  and replays that file at the next login, so the run continues where the
  terminal stopped
- **d)** tmux hands the script to the login shell as a background job, so
  the shell stops passing on the signal it receives when the connection ends

:::{solution} Solution Q1
:class: dropdown

**a)** The tmux server runs on the login node and owns the session; the
client only draws it. Losing the client leaves the server and every process
in the session untouched. Option b) describes a keep-alive, which fails as
soon as the connection does drop. Option c) would give you old output rather
than a running command. Option d) is `nohup` and job control: a real
technique, but it protects one command and gives you nothing to reattach to
at the next login (Episode 2).
:::

## Question 2

A learner watches a growing log with `tail -f` inside a tmux session called
`logs`. They press Ctrl+B and then d. The shell prompt of the machine
returns, with a line above it reporting that the client detached from
session `logs`. What is the state of the `tail` process at that moment?

- **a)** tail keeps running in the session, which the tmux server still
  holds, and the client that was drawing the session has disconnected
- **b)** tail is stopped in the same way as after Ctrl+Z, and it resumes
  reading the log when the session is attached again
- **c)** tail received the interrupt signal that Ctrl+C sends, so the
  session now holds a shell with no command running in it
- **d)** tail was written into the saved state of the session, and it starts
  reading the log from the beginning at the next attach

:::{solution} Solution Q2
:class: dropdown

**a)** Detaching disconnects the client. The server, the session, the shell
in it and every process that shell started continue, which is why the log
keeps being read while nobody is looking. Option b) is Ctrl+Z, which stops a
process, and option c) is Ctrl+C, which interrupts it; neither is what
Ctrl+B d does. Option d) assumes a session is serialized to disk: it is
memory in a running process (Episode 2).
:::

## Question 3

A session called `build` was detached and left running. The machine is
rebooted. After the next login `tmux ls` answers `no server running on
/tmp/tmux-1000/default`. Which statement explains that answer?

- **a)** the tmux server is an ordinary process on that machine, so the
  reboot ended it together with every session it was holding
- **b)** the sessions are stored under `/tmp/tmux-1000` and come back when
  tmux attach is run with the name of the session
- **c)** the sessions belong to the SSH connection, so they were lost
  because the reboot closed the connection rather than because it ended the
  server
- **d)** the server was started by the login shell of the earlier session,
  so the sessions return once the same user logs in on that machine again

:::{solution} Solution Q3
:class: dropdown

**a)** A session is memory in a running server process, not a file. The path
under `/tmp` is the socket the clients connect through, and an empty socket
file holds no windows, which is what option b) misses. Option c) has the
ownership backwards, as the two-client section of Episode 2 shows, since a
session with no client at all keeps running. Option d) would make a session
survive a reboot, which is exactly the limit this module states: a
multiplexer answers a dropped connection, not a restarted machine (Episode
2).
:::

## Question 4

nano is editing a file in a tmux pane. The learner wants nano's Where Is
search, so they press Ctrl+B and then w. Instead of a search prompt, a list
of the windows of the session appears. Which statement describes what
happened and how to reach nano with that key?

- **a)** tmux read Ctrl+B as its prefix and took the next key as its own
  command; pressing Ctrl+B twice sends one Ctrl+B through to nano
- **b)** nano stops reading control keys while its buffer differs from the
  file, so tmux received the key and answered with its own window list
- **c)** the pane had been left in copy mode, where tmux reads the keys
  itself; leaving copy mode with q gives Ctrl+B back to nano
- **d)** the terminal delivers Ctrl+B to the process in the foreground of
  the outermost shell, which is the tmux client rather than nano

:::{solution} Solution Q4
:class: dropdown

**a)** tmux watches for its prefix, Ctrl+B by default, and reads the key
that follows as a tmux command; `w` is `choose-tree`. The pane never sees
either key, which is why option b) blames the wrong program. Copy mode in
option c) is a different state, and its indicator would have been visible in
the window name. Option d) would make every keystroke reach the client
rather than the pane, and then nothing could be typed at all. Pressing the
prefix twice invokes `send-prefix`, which delivers the literal Ctrl+B
(Episode 4).
:::

## Question 5

A file `report.txt` is open in Vim in a session called `edit`. Three lines
have been typed and no write command has been given. From another terminal
the learner runs `tmux kill-session -t edit`. What does the working
directory hold afterwards?

- **a)** report.txt with the content it had before the edit, next to the
  swap file `.report.txt.swp` that holds the unwritten change
- **b)** report.txt with the three new lines in it, because tmux writes the
  contents of the pane to the file before it ends the session
- **c)** report.txt with the content it had before the edit and no other
  file, because ending the session removes what the pane created
- **d)** report.txt with no content in it, because Vim empties the file when
  it opens it and writes the text back at the first write command

:::{solution} Solution Q5
:class: dropdown

**a)** Killing the session ends the processes in it. Vim answers the hangup
by preserving its swap file and exiting, so the edit is recoverable with
`vim -r report.txt` while the file itself is untouched. Option b) credits
tmux with saving text it never had. Option c) is the common assumption that
makes people give up on the work, and the swap file is the reason not to.
Option d) describes a truncate-on-open editor, which Vim is not: it reads
the file into a buffer and leaves the original alone until a write (Episode
4).
:::

## Question 6

:::::{exercise} hx1 — A session that survives the disconnection
Work in the module's working directory and use a tmux session called `run`.
Episode 4 removed that directory, so recreate it first, together with a
command that keeps writing:

```console
$ mkdir -p ~/use17 && cd ~/use17
```

The `ticker.sh` script from Episode 2 is a command that keeps writing; any
other one will do.

1. In the session, rename the first window to `job` and start a command in
   it that keeps writing to a file for at least a minute.
2. Open a second window called `notes`, and in it open a new file
   `handover.txt` in an editor. Type one line describing the job. Do **not**
   write it yet.
3. Detach from the session.
4. From the shell, with nothing attached, show that the job's output file is
   still growing and that `handover.txt` does not exist yet.
5. Reattach, write `handover.txt`, leave the editor, stop the job, and end
   the session.
6. Show that no session, no server and no leftover process remain, and
   remove the directory.

Produce a short report with four parts:

- **The layout.** The command or key sequence that created each window, and
  one executed command whose output lists both windows of the session.
- **The proof while detached.** Two readings of the job's output file taken
  at least five seconds apart while no client is attached, and the command
  output showing that `handover.txt` did not exist at that time.
- **The write.** The key sequence that wrote the file, and one executed
  command from the shell whose output shows the line is on disk.
- **The cleanup.** The commands and their outputs showing no session, no
  process and no directory left.

**Success criteria:** the session had two named windows; the job's line
count grew between the two detached readings; `handover.txt` was absent
before the write and present with the required line after it; and all four
cleanup checks report a negative result.

`episodes/code/self-check.sh` asks the machine for you: run it as
`hx1-open` while the session is detached and the note unwritten, as
`hx1-final` after the write and the stop, and as `cleanup` at the end.
:::::

::::{solution} Solution Q6
:class: dropdown

**The layout.** `tmux new -s run`, then `Ctrl+B ,` `Ctrl+U` `job` Enter, the
job started in that window, then `Ctrl+B c` and `Ctrl+B ,` `Ctrl+U` `notes`
Enter. The same from the shell, which is how the model answer was executed:

```console
$ tmux new-session -d -s run -c "$HOME/use17"
$ tmux rename-window -t run:0 job
$ tmux send-keys -t run:job "$HOME/use17/ticker.sh > $HOME/use17/job.log 2>&1" Enter
$ tmux new-window -t run -n notes -c "$HOME/use17"
$ tmux list-windows -t run
0: job- (1 panes) [80x24] [layout b25d,80x24,0,0,0] @0
1: notes* (1 panes) [80x24] [layout b25e,80x24,0,0,1] @1 (active)
```

**The proof while detached.** With `nano handover.txt` open in the `notes`
window and one line typed but not written:

```console
$ tmux ls
run: 2 windows (created Fri Jul 31 10:19:48 2026)
$ ls handover.txt
ls: cannot access 'handover.txt': No such file or directory
$ wc -l < job.log
3
$ sleep 5; wc -l < job.log
11
```

Three lines, then eleven, with nothing attached: the job kept running.
`handover.txt` does not exist, because the line is in the editor's buffer.

**The write.** Ctrl+O, Enter, then Ctrl+X in the `notes` window:

```console
$ cat handover.txt
the job was started at 10:00
$ md5sum handover.txt
2b6d8d109709df8eef6405bc3c5c7c6e  handover.txt
$ wc -l < handover.txt
1
```

**The cleanup.** Ctrl+C in the `job` window stops the writer, which the log
confirms by not growing any more, and the session is ended by name:

```console
$ wc -l < job.log
14
$ sleep 3; wc -l < job.log
14
$ tmux kill-session -t run; tmux ls
no server running on /tmp/tmux-1000/default
$ pgrep -af "bash .*ticker.sh" || echo "no ticker.sh process is running"
no ticker.sh process is running
$ cd ~ && rm -rf ~/use17 && ls -d ~/use17
ls: cannot access '/home/trainee/use17': No such file or directory
```

Four negative answers: no session, no server, no process, no directory.

::::

::::{admonition} Rubric for question 6
:class: hint

| Criterion | Meets | Does not meet |
|---|---|---|
| Two named windows in one session | An executed command lists both windows with the names the task asked for | The names are asserted, or the two tasks were run in two sessions |
| The detached proof | Two readings of the job's output file, taken with nothing attached, whose line counts differ, plus the command output showing `handover.txt` absent | One reading only, or the growth is asserted, or the readings were taken while attached |
| The write is shown from outside the editor | An executed shell command quotes the line from the file after the write | The editor's own write message is offered as the only proof |
| Cleanup verified | Four command outputs: no session, no leftover process, no directory, and the job's log no longer growing | Any of the four is asserted without output, or a process is left running |
::::

:::{keypoints}
- Questions 1 to 3 test the model: server, session and client end at
  different times, and a session answers a dropped connection rather than a
  reboot.
- Question 4 tests the prefix, which is the key routing rule inside every
  pane.
- Question 5 tests what a killed session leaves on disk.
- Question 6 asks for the whole cycle, proved from outside the session.
:::
