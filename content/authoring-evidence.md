# Authoring evidence

How this module was built and verified. This page is authoring metadata for
reviewers, not learning content. Learners can skip it.

## The official outcomes

The two outcomes are quoted from the EVITA CQF course list (final version
2026-06-01), page 32, section SDS.OSV1. Unlike the neighbouring modules,
neither of this module's outcomes is wrapped across a page line, so both are
single-line quotations that needed no rejoining.

| Official text as published | Reproduced in `module.yaml` |
|---|---|
| Give examples for use cases for such a multiplexer | Give examples for use cases for such a multiplexer |
| Review editing files using a terminal multiplexer | Review editing files using a terminal multiplexer |

The repeated "for" and the pointing "such a" in the first outcome are in the
source, which prints the outcome directly under the module title. They are
reproduced unchanged. This module's outcome texts contain no orthographic
errors, so each `official_source_text` field in `module.yaml` is
character-identical to its `official` field.

`cqf_deltas` is empty: no outcome was added, split, dropped or reworded.

## Outcome to assessment map

| Outcome | Bloom | Taught in | Assessed by |
|---|---|---|---|
| O1 Give examples for use cases for such a multiplexer | understand | Episodes 2 and 3 | q1 (use-case selection, session persistence), q2 (disconnect behaviour), q3 (session persistence), rc1, rc2, ex1, ex2, hx1 |
| O2 Review editing files using a terminal multiplexer | apply | Episode 4 | q4 (prefix routing, editor in session), q5 (unsaved buffer on kill, save and verify), rc3, ex3, hx1 |

Every assessment id in `questions.yaml` and in the episodes maps back to a
component of one of the two outcomes; the validator rejects an outcome with
no assessment and an assessment with no outcome.

## Environments and evidence status

| Path | Specification | Evidence |
|---|---|---|
| Windows | Windows 11 + WSL2 Ubuntu 24.04.1 LTS, tmux 3.4, GNU Screen 4.09.01, GNU nano 7.2, Vim 9.1, ordinary user | verified |
| Linux | Ubuntu 24.04 LTS in a disposable VM or on bare metal, same packages | supported |
| macOS | Multipass or UTM running Ubuntu 24.04 LTS | supported |
| HPC cluster | Generic EuroHPC login node, tmux or screen over SSH | supported |

Every transcript was harvested on the Windows path. The other three run the
same distribution and the same packages; they are marked supported because
they were not executed during authoring, which is what that word means here.

## How the screens were produced

The subject of this module is also the tool used to harvest it, so the two
are kept apart by socket name:

- The **harness** server runs as `tmux -L harvest -f /dev/null` and holds one
  session whose single pane is fixed at 80 columns by 24 rows with its own
  status line switched off. That pane plays the part of the learner's
  terminal window, and `tmux capture-pane -p` writes its contents into the
  transcript.
- The **learner's** server runs on the default socket, `/tmp/tmux-1000/default`.
  Every tmux command an episode shows runs there, which is why `tmux ls`
  inside a captured screen lists only the sessions that episode created.

The pane shell inherits `$TMUX` from the harness server and is made to
`unset TMUX TMUX_PANE` before anything else; without that, the inner tmux
declines to nest and no screen would be produced at all.

Three harvest scripts and three transcripts:

| Script | Transcript | Contents |
|---|---|---|
| `evidence/harvest-setup.sh` | `evidence/transcript-setup.txt` | Package installation as root, and the passages of `tmux(1)` and `screen(1)` quoted in this module, extracted from the manual pages shipped on the baseline |
| `evidence/harvest.sh` | `evidence/transcript.txt` | Everything the episodes show: 52 captured screens and the console blocks around them |
| `evidence/harvest-exercises.sh` | `evidence/transcript-exercises.txt` | The model answers of ex1, ex2, ex3 and hx1, executed with the session and file names the episodes ask for |

The exercises were harvested separately on purpose. Quoting a `tmux ls` line
with a session name that had never been used would be invented output, and
splitting the harvest means a late change to an exercise costs one short run
instead of re-synchronising 52 screens.

