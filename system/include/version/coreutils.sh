#!/bin/sh

env --version \
    | head -n 1 \
    | cut -d ' ' -f 4 \
    | cut -d '(' -f 1