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

# Packager abstraction layer

# Detect and return the active package manager type
pkgType() {
    if command -v pacman &>/dev/null; then echo "pacman"
    elif command -v apt-get &>/dev/null; then echo "apt"
    elif command -v dnf &>/dev/null; then echo "dnf"
    elif command -v zypper &>/dev/null; then echo "zypper"
    else echo "unknown"
    fi
}

# Load the correct backend
_PKG_TYPE=$(pkgType)

if [[ "$_PKG_TYPE" == "unknown" ]]; then
    notify-send "lazy-package" "Unsupported platform: no supported package manager found." 2>/dev/null || true
    echo "Error: No supported package manager found (pacman, apt, dnf, zypper)." >&2
    exit 1
fi

require "packagers/$_PKG_TYPE"

# Wrapper functions — dispatch to the active backend
install_package()  { "${_PKG_TYPE}Install"  "$@"; }
remove_package()   { "${_PKG_TYPE}Remove"   "$@"; }
update_packages()  { "${_PKG_TYPE}Update"   "$@"; }
get_package_info() { "${_PKG_TYPE}Info"     "$@"; }
search_packages()  { "${_PKG_TYPE}Search"   "$@"; }
list_installed()   { "${_PKG_TYPE}ListInstalled"; }
list_all()         { "${_PKG_TYPE}ListAll";  }
clean_orphans()    { "${_PKG_TYPE}CleanOrphans"; }
check_updates()    { _check_updates_cached; }
is_installed()     { "${_PKG_TYPE}IsInstalled" "$@"; }
get_package_source() { "${_PKG_TYPE}GetSource" "$@"; }
get_package_deps()   { "${_PKG_TYPE}GetDeps"   "$@"; }
build_pkg_cache()  {
    if declare -f "${_PKG_TYPE}BuildCache" &>/dev/null; then
        "${_PKG_TYPE}BuildCache"
    else
        # pacman uses its own cache.sh build_cache
        build_cache
    fi
}

# Cached update check (6-hour interval)
_check_updates_cached() {
    if _update_check_needed; then
        mkdir -p "$CACHE_DIR"
        if "${_PKG_TYPE}CheckUpdates"; then
            echo "1" > "$UPDATE_CHECK_FILE"
        else
            echo "0" > "$UPDATE_CHECK_FILE"
        fi
    fi
    [[ -f "$UPDATE_CHECK_FILE" ]] && [[ "$(cat "$UPDATE_CHECK_FILE")" == "1" ]]
}

_update_check_needed() {
    [[ ! -f "$UPDATE_CHECK_FILE" ]] && return 0
    local age=$(( $(date +%s) - $(stat -c %Y "$UPDATE_CHECK_FILE" 2>/dev/null || echo 0) ))
    [[ $age -gt $UPDATE_CHECK_INTERVAL ]] && return 0
    return 1
}
