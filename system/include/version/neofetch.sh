#!/bin/sh

neofetch --version \
    | head -n 1 \
    | cut -d ' ' -f 2