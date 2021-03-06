#!/usr/bin/env bash

koopa::has_file_ext() { # {{{1
    # """
    # Does the input contain a file extension?
    # @note Updated 2020-07-04.
    #
    # @examples
    # koopa::has_file_ext 'hello.txt'
    # """
    local file
    koopa::assert_has_args "$#"
    for file in "$@"
    do
        koopa::str_match "$(koopa::print "$file")" '.' || return 1
    done
    return 0
}

koopa::has_monorepo() { # {{{1
    # """
    # Does the current user have a monorepo?
    # @note Updated 2020-07-03.
    # """
    [[ -d "$(koopa::monorepo_prefix)" ]]
}

koopa::has_no_environments() { # {{{1
    # """
    # Detect activation of virtual environments.
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_conda_active && return 1
    koopa::is_venv_active && return 1
    return 0
}

koopa::has_passwordless_sudo() { # {{{1
    # """
    # Check if sudo is active or doesn't require a password.
    # @note Updated 2020-07-03.
    #
    # See also:
    # https://askubuntu.com/questions/357220
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_installed sudo || return 1
    sudo -n true 2>/dev/null && return 0
    return 1
}

koopa::has_sudo() { # {{{1
    # """
    # Check that current user has administrator (sudo) permission.
    # @note Updated 2020-06-30.
    #
    # This check is hanging on an CPI AWS Ubuntu EC2 instance, I think due to
    # 'groups' can lag on systems for domain user accounts.
    # Currently seeing on CPI AWS Ubuntu config.
    #
    # Avoid prompting with '-n, --non-interactive', but note that this isn't
    # supported on all systems.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # Alternate approach:
    # > sudo -l
    #
    # List all users with sudo access:
    # > getent group sudo
    #
    # - macOS: admin
    # - Debian: sudo
    # - Fedora: wheel
    #
    # See also:
    # - https://serverfault.com/questions/364334
    # - https://linuxhandbook.com/check-if-user-has-sudo-rights/
    # """
    koopa::assert_has_no_args "$#"
    # Always return true for root user.
    [[ "$(koopa::user_id)" -eq 0 ]] && return 0
    # Return false if 'sudo' program is not installed.
    koopa::is_installed sudo || return 1
    # Early return true if user has passwordless sudo enabled.
    koopa::has_passwordless_sudo && return 0
    # Check if user is any accepted admin group.
    # Note that this step is very slow for Active Directory domain accounts.
    koopa::str_match_regex "$(groups)" '\b(admin|root|sudo|wheel)\b'
}

koopa::is_anaconda() { # {{{1
    # """
    # Is Anaconda (rather than Miniconda) installed?
    # @note Updated 2020-07-08.
    # """
    [[ -x "$(koopa::conda_prefix)/bin/anaconda" ]]
}

koopa::is_array_non_empty() { # {{{1
    # """
    # Is the array non-empty?
    # @note Updated 2020-07-17.
    #
    # Particularly useful for checking against readarray return, which currently
    # returns a length of 1 for empty input, due to newlines line break.
    # """
    local arr
    [[ "$#" -gt 0 ]] || return 1
    arr=("$@")
    [[ -z "${arr[0]}" ]] && return 1
    return 0
}

koopa::is_bash_ok() { # {{{1
    # """
    # Is the current version of Bash OK (or super old)?
    # @note Updated 2020-07-05.
    # 
    # Older versions (< 4; e.g. shipping version on macOS) have issues with
    # 'read' that we have to handle with special care here.
    # """
    # shellcheck disable=SC2039
    local major_version version
    koopa::is_installed bash || return 1
    version="$(koopa::get_version 'bash')"
    major_version="$(koopa::major_version "$version")"
    [[ "$major_version" -ge 4 ]]
}

koopa::is_cellar() { # {{{1
    # """
    # Is a specific command or file cellarized?
    # @note Updated 2020-07-04.
    #
    # Currently only supported for Linux.
    # """
    local cellar_prefix str
    koopa::assert_has_args "$#"
    cellar_prefix="$(koopa::cellar_prefix)"
    [[ -d "$cellar_prefix" ]] || return 1
    for str in "$@"
    do
        if koopa::is_installed "$str"
        then
            str="$(koopa::which_realpath "$str")"
        elif [[ -e "$str" ]]
        then
            str="$(realpath "$str")"
        else
            return 1
        fi
        koopa::str_match_regex "$str" "^${cellar_prefix}" || return 1
    done
    return 0
}

