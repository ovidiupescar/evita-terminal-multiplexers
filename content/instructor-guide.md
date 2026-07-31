# Instructor guide

Delivery notes for SDS.OSV1-USE1.7. Learners do not need this page.

## Why we teach this lesson

The failure this module removes is common and expensive: a run started over
SSH dies when the connection drops, and the work is repeated. The tool is
small enough to learn in an afternoon and is installed on most shared
systems already. The second reason is quieter but matters as much: one
connection can show several things at once, which is what makes a login node
usable for anything but a single command.

## Timing

Two hours, four episodes and a quiz.

| Block | Minutes | Mode |
|---|---|---|
| Setup | 10 | Learners work, instructor circulates |
| Episode 2, sessions | 35 | Demonstrate the experiment, then guided, then independent |
| Episode 3, windows and panes | 25 | Type-along |
| Episode 4, editing in a session | 30 | Demonstrate, then independent |
| Quiz | 20 | Individual |

The two-hour figure holds only if the environment exists before the session
starts. For a cohort that installs Ubuntu during the class, add half an hour
and cut the GNU Screen section of Episode 3.

## Hardware requirements

Any Ubuntu 24.04 machine with an ordinary account and `sudo` for one
installation. A cohort may provision one disposable virtual machine per
trainee; a shared machine works too, because every session is per-user and
no command in this module touches another account.

The one setup detail that breaks the class: a learner who brings a machine
with `~/.tmux.conf` has a different prefix key, and every keystroke in the
material is then wrong. The verification block in the setup episode prints
the prefix in use. Move the file aside for the duration rather than
rewriting the episodes.

**On an HPC login node** a multiplexer is normally installed already, and on
the systems the authors have used `screen` is the more common of the two.
That statement was not verified on a EuroHPC system while this module was
written; see {doc}`authoring-evidence`. Nothing in the module depends on it.
Two things are worth saying to a cohort heading for a cluster: a session
keeps an interactive shell alive and is not a place to run compute, which
belongs in a batch job; and some centres clean up leftover login-node
processes, so a session is not storage.

## Learner personas

- **The returning user.** Has an account on a cluster, edits job scripts
  over SSH, and has lost an edit to a dropped connection at least once. The
  module lands immediately; the risk is that they stop after Episode 2.
- **The daily tmux user.** Uses tmux as a window manager and has never
  detached on purpose. Compress Episodes 2 and 3 for them and spend the time
  on Episode 4 and the quiz; almost none of them have recovered a Vim swap
  file after a killed session.
- **The newcomer.** Finished SDS.OSV1-USE1.3 and USE1.6 and has never seen a
  status line. For them the keystrokes are the whole difficulty; slow down
  in Episode 3 rather than in Episode 2.

## Additional teaching recommendations

### Preparing exercises

Nothing to prepare beyond the environment. The `ticker.sh` fixture is
created by the learner in Episode 2 and is used again in the quiz; if you
teach the quiz as a separate session, remind them that Episode 4 removed the
working directory.

### Demonstrating the experiment

The Case A and Case B runs in Episode 2 carry the module. Run them live if
you can; the pair takes twenty seconds and is more convincing than a
transcript. The `setsid script ...` line is long, so paste it rather than
typing it. If a learner asks why `script` is involved, the answer is that it
is the cheapest way to lose a terminal without losing the one you are
teaching from, and that the signal the ticker receives is the same SIGHUP a
dropped connection delivers.

### Interesting questions you might get

- *Why not just use `nohup`?* Because `nohup` protects one command and gives
  you a file, not a screen you can type into again. Both are correct answers
  to different questions; the entry check in Episode 2 is written around
  this.
- *Does the session survive a reboot?* No, and question 3 of the quiz is
  built on it. A session is memory in a running server process.
- *Can two people share one session?* Yes, and Episode 2 shows it with
  two captured screens. Both clients have full control; there is no
  read-only mode without extra configuration.
- *What happens if the two clients have different terminal sizes?* tmux
  draws the session at the smaller size for both. Worth mentioning, not
  worth demonstrating.

### Typical pitfalls

1. **The prefix.** The first ten minutes of Episode 2 are lost to Ctrl+B
   being held down while the next key is pressed. Say "Ctrl+B, let go, then
   the key" out loud, and repeat it in Episode 3.
2. **`exit` instead of Ctrl+B d.** A learner ends the session, sees
   `tmux ls` report no server, and concludes the tool does not work. The
   when-it-breaks section of Episode 2 is written for that moment; let them
   reach it rather than warning them first.
3. **Expecting the file to be saved.** In Episode 4, most learners expect
   the detached session to have written the buffer. The checksum before and
   after the detach is the point of the episode; do not skip it to save
   time.
4. **The rename prompt.** `Ctrl+B ,` offers the current name and appends
   what is typed, which produces `bashnotes`. Episode 3 shows both screens
   and the `Ctrl+U` that clears the line.
5. **Scrollback.** Learners reach for the mouse wheel. Copy mode is the
   answer and `q` is the exit; both are easy to forget under time pressure.

### Adaptations

- **Short slot of one hour.** Setup, Episode 2 in full, and question 6 of
  the quiz. Episodes 3 and 4 become homework; they need no instructor.
- **Cohorts on a cluster with `screen` only.** Teach Episode 3's comparison
  table first, then run the episodes with `screen`. The model is identical
  and only the prefix and the command names change, but the captured screens
  will not match, so say that up front.

## Marking the hands-on task

The rubric is on the quiz page. Two failure patterns to watch for:

- **Claims without output.** "The log kept growing" with no two readings.
  The task asks for evidence, and assertion does not meet the criterion.
- **Readings taken while attached.** The point is that nothing was drawing
  the session. A learner who runs `wc -l` in a second pane of the same
  session has shown something true but different; ask them to detach and
  repeat.

Learners who choose different file or session names have not made a mistake.
Mark against the rubric.

## Cleanup

Episode 4 ends with four checks that must all come back negative: no server,
no screen socket, no working directory, no leftover process. On a shared
machine, run them yourself at the end of the class as well. A forgotten
detached session is invisible from the outside and will still be there next
week.
