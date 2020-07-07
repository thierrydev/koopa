#!/usr/bin/env bash
# shellcheck disable=SC2039

koopa::conda_create_env() { # {{{1
    # """
    # Create a conda environment.
    # @note Updated 2020-06-29.
    # """
    local flags force env_name name pos prefix version
    koopa::assert_has_args "$#"
    force=0
    version=
    pos=()
    while (("$#"))
    do
        case "$1" in
            --force)
                force=1
                shift 1
                ;;
            --version=*)
                version="${1#*=}"
                shift 1
                ;;
            --version)
                version="$2"
                shift 2
                ;;
            --)
                shift 1
                break
                ;;
            --*|-*)
                koopa::invalid_arg "$1"
                ;;
            *)
                pos+=("$1")
                shift 1
                ;;
        esac
    done
    [[ "${#pos[@]}" -gt 0 ]] && set -- "${pos[@]}"
    name="${1:?}"
    if [[ -n "${version:-}" ]]
    then
        env_name="${name}@${version}"
    else
        env_name="$name"
    fi
    prefix="$(koopa::conda_prefix)/envs/${env_name}"
    if [[ "$force" -eq 1 ]]
    then
        conda remove --name "$env_name" --all
    fi
    if [[ -d "$prefix" ]]
    then
        koopa::note "'${env_name}' is installed."
        return 0
    fi
    koopa::info "Creating '${env_name}' conda environment."
    koopa::activate_conda
    koopa::assert_is_installed conda
    flags=(
        "--name=${env_name}"
        "--quiet"
        "--yes"
    )
    if [[ -n "${version:-}" ]]
    then
        flags+=("${name}=${version}")
    else
        flags+=("$name")
    fi
    conda create "${flags[@]}"
    koopa::sys_set_permissions -r "$prefix"
    return 0
}

koopa::conda_remove_env() { # {{{1
    # """
    # Remove conda environment.
    # @note Updated 2020-06-30.
    # """
    local arg
    koopa::assert_has_args "$#"
    koopa::activate_conda
    koopa::assert_is_installed conda
    for arg in "$@"
    do
        conda remove --yes --name="$arg" --all
    done
    return 0
}
