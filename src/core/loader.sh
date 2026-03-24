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

declare -A _LOADED_MODULES

# Load a module by name
require() {
    local module="$1"
    [[ -n "${_LOADED_MODULES[$module]:-}" ]] && return 0
    
    local module_path="${MODULE_DIR}/${module}.sh"
    if [[ ! -f "$module_path" ]]; then
        echo "Error: Module not found: $module" >&2
        exit 1
    fi
    
    # shellcheck disable=SC1090  # Dynamic sourcing by design
    source "$module_path"
    _LOADED_MODULES[$module]=1
}
