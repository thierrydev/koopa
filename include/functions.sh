#!/bin/sh

# POSIX-compliant functions.
# Modified 2019-06-19.



# Assertive check functions                                                 {{{1
# ==============================================================================

assert_has_no_environments() {
    # Ensure conda is deactivated.
    if [ -x "$(command -v conda)" ] && [ ! -z "${CONDA_PREFIX:-}" ]
    then
        >&2 printf "Error: conda is active.\n"
        exit 1
    fi

    # Ensure Python virtual environment is deactivated.
    if [ -x "$(command -v deactivate)" ]
    then
        >&2 printf "Error: Python virtualenv is active.\n"
        exit 1
    fi
}

assert_has_sudo() {
    if ! has_sudo
    then
        >&2 printf "Error: sudo is required for this script.\n"
        exit 1
    fi
}

assert_is_installed() {
    program="$1"
    command -v "$program" >/dev/null 2>&1 || {
        >&2 printf "Error: %s is not installed.\n" "$program"
        return 1
    }
}

assert_is_os_darwin() {
    if [ ! "$KOOPA_OS_NAME" = "darwin" ] || [ -z "${MACOS:-}" ]
    then
        >&2 printf "Error: macOS is required.\n"
        exit 1
    fi
}

assert_is_os_debian() {
    if ! grep "ID="      /etc/os-release | grep -q "debian" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "debian"
    then
        >&2 printf "Error: Debian is required.\n"
        exit 1
    fi
}

assert_is_os_fedora() {
    if ! grep "ID="      /etc/os-release | grep -q "fedora" &&
       ! grep "ID_LIKE=" /etc/os-release | grep -q "fedora"
    then
        >&2 printf "Error: Fedora is required.\n"
        exit 1
    fi
}



# Quiet variants                                                            {{{1
# ==============================================================================

quiet_cd() {
    cd "$@" >/dev/null || return 1
}

# Regular expression matching that is POSIX compliant.
# https://stackoverflow.com/questions/21115121
# Avoid using `[[ =~ ]]` in sh config files.
# expr is faster than using case.

quiet_expr() {
    expr "$1" : "$2" 1>/dev/null
}

# Consider not using `&>` here, it isn't POSIX.
# https://unix.stackexchange.com/a/80632

quiet_which() {
    # command -v "$1" >/dev/null
    command -v "$1" >/dev/null 2>&1
}



# File system and build utilities                                           {{{1
# ==============================================================================

# Check if directory already exists at prefix.
# Modified 2019-06-17.
check_prefix() {
    path="$1"
    # Error on existing installation.
    if [ -d "$path" ]
    then
        >&2 printf "Error: Directory already exists.\n%s\n" "$prefix"
        exit 1
    fi
}

# Return the installation prefix to use.
# Modified 2019-06-19.
get_prefix() {
    if has_sudo
    then
        if [ "$KOOPA_DIR" = "/opt/koopa/koopa" ]
        then
            prefix="/opt/koopa"
        else
            prefix="/usr/local"
        fi
    else
        prefix="${HOME}/.local"
    fi
    echo "$prefix"
}

get_prefix_group() {
    # Standard user.
    ! has_sudo && return "$(whoami)"

    # Administrator.
    if groups | grep -Eq "\b(admin)\b"
    then
        # Darwin (macOS).
        group="admin"
    elif groups | grep -Eq "\b(sudo)\b"
    then
        # Debian.
        group="sudo"
    else
        # Fedora.
        group="wheel"
    fi
    echo "$group"
}

# Administrator (sudo) permission.
# Currently performing a simple check by verifying wheel group.
# - Darwin (macOS): admin
# - Debian: sudo
# - Fedora: wheel
# Modified 2019-06-19.
has_sudo() {
    groups | grep -Eq "\b(admin|sudo|wheel)\b"
}

# Fix the group permissions on the prefix directory.
# Modified 2019-06-19.
prefix_chgrp() {
    path="$1"
    group="$(get_prefix_group)"
    if has_sudo
    then
        sudo chgrp -Rh "$group" "$path"
        sudo chmod -R g+w "$path"
    else
        chgrp -Rh "$group" "$path"
        chmod -R g+w "$path"
    fi
}

