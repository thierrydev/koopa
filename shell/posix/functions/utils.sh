#!/bin/sh
# shellcheck disable=SC2039

_koopa_array_to_r_vector() {                                              # {{{3
    # """
    # Convert a bash array to an R vector string.
    # Updated 2019-09-25.
    #
    # Example: ("aaa" "bbb") array to 'c("aaa", "bbb")'.
    # """
    local x
    x="$(printf '"%s", ' "$@")"
    x="$(_koopa_strip_right "$x" ", ")"
    printf "c(%s)\n" "$x"
}

_koopa_bcbio_version() {
    # """
    # Get current bcbio-nextgen stable release version.
    # Updated 2019-11-22.
    #
    # Alternate approach:
    # > current="$(_koopa_github_latest_release "bcbio/bcbio-nextgen")"
    # """
    curl --silent "https://raw.githubusercontent.com/bcbio/bcbio-nextgen\
/master/requirements-conda.txt" \
        | grep 'bcbio-nextgen=' \
        | cut -d '=' -f 2
}

_koopa_cpu_count() {
    # """
    # Get the number of cores (CPUs) available.
    # Updated 2019-11-21.
    # """
    local n
    if _koopa_is_darwin
    then
        n="$(sysctl -n hw.ncpu)"
    elif _koopa_is_linux
    then
        n="$(getconf _NPROCESSORS_ONLN)"
    else
        # Otherwise assume single threaded.
        n=1
    fi
    # Set to n-1 cores, if applicable.
    # We're leaving a core free to monitor remote sessions.
    if [ "$n" -gt 1 ]
    then
        n=$((n - 1))
    fi
    echo "$n"
}

_koopa_quiet_cd() {                                                       # {{{3
    # """
    # Change directory quietly
    # Updated 2019-10-29.
    # """
    cd "$@" > /dev/null || return 1
}

_koopa_quiet_expr() {                                                     # {{{3
    # """
    # Quiet regular expression matching that is POSIX compliant.
    # Updated 2019-10-08.
    #
    # Avoid using '[[ =~ ]]' in sh config files.
    # 'expr' is faster than using 'case'.
    #
    # See also:
    # - https://stackoverflow.com/questions/21115121
    # """
    expr "$1" : "$2" 1>/dev/null
}

_koopa_quiet_rm() {                                                       # {{{3
    # """
    # Remove quietly.
    # Updated 2019-10-29.
    # """
    rm -fr "$@" > /dev/null 2>&1
}

_koopa_update_git_repo() {                                                # {{{3
    # """
    # Update a git repository.
    # Updated 2019-11-26.
    # """
    local repo
    repo="$1"
    [ -d "${repo}" ] || return 0
    [ -x "${repo}/.git" ] || return 0
    _koopa_message "Updating '${repo}'."
    (
        cd "$repo" || exit 1
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
    return 0
}