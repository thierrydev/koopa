#!/usr/bin/env bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
# shellcheck source=/dev/null
source "${script_dir}/../../../shell/bash/include/header.sh"



# Programs                                                                  {{{1
# ==============================================================================

if _koopa_is_darwin
then
    update-homebrew
    # > if _koopa_has_sudo
    # > then
    # >     update-tex
    # > fi
elif _koopa_is_linux
then
    reset-prefix-permissions
    prefix="$(_koopa_build_prefix)"
    remove-broken-symlinks "$prefix"
    remove-empty-dirs "$prefix"
fi

update-conda
update-venv
update-rust
update-r-packages



# Config dirs                                                               {{{1
# ==============================================================================

config_dir="$(_koopa_config_dir)"

# Loop across config directories and update git repos.
dirs=(
    Rcheck
    docker
    dotfiles
    dotfiles-private
    oh-my-zsh
    rbenv
    scripts-private
    spacemacs
)
for dir in "${dirs[@]}"
do
    # Skip directories that aren't a git repo.
    if [[ ! -x "${config_dir}/${dir}/.git" ]]
    then
        continue
    fi
    _koopa_message "Updating '${dir}'."
    (
        cd "${config_dir}/${dir}" || exit 1
        # Run updater script, if defined.
        # Otherwise pull the git repo.
        if [[ -x "UPDATE.sh" ]]
        then
            ./UPDATE.sh
        else
            git fetch --all
            git pull
        fi
    )
done

# Update repo.
_koopa_message "Updating koopa."
(
    cd "$KOOPA_HOME" || exit 1
    git fetch --all
    # > git checkout master
    git pull
)

# Clean up legacy files.
if [[ -d "${KOOPA_HOME}/system/config" ]]
then
    rm -frv "${KOOPA_HOME}/system/config"
fi

_koopa_message "koopa update was successful."
_koopa_note "Shell must be reloaded for changes to take effect."
