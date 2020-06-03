#!/usr/bin/env bash

_koopa_activate_bash() {  # {{{1
    # """
    # Activate Bash shell.
    # @note Updated 2020-06-03.
    # """
    # Correct minor directory changing spelling mistakes.
    shopt -s cdspell

    # Check the window size after each command and if necessary, update the
    # values of LINES and COLUMNS.
    shopt -s checkwinsize

    # Save multiline commands.
    shopt -s cmdhist

    # If set, the pattern "**" used in a pathname expansion context will match
    # all files and zero or more directories and subdirectories.
    # > shopt -s globstar

    # Append to the history file, don't overwrite it.
    shopt -s histappend

    # Map key bindings to default editor.
    # Note that Bash currently uses Emacs by default.
    case "${EDITOR:-}" in
        emacs)
            set -o emacs
            ;;
        vi|vim)
            set -o vi
            ;;
    esac

    # Make less more friendly for non-text input files, see lesspipe(1).
    [[ -x /usr/bin/lesspipe ]] && eval "$(SHELL=/bin/sh lesspipe)"

    # Readline input options.
    if [[ -z "${INPUTRC:-}" ]] && [[ -r "${HOME}/.inputrc" ]]
    then
        export INPUTRC="${HOME}/.inputrc"
    fi

    # Prompt.
    PS1="$(_koopa_prompt)"
    export PS1

    # Alias definitions.
    # See /usr/share/doc/bash-doc/examples in the bash-doc package.
    if [[ -f ~/.bash_aliases ]]
    then
        # shellcheck source=/dev/null
        . ~/.bash_aliases
    fi

    return 0
}
