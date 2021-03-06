#!/bin/sh
# koopa nolint=coreutils

# """
# POSIX shell header.
# @note Updated 2020-07-20.
# """

if [ -z "${KOOPA_PREFIX:-}" ]
then
    printf '%s\n' "ERROR: Required 'KOOPA_PREFIX' is unset." >&2
    exit 1
fi

# Source POSIX functions.
# Use shell globbing instead of 'find', which doesn't support source.
for file in "${KOOPA_PREFIX}/shell/posix/functions/"*'.sh'
do
    # shellcheck source=/dev/null
    [ -f "$file" ] && . "$file"
done
unset -v file

# Ensure koopa scripts are in path.
_koopa_activate_koopa_paths