koopa::is_current_version() { # {{{1
    # """
    # Is the program version current?
    # @note Updated 2020-07-20.
    # """
    local actual_version app expected_version
    koopa::assert_has_args "$#"
    for app in "$@"
    do
        expected_version="$(koopa::variable "$app")"
        actual_version="$(koopa::get_version "$app")"
        [[ "$actual_version" == "$expected_version" ]] || return 1
    done
    return 0
}

koopa::is_defined_in_user_profile() { # {{{1
    # """
    # Is koopa defined in current user's shell profile configuration file?
    # @note Updated 2020-07-04.
    # """
    local file
    koopa::assert_has_no_args "$#"
    file="$(koopa::find_user_profile)"
    koopa::file_match "$file" 'koopa'
}

koopa::is_docker() { # {{{1
    # """
    # Is the current shell running inside Docker?
    # @note Updated 2020-07-04.
    #
    # https://stackoverflow.com/questions/23513045
    # """
    koopa::assert_has_no_args "$#"
    koopa::file_match '/proc/1/cgroup' ':/docker/'
}

koopa::is_export() { # {{{1
    # """
    # Is a variable exported in the current shell session?
    # @note Updated 2020-06-30.
    #
    # Use 'export -p' (POSIX) instead of 'declare -x' (Bashism).
    #
    # See also:
    # - https://unix.stackexchange.com/questions/390831
    #
    # @examples
    # koopa::is_export 'KOOPA_SHELL'
    # """
    local arg exports
    koopa::assert_has_args "$#"
    exports="$(export -p)"
    for arg in "$@"
    do
        koopa::str_match_regex "$exports" "\b${arg}\b=" || return 1
    done
    return 0
}

koopa::is_file_system_case_sensitive() { # {{{1
    # """
    # Is the file system case sensitive?
    # @note Updated 2020-07-04.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    koopa::assert_has_no_args "$#"
    koopa::assert_is_installed find
    touch '.tmp.checkcase' '.tmp.checkCase'
    count="$(find . -maxdepth 1 -iname '.tmp.checkcase' | wc -l)"
    koopa::quiet_rm '.tmp.check'*
    [[ "$count" -eq 2 ]]
}

koopa::is_function() { # {{{1
    # """
    # Check if variable is a function.
    # @note Updated 2020-07-07.
    #
    # Note that 'declare' and 'typeset' are bashisms, and not POSIX.
    # Checking against 'type' works consistently across POSIX shells.
    #
    # Works in bash, ksh, zsh:
    # > typeset -f "$fun"
    #
    # Works in bash, zsh:
    # > declare -f "$fun"
    #
    # Works in bash (note use of '-t' flag):
    # [[ "$(type -t "$fun")" == 'function' ]]
    #
    # @seealso
    # - https://stackoverflow.com/questions/11478673/
    # - https://stackoverflow.com/questions/85880/
    # """
    local fun str
    koopa::assert_has_args "$#"
    for fun in "$@"
    do
        str="$(type "$fun" 2>/dev/null)"
        # Harden against empty string return.
        [[ -z "$str" ]] && str='no'
        koopa::str_match "$str" 'function' || return 1
    done
    return 0
}

koopa::is_github_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitHub access?
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_ssh_enabled 'git@github.com' 'successfully authenticated'
}

koopa::is_gitlab_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled for GitLab access?
    # @note Updated 2020-06-30.
    # """
    koopa::assert_has_no_args "$#"
    koopa::is_ssh_enabled 'git@gitlab.com' 'Welcome to GitLab'
}

koopa::is_powerful() { # {{{1
    # """
    # Is the current machine powerful?
    # @note Updated 2020-03-07.
    # """
    local cores
    koopa::assert_has_no_args "$#"
    cores="$(koopa::cpu_count)"
    [[ "$cores" -ge 7 ]] && return 0
    return 1
}

