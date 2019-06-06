# koopa 🐢

[![Travis CI build status](https://travis-ci.com/acidgenomics/koopa.svg?branch=master)](https://travis-ci.com/acidgenomics/koopa)
[![Repo status: active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)

Shell bootloader for bioinformatics.

## Requirements

Currently, these [POSIX][]-compliant shells are supported: [bash][], [zsh][], [ksh][].

Dependencies:

- Linux or macOS. Windows isn't supported.
- [Bash][] >= 5. Always required, even when using a different shell.
- [Python][] >= 3.7.
- [R][] >= 3.6.

Optional:

- [Conda][] >= 4.5.
  Note that [conda][] doesn't currently work with ksh (see [issue](https://github.com/conda/conda/issues/7843)).

## Installation

Clone the repository:

```sh
git clone https://github.com/acidgenomics/koopa.git ~/koopa
```

Run the installer script:

```
~/koopa/install
```

Add these lines to your POSIX-compliant shell configuration file.

```sh
# koopa shell
# https://github.com/acidgenomics/koopa
# shellcheck source=/dev/null
. "${HOME}/koopa/activate"
```

Koopa should now activate at login.

To obtain information about the working environment, run `koopa-info`.

## Troubleshooting

### Shell configuration file

Not sure where to source `activate` in your configuration? Here are some general recommendations, in order of priority for each shell. These can differ depending on the operating system, so refer to your shell documentation for details.

- [bash][]: `.bash_profile`, `.bashrc`.
- [zsh][]: `.zshrc`, `.zprofile`.
- [ksh][]: `.kshrc`, `.profile`.

### dotfiles example

Koopa is intended to help simplify the bioinformatics side of a user's shell configuration. Take a look at Mike's [dotfiles][] repo for an example configuration that sources koopa.

## Additional configuration

Koopa provides automatic configuration and `$PATH` variable support for a number of popular bioinformatics tools. When configuring manually, ensure that variables are defined before sourcing `activate`.

### Aspera Connect

[Aspera Connect][] is a secure file transfer application commonly used by numerous organizations, including the NIH and Broad Institute. Koopa will automatically detect Aspera when it is installed at the default path of `~/.aspera/`. Otherwise, the installation path can be defined manually using the `$ASPERA_EXE` variable.

```bash
export ASPERA_EXE="${HOME}/.aspera/connect/bin/asperaconnect"
```

### bcbio

[bcbio][] is a [Python][] toolkit that provides modern NGS analysis pipelines for RNA-seq, single-cell RNA-seq, ChIP-seq, and variant calling. Koopa provides automatic configuration support for the Harvard O2 and Odyssey high-performance computing clusters. Otherwise, the installation path can be defined manually using the `$BCBIO_EXE` variable.

```bash
export BCBIO_EXE="/usr/local/bin/bcbio_nextgen.py"
```

### conda

[Conda][] is an open source package management system that provides pre-built binaries using versioned recipes for Linux and macOS.

Koopa supports automatic loading of a default environment.
Simply set the `$CONDA_DEFAULT_ENV` variable to your desired environment name.

```bash
export CONDA_DEFAULT_ENV="scikit-learn"
```

Koopa provides automatic detection and activation support when conda is installed at any of these locations (note priority):

- `~/anaconda3/`
- `~/miniconda3/`
- `/usr/local/anaconda3/`
- `/usr/local/miniconda3/`

Oherwise, the installation path can be defined manually using the `$CONDA_EXE` variable.

```bash
export CONDA_EXE="${HOME}/anaconda3/bin/conda"
```

### SSH key

On Linux, koopa will launch `ssh-agent` and attempt to import the default [SSH][] key at `~/.ssh/id_rsa`, if the key file exists. A different default key can be defined manually using the `$SSH_KEY` variable.

```bash
export SSH_KEY="${HOME}/.ssh/id_rsa"
```

On macOS, instead we recommend adding these lines to `~/.ssh/config` to use the system keychain:

```
Host *
    AddKeysToAgent yes
    IdentityFile ~/.ssh/id_rsa
    UseKeychain yes
```

### PGP key

Automatic [PGP][] key support will be added in a future update.

## Tools

Upon activation, koopa makes some additional scripts available in `$PATH`, which are defined in the [`bin/`](bin/) directory of the repo. Run `koopa-list` for a complete list.

[Aspera Connect]: https://downloads.asperasoft.com/connect2/
[Bash]: https://www.gnu.org/software/bash/  "Bourne again shell"
[bcbio]: https://bcbio-nextgen.readthedocs.io/
[Conda]: https://conda.io/
[dotfiles]: https://github.com/mjsteinbaugh/dotfiles/
[Fish]: https://fishshell.com/
[Git]: https://git-scm.com/
[ksh]: http://www.kornshell.com/  "KornShell"
[PGP]: https://www.openpgp.org/
[POSIX]: https://en.wikipedia.org/wiki/POSIX  "Portable Operating System Interface"
[Python]: https://www.python.org/
[R]: https://www.r-project.org/
[SSH]: https://en.wikipedia.org/wiki/Secure_Shell
[tcsh]: https://en.wikipedia.org/wiki/Tcsh
[Zsh]: https://www.zsh.org/  "Z shell"