# Create the prefix directory.
# Modified 2019-06-19.
prefix_mkdir() {
    path="$1"
    check_prefix "$path"

    if has_sudo
    then
        sudo mkdir -p "$path"
        sudo chown "$(whoami)" "$path"
    else
        mkdir -p "$path"
    fi

    prefix_chgrp "$path"
}

# Modified 2019-06-19.
rm_dotfile() {
    path="${HOME}/.${1}"
    name="$(basename "$path")"
    if [ -L "$path" ]
    then
        printf "Removing '%s'.\n" "$name"
        rm -f "$path"
    elif [ -f "$path" ] || [ -d "$path" ]
    then
        printf "Warning: Not symlink: %s\n" "$name"
    fi
}



# Path string modifiers                                                     {{{1
# ==============================================================================

# Modified from Mike McQuaid's dotfiles.
# https://github.com/MikeMcQuaid/dotfiles/blob/master/shrc.sh

add_to_path_start() {
    [ ! -d "$1" ] && remove_from_path "$1" && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${1}:${PATH}"
}

add_to_path_end() {
    [ ! -d "$1" ] && remove_from_path "$1" && return 0
    echo "$PATH" | grep -q "$1" && return 0
    export PATH="${PATH}:${1}"
}

force_add_to_path_start() {
    remove_from_path "$1"
    export PATH="${1}:${PATH}"
}

force_add_to_path_end() {
    remove_from_path "$1"
    export PATH="${PATH}:${1}"
}

# Look into an improved POSIX method here. This works for bash and ksh.
# Note that this won't work on the first item in PATH.
remove_from_path() {
    # SC2039: In POSIX sh, string replacement is undefined.
    # shellcheck disable=SC2039
    export PATH="${PATH//:$1/}"
}



# Version parsers                                                           {{{1
# ==============================================================================

# Get version stored internally in versions.txt file.
# Modified 2019-06-18.
koopa_variable() {
    what="$1"
    file="${KOOPA_DIR}/include/variables.txt"
    match="$(grep -E "^${what}=" "$file" || echo "")"
    if [ -n "$match" ]
    then
        echo "$match" | cut -d "\"" -f 2
    else
        >&2 printf "Error: %s not defined in %s.\n" "$what" "$file"
        return 1
    fi
}



# System configuration helpers                                              {{{1
# ==============================================================================

# Update XDG local configuration.
# ~/.config/koopa
# Modified 2019-06-19.
update_xdg_config() {
    [ -d "$KOOPA_CONFIG_DIR" ] || return 1
    ln -fs "${KOOPA_DIR}/activate" "${KOOPA_CONFIG_DIR}/activate"
    ln -fs "${KOOPA_DIR}/config/dotfiles" "${KOOPA_CONFIG_DIR}/dotfiles"
}

# Update dynamic linker (LD) configuration.
# Modified 2019-06-19.
sudo_update_ldconfig() {
    if [ -d /etc/ld.so.conf.d ]
    then
        sudo ln -fs \
            "${KOOPA_DIR}/config/etc/ld.so.conf.d/"*".conf" \
            /etc/ld.so.conf.d/.
        sudo ldconfig
    fi
}

# Add shared profile symlink in `/etc/profile.d/`.
# Modified 2019-06-19.
sudo_update_profile() {
    assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0

    printf "Updating '/etc/profile.d/'.\n"
    sudo mkdir -p /etc/profile.d
    sudo ln -fs \
        "${KOOPA_DIR}/config/etc/profile.d/koopa.sh" \
       /etc/profile.d/koopa.sh
}

# Add shared R configuration symlinks in `${R_HOME}/etc`.
# Modified 2019-06-19.
sudo_update_r_config() {
    assert_has_sudo
    [ -z "${LINUX:-}" ] && return 0
 
    printf "Updating '/etc/rstudio/'.\n"
    sudo mkdir -p /etc/rstudio
    sudo ln -fs \
        "${KOOPA_DIR}/config/etc/rstudio/"* \
        /etc/rstudio/.

    printf "Updating '%s'.\n" "$R_HOME"
    sudo ln -fs \
        "${KOOPA_DIR}/config/R/etc/"* \
        "${R_HOME}/etc/".
}
