#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Need to configure Zsh to support system-wide config files in '/etc/zsh'.
# Note that RHEL 7 locates these to '/etc' by default instead.
#
# We're linking these in the cellar instead, at '/usr/local/etc/zsh'.
# There are some system config files for Zsh in Debian that don't play nice
# with autocomplete otherwise.
#
# Fix required for Ubuntu Docker image:
# configure: error: no controlling tty
# Try running configure with '--with-tcsetpgrp' or '--without-tcsetpgrp'.
#
# Mirrors:
# - url="ftp://ftp.fu-berlin.de/pub/unix/shells/${name}/${file}"
# - url="https://www.zsh.org/pub/${file}" (slow)
# - url="https://downloads.sourceforge.net/project/\
#       ${name}/${name}/${version}/${file}" (redirects, curl issues)
#
# See also:
# - https://github.com/Homebrew/legacy-homebrew/issues/25719
# - https://github.com/TACC/Lmod/issues/434
# """

etc_dir="${prefix}/etc/${name}"
file="${name}-${version}.tar.xz"
url="ftp://ftp.fu-berlin.de/pub/unix/shells/${name}/${file}"
koopa::download "$url"
koopa::extract "$file"
koopa::cd "${name}-${version}"
./configure \
    --prefix="$prefix" \
    --enable-etcdir="$etc_dir" \
    --without-tcsetpgrp
make --jobs="$jobs"
# > make check
# > make test
make install
if koopa::is_debian
then
    koopa::info "Linking shared config scripts into '${etc_dir}'."
    koopa::ln \
        -t "${etc_dir}" \
        "$(koopa::prefix)/os/$(koopa::os_id)/etc/zsh/"*
fi
koopa::enable_shell "$name"
