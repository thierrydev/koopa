#!/bin/sh

Genrich --version 2>&1 \
    | head -n 1 \
    | cut -d ' ' -f 3