# Editing a file inside a session

Editing a job script over SSH is where a dropped connection hurts most: the
editor dies with the connection, and whatever was not written is gone.
Running the editor inside a session removes that risk, and adds one new
problem. The prefix key now sits between your fingers and the editor.

This episode assumes you can already open, change and save a file in nano
and in Vim. SDS.OSV1-USE1.6 teaches that; nothing here teaches the editors.

:::{objectives}
- Open a file in an editor inside a tmux session, detach with the buffer
  unwritten, reattach and finish the edit.
- Prove from outside the session which content is on disk and when.
- Send a keystroke to the editor when tmux claims the same key.
- Say what a killed session leaves behind, and recover it.
:::

:::{instructor-note}
- 12 min worked, 8 min guided, 10 min independent, 5 min cleanup
- The detach with an unwritten buffer is the moment that changes people's
  habits: the file on disk is still the old one, and everybody expects the
  session to have "saved" something
- The Vim recovery at the end is the only part that can leave state behind
  (a swap file). The cleanup section removes it and verifies
- Adaptation: a cohort short of time can skip the `cat -v` demonstration and
  keep only the `Ctrl+B w` collision
:::

## Entry check

:::::{discussion}
You are editing `plan.txt` in nano inside a tmux session. You have typed
three new lines and pressed nothing else. Your connection drops.

1. What does `cat plan.txt` print on the next login?
2. What does `tmux attach` give you?

::::{solution}
:class: dropdown

1. The old content. Typing changes the editor's buffer, not the file; only a
   write changes the file.
2. The same nano screen, with the three lines still in the buffer, because
   nano never stopped running. Pressing Ctrl+O then writes them.

::::
:::::

## Worked example: an edit across a detach

The fixture is a two-line file in the working directory:

```console
$ cd ~/use17
$ cat notes.txt
run the preprocessing step
check the output size
$ md5sum notes.txt
1a7b3b30db771a1296558582850d00c2  notes.txt
```

:::{demo}

**Step 1. Start a session and open the file in it.**

```console
$ tmux new -s edit
```

```text
trainee@trainvm:~/use17$
[edit] 0:bash*                                         "trainvm" 10:05 31-Jul-26
```

```console
$ nano notes.txt
```

```text
  GNU nano 7.2                        notes.txt
run the preprocessing step
check the output size
                                [ Read 2 lines ]
^G Help      ^O Write Out ^W Where Is  ^K Cut       ^T Execute   ^C Location
^X Exit      ^R Read File ^\ Replace   ^U Paste     ^J Justify   ^/ Go To Line
[edit] 0:bash*                                         "trainvm" 10:05 31-Jul-26
```

nano's two help rows and tmux's status line share the bottom of the screen.
The editor has 22 rows instead of 24, and nothing else changes.

**Step 2. Add a line and leave it unwritten.**

Press Down, End, Enter, then type `archive the log directory`:

```text
  GNU nano 7.2                        notes.txt *
run the preprocessing step
check the output size
archive the log directory
^G Help      ^O Write Out ^W Where Is  ^K Cut       ^T Execute   ^C Location
^X Exit      ^R Read File ^\ Replace   ^U Paste     ^J Justify   ^/ Go To Line
[edit] 0:nano*                                         "trainvm" 10:05 31-Jul-26
```

Two reports of the same fact: the star after `notes.txt` in nano's title bar,
and the window name in the status line, which is now `nano`.

**Step 3. Detach with the buffer unwritten: Ctrl+B then d.**

```text
trainee@trainvm:~/use17$ tmux new -s edit
[detached (from session edit)]
trainee@trainvm:~/use17$
```

**Step 4. Ask the file system what it has.**

```console
$ cat notes.txt
run the preprocessing step
check the output size
$ md5sum notes.txt
1a7b3b30db771a1296558582850d00c2  notes.txt
$ tmux ls
edit: 1 windows (created Fri Jul 31 10:05:50 2026)
```

The checksum has not moved. The session is still there and so is nano, with
the third line in its buffer, but the file on disk is the file you started
with. A session protects the **editor**, not the **file**.

**Step 5. Reattach.**

```console
$ tmux attach -t edit
```

```text
  GNU nano 7.2                        notes.txt *
run the preprocessing step
check the output size
archive the log directory
^G Help      ^O Write Out ^W Where Is  ^K Cut       ^T Execute   ^C Location
^X Exit      ^R Read File ^\ Replace   ^U Paste     ^J Justify   ^/ Go To Line
[edit] 0:nano*                                         "trainvm" 10:06 31-Jul-26
```

The same screen, down to the star and the cursor.

**Step 6. Write and leave.**

Ctrl+O, then Enter to accept the offered name:

```text
  GNU nano 7.2                        notes.txt
run the preprocessing step
check the output size
archive the log directory
                               [ Wrote 3 lines ]
^G Help      ^O Write Out ^W Where Is  ^K Cut       ^T Execute   ^C Location
^X Exit      ^R Read File ^\ Replace   ^U Paste     ^J Justify   ^/ Go To Line
[edit] 0:nano*                                         "trainvm" 10:06 31-Jul-26
```

