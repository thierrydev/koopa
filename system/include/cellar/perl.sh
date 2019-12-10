#!/usr/bin/env bash
set -Eeu -o pipefail

# https://www.cpan.org/src/
# https://metacpan.org/pod/distribution/perl/INSTALL
# https://perlmaven.com/how-to-build-perl-from-source-code

# Using 'PERL_MM_USE_DEFAULT' below to avoid interactive prompt to configure
# CPAN.pm for the first time.
#
# Otherwise you'll hit this interactive prompt:
#
# CPAN.pm requires configuration, but most of it can be done automatically.
# If you answer 'no' below, you will enter an interactive dialog for each
# configuration option instead.
#
# Would you like to configure as much as possible automatically? [yes]
#
# See also:
# - https://metacpan.org/pod/CPAN::FirstTime
# - https://www.reddit.com/r/perl/comments/1xed7b/
#       how_can_i_configure_cpan_as_much_as_possible/

name="perl"
version="$(_koopa_variable "$name")"
prefix="$(_koopa_cellar_prefix)/${name}/${version}"
tmp_dir="$(_koopa_tmp_dir)/${name}"
jobs="$(_koopa_cpu_count)"

_koopa_message "Installing ${name} ${version}."

(
    _koopa_cd_tmp_dir "$tmp_dir"
    file="perl-${version}.tar.gz"
    url="https://www.cpan.org/src/5.0/${file}"
    _koopa_download "$url"
    _koopa_extract "$file"
    cd "perl-${version}" || exit 1
    ./Configure \
        -des \
        -Dprefix="$prefix"
    make --jobs="$jobs"
    # > make test
    make install
    rm -fr "$tmp_dir"
)

_koopa_link_cellar "$name" "$version"

export PERL_MM_USE_DEFAULT=1

_koopa_message "Installing CPAN Minus."
"${prefix}/bin/cpan" -i App::cpanminus
_koopa_link_cellar "$name" "$version"

_koopa_message "Installing 'File::Rename' module."
"${prefix}/bin/cpanm" File::Rename
_koopa_link_cellar "$name" "$version"