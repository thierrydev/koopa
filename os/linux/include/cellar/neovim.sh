#!/usr/bin/env bash
# shellcheck disable=SC2154

# """
# Currently failing to build on CentOS.
#
# make[5]: Leaving directory '/tmp/XXX/neovim-0.4.3/.deps/build/src/libuv-build'
# make[4]: Leaving directory '/tmp/XXX/neovim-0.4.3/.deps/build/src/libuv-build'
# [ 62%] Completed 'libuv'
# make[3]: Leaving directory '/tmp/XXX/neovim-0.4.3/.deps'
# [ 62%] Built target libuv
# make[2]: Leaving directory '/tmp/XXX/neovim-0.4.3/.deps'
# make[1]: *** [Makefile:84: all] Error 2
# make[1]: Leaving directory '/tmp/XXX/neovim-0.4.3/.deps'
# make: *** [Makefile:101: deps] Error 2
# """

# Skip building on CentOS.
if _koopa_is_centos
then
    _koopa_exit "'${name}' currently won't build on CentOS."
fi

file="v${version}.tar.gz"
url="https://github.com/${name}/${name}/archive/${file}"
_koopa_download "$url"
_koopa_extract "$file"
cd "${name}-${version}" || exit 1
make \
    --jobs="$jobs" \
    CMAKE_BUILD_TYPE=Release \
    CMAKE_INSTALL_PREFIX="$prefix"
make install