Ctrl+X leaves nano and the shell prompt comes back inside the session.

**Step 7. Prove the write from outside the editor.**

```console
$ cat notes.txt
run the preprocessing step
check the output size
archive the log directory
$ md5sum notes.txt
6ec3405b83adf33a553e6c48531c7108  notes.txt
$ wc -l notes.txt
3 notes.txt
```

A different checksum, three lines. The edit survived a detach and reached
the disk when it was written, not before.

:::

## The prefix takes the key first

Inside a session, `Ctrl+B` belongs to tmux. Press `Ctrl+B` then `w`
intending nano's Where Is, and tmux answers with its own window chooser
drawn over the editor:

```text
(0) - edit: 1 windows (attached)
(1) └─> 0: [tmux]*
┌ 0 (sort: index) ─────────────────────────────────────────────────────────────┐
│   GNU nano 7.2                        notes.txt *                            │
│ run the preprocessing step                                                   │
│ check the output size                                                        │
│ archive the log directory                                                    │
│                                     ┌───┐                                    │
│                                     │ 0 │                                    │
│                                     └───┘                                    │
└──────────────────────────────────────────────────────────────────────────────┘
[edit] 0:[tmux]*                                       "trainvm" 10:06 31-Jul-26
```

nano never saw either key. Escape closes the chooser and the editor is back
exactly as it was.

To send the prefix itself to the program, press it twice. `cat -v` prints
control characters visibly, which makes the difference easy to see:

```text
trainee@trainvm:~/use17$ cat -v
^B
[edit] 0:cat*                                          "trainvm" 10:06 31-Jul-26
```

The `^B` on the screen is the terminal echoing the one literal Ctrl+B that
reached the pane after the second press. Enter, and `cat -v` prints the byte
it read, which is the proof that the program received it:

```text
trainee@trainvm:~/use17$ cat -v
^B
^B
[edit] 0:cat*                                          "trainvm" 10:06 31-Jul-26
```

Stop `cat` with Ctrl+C. In practice the collisions you meet are `Ctrl+B` in
Vim (page up) and `Ctrl+B` in nano (back one character); `Ctrl+B Ctrl+B`
delivers them.

## Guided practice

:::{type-along}

Repeat the cycle with a file of your own and check it from outside every
time.

1. `tmux new -s work2`
2. In the session: `nano ~/use17/checklist.txt`, type two lines.
3. `md5sum ~/use17/checklist.txt` **from a second view**: open a pane with
   `Ctrl+B %` rather than detaching, so the editor stays on screen. The file
   does not exist yet, and `md5sum` says so.
4. Back in the editor pane with `Ctrl+B o`: write with Ctrl+O, Enter.
5. In the other pane, run `md5sum` again. Now it answers.
6. Detach with Ctrl+B d, then `tmux kill-session -t work2`.

Checkpoint after step 3: if `md5sum` reports a checksum rather than a
missing file, you wrote the buffer already. Nothing is broken; the point of
the step is only lost.

:::

## When it breaks: the session is killed with an unwritten buffer

Vim in a session, one line typed in insert mode, nothing written:

```text
alpha
delta
beta
gamma
-- INSERT --                                                  2,6           All
[edit] 0:vim*                                          "trainvm" 10:06 31-Jul-26
```

From another terminal, the session is killed:

```console
$ tmux kill-session -t edit
```

The client exits and the pane goes with the session:

```text
trainee@trainvm:~/use17$ tmux attach -t edit
[exited]
trainee@trainvm:~/use17$
```

**Symptom.** The editor is gone and the typed line is not in the file.

**Evidence.**

```console
$ ls -a
.
..
.report.txt.swp
build.log
notes.txt
plain.log
report.txt
ticker.sh
tmux.log
$ cat report.txt
alpha
beta
gamma
$ md5sum report.txt
6c7831c26f0d0a5f807006854aa682f4  report.txt
$ ls -l .report.txt.swp
-rw-r--r-- 1 trainee trainee 12288 Jul 31 10:06 .report.txt.swp
```

**Cause.** Killing the session ends every process in it. Vim received the
hangup, and Vim's answer to a hangup is to preserve its swap file and exit.
tmux moved nothing into the file: it never had the text, the editor did.

**Remedy.** Vim keeps the unwritten change in `.report.txt.swp`:

```console
$ vim -r report.txt
```

```text
Using swap file ".report.txt.swp"
Original file "~/use17/report.txt"
Recovery completed. You should check if everything is OK.
(You might want to write out this file under another name
and run diff with the original file to check for changes)
You may want to delete the .swp file now.

Press ENTER or type command to continue
```

**Verify.** Press Enter and the recovered buffer holds the line that was
never written:

```text
alpha
delta
beta
gamma
                                                              2,5           All
```

Leave with `:q!` if you do not want it, or write it with `:w` if you do,
then remove the swap file:

```console
$ rm -f .report.txt.swp; ls -a
.   build.log  plain.log   ticker.sh
..  notes.txt  report.txt  tmux.log
```

