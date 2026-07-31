# Terminal multiplexers

The connection drops and the run dies with it. That is the problem a
terminal multiplexer solves: your commands run inside a session owned by a
process on the remote machine, and the terminal you look at is only a client
that can leave and come back. The same session holds several windows and
panes, so one connection shows the job, a shell and the file you are editing
at once.

This module builds that from a single experiment, then uses it: **tmux** for
the sessions, windows, panes and scrollback, **GNU Screen** as the fallback
found on systems without tmux, and an editing session that survives a
detach and proves from outside that the file reached the disk. Every screen
in the material was captured from a running terminal, including the
refusals: the session ended by `exit`, the nesting tmux declines, and the
kill that leaves an unwritten buffer in a recovery file.

This module implements **SDS.OSV1-USE1.7** of the EVITA Competence and
Qualification Framework (course SDS.OSV1, "Virtualization and the Linux
operating system").

:::{prereq}

- Comfortable shell use: navigating directories, listing files, reading a
  command's output. SDS.OSV1-USE1.3 covers the file system tree.
- Opening a file in nano or Vim, typing, writing and leaving.
  SDS.OSV1-USE1.6 covers the editors; this module puts them in a session and
  teaches neither.
- An Ubuntu 24.04 LTS shell with an ordinary user account, and `sudo` once
  to install two packages. The setup episode gives options for Windows,
  macOS and Linux hosts.
:::

:::{toctree}
:caption: Software setup
:maxdepth: 1

episodes/use17-1-setup
:::

```{toctree}
:caption: The lesson
:maxdepth: 1

episodes/use17-2-sessions
episodes/use17-3-windows-and-panes
episodes/use17-4-editing-in-a-session
episodes/quiz/quiz
```

:::{toctree}
:caption: Reference
:maxdepth: 1

instructor-guide
reference-for-learners
authoring-evidence
:::

## Learning outcomes

This material serves new Linux users and HPC users who work on machines they
reach over SSH, where a dropped connection costs a running job or an
unfinished edit.

By the end of this module (about 2 hours), you can:

- **Give examples for use cases for such a multiplexer** *(official CQF
  outcome)*: name the situations a multiplexer answers and the mechanism
  behind each one, from a command that has to survive a dropped connection,
  through several views inside one connection, to two people attached to one
  screen; and say what it does not do, including surviving a reboot.
- **Review editing files using a terminal multiplexer** *(official CQF
  outcome)*: open a file in an editor inside a session, detach with the
  buffer unwritten, reattach and finish the edit, prove from outside the
  session what is on disk, send a keystroke the prefix would otherwise take,
  and recover an unwritten buffer after the session is killed.

The outcome texts above are the official CQF outcomes reproduced verbatim.
See {doc}`authoring-evidence`.

## See also

:::{admonition} Credit
:class: warning

Author: Ovidiu Pescar, Fisherman Engineering.

Built with the [EVITA module
template](https://code.europa.eu/eurohpc-ju/evita/module-template). How the
module was built and verified is documented in {doc}`authoring-evidence`.
The editors this module runs inside a session are taught in the companion
module SDS.OSV1-USE1.6, and the signals behind Ctrl+C and Ctrl+Z in
SDS.OSV1-USE1.8.

:::

::::{admonition} License
:class: attention

FIXME: Ensure licenses are correct, and a plain-text copy is added to the repository.

:::{admonition} CC BY-SA for media and pedagogical material
:class: attention dropdown

Copyright © {{ copyright }}. This material is released by EVITA project, {{ author }} under the Creative Commons Attribution-ShareAlike 4.0 International (CC BY-SA 4.0).

**Canonical URL**: <https://creativecommons.org/licenses/by-sa/4.0/>

[See the legal code](https://creativecommons.org/licenses/by-sa/4.0/legalcode.en)

## You are free to

1. **Share** — copy and redistribute the material in any medium or format for any purpose, even commercially.
2. **Adapt** — remix, transform, and build upon the material for any purpose, even commercially.
3. The licensor cannot revoke these freedoms as long as you follow the license terms.

## Under the following terms

1. **Attribution** — You must give [appropriate credit](https://creativecommons.org/licenses/by-sa/4.0/#ref-appropriate-credit) , provide a link to the license, and [indicate if changes were made](https://creativecommons.org/licenses/by-sa/4.0/#ref-indicate-changes) . You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
2. **ShareAlike** — If you remix, transform, or build upon the material, you must distribute your contributions under the [same license](https://creativecommons.org/licenses/by-sa/4.0/#ref-same-license) as the original.
3. **No additional restrictions** — You may not apply legal terms or [technological measures](https://creativecommons.org/licenses/by-sa/4.0/#ref-technological-measures) that legally restrict others from doing anything the license permits.

## Notices

You do not have to comply with the license for elements of the material in the public domain or where your use is permitted by an applicable [exception or limitation](https://creativecommons.org/licenses/by-sa/4.0/deed.en#ref-exception-or-limitation) .

No warranties are given. The license may not give you all of the permissions necessary for your intended use. For example, other rights such as [publicity, privacy, or moral rights](https://creativecommons.org/licenses/by-sa/4.0/deed.en#ref-publicity-privacy-or-moral-rights) may limit how you use the material.

This deed highlights only some of the key features and terms of the actual license. It is not a license and has no legal value. You should carefully review all of the terms and conditions of the actual license before using the licensed material.

:::

:::{admonition} MIT for source code and code snippets
:class: attention dropdown

MIT License

Copyright (c) {{ copyright }}

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

:::

:::{note}
*To module authors*: For code you may use any OSI-approved license as mentioned in <https://spdx.org/licenses/>, such as Apache License 2.0, GNU GPLv3, MIT. Please make sure to update the deed above and
`LICENSE.code` file accordingly.
:::

::::
