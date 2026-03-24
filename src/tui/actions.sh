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

# TUI actions

require core/prompt
require cache/cache

handle_package_action() {
    local line="$1"
    local pkg; pkg=$(echo "$line" | awk '{print $3}')
    [[ -z "$pkg" ]] && return

    clear
    if is_installed "$pkg"; then
        remove_package "$pkg"
    else
        if ask_yn "Install $pkg? (Y/N): "; then
            install_package "$pkg"
        else
            echo "Cancelled."
        fi
    fi

    read -rp "Press Enter to continue..."
}
