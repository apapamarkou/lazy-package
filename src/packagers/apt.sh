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

# APT backend (Debian/Ubuntu)

aptIsInstalled() { dpkg -s "$1" &>/dev/null; }

aptGetSource() { echo "repo"; }

aptInstall() {
    local pkg="$1"
    if aptIsInstalled "$pkg"; then
        echo -e "${COLOR_GREEN}Package '$pkg' is already installed.${COLOR_RESET}"
        return 0
    fi
    sudo apt-get install -y "$pkg"
}

aptRemove() {
    local pkg="$1"
    if ! aptIsInstalled "$pkg"; then
        echo -e "${COLOR_RED}Package not installed: $pkg${COLOR_RESET}"
        return 1
    fi
    local rdeps; rdeps=$(apt-cache rdepends --installed "$pkg" 2>/dev/null | tail -n +2)
    if [[ -n "$rdeps" ]]; then
        echo "The following packages depend on this package:"
        echo; echo "$rdeps"; echo
        echo -e "${COLOR_YELLOW}Warning:${COLOR_RESET} Removing it may break dependencies."; echo
    fi
    if ask_yn "Remove $pkg? (Y/N): "; then
        sudo apt-get remove "$pkg"
    else
        echo "Cancelled."
    fi
}

aptUpdate() { sudo apt-get update && sudo apt-get upgrade -y; }

aptInfo() { apt-cache show "$1" 2>/dev/null; }

aptSearch() {
    local term="$1" names_only="${2:-false}"
    if [[ "$names_only" == "true" ]]; then
        apt-cache pkgnames "$term" 2>/dev/null | awk '{print $0 " repo"}'
    else
        apt-cache search "$term" 2>/dev/null | awk '{print $1 " repo"}'
    fi
}

aptGetDeps() { apt-cache depends "$1" 2>/dev/null | awk '/^  Depends:/{print $2}'; }

aptListInstalled() { dpkg --get-selections | awk '$2=="install"{print $1}'; }

aptListAll() {
    ensure_cache
    jq -r '"\(.name) \(.source)"' "$CACHE_FILE"
}

aptCleanOrphans() {
    local orphans; orphans=$(deborphan 2>/dev/null)
    if [[ -z "$orphans" ]]; then echo "No orphan packages found."; return 0; fi
    echo "Orphan packages:"; echo "$orphans"; echo
    if ask_yn "Remove these packages? (Y/N): "; then
        sudo apt-get remove "$orphans"
    else
        echo "Cancelled."
    fi
}

aptCheckUpdates() {
    sudo apt-get update -qq &>/dev/null
    apt-get -s upgrade 2>/dev/null | grep -q "^Inst"
}

aptBuildCache() {
    mkdir -p "$CACHE_DIR"
    local tmpfile="${CACHE_FILE}.tmp"
    apt-cache pkgnames 2>/dev/null | awk '{print "{\"name\":\"" $0 "\",\"source\":\"repo\"}"}' > "$tmpfile"
    mv "$tmpfile" "$CACHE_FILE"
}
