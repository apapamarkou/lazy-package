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

# Zypper backend (openSUSE)

zypperIsInstalled() { rpm -q "$1" &>/dev/null; }

zypperGetSource() { echo "repo"; }

zypperInstall() {
    local pkg="$1"
    if zypperIsInstalled "$pkg"; then
        echo -e "${COLOR_GREEN}Package '$pkg' is already installed.${COLOR_RESET}"
        return 0
    fi
    sudo zypper install -y "$pkg"
}

zypperRemove() {
    local pkg="$1"
    if ! zypperIsInstalled "$pkg"; then
        echo -e "${COLOR_RED}Package not installed: $pkg${COLOR_RESET}"
        return 1
    fi
    local rdeps; rdeps=$(zypper search --requires-pkg "$pkg" 2>/dev/null | tail -n +5)
    if [[ -n "$rdeps" ]]; then
        echo "The following packages depend on this package:"
        echo; echo "$rdeps"; echo
        echo -e "${COLOR_YELLOW}Warning:${COLOR_RESET} Removing it may break dependencies."; echo
    fi
    if ask_yn "Remove $pkg? (Y/N): "; then
        sudo zypper remove -y "$pkg"
    else
        echo "Cancelled."
    fi
}

zypperUpdate() { sudo zypper update -y; }

zypperInfo() { zypper info "$1" 2>/dev/null; }

zypperSearch() {
    local term="$1" names_only="${2:-false}"
    if [[ "$names_only" == "true" ]]; then
        zypper search -t package "$term" 2>/dev/null | awk 'NR>4 && /\|/{print $2 " repo"}'
    else
        zypper search "$term" 2>/dev/null | awk 'NR>4 && /\|/{print $2 " repo"}'
    fi
}

zypperGetDeps() { zypper info --requires "$1" 2>/dev/null | awk '/^Requires/,0' | tail -n +2 | awk '{print $1}'; }

zypperListInstalled() { rpm -qa --qf "%{NAME}\n"; }

zypperListAll() {
    ensure_cache
    jq -r '"\(.name) \(.source)"' "$CACHE_FILE"
}

zypperCleanOrphans() {
    echo "Orphan removal not directly supported by zypper."
    echo "Use: sudo zypper packages --unneeded"
}

zypperCheckUpdates() {
    zypper list-updates 2>/dev/null | grep -q "^v "
}

zypperBuildCache() {
    mkdir -p "$CACHE_DIR"
    local tmpfile="${CACHE_FILE}.tmp"
    zypper packages --repo 2>/dev/null | awk -F'|' 'NR>4{gsub(/ /,"",$3); print "{\"name\":\"" $3 "\",\"source\":\"repo\"}"}' > "$tmpfile"
    mv "$tmpfile" "$CACHE_FILE"
}
