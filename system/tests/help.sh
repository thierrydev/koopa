#!/usr/bin/env bash
set -Eeu -o pipefail

# Check that all scripts support '--help' flag.
# Updated 2020-01-14.

KOOPA_PREFIX="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../.." \
    >/dev/null 2>&1 && pwd -P)"
export KOOPA_PREFIX
# shellcheck source=/dev/null
source "${KOOPA_PREFIX}/shell/bash/include/header.sh"

_koopa_message "Running manual file '--help' flag checks."

# Put all 'man/' dirs into an array and loop.
man_dirs=()
while IFS= read -r -d $'\0'
do
    man_dirs+=("$REPLY")
done < <( \
    find "$KOOPA_PREFIX" \
        -mindepth 1 \
        -type d \
        -name "man" \
        -not -path "*/cellar/*" \
        -not -path "*/dotfiles/*" \
        -print0 \
        | sort -z \
    )

for dir in "${man_dirs[@]}"
do
    _koopa_add_to_manpath_start "$dir"
done

# Put all 'bin/' and/or 'sbin/' dirs into an array and loop.
bin_dirs=()
while IFS= read -r -d $'\0'
do
    bin_dirs+=("$REPLY")
done < <( \
    find "$KOOPA_PREFIX" \
        -mindepth 1 \
        -type d \
        \( -name "bin" -o -name "sbin" \) \
        -not -path "*/cellar/*" \
        -not -path "*/dotfiles/*" \
        -print0 \
        | sort -z \
    )

for dir in "${bin_dirs[@]}"
do
    files=()
    while IFS= read -r -d $'\0'
    do
        files+=("$REPLY")
    done < <( \
        find "$dir" \
            -mindepth 1 \
            -maxdepth 1 \
            -type f \
            -print0 \
            | sort -z \
        )
    for file in "${files[@]}"
    do
        echo "$file"
        "$file" --help > /dev/null
    done
done