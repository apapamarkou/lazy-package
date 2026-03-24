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

# shellcheck disable=SC1091

MODULE_DIR="${MODULE_DIR:-$(dirname "$0")}"
source "$MODULE_DIR/core/loader.sh"

require core/config
require core/colors
require core/utils
require core/packager
require cache/cache

declare -A installed_map
while read -r pkg; do
    installed_map[$pkg]=1
done < <(list_installed)

while read -r pkg source; do
    is_inst=0
    [[ -n "${installed_map[$pkg]:-}" ]] && is_inst=1
    format_package_line "$pkg" "$source" "$is_inst"
done < <(jq -r '.name + " " + .source' "$CACHE_FILE")
