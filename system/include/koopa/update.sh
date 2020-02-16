#!/usr/bin/env bash
set -Eeu -o pipefail

set -x

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"

# e.g. /usr/local/koopa
koopa_prefix="$(_koopa_prefix)"
# e.g. ~/.config/koopa
config_prefix="$(_koopa_config_prefix)"
# e.g. /usr/local/opt
app_prefix="$(_koopa_app_prefix)"
# e.g. /usr/local
make_prefix="$(_koopa_make_prefix)"

system=0

while (("$#"))
do
    case "$1" in
        --system)
            system=1
            shift 1
            ;;
        *)
            _koopa_invalid_arg "$1"
            ;;
    esac
done

_koopa_h1 "Updating koopa at '${koopa_prefix}'."

# Note that stable releases are not git, and can't be updated.
if ! _koopa_is_git "$koopa_prefix"
then
    version="$(_koopa_version)"
    url="https://koopa.acidgenomics.com"
    _koopa_note "Stable release of koopa ${version} detected."
    _koopa_note "To update, first run the 'uninstall' script."
    _koopa_note "Then run the default install command at '${url}'."
    exit 1
fi

if _koopa_is_shared_install
then
    if [[ "$system" -eq 1 ]]
    then
        _koopa_dl "config prefix" "${config_prefix}"
        _koopa_dl "make prefix" "${make_prefix}"
        _koopa_dl "app prefix" "${app_prefix}"
        echo
    fi
    _koopa_note "Shared installation detected."
    _koopa_note "sudo privileges are required."
    _koopa_assert_has_sudo
fi

_koopa_set_permissions "$koopa_prefix"

(
    cd "$koopa_prefix" || exit 1
    _koopa_git_pull
    cd "${koopa_prefix}/dotfiles" || exit 1
    _koopa_git_reset
    _koopa_git_pull
) 2>&1 | tee "$(_koopa_tmp_log_file)"

_koopa_set_permissions "$koopa_prefix"

_koopa_update_xdg_config
_koopa_update_ldconfig
_koopa_update_etc_profile_d

# Loop across config directories and update git repos.
# Consider nesting these under 'app' directory.
_koopa_h1 "Updating user config at '${config_prefix}'."
rm -frv "${config_prefix}/"{Rcheck,autojump,oh-my-zsh,pyenv,rbenv,spacemacs}

repos=(
    docker
    dotfiles-private
    scripts-private
)
for repo in "${repos[@]}"
do
    repo="${config_prefix}/${repo}"
    [ -d "$repo" ] || continue
    _koopa_git_pull "$repo"
done

if [[ "$system" -eq 1 ]]
then
    _koopa_h1 "Updating system configuration."
    if _koopa_is_macos
    then
        update-homebrew
    elif _koopa_is_installed configure-vm
    then
        configure-vm
    fi
    if [[ ! -f "${config_prefix}/rsync" ]]
    then
        update-r-packages
        update-conda
        update-python-packages
        update-rust
        update-rust-packages
        update-perlbrew
        if _koopa_is_linux
        then
            update-pyenv
            update-rbenv
        fi
    fi
    # Update managed git repos.
    _koopa_git_pull "${HOME}/.emacs.d-doom"
    _koopa_git_pull "${HOME}/.emacs.d-spacemacs"
    _koopa_git_pull "${XDG_DATA_HOME}/Rcheck"
fi

_koopa_fix_zsh_permissions

_koopa_success "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
