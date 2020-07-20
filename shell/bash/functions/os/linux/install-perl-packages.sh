#!/usr/bin/env bash

koopa::install_perl_packages() {
    # """
    # Install Perl packages.
    # @note Updated 2020-07-20.
    # """
    local module modules name_fancy
    koopa::assert_is_installed cpan perl
    name_fancy='Perl packages'
    koopa::install_start "$name_fancy"
    export PERL_MM_USE_DEFAULT=1
    if ! koopa::is_installed cpanm
    then
        koopa::info "CPAN Minus"
        cpan -i "App::cpanminus" &>/dev/null
    fi
    koopa::assert_is_installed cpanm
    if [[ "$#" -gt 0 ]]
    then
        modules=("$@")
    else
        modules=(
            'App::Ack'
            'File::Rename'
        )
    fi
    for module in "${modules[@]}"
    do
        echo 'FIXME 1'
        koopa::info "${module}"
        cpanm "$module" &>/dev/null
        echo 'FIXME 2'
    done
    koopa::install_success "$name_fancy"
    return 0
}