koopa::is_python_package_installed() { # {{{1
    # """
    # Check if Python package is installed.
    # @note Updated 2020-07-05.
    #
    # Fast mode: checking the 'site-packages' directory.
    #
    # Alternate, slow mode:
    # > local freeze
    # > freeze="$("$python" -m pip freeze)"
    # > koopa::str_match_regex "$freeze" "^${pkg}=="
    #
    # See also:
    # - https://stackoverflow.com/questions/1051254
    # - https://askubuntu.com/questions/588390
    # """
    local pkg pos prefix python
    koopa::assert_has_args "$#"
    python='python3'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --python=*)
                python="${1#*=}"
                shift 1
                ;;
            --python)
                python="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    koopa::is_installed "$python" || return 1
    prefix="$(koopa::python_site_packages_prefix "$python")"
    for pkg in "$@"
    do
        if [[ ! -d "${prefix}/${pkg}" ]] && [[ ! -f "${prefix}/${pkg}.py" ]]
        then
            return 1
        fi
    done
    return 0
}

koopa::is_r_package_installed() { # {{{1
    # """
    # Is the requested R package installed?
    # @note Updated 2020-07-06.
    #
    # This will only return true for user-installed packages.
    #
    # Fast mode: checking the 'site-library' directory.
    #
    # Alternate, slow mode:
    # > Rscript -e "'${1}' %in% rownames(utils::installed.packages())" \
    # >     | grep -q 'TRUE'
    # """
    local pkg pos r
    koopa::assert_has_args "$#"
    r='R'
    pos=()
    while (("$#"))
    do
        case "$1" in
            --r=*)
                r="${1#*=}"
                shift 1
                ;;
            --r)
                r="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    koopa::assert_has_args "$#"
    koopa::is_installed "$r" || return 1
    prefix="$(koopa::r_library_prefix "$r")"
    for pkg in "$@"
    do
        [[ -d "${prefix}/${pkg}" ]] || return 1
    done
    return 0
}

koopa::is_recent() { # {{{1
    # """
    # If the file exists and is more recent than 2 weeks old.
    #
    # @note Updated 2020-06-03.
    #
    # Current approach uses GNU find to filter based on modification date.
    #
    # Alternatively, can we use 'stat' to compare the modification time to Unix
    # epoch in seconds or with GNU date.
    #
    # @seealso
    # - https://stackoverflow.com/a/32019461
    #
    # @examples
    # koopa::is_recent ~/hello-world.txt
    # """
    local days exists file
    koopa::assert_has_args "$#"
    koopa::assert_is_installed find
    days=14
    for file in "$@"
    do
        [[ -e "$file" ]] || return 1
        exists="$( \
            find "$file" \
                -mindepth 0 \
                -maxdepth 0 \
                -mtime "-${days}" \
            2>/dev/null \
        )"
        [[ -n "$exists" ]] || return 1
    done
    return 0
}

koopa::is_set() { # {{{1
    # """
    # Is the variable set and non-empty?
    # @note Updated 2020-07-05.
    #
    # Passthrough of empty strings is bad practice in shell scripting.
    #
    # Note that usage of 'declare' here is a bashism.
    # Can consider using 'type' instead for POSIX compliance.
    #
    # @seealso
    # - https://stackoverflow.com/questions/3601515
    # - https://unix.stackexchange.com/questions/504082
    # - https://www.gnu.org/software/bash/manual/html_node/
    #       Shell-Parameter-Expansion.html
    # """
    local value var x
    koopa::assert_has_args "$#"
    for var
    do
        # Check if variable is defined.
        x="$(declare -p "$var" 2>/dev/null || true)"
        [[ -n "$x" ]] || return 1
        # Check if variable contains non-empty value.
        value="${!var}"
        [[ -n "$value" ]] || return 1
    done
    return 0
}

koopa::is_ssh_enabled() { # {{{1
    # """
    # Is SSH key enabled (e.g. for git)?
    # @note Updated 2020-07-04.
    #
    # @seealso
    # - https://help.github.com/en/github/authenticating-to-github/
    #       testing-your-ssh-connection
    # """
    local pattern url x
    koopa::assert_has_args_eq "$#" 2

    url="${1:?}"
    pattern="${2:?}"
    koopa::is_installed ssh || return 1
    x="$( \
        ssh -T \
            -o StrictHostKeyChecking=no \
            "$url" 2>&1 \
    )"
    [[ -n "$x" ]] || return 1
    koopa::str_match "$x" "$pattern"
}
