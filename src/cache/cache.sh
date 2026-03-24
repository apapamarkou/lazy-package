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
# Package cache management — minimal cache for fast startup

cache_needs_rebuild() {
    [[ ! -f "$CACHE_FILE" ]] && return 0
    local age=$(( $(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0) ))
    [[ $age -gt $CACHE_MAX_AGE ]] && return 0
    return 1
}

# Build cache — delegates to active packager backend (or pacman default)
build_cache() {
    mkdir -p "$CACHE_DIR"
    local tmpfile="${CACHE_FILE}.tmp"

    # pacman-specific (supports AUR via yay)
    pacman -Slq | awk '{print "{\"name\":\"" $0 "\",\"source\":\"repo\"}"}'  > "$tmpfile"

    if [[ "$INCLUDE_AUR" == "1" ]] && command -v yay &>/dev/null; then
        echo "Including AUR packages (this may take a while)..." >&2
        local repo_list="${CACHE_DIR}/repo.tmp"
        pacman -Slq | sort > "$repo_list"
        yay -Slq 2>/dev/null | sort | comm -13 "$repo_list" - | \
            awk '{print "{\"name\":\"" $0 "\",\"source\":\"aur\"}"}'  >> "$tmpfile"
        rm -f "$repo_list"
    fi

    mv "$tmpfile" "$CACHE_FILE"
}

ensure_cache() {
    if cache_needs_rebuild; then
        echo "Building package cache..." >&2
        # Use packager-specific builder if available, else fall back to build_cache
        if declare -f build_pkg_cache &>/dev/null; then
            build_pkg_cache
        else
            build_cache
        fi
    fi
}

search_cache() {
    local term="$1"
    ensure_cache
    jq -r 'select(.name | contains("'"$term"'")) | "\(.name) \(.source)"' "$CACHE_FILE"
}

get_all_packages() {
    ensure_cache
    jq -r '"\(.name) \(.source)"' "$CACHE_FILE"
}
