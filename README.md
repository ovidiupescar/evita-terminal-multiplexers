# Terminal multiplexers (SDS.OSV1-USE1.7)

EVITA training module for course **SDS.OSV1 — Virtualization and the Linux
operating system**, module **USE1.7**. About two hours.

A connection to a remote machine can drop, and the command running on the
far end dies with it. A terminal multiplexer moves that command into a
session owned by a server process on the remote machine, so the terminal you
look at becomes a client that can leave and come back. The same session
holds windows and panes, so one connection can show a job, a shell and an
editor at once.

The module is built for a disposable Ubuntu 24.04 machine and an ordinary
user account. Two packages are installed once; nothing else needs `sudo`.

## Episodes

| Episode | What it does |
|---|---|
| `use17-1-setup` | Ubuntu 24.04 shell on Windows, macOS or Linux; install `tmux` and `screen`; verify the versions and that the stock prefix key is in use; create the working directory |
| `use17-2-sessions` | The same command run twice, once on a pseudo-terminal that is then destroyed and once inside a detached session, as the evidence for the whole module; the server, session and client model read off `ps` and `pstree`; the session lifecycle (`new`, Ctrl+B d, `ls`, `attach`, `kill-session`); two clients on one session; `exit` in the last pane, the nesting refusal, and attaching a session that is gone |
| `use17-3-windows-and-panes` | Splitting a window, moving between panes, opening and renaming windows, copy mode for scrollback, the kill-pane prompt, and the same model in GNU Screen with a command-by-command comparison |
| `use17-4-editing-in-a-session` | An edit carried across a detach and proved from outside the session with checksums; the prefix collision and `Ctrl+B Ctrl+B`; a session killed while a Vim buffer is unwritten, the swap file it leaves, and `vim -r`; verified cleanup |
| `quiz/quiz` | Five multiple-choice questions and one hands-on task with a rubric |

## Evidence

Every command output and every terminal screen in this module was executed
on the pinned baseline and harvested, never typed by hand:

- `evidence/harvest-setup.sh` produces `evidence/transcript-setup.txt`: the
  package installation, run as root, plus the quoted passages of `tmux(1)`
  and `screen(1)` checked against the manual pages shipped on the baseline.
- `evidence/harvest.sh` produces `evidence/transcript.txt`: everything else,
  run as an ordinary user, with 52 captured screens and the console blocks
  around them.
- `evidence/harvest-exercises.sh` produces
  `evidence/transcript-exercises.txt`: the model answers of the three
  exercises and of the hands-on task, executed with the session and file
  names the episodes ask for.

The subject of this module is also the tool used to harvest it. The two are
kept apart by socket name: the learner's tmux runs on the default socket,
inside a pane of a second tmux server (`-L harvest`) that is fixed at 80 by
24 and captured. `masks.yaml` lists what is normalized in the shown output
and what is deliberately left as harvested.

`module.yaml` carries the official CQF outcomes verbatim, the outcome to
assessment map and the declared environments; `sources.yaml` is the source
ledger; `questions.yaml` is the machine-readable quiz.
`content/authoring-evidence.md` renders all of that into the built site.

## Building

```bash
python -m venv .venv
.venv/bin/pip install --group notebook .
EVITA=1 .venv/bin/sphinx-build -n -W --keep-going -T -b html content _build/html
.venv/bin/python -m pytest tests/ -q
```

`EVITA=1` is required: without it the EVITA branding is skipped silently.

## Licence

Pedagogical material and media: CC BY-SA 4.0 (`LICENSE`). Code snippets and
the harvest scripts: MIT (`LICENSE.code`).

## EVITA Project Funding
🇪🇺 Funded by the European Union. Views and opinions expressed are however those of the author(s) only and do not necessarily reflect those of the European Union or the European High-Performance Computing Joint Undertaking. Neither the European Union nor the granting authority can be held responsible for them. Grant agreement No. 101196394.

## Disclaimer
This material should be regarded as a "living tool" open for improvement and its content may be subject to modifications without notice. It has not yet undergone formal review by the EuroHPC JU and is shared for informational purposes only.
