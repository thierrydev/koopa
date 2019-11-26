#!/bin/sh
# shellcheck disable=SC2039

_koopa_assert_has_args() {                                                # {{{3
    # """
    # Assert that the user has passed required arguments to a script.
    # Updated 2019-10-23.
    # """
    if [ "$#" -eq 0 ]
    then
        _koopa_stop "\
Required arguments missing.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_no_args() {                                             # {{{3
    # """
    # Assert that the user has not passed any arguments to a script.
    # Updated 2019-10-23.
    # """
    if [ "$#" -ne 0 ]
    then
        _koopa_stop "\
Invalid argument: '${1}'.
Run with '--help' flag for usage details."
    fi
    return 0
}

_koopa_assert_has_file_ext() {                                            # {{{3
    # """
    # Assert that input contains a file extension.
    # Updated 2019-10-23.
    # """
    if ! _koopa_has_file_ext "$1"
    then
        _koopa_stop "No file extension: '${1}'."
    fi
    return 0
}

_koopa_assert_has_no_envs() {                                             # {{{3
    # """
    # Assert that conda and Python virtual environments aren't active.
    # Updated 2019-10-23.
    # """
    if ! _koopa_has_no_environments
    then
        _koopa_stop "\
Active environment detected.
       (conda and/or python venv)

Deactivate using:
    venv:  deactivate
    conda: conda deactivate

Deactivate venv prior to conda, otherwise conda python may be left in path."
    fi
    return 0
}

_koopa_assert_has_sudo() {                                                # {{{3
    # """
    # Assert that current user has sudo (admin) permissions.
    # Updated 2019-10-23.
    # """
    if ! _koopa_has_sudo
    then
        _koopa_stop "sudo is required."
    fi
    return 0
}

_koopa_assert_is_conda_active() {                                         # {{{3
    # """
    # Assert that a Conda environment is active.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_conda_active
    then
        _koopa_stop "No active Conda environment detected."
    fi
    return 0
}

_koopa_assert_is_darwin() {                                               # {{{3
    # """
    # Assert that platform is Darwin (macOS).
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_darwin
    then
        _koopa_stop "macOS (Darwin) is required."
    fi
    return 0
}

_koopa_assert_is_debian() {                                               # {{{3
    # """
    # Assert that platform is Debian.
    # Updated 2019-10-25.
    # """
    if ! _koopa_is_debian
    then
        _koopa_stop "Debian is required."
    fi
    return 0
}

_koopa_assert_is_dir() {                                                  # {{{3
    # """
    # Assert that input is a directory.
    # Updated 2019-10-23.
    # """
    if [ ! -d "$1" ]
    then
        _koopa_stop "Not a directory: '${1}'."
    fi
    return 0
}

_koopa_assert_is_executable() {                                           # {{{3
    # """
    # Assert that input is executable.
    # Updated 2019-10-23.
    # """
    if [ ! -x "$1" ]
    then
        _koopa_stop "Not executable: '${1}'."
    fi
    return 0
}

_koopa_assert_is_existing() {                                             # {{{3
    # """
    # Assert that input exists on disk.
    # Updated 2019-10-23.
    #
    # Note that '-e' flag returns true for file, dir, or symlink.
    # """
    if [ ! -e "$1" ]
    then
        _koopa_stop "Does not exist: '${1}'."
    fi
    return 0
}

_koopa_assert_is_fedora() {                                               # {{{3
    # """
    # Assert that platform is Fedora.
    # Updated 2019-10-25.
    # """
    if ! _koopa_is_fedora
    then
        _koopa_stop "Fedora is required."
    fi
    return 0
}

_koopa_assert_is_file() {                                                 # {{{3
    # """
    # Assert that input is a file.
    # Updated 2019-09-12.
    # """
    if [ ! -f "$1" ]
    then
        _koopa_stop "Not a file: '${1}'."
    fi
    return 0
}

_koopa_assert_is_file_type() {                                            # {{{3
    # """
    # Assert that input matches a specified file type.
    # Updated 2019-10-23.
    #
    # Example: _koopa_assert_is_file_type "$x" "csv"
    # """
    _koopa_assert_is_file "$1"
    _koopa_assert_is_matching_regex "$1" "\.${2}\$"
}

_koopa_assert_is_git() {                                                  # {{{3
    # """
    # Assert that current directory is a git repo.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_git
    then
        _koopa_stop "Not a git repo."
    fi
    return 0
}

_koopa_assert_is_installed() {                                            # {{{3
    # """
    # Assert that programs are installed.
    # Updated 2019-10-23.
    #
    # Supports checking of multiple programs in a single call.
    # Note that '_koopa_is_installed' is not vectorized.
    # """
    for arg in "$@"
    do
        if ! _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is not installed."
        fi
    done
    return 0
}