The self-check script shipped with the module,
`content/episodes/code/self-check.sh`, was itself executed against both a
correct and a deliberately wrong state for every subcommand; the run is in
`evidence/transcript-selfcheck.txt`.

## What is normalized in the shown output

`masks.yaml` is the full list. In short: the account name, the host name,
the home directory path, the per-user screen socket directory, process ids
and clock times are replaced, because they identify the authoring machine or
change on every run.

Left as harvested, because they are the evidence: session, window and pane
names; the tick counters and the line counts taken from them; pane geometry
and window and pane indexes; the copy-mode position counter; and the md5
checksums of the fixture files.

## Source ledger

`sources.yaml` carries twelve entries. Every upstream claim was checked
against the manual page shipped on the pinned baseline, and the quoted
passage is in `evidence/transcript-setup.txt`.

| Claim | Source | Level |
|---|---|---|
| Session, server and client model; socket in /tmp; the server exits with the last session | `tmux(1)` DESCRIPTION | verified |
| A session survives an accidental disconnection or an intentional detach | `tmux(1)` DESCRIPTION | verified |
| The prefix is C-b, C-b sends it through, and the default bindings used here | `tmux(1)` DEFAULT KEY BINDINGS | verified |
| Screen multiplexes a physical terminal; `-ls`, `-dm`, `-r`, `-X`; prefix Ctrl+A | `screen(1)` | verified |
| SIGHUP is delivered on hangup of the controlling terminal, default action Term | `signal(7)` | verified |
| `script(1)` runs a command under a newly allocated pseudo-terminal | `script(1)` | verified |
| `nohup` runs a command immune to hangups | `nohup(1)` | verified |
| Vim preserves its swap file on a hangup and `vim -r` recovers from it | Vim `recover.txt` | verified |
| nano's Write Out and Exit commands, and the caret notation | `nano(1)` | verified |
| A multiplexer is normally installed on an HPC login node, screen more often than tmux | authors' experience of other systems | **working assumption** |
| Every screen and output in the episodes | `evidence/transcript.txt` | verified |
| The installation shown in the setup episode | `evidence/transcript-setup.txt` | verified |

## Gate results

Gate results are generated, not asserted: `build/gate-results.json` is the
receipt written by the validator and is committed with the module. Three
lanes ran.

| Lane | Command | Result |
|---|---|---|
| Static preflight | `python validate.py --receipt .` | 0 errors |
| Strict build | `EVITA=1 sphinx-build -n -W --keep-going -T -b html content _build/html` | build succeeded, exit 0 |
| Template and citation tests | `python -m pytest tests/ -q` | 8 passed |

A fourth check is specific to this course: the rendered quiz page is grepped
for the option list, because MCQ options written as bare `a)` lines pass a
strict build and still render as one paragraph. The built page reports 20
option list items, four for each of the five questions.

## Known limitations

1. **No cluster was available.** The HPC path in `module.yaml` is marked
   *supported*, not *verified*. Nothing in the module needs a cluster: every
   command runs on the learner's own machine as an ordinary user. The
   statement that a login node normally has a multiplexer installed is a
   declared working assumption in the source ledger.
2. **One host path was executed.** All transcripts come from WSL2 on
   Windows 11. The Linux and macOS paths run the same Ubuntu 24.04 packages
   and are expected to behave identically, but they were not executed.
3. **Timings are estimates.** The minute figures in the instructor guide
   come from the structure of the material, not from a dry run with a
   cohort. They should be corrected after the first delivery.
4. **The disconnection is staged.** Episode 2 destroys a pseudo-terminal
   held by `script(1)` rather than dropping a real SSH connection, so that
   the whole experiment fits in one window. The signal the process receives
   is the same SIGHUP; a real dropped connection was not part of the
   harvest.
5. **The two-client demonstration used two local terminals**, not two
   people on two machines. The `tmux list-clients` output shows two
   different pseudo-terminals attached to one session, which is the property
   being claimed.
6. **Reboot behaviour is argued, not harvested.** Question 3 rests on the
   documented fact that a session is memory in a server process; no reboot
   was performed for this module. Night 1 of this course
   (SDS.OSV1-ADM7.2) did harvest a real reboot for its own purposes.