Note where this recovery happened: in a plain shell, with no session at all.
The recovery file is on disk, so it does not need the session that produced
it.

## Independent task

:::::{exercise}
**Finish an edit across a disconnection.**

A configuration file has to gain one line, and you will be interrupted in
the middle. Use a session called `remote` and the file
`~/use17/settings.conf`, which you create first with two lines of your
choice.

1. Open the file in nano inside the session and add a third line reading
   `threads = 4`.
2. Without writing it, detach.
3. From the shell, record `md5sum ~/use17/settings.conf` and its line count.
4. Reattach, write the file, leave the editor and the session.
5. Record the checksum and the line count again.

Success criteria: the checksum in step 5 differs from the one in step 3, the
line count goes from 2 to 3, `grep -c "threads = 4"` answers 1, and
`tmux ls` reports no session called `remote` at the end.

::::{solution}
:class: dropdown

The editing is done by hand inside the session; these are the checks around
it and the state each one reports.

```console
$ printf "input = data.csv\nworkdir = /scratch\n" > settings.conf
$ cat settings.conf
input = data.csv
workdir = /scratch
$ tmux new -s remote
```

Open `nano settings.conf`, move to the end of the last line, press Enter and
type `threads = 4`. Detach with Ctrl+B d, then run the step-3 checks from
the shell:

```console
$ tmux ls
remote: 1 windows (created Fri Jul 31 10:19:40 2026)
$ md5sum settings.conf
d3c3f610d8a76fa5469b094bb4283f80  settings.conf
$ wc -l < settings.conf
2
$ grep -c "threads = 4" settings.conf
0
```

Two lines, no match, and the checksum of the file you created. Reattach with
`tmux attach -t remote`, write with Ctrl+O and Enter, leave nano with
Ctrl+X. nano was the only thing running in the only pane, so the session
ends when it exits and the client reports `[exited]`:

```console
$ tmux ls
no server running on /tmp/tmux-1000/default
$ cat settings.conf
input = data.csv
workdir = /scratch
threads = 4
$ md5sum settings.conf
82a7fb7e0f6a48cafe00a042f0211798  settings.conf
$ wc -l < settings.conf
3
$ grep -c "threads = 4" settings.conf
1
```

All five criteria: a different checksum, three lines instead of two, one
match for the new line, and no session left. The checksum in step 3 is the
part that matters. It is the same before and after the detach, which is the
evidence that a session keeps the editor and not the file.

::::
:::::

## Cleanup

This is the end of the module. Return the machine to the state the setup
episode left it in.

```console
$ tmux kill-server 2>/dev/null; tmux ls
no server running on /tmp/tmux-1000/default
$ screen -ls
No Sockets found in /run/screen/S-trainee.

$ cd ~ && rm -rf ~/use17 && ls -d ~/use17
ls: cannot access '/home/trainee/use17': No such file or directory
$ pgrep -af "tmux|screen|ticker" || echo "no tmux, screen or ticker process is running"
no tmux, screen or ticker process is running
```

Four checks, four negative answers: no server, no screen socket, no working
directory, no process left running. The socket file under `/tmp` may remain
after the server exits; it is an empty file that the next server reuses.

The `tmux` and `screen` packages stay installed on purpose. A disposable
virtual machine is discarded whole, and removing a tool the learner may want
to keep is not an improvement.

## Retrieval check

:::::{discussion}
1. You detach with an unwritten buffer and reattach an hour later. What is
   on disk during that hour?
2. `Ctrl+B` does nothing useful in the editor. Which two keystrokes give the
   editor a literal `Ctrl+B`?
3. A colleague kills your session while Vim has unwritten changes. Where is
   that work, and which command reads it back?

::::{solution}
:class: dropdown

1. The content the file had before the edit. The buffer lives in the editor
   process, which the session keeps alive; the file changes only on a write.
2. `Ctrl+B` twice. The first press is the prefix, the second is the binding
   `send-prefix`.
3. In Vim's swap file next to the file, named `.<file>.swp`. `vim -r <file>`
   opens it and reports what it recovered; the swap file is then removed by
   hand.

::::
:::::

:::{admonition} Take it further
:class: seealso

Your habit until now was to open the editor directly after logging in. Write
down what you would have to change so that every remote edit starts inside a
session instead, and name the one case where the extra session buys you
nothing.
:::

:::{keypoints}
- An editor inside a session survives a detach with its buffer intact; the
  file on disk changes only when you write it.
- Check the result from outside the editor: content, checksum, line count.
- tmux takes the prefix before the editor sees it; press the prefix twice to
  send it through.
- Killing a session ends the editor. Vim leaves `.<file>.swp` and `vim -r`
  recovers it; nano leaves `<file>.save`.
- The cleanup is four checks that must all come back negative.
:::

:::{seealso}
- SDS.OSV1-USE1.6 for the editors themselves.
- Vim's `:help recover` for the swap-file mechanism and its limits.
- `man tmux`, the `send-prefix` binding.
:::
