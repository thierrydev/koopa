#!/usr/bin/env bash

koopa::fedora_install_google_cloud_sdk() { # {{{1
    # """
    # Install Google Cloud SDK.
    # @note Updated 2020-07-16.
    # @seealso
    # - https://cloud.google.com/sdk/docs/downloads-yum
    # """
    local name_fancy
    koopa::exit_if_installed gcloud
    name_fancy='Google Cloud SDK'
    koopa::install_start "$name_fancy"
    koopa::yum_add_google_cloud_sdk_repo
    sudo dnf -y install google-cloud-sdk
    koopa::install_success "$name_fancy"
    return 0
}

