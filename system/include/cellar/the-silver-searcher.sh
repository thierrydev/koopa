#!/usr/bin/env bash
set -Eeu -o pipefail

# Note that Ag has been renamed to The Silver Searcher.

# GPG signed releases:
# https://geoff.greer.fm/ag/

# RHEL 7:
# checking for clang-format... no
# configure: WARNING: clang-format not found. 'make test' will not detect
# improperly-formatted files.

name="the-silver-searcher"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
build="$(_koopa_make_build_string)"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    # GitHub.
    # > file="${version}.tar.gz"
    # > url="https://github.com/ggreer/the_silver_searcher/archive/${file}"
    # GPG signed release.
    file="the_silver_searcher-2.2.0.tar.gz"
    url="https://geoff.greer.fm/ag/releases/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "the_silver_searcher-${version}" || exit 1
    ./configure \
        --build="$build" \
        --prefix="$prefix"
    make --jobs="$jobs"
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"