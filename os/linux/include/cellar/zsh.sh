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
# See also:
# - https://github.com/Homebrew/legacy-homebrew/issues/25719
# - https://github.com/TACC/Lmod/issues/434
# """

etc_dir="${prefix}/etc/${name}"
url_stem="https://sourceforge.net/projects/${name}/files/${name}"
file="${name}-${version}.tar.xz"
_koopa_download "${url_stem}/${version}/${file}/download" "$file"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
# Fix required for Ubuntu Docker image:
# configure: error: no controlling tty
# Try running configure with '--with-tcsetpgrp' or '--without-tcsetpgrp'.
./configure \
    --prefix="$prefix" \
    --enable-etcdir="$etc_dir" \
    --without-tcsetpgrp
make --jobs="$jobs"
# > make check
# > make test
make install

if _koopa_is_debian
then
    _koopa_h1 "Linking shared config scripts into '${etc_dir}'."
    mkdir -pv "$etc_dir"
    ln -fnsv \
        "$(_koopa_prefix)/os/$(_koopa_os_id)/etc/zsh/"* \
        "${etc_dir}/."
fi

_koopa_enable_shell "$name"
