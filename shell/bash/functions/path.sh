#!/usr/bin/env bash

koopa::_list_path_priority() { # {{{1
    # """
    # Split PATH string by ':' delim into lines.
    # @note Updated 2019-10-27.
    #
    # Note that we're using awk approach here because it is shell agnostic.
    #
    # Bash here string parsing approach (non-POSIX):
    # Refer to heredoc format in 'man bash' for details.
    # > tr ':' '\n' <<< "$str"
    #
    # Bash parameter expansion approach:
    # > koopa::print "${PATH//:/$'\n'}"
    #
    # see also:
    # - https://askubuntu.com/questions/600018
    # - https://stackoverflow.com/questions/26849247
    # - https://www.gnu.org/software/gawk/manual/html_node/String-Functions.html
    # - https://www.unix.com/shell-programming-and-scripting/
    #       77199-splitting-string-awk.html
    # """
    local str
    koopa::assert_has_args_le "$#" 1
    koopa::assert_is_installed awk
    str="${1:-$PATH}"
    x="$( \
        koopa::print "$str" \
        | awk '{split($0,array,":")} END { for (i in array) print array[i] }' \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::_list_path_priority_unique() { # {{{1
    # """
    # Split PATH string by ':' delim into lines but only return uniques.
    # @note Updated 2020-07-03.
    # """
    local x
    koopa::assert_is_installed awk tac
    x="$( \
        koopa::_list_path_priority "$@" \
            | tac \
            | awk '!a[$0]++' \
            | tac \
    )"
    [[ -n "$x" ]] || return 1
    koopa::print "$x"
    return 0
}

koopa::add_conda_env_to_path() { # {{{1
    # """
    # Add conda environment(s) to PATH.
    # @note Updated 2020-06-30.
    # """
    # shellcheck disable=SC2039
    local bin_dir name
    koopa::assert_has_args "$#"
    koopa::assert_is_installed conda
    [[ -z "${CONDA_PREFIX:-}" ]] || return 1
    for name in "$@"
    do
        bin_dir="${CONDA_PREFIX}/envs/${name}/bin"
        if [[ ! -d "$bin_dir" ]]
        then
            koopa::warning "Conda environment missing: '${bin_dir}'."
            return 1
        fi
        koopa::add_to_path_start "$bin_dir"
    done
    return 0
}

koopa::list_path_priority() { # {{{1
    # """
    # List path priority.
    # @note Updated 2020-07-10.
    # """
    local all all_arr n_all n_dupes n_unique unique
    koopa::assert_is_installed awk
    all="$(koopa::_list_path_priority "$@")"
    readarray -t all_arr <<< "$(koopa::print "$all")"
    unique="$(koopa::print "$all" | awk '!a[$0]++')"
    readarray -t unique_arr <<< "$(koopa::print "$unique")"
    n_all="${#all_arr[@]}"
    n_unique="${#unique_arr[@]}"
    n_dupes="$((n_all-n_unique))"
    if [[ "$n_dupes" -gt 0 ]]
    then
        koopa::note "${n_dupes} duplicate(s) detected."
    fi
    koopa::print "$all"
    return 0
}
