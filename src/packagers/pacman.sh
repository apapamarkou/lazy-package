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

# Pacman/yay backend

pacmanIsInstalled() { pacman -Q "$1" &>/dev/null; }

pacmanGetSource() {
    pacman -Si "$1" &>/dev/null && echo "repo" || echo "aur"
}

pacmanInstall() {
    local pkg="$1"
    if pacmanIsInstalled "$pkg"; then
        echo -e "${COLOR_GREEN}Package '$pkg' is already installed.${COLOR_RESET}"
        return 0
    fi
    local src; src=$(pacmanGetSource "$pkg")
    if [[ "$src" == "repo" ]]; then
        sudo pacman -S --needed "$pkg"
    else
        yay -S --needed "$pkg"
    fi
}

pacmanRemove() {
    local pkg="$1"
    if ! pacmanIsInstalled "$pkg"; then
        echo -e "${COLOR_RED}Package not installed: $pkg${COLOR_RESET}"
        return 1
    fi
    local rdeps; rdeps=$(pactree -r "$pkg" 2>/dev/null | tail -n +2)
    if [[ -n "$rdeps" ]]; then
        echo "The following packages depend on this package:"
        echo; echo "$rdeps"; echo
        echo -e "${COLOR_YELLOW}Warning:${COLOR_RESET} Removing it may break dependencies."; echo
    fi
    if ask_yn "Remove $pkg? (Y/N): "; then
        sudo pacman -R "$pkg"
    else
        echo "Cancelled."
    fi
}

pacmanUpdate() {
    yay -Syu
}

pacmanInfo() {
    local pkg="$1"
    local src; src=$(pacmanGetSource "$pkg")
    if [[ "$src" == "repo" ]]; then
        pacman -Si "$pkg" 2>/dev/null
    else
        yay -Si "$pkg" 2>/dev/null
    fi
}

pacmanSearch() {
    local term="$1" names_only="${2:-false}"
    ensure_cache
    if [[ "$names_only" == "true" ]]; then
        jq -r 'select(.name | startswith("'"$term"'")) | "\(.name) \(.source)"' "$CACHE_FILE"
    else
        jq -r 'select(.name | contains("'"$term"'")) | "\(.name) \(.source)"' "$CACHE_FILE"
    fi
}

pacmanGetDeps() {
    local src; src=$(pacmanGetSource "$1")
    if [[ "$src" == "repo" ]]; then
        pacman -Si "$1" 2>/dev/null | grep -E '^Depends On' | sed 's/.*: //'
    else
        yay -Si "$1" 2>/dev/null | grep -E '^Depends On' | sed 's/.*: //'
    fi
}

pacmanListInstalled() { pacman -Qq; }

pacmanListAll() {
    ensure_cache
    jq -r '"\(.name) \(.source)"' "$CACHE_FILE"
}

pacmanCleanOrphans() {
    local orphans; orphans=$(pacman -Qtdq 2>/dev/null)
    if [[ -z "$orphans" ]]; then echo "No orphan packages found."; return 0; fi
    echo "Orphan packages:"; echo "$orphans"; echo
    if ask_yn "Remove these packages? (Y/N): "; then
        mapfile -t orphan_list <<< "$orphans"
        sudo pacman -Rns "${orphan_list[@]}"
    else
        echo "Cancelled."
    fi
}

pacmanCheckUpdates() {
    checkupdates &>/dev/null
}