_koopa_assert_is_linux() {                                                # {{{3
    # """
    # Assert that platform is Linux.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_linux
    then
        _koopa_stop "Linux is required."
    fi
    return 0
}

_koopa_assert_is_non_existing() {                                         # {{{3
    # """
    # Assert that input does not exist on disk.
    # Updated 2019-10-23.
    # """
    if [ -e "$1" ]
    then
        _koopa_stop "Exists: '${1}'."
    fi
    return 0
}

_koopa_assert_is_not_dir() {                                              # {{{3
    # """
    # Assert that input is not a directory.
    # Updated 2019-10-23.
    # """
    if [ -d "$1" ]
    then
        _koopa_stop "Directory exists: '${1}'."
    fi
    return 0
}

_koopa_assert_is_not_file() {                                             # {{{3
    # """
    # Assert that input is not a file.
    # Updated 2019-10-23.
    # """
    if [ -f "$1" ]
    then
        _koopa_stop "File exists: '${1}'."
    fi
    return 0
}

_koopa_assert_is_not_installed() {                                        # {{{3
    # """
    # Assert that programs are not installed.
    # Updated 2019-10-23.
    # """
    for arg in "$@"
    do
        if _koopa_is_installed "$arg"
        then
            _koopa_stop "'${arg}' is installed."
        fi
    done
    return 0
}

_koopa_assert_is_not_symlink() {                                          # {{{3
    # """
    # Assert that input is not a symbolic link.
    # Updated 2019-10-23.
    # """
    if [ -L "$1" ]
    then
        _koopa_stop "Symlink exists: '${1}'."
    fi
    return 0
}

