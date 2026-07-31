# Setting Up the Environment

This module runs commands inside terminal sessions that you leave and come
back to. You need an **Ubuntu 24.04 LTS** shell, the two multiplexers `tmux`
and `screen`, and one working directory. Everything after the installation
runs as an ordinary user.

:::{objectives}
- Obtain a shell on Ubuntu 24.04 LTS, on any host operating system.
- Install `tmux` and `screen` and confirm their versions.
- Create the working directory that Episodes 2 to 4 use.
:::

:::{instructor-note}
- 10 min, of which the `apt-get` run is the slowest part on a fresh virtual
  machine
- Learners who built an environment for another SDS.OSV1 module reuse it and
  run only the installation and the verification block
- The one setup detail that matters later: this module assumes **no**
  `~/.tmux.conf`. A learner who brings a configured machine may have a
  different prefix key, and every keystroke in Episodes 2 to 4 will be
  wrong. The verification block reports the prefix in use
- Cohorts may provision one Ubuntu 24.04 virtual machine per trainee; any
  Ubuntu 24.04 account with `sudo` for the single install works
:::

## Local installation

The baseline for all shown outputs: **Ubuntu 24.04.1 LTS, tmux 3.4, GNU
Screen 4.09.01, an ordinary user account**.

::::{tabs}

:::{group-tab} Linux

If you already run Ubuntu 24.04, open a terminal and go to the installation
step. Otherwise use a throwaway virtual machine:

```bash
sudo snap install multipass
multipass launch 24.04 --name evita-use17
multipass shell evita-use17
```

Any hypervisor (virt-manager, VirtualBox) with an Ubuntu 24.04 Server image
works equally well.

:::

:::{group-tab} Windows

WSL2 is enough for this module and is what the outputs below were harvested
on:

```powershell
wsl --install -d Ubuntu-24.04
```

Run every command of this module inside the Ubuntu shell, not in PowerShell.
The key names in this module are the ones your keyboard sends to that shell:
Ctrl, Alt, Esc.

:::

:::{group-tab} macOS

```bash
brew install multipass
multipass launch 24.04 --name evita-use17
multipass shell evita-use17
```

On Apple Silicon, UTM with an Ubuntu 24.04 ARM image is the common
alternative. Inside the Ubuntu shell, the key this module calls Ctrl is the
Control key on your keyboard. The Command key is not used.

:::

::::

:::{caution}
Use a machine you can throw away. This module installs two packages, starts
background processes and kills them again. None of that damages a system,
but a disposable virtual machine keeps a mistake cheap, and the cleanup
section of Episode 4 is written for the state this module creates, not for
whatever else your daily machine runs.
:::

## Install the two multiplexers

```console
$ sudo apt-get update
$ sudo apt-get install -y tmux screen
```

On a machine that has neither package, `apt-get` reports two new ones:

```console
The following NEW packages will be installed:
  screen tmux
0 upgraded, 2 newly installed, 0 to remove and 134 not upgraded.
Need to get 1134 kB of archives.
After this operation, 2208 kB of additional disk space will be used.
```

Many Ubuntu images already carry `tmux`. If yours does, `apt-get` says so and
changes nothing. Either outcome is fine.

## Verify your environment

:::{type-along}

In your Ubuntu 24.04 shell:

```console
$ grep PRETTY_NAME /etc/os-release
PRETTY_NAME="Ubuntu 24.04.1 LTS"
$ tmux -V
tmux 3.4
$ screen --version
Screen version 4.09.01 (GNU) 20-Aug-23
```

Then check that no configuration file changes the keys this module uses:

```console
$ ls -l ~/.tmux.conf /etc/tmux.conf
  ls: cannot access '/home/trainee/.tmux.conf': No such file or directory
  ls: cannot access '/etc/tmux.conf': No such file or directory
$ tmux -f /dev/null start-server \; show-options -g prefix \; show-options -g default-terminal \; show-options -g status \; kill-server
prefix C-b
default-terminal tmux-256color
status on
```

Two files reported missing is the expected result: this module is written for
the defaults. `prefix C-b` is the keystroke every later episode calls
**Ctrl+B**. If your machine reports a different prefix, either move the
configuration file aside for the duration of the module or read `C-b` in
these episodes as whatever your prefix is.

A slightly different tmux version is not a problem. Version 3.4 is what
Ubuntu 24.04 ships, and the commands in this module have been stable for
years.

:::

## Create the working directory

Everything you create in this module lives in one directory, which Episode 4
removes:

```console
$ mkdir -p ~/use17 && cd ~/use17 && pwd
/home/trainee/use17
```

Your own user name appears where this transcript shows `trainee`.

:::{note}
**On an HPC login node** you normally find a multiplexer installed already,
`screen` more often than `tmux`. Check with `tmux -V` and `screen --version`
before you install anything: on a shared system you have no package
manager, and there is nothing to install. Everything else in this module
works there unchanged, because no command in it needs privileges. This
statement about clusters rests on the authors' experience of other systems
and not on a EuroHPC account, which is recorded in
{doc}`../authoring-evidence`.
:::

:::{keypoints}
- One Ubuntu 24.04 shell, `tmux` and `screen` installed, and the working
  directory `~/use17`.
- This module assumes the stock configuration, where the tmux prefix is
  Ctrl+B.
- Nothing after this episode needs `sudo`.
:::
