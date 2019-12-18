---
title: koopa
layout: front
---

![Screenshot](images/screenshot.png)

# Requirements

- [POSIX][]-compliant shell: [Bash][] or [Zsh][]
- Linux or macOS

Tested on:

- macOS Catalina, Mojave
- Debian 10 (Buster)
- Ubuntu 18 LTS (Bionic Beaver)
- Fedora 31
- RHEL 8 / CentOS 8
- RHEL 7 / CentOS 7
- Amazon Linux 2
- openSUSE Leap
- Raspbian Buster
- Kali
- Arch
- Alpine

Dependencies for executable scripts in `bin/`:

- [Bash][] >= 4
- [Python][] >= 3
- [R][] >= 3.6

# Installation

Requirements: bash, curl, git.

## Single user

```sh
curl -sSL https://koopa.acidgenomics.com/install | bash
```

Installs into `~/.local/share/koopa/`, following the recommended [XDG base directory specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html).

Next, add these lines to your shell configuration file:

```sh
# koopa shell
# https://koopa.acidgenomics.com/
# shellcheck source=/dev/null
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-${HOME}/.config}"
. "${XDG_CONFIG_HOME}/koopa/activate"
```

Not sure where to source `activate` in your configuration? Here are some general recommendations, in order of priority for each shell. These can differ depending on the operating system, so refer to your shell documentation for details.

- [bash][]: `.bash_profile`, `.bashrc`.
- [zsh][]: `.zshrc`, `.zprofile`.

## Shared (for all users)

Requires sudo (i.e. administrator) permissions.

```sh
curl -sSL https://koopa.acidgenomics.com/install | bash -s -- --shared
```

Installs into `/usr/local/koopa/`.

This will also add a shared profile configuration file into `/etc/profile.d/` for supported Linux distros, but not macOS.

If you're going to install any programs using the cellar scripts, also ensure the permissions for `/usr/local/` are group writable. The installer attempts to fix this automatically, if necessary.

## Check installation

Restart the shell. Koopa should now activate automatically at login. You can verify this with `command -v koopa`. Next, check your environment dependencies with `koopa check`. To obtain information about the working environment, run `koopa info`.

[aspera connect]: https://downloads.asperasoft.com/connect2/
[bash]: https://www.gnu.org/software/bash/  "Bourne Again SHell"
[bcbio]: https://bcbio-nextgen.readthedocs.io/
[conda]: https://conda.io/
[dash]: https://wiki.archlinux.org/index.php/Dash  "Debian Almquist SHell"
[dotfiles]: https://github.com/mjsteinbaugh/dotfiles/
[fish]: https://fishshell.com/  "Friendly Interactive SHell"
[git]: https://git-scm.com/
[koopa]: https://koopa.acidgenomics.com/
[ksh]: http://www.kornshell.com/  "KornSHell"
[pgp]: https://www.openpgp.org/
[posix]: https://en.wikipedia.org/wiki/POSIX  "Portable Operating System Interface"
[python]: https://www.python.org/
[python]: https://www.python.org/
[r]: https://www.r-project.org/
[r]: https://www.r-project.org/
[ssh]: https://en.wikipedia.org/wiki/Secure_Shell
[tcsh]: https://en.wikipedia.org/wiki/Tcsh  "TENEX C Shell"
[zsh]: https://www.zsh.org/  "Z SHell"
