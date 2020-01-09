#!/usr/bin/env bash
set -Eeu -o pipefail

_koopa_assert_is_installed sqlite3

name="proj"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
make_prefix="$(_koopa_make_prefix)"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

# pkg-config doesn't detect sqlite3 library correctly
#
# https://github.com/OSGeo/PROJ/issues/1529
# 
# checking for SQLITE3... configure: error: Package requirements (sqlite3 >=
# 3.11) were not met:
#
# Requested 'sqlite3 >= 3.11' but version of SQLite is 3.7.17
#
# Consider adjusting the PKG_CONFIG_PATH environment variable if you
# installed software in a non-standard prefix.
#
# Alternatively, you may set the environment variables SQLITE3_CFLAGS
# and SQLITE3_LIBS to avoid the need to call pkg-config.
# See the pkg-config man page for more details.

export SQLITE3_CFLAGS="-I${make_prefix}/include"
export SQLITE3_LIBS="-L${make_prefix}/lib -lsqlite3"

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="${name}-${version}.tar.gz"
    url="https://github.com/OSGeo/PROJ/releases/download/${version}/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "${name}-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"
