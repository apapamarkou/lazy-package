#!/usr/bin/env bash

#  _                      ____            _                    
# | |    __ _ _____   _  |  _ \ __ _  ___| | ____ _  __ _  ___ 
# | |   / _` |_  / | | | | |_) / _` |/ __| |/ / _` |/ _` |/ _ \
# | |__| (_| |/ /| |_| | |  __/ (_| | (__|   < (_| | (_| |  __/
# |_____\__,_/___|\__, | |_|   \__,_|\___|_|\_\__,_|\__, |\___|
#                 |___/                             |___/      
#
# A unified package manager interface for linux systems
#
# Author: Andrianos Papamarkou
# email: papamarkoua@gmail.com
# web: https://github.com/apapamarkou/lazy-package
#

# Configuration and constants
# shellcheck disable=SC2034  # Variables used by sourcing scripts

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/lazy-package"
CACHE_FILE="$CACHE_DIR/packages.ndjson"
UPDATE_CHECK_FILE="$CACHE_DIR/update_check"
CACHE_MAX_AGE=$((24 * 3600))
UPDATE_CHECK_INTERVAL=$((6 * 3600))

INCLUDE_AUR="${LAZYPACKAGE_INCLUDE_AUR:-1}"

if [[ -z "${PAGER:-}" ]]; then
    if command -v most &>/dev/null; then
        PAGER="most"
    elif command -v less &>/dev/null; then
        PAGER="less -FR"
    else
        PAGER="more"
    fi
fi
