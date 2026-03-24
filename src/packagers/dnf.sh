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

# DNF backend (Fedora/RHEL)

dnfIsInstalled() { rpm -q "$1" &>/dev/null; }

dnfGetSource() { echo "repo"; }

dnfInstall() {
    local pkg="$1"
    if dnfIsInstalled "$pkg"; then
        echo -e "${COLOR_GREEN}Package '$pkg' is already installed.${COLOR_RESET}"
        return 0
    fi
    sudo dnf install -y "$pkg"
}

dnfRemove() {
    local pkg="$1"
    if ! dnfIsInstalled "$pkg"; then
        echo -e "${COLOR_RED}Package not installed: $pkg${COLOR_RESET}"
        return 1
    fi
    local rdeps; rdeps=$(dnf repoquery --whatrequires --installed "$pkg" 2>/dev/null)
    if [[ -n "$rdeps" ]]; then
        echo "The following packages depend on this package:"
        echo; echo "$rdeps"; echo
        echo -e "${COLOR_YELLOW}Warning:${COLOR_RESET} Removing it may break dependencies."; echo
    fi
    if ask_yn "Remove $pkg? (Y/N): "; then
        sudo dnf remove -y "$pkg"
    else
        echo "Cancelled."
    fi
}

dnfUpdate() { sudo dnf upgrade -y; }

dnfInfo() { dnf info "$1" 2>/dev/null; }

dnfSearch() {
    local term="$1" names_only="${2:-false}"
    if [[ "$names_only" == "true" ]]; then
        dnf repoquery --qf "%{name}\n" "*${term}*" 2>/dev/null | awk '{print $0 " repo"}'
    else
        dnf search "$term" 2>/dev/null | grep -E '^\S' | awk -F'.' '{print $1 " repo"}'
    fi
}

dnfGetDeps() { dnf repoquery --requires "$1" 2>/dev/null | grep -v '\.so' | grep -v 'rtld' | grep -v 'rpmlib' | grep -v '^/' | awk '{print $1}' | sort -u; }

dnfListInstalled() { rpm -qa --qf "%{NAME}\n"; }

dnfListAll() {
    ensure_cache
    jq -r '"\(.name) \(.source)"' "$CACHE_FILE"
}

dnfCleanOrphans() {
    local orphans; orphans=$(dnf repoquery --unneeded 2>/dev/null)
    if [[ -z "$orphans" ]]; then echo "No orphan packages found."; return 0; fi
    echo "Orphan packages:"; echo "$orphans"; echo
    if ask_yn "Remove these packages? (Y/N): "; then
        sudo dnf autoremove -y
    else
        echo "Cancelled."
    fi
}

dnfCheckUpdates() {
    dnf check-update &>/dev/null
    [[ $? -eq 100 ]]
}

dnfBuildCache() {
    mkdir -p "$CACHE_DIR"
    local tmpfile="${CACHE_FILE}.tmp"
    dnf list 2>/dev/null | awk 'NR>1 {split($1,a,"."); print "{\"name\":\"" a[1] "\",\"source\":\"repo\"}"}' | sort -u > "$tmpfile"
    mv "$tmpfile" "$CACHE_FILE"
}