_koopa_is_powerful() {                                                    # {{{3
    # """
    # Is the current machine powerful?
    # Updated 2019-11-22.
    # """
    local cores
    cores="$(_koopa_cpu_count)"
    if [ "$cores" -ge 7 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_assert_is_r_package_installed() {                                  # {{{3
    # """
    # Assert that a specific R package is installed.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_r_package_installed "$1"
    then
        _koopa_stop "'${1}' R package is not installed."
    fi
    return 0
}

_koopa_assert_is_readable() {                                             # {{{3
    # """
    # Assert that input is readable.
    # Updated 2019-10-23.
    # """
    if [ ! -r "$1" ]
    then
        _koopa_stop "Not readable: '${1}'."
    fi
    return 0
}

_koopa_assert_is_symlink() {                                              # {{{3
    # """
    # Assert that input is a symbolic link.
    # Updated 2019-10-23.
    # """
    if [ ! -L "$1" ]
    then
        _koopa_stop "Not symlink: '${1}'."
    fi
    return 0
}

_koopa_assert_is_venv_active() {                                          # {{{3
    # """
    # Assert that a Python virtual environment is active.
    # Updated 2019-10-23.
    # """
    _koopa_assert_is_installed pip
    if ! _koopa_is_venv_active
    then
        _koopa_stop "No active Python venv detected."
    fi
    return 0
}

_koopa_assert_is_writable() {                                             # {{{3
    # """
    # Assert that input is writable.
    # Updated 2019-10-23.
    # """
    if [ ! -r "$1" ]
    then
        _koopa_stop "Not writable: '${1}'."
    fi
    return 0
}

_koopa_assert_is_matching_fixed() {                                       # {{{3
    # """
    # Assert that input matches a fixed pattern.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_matching_fixed "$1" "$2"
    then
        _koopa_stop "'${1}' doesn't match fixed pattern '${2}'."
    fi
    return 0
}

_koopa_assert_is_matching_regex() {                                       # {{{3
    # """
    # Assert that input matches a regular expression pattern.
    # Updated 2019-10-23.
    # """
    if ! _koopa_is_matching_regex "$1" "$2"
    then
        _koopa_stop "'${1}' doesn't match regex pattern '${2}'."
    fi
    return 0
}

_koopa_check_azure() {                                                    # {{{3
    # """
    # Check Azure VM integrity.
    # Updated 2019-10-31.
    # """
    _koopa_is_azure || return 0
    if [ -e "/mnt/resource" ]
    then
        _koopa_check_user "/mnt/resource" "root"
        _koopa_check_group "/mnt/resource" "root"
        _koopa_check_access_octal "/mnt/resource" "1777"
    fi
    _koopa_check_mount "/mnt/rdrive"
    return 0
}

_koopa_check_access_human() {                                             # {{{3
    # """
    # Check if file or directory has expected human readable access.
    # Updated 2019-10-31.
    # """
    if [ ! -e "$1" ]
    then
        _koopa_warning "'${1}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_human "$1")"
    if [ "$access" != "$2" ]
    then
        _koopa_warning "'${1}' current access '${access}' is not '${2}'."
    fi
    return 0
}

_koopa_check_access_octal() {                                             # {{{3
    # """
    # Check if file or directory has expected octal access.
    # Updated 2019-10-31.
    # """
    if [ ! -e "$1" ]
    then
        _koopa_warning "'${1}' does not exist."
        return 1
    fi
    local access
    access="$(_koopa_stat_access_octal "$1")"
    if [ "$access" != "$2" ]
    then
        _koopa_warning "'${1}' current access '${access}' is not '${2}'."
    fi
    return 0
}

_koopa_check_group() {                                                    # {{{3
    # """
    # Check if file or directory has an expected group.
    # Updated 2019-10-31.
    # """
    if [ ! -e "$1" ]
    then
        _koopa_warning "'${1}' does not exist."
        return 1
    fi
    local group
    group="$(_koopa_stat_group "$1")"
    if [ "$group" != "$2" ]
    then
        _koopa_warning "'${1}' current group '${group}' is not '${2}'."
        return 1
    fi
    return 0
}

_koopa_check_mount() {                                                    # {{{3
    # """
    # Check if a drive is mounted.
    # Usage of find is recommended over ls here.
    # Updated 2019-10-31.
    # """
    if [ "$(find "$1" -mindepth 1 -maxdepth 1 | wc -l)" -eq 0 ]
    then
        _koopa_warning "'${1}' is unmounted."
        return 1
    fi
    return 0
}

_koopa_check_user() {                                                     # {{{3
    # """
    # Check if file or directory has an expected user.
    # Updated 2019-10-31.
    # """
    if [ ! -e "$1" ]
    then
        _koopa_warning "'${1}' does not exist."
        return 1
    fi
    local user
    user="$(_koopa_stat_user "$1")"
    if [ "$user" != "$2" ]
    then
        _koopa_warning "'${1}' current user '${user}' is not '${2}'."
        return 1
    fi
    return 0
}

_koopa_has_file_ext() {                                                   # {{{3
    # """
    # Does the input contain a file extension?
    # Updated 2019-10-08.
    #
    # Simply looks for a "." and returns true/false.
    # """
    echo "$1" | grep -q "\."
}

_koopa_has_no_environments() {                                            # {{{3
    # """
    # Detect activation of virtual environments.
    # Updated 2019-10-20.
    # """
    _koopa_is_conda_active && return 1
    _koopa_is_venv_active && return 1
    return 0
}

_koopa_has_sudo() {                                                       # {{{3
    # """
    # Check that current user has administrator (sudo) permission.
    # Updated 2019-09-28.
    #
    # Note that use of 'sudo -v' does not work consistently across platforms.
    #
    # - Darwin (macOS): admin
    # - Debian: sudo
    # - Fedora: wheel
    # """
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}

_koopa_invalid_arg() {                                                    # {{{3
    # """
    # Error on invalid argument.
    # Updated 2019-10-23.
    # """
    _koopa_stop "Invalid argument: '${1}'."
}

_koopa_is_aws() {                                                         # {{{3
    # """
    # Is the current session running on AWS?
    # Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "aws" ]
}

_koopa_is_azure() {                                                       # {{{3
    # """
    # Is the current session running on Microsoft Azure?
    # Updated 2019-11-25.
    # """
    [ "$(_koopa_host_id)" = "azure" ]
}

_koopa_is_conda_active() {                                                # {{{3
    # """
    # Is there a Conda environment active?
    # Updated 2019-10-20.
    # """
    [ -n "${CONDA_DEFAULT_ENV:-}" ]
}

_koopa_is_darwin() {                                                      # {{{3
    # """
    # Is the operating system Darwin (macOS)?
    # Updated 2019-06-22.
    # """
    [ "$(uname -s)" = "Darwin" ]
}

_koopa_is_debian() {                                                      # {{{3
    # """
    # Is the operating system Debian?
    # Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "debian" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "debian"
}

_koopa_is_fedora() {                                                      # {{{3
    # """
    # Is the operating system Fedora?
    # Updated 2019-10-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "fedora" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
}

_koopa_is_file_system_case_sensitive() {                                  # {{{3
    # """
    # Is the file system case sensitive?
    # Updated 2019-10-21.
    #
    # Linux is case sensitive by default, whereas macOS and Windows are not.
    # """
    touch ".tmp.checkcase" ".tmp.checkCase"
    count="$(find . -maxdepth 1 -iname ".tmp.checkcase" | wc -l)"
    _koopa_quiet_rm .tmp.check* 
    if [ "$count" -eq 2 ]
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_git() {                                                         # {{{3
    # """
    # Is the current working directory a git repository?
    # Updated 2019-10-14.
    #
    # See also:
    # - https://stackoverflow.com/questions/2180270
    # """
    if git rev-parse --git-dir > /dev/null 2>&1
    then
        return 0
    else
        return 1
    fi
}

_koopa_is_git_clean() {                                                   # {{{3
    # """
    # Is the current git repo clean, or does it have unstaged changes?
    # Updated 2019-10-14.
    #
    # See also:
    # - https://stackoverflow.com/questions/3878624
    # - https://stackoverflow.com/questions/3258243
    # """
    # Are there unstaged changes?
    if ! git diff-index --quiet HEAD --
    then
        return 1
    fi
    # In need of a pull or push?
    if [ "$(git rev-parse HEAD)" != "$(git rev-parse '@{u}')" ]
    then
        return 1
    fi
    return 0
}

_koopa_is_installed() {                                                   # {{{3
    # """
    # Is the requested program name installed?
    # Updated 2019-10-02.
    # """
    command -v "$1" >/dev/null
}

_koopa_is_interactive() {                                                 # {{{3
    # """
    # Is the current shell interactive?
    # Updated 2019-06-21.
    # """
    echo "$-" | grep -q "i"
}

_koopa_is_linux() {                                                       # {{{3
    # """
    # Updated 2019-06-21.
    # """
    [ "$(uname -s)" = "Linux" ]
}

_koopa_is_local_install() {                                               # {{{3
    # """
    # Is koopa installed only for the current user?
    # Updated 2019-06-25.
    # """
    echo "$KOOPA_PREFIX" | grep -Eq "^${HOME}"
}

_koopa_is_login() {                                                       # {{{3
    # """
    # Is the current shell a login shell?
    # Updated 2019-08-14.
    # """
    echo "$0" | grep -Eq "^-"
}

_koopa_is_login_bash() {                                                  # {{{3
    # """
    # Is the current shell a login bash shell?
    # Updated 2019-06-21.
    # """
    [ "$0" = "-bash" ]
}

_koopa_is_login_zsh() {                                                   # {{{3
    # """
    # Is the current shell a login zsh shell?
    # Updated 2019-06-21.
    # """
    [ "$0" = "-zsh" ]
}

_koopa_is_matching_fixed() {                                              # {{{3
    # """
    # Does the input match a fixed string?
    # Updated 2019-10-14.
    # """
    echo "$1" | grep -Fq "$2"
}

_koopa_is_matching_regex() {                                              # {{{3
    # """
    # Does the input match a regular expression?
    # Updated 2019-10-13.
    # """
    echo "$1" | grep -Eq "$2"
}

_koopa_is_r_package_installed() {                                         # {{{3
    # """
    # Is the requested R package installed?
    # Updated 2019-10-20.
    # """
    _koopa_is_installed R || return 1
    Rscript -e "\"$1\" %in% rownames(utils::installed.packages())" \
        | grep -q "TRUE"
}

_koopa_is_rhel() {                                                        # {{{3
    # """
    # Is the operating system RHEL?
    # Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep "ID=" /etc/os-release | grep -q "rhel" ||
        grep "ID_LIKE=" /etc/os-release | grep -q "rhel"
    return 0
}

_koopa_is_rhel_7() {                                                       # {{{3
    # """
    # Is the operating system RHEL 7?
    # Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="7' /etc/os-release || return 1
    return 0
}

_koopa_is_rhel_8() {                                                       # {{{3
    # """
    # Is the operating system RHEL 8?
    # Updated 2019-11-25.
    # """
    [ -f /etc/os-release ] || return 1
    grep -q 'ID="rhel"' /etc/os-release || return 1
    grep -q 'VERSION_ID="8' /etc/os-release || return 1
    return 0
}

_koopa_is_remote() {                                                      # {{{3
    # """
    # Is the current shell session a remote connection over SSH?
    # Updated 2019-06-25.
    # """
    [ -n "${SSH_CONNECTION:-}" ]
}

_koopa_is_shared_install() {                                              # {{{3
    # """
    # Is koopa installed for all users (shared)?
    # Updated 2019-06-25.
    # """
    ! _koopa_is_local_install
}

_koopa_is_venv_active() {                                                 # {{{3
    # """
    # Is there a Python virtual environment active?
    # Updated 2019-10-20.
    # """
    [ -n "${VIRTUAL_ENV:-}" ]
}

_koopa_missing_arg() {                                                    # {{{3
    # """
    # Error on a missing argument.
    # Updated 2019-10-23.
    # """
    _koopa_stop "Missing required argument."
}

_koopa_warn_if_export() {                                                 # {{{3
    # """
    # Warn if variable is exported in current shell session.
    # Updated 2019-10-27.
    #
    # Useful for checking against unwanted compiler settings.
    # In particular, useful to check for 'LD_LIBRARY_PATH'.
    # """
    local arg
    for arg in "$@"
    do
        if declare -x | grep -Eq "\b${arg}\b="
        then
            _koopa_warning "'${arg}' is exported."
        fi
    done
    return 0
}