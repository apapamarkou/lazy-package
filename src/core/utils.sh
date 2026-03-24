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

# Utility functions

# Format package line for display
format_package_line() {
    local pkg="$1"
    local source="$2"
    local installed="${3:-0}"
    local mark="_" color="$COLOR_GREY"
    local src_label="Rep"

    [[ "$installed" == "1" ]] && { mark="I"; color="$COLOR_GREEN"; }
    [[ "$source" == "aur" ]] && src_label="AUR"

    echo -e "${color}[${mark}] [${src_label}] ${pkg}${COLOR_RESET}"
}